#!/usr/bin/env python3
"""Deterministic offline itemID -> profession compiler; no runtime network."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "addon/CraftAtlas/Data"
SOURCE = DATA / "materials.source.json"
REGISTRY = DATA / "professions.source.json"
TARGET = DATA / "Materials.lua"
REGISTRY_LUA = DATA / "Professions.lua"
COVERAGE = DATA / "coverage-report.json"
RIGHTS = {"original-factual-research", "compatible-licensed-source"}
HEADER = ("local _, ns = ...\n\n"
          "-- Deterministic output from scripts/build_materials.py. Do not edit.\n"
          "ns.materials = {\n")


def load():
    return (json.loads(SOURCE.read_text(encoding="utf-8")),
            json.loads(REGISTRY.read_text(encoding="utf-8")))


def validate_catalog(data, registry, release=False):
    errors, known = [], set()
    for index, entry in enumerate(registry.get("professions", [])):
        if not isinstance(entry, dict):
            errors.append(f"profession {index}: not an object")
            continue
        key = entry.get("key")
        if not isinstance(key, str) or not key.isupper() or key in known:
            errors.append(f"profession {index}: invalid/duplicate key")
            continue
        known.add(key)
        if entry.get("role") != "consumer":
            errors.append(f"{key}: not a consuming profession")
        for field in ("enUS", "esES", "source"):
            if not isinstance(entry.get(field), str) or not entry[field].strip():
                errors.append(f"{key}: missing {field}")
    if not known:
        errors.append("missing verified profession registry")
    items = data.get("materials")
    if not isinstance(items, list):
        return errors + ["missing materials list"]
    seen, used, multi = set(), set(), 0
    for i, item in enumerate(items):
        if not isinstance(item, dict):
            errors.append(f"item {i}: invalid object")
            continue
        item_id = item.get("itemID")
        if type(item_id) is not int or item_id < 1 or item_id in seen:
            errors.append(f"item {i}: duplicate/invalid itemID")
            continue
        seen.add(item_id)
        relations = item.get("relations")
        if not isinstance(relations, list) or not relations:
            errors.append(f"item {item_id}: no relations")
            continue
        local = set()
        for rel in relations:
            if not isinstance(rel, dict):
                errors.append(f"item {item_id}: bad relation")
                continue
            key = rel.get("professionKey")
            if not isinstance(key, str) or key not in known or key in local:
                errors.append(f"item {item_id}: unknown/duplicate profession")
                continue
            local.add(key)
            if rel.get("usageKind") not in ("ingredient", "component", "reagent"):
                errors.append(f"item {item_id}/{key}: bad usageKind")
            for f in ("source", "reviewedAt", "clientBuild", "rights", "status"):
                if not isinstance(rel.get(f), str) or not rel[f].strip():
                    errors.append(f"item {item_id}/{key}: missing {f}")
            if rel.get("rights") not in RIGHTS:
                errors.append(f"item {item_id}/{key}: invalid source rights")
            if rel.get("status") not in ("researched", "verified"):
                errors.append(f"item {item_id}/{key}: invalid verification")
        used.update(local)
        if len(local) > 1:
            multi += 1
    if release:
        if len(seen) < 30: errors.append(f"release needs 30 verified itemIDs; got {len(seen)}")
        if len(used) < 5: errors.append(f"release needs 5 professions; got {len(used)}")
        if multi < 2: errors.append(f"release needs 2 multi-profession items; got {multi}")
        if any(r.get("status") != "verified" for item in items for r in item.get("relations", [])):
            errors.append("release has unverified material relations")
    return errors


def generate(data, registry):
    lines = [HEADER]
    for item in sorted(data["materials"], key=lambda x: x["itemID"]):
        keys = sorted({r["professionKey"] for r in item["relations"]})
        lines.append(f'    [{item["itemID"]}] = {{{", ".join(json.dumps(k) for k in keys)}}},\n')
    lines.append("}\n")
    return "".join(lines)


def generate_registry(registry):
    lines = ['local _, ns = ...\n\n-- Generated profession registry; stable keys.\n',
             'ns.professionOrder = {\n']
    for p in registry["professions"]:
        lines.append(f'    {json.dumps(p["key"])},\n')
    lines.append('}\nns.professionNames = {\n')
    for p in registry["professions"]:
        a = json.dumps(p["enUS"], ensure_ascii=False)
        b = json.dumps(p["esES"], ensure_ascii=False)
        lines.append(f'    [{json.dumps(p["key"])}] = {{ enUS = {a}, esES = {b} }},\n')
    lines.append('}\n')
    return "".join(lines)


def coverage_report(data, registry):
    items = data["materials"]
    verified = sum(all(r["status"] == "verified" for r in item["relations"]) for item in items)
    universe = data.get("referenceUniverse") or {}
    denominator = universe.get("eligibleItemIDs")
    counts = {p["key"]: 0 for p in registry["professions"]}
    for item in items:
        for r in item["relations"]:
            counts[r["professionKey"]] += 1
    allowed = (type(denominator) is int and verified == denominator and
               all(universe.get(f) for f in ("clientBuild", "sourceSnapshot", "rights")))
    return {
        "referenceUniverse": universe,
        "candidateItemIDs": len(items),
        "verifiedItemIDs": verified,
        "unverifiedItemIDs": len(items) - verified,
        "multiProfessionItemIDs": sum(len(item["relations"]) > 1 for item in items),
        "perProfessionCandidateItems": {k: counts[k] for k in sorted(counts)},
        "coveragePercent": round(100 * verified / denominator, 2)
            if type(denominator) is int and denominator > 0 and verified <= denominator else None,
        "fullCoverageClaimAllowed": bool(allowed),
        "note": "Unknown reference denominator means completeness cannot be claimed."
    }


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--release", action="store_true")
    args = parser.parse_args(argv)
    data, registry = load()
    errors = validate_catalog(data, registry, release=args.release)
    if errors:
        parser.error("; ".join(errors))
    outputs = {
        TARGET: generate(data, registry),
        REGISTRY_LUA: generate_registry(registry),
        COVERAGE: json.dumps(coverage_report(data, registry), indent=2, ensure_ascii=False) + "\n"
    }
    if args.check:
        drift = [str(p) for p, content in outputs.items() if not p.is_file() or p.read_text(encoding="utf-8") != content]
        if drift: parser.error("generated drift: " + ", ".join(drift))
    else:
        for path, content in outputs.items():
            path.write_text(content, encoding="utf-8")
    print(f'OK: {len(data["materials"])} itemIDs and {len(registry["professions"])} registered professions')


if __name__ == "__main__":
    main()
