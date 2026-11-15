#!/usr/bin/env python3
"""Deterministic offline itemID -> profession compiler; no runtime network."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "addon/CraftAtlas/Data"
SOURCE = DATA / "materials.source.json"
REGISTRY = DATA / "professions.source.json"
TARGET = DATA / "Materials.lua"
REGISTRY_LUA = DATA / "Professions.lua"
COVERAGE = DATA / "coverage-report.json"
RECIPE_SOURCE = DATA / "recipe-uses.source.json"
RECIPE_TARGET = DATA / "RecipeUses.lua"
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
        if not (data.get("referenceUniverse") or {}).get("liveClientValidated"):
            errors.append("release requires owner-confirmed live Forever client validation")
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


def validate_recipe_uses(recipe_data, materials, registry):
    errors = []
    professions = {p["key"] for p in registry["professions"]}
    relations = {
        (m["itemID"], r["professionKey"], spell)
        for m in materials["materials"]
        for r in m["relations"]
        for spell in r.get("recipeIDs", [])
        if r.get("usageKind") in ("ingredient", "component", "reagent")
    }
    if recipe_data.get("schemaVersion") != 1 or not recipe_data.get("source") or not recipe_data.get("license"):
        errors.append("invalid recipe source provenance/schema")
    if recipe_data.get("liveClientValidated") is True:
        errors.append("recipe snapshot may not claim live-client validation without evidence")
    seen = set()
    for i, row in enumerate(recipe_data.get("uses", [])):
        if not isinstance(row, list) or len(row) != 6:
            errors.append(f"recipe use {i}: invalid format")
            continue
        item, spell, prof, qty, output, kind = row
        if any(type(n) is not int or n <= 0 for n in (item, spell, qty)):
            errors.append(f"recipe use {i}: invalid input, spell or quantity")
        if prof not in professions or (item, prof, spell) not in relations:
            errors.append(f"recipe use {i}: not a known source reagent relationship")
        if type(output) is not int or output < 0 or kind not in ("item", "enchant", "unknown"):
            errors.append(f"recipe use {i}: invalid output or kind")
        if kind == "item" and output == 0 or kind != "item" and output != 0:
            errors.append(f"recipe use {i}: inconsistent output status")
        key = (item, spell, prof)
        if key in seen:
            errors.append(f"recipe use {i}: duplicate relationship")
        seen.add(key)
    if not seen:
        errors.append("no recipe input relations")
    missing = relations - seen
    if missing:
        errors.append(f"missing {len(missing)} recipe source reagent relationships")
    return errors


def generate_recipe_uses(data, registry):
    order = [p["key"] for p in registry["professions"]]
    kinds = ["item", "enchant", "unknown"]
    lines = [
        "local _, ns = ...\\n",
        "-- Generated by scripts/build_materials.py. Do not edit.\\n",
        "-- Source: MIT LibProfessionDB Forever 1.60.1.69977; not live-client verified.\\n",
        "ns.recipeUses = {\\n",
    ]
    previous = None
    for item, spell, profession, qty, output, kind in sorted(
            data["uses"], key=lambda row: (row[0], row[2], row[1])):
        if item != previous:
            if previous is not None:
                lines.append("},\\n")
            lines.append(f"    [{item}] = {{")
            previous = item
        fields = [spell, order.index(profession) + 1, qty, output, kinds.index(kind) + 1]
        lines.append("{" + ",".join(str(number) for number in fields) + "},")
    if previous is not None:
        lines.append("},\\n")
    lines.append("}\\n")
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
    allowed = (type(denominator) is int and verified == denominator
               and universe.get("completeReferenceUniverse") is True
               and universe.get("liveClientValidated") is True
               and all(universe.get(f) for f in ("clientBuild", "sourceSnapshot", "rights")))
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



# Core Lua data import is OFFLINE and is limited to the MIT-licensed
# LibProfessionDB Forever recipe files that a contributor obtained themselves.
# Do not infer actual live realm recipe availability from these DBC records.
PROFESSION_FILES = {
    "alchemy": "ALCHEMY", "blacksmithing": "BLACKSMITHING",
    "cooking": "COOKING", "enchanting": "ENCHANTING",
    "engineering": "ENGINEERING", "firstaid": "FIRST_AID",
    "fishing": "FISHING", "herbalism": "HERBALISM",
    "leatherworking": "LEATHERWORKING", "mining": "MINING",
    "skinning": "SKINNING", "tailoring": "TAILORING",
}
RECIPE_START = re.compile(r"(?m)^\t\t\[(\d+)\] = \{")
REAGENT_BLOCK = re.compile(r'\["reagents"\]\s*=\s*\{([^}]*)\}')
REAGENT_PAIR = re.compile(r"\[(\d+)\]\s*=\s*(\d+)")


def extract_reagent_facts(lua_source):
    """Return [(recipe_spell_id, reagent_item_id)] from Lua recipe blocks.

    Split at two-tab recipe boundaries so data from consecutive recipes cannot
    accidentally mix. No arbitrary Lua code is executed.
    """
    starts = list(RECIPE_START.finditer(lua_source))
    relations = set()
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(lua_source)
        block = lua_source[match.end():end]
        reagent_block = REAGENT_BLOCK.search(block)
        if not reagent_block:
            continue
        spell = int(match.group(1))
        for item_match in REAGENT_PAIR.finditer(reagent_block.group(1)):
            item_id, count = int(item_match.group(1)), int(item_match.group(2))
            if item_id > 0 and count > 0:
                relations.add((spell, item_id))
    return sorted(relations)


def import_libprofessiondb(directory, reference_url, client_build, review_date, registry):
    """Create a snapshot using reviewed MIT LibProfessionDB core files.

    The source data rights and exact version remain contributor responsibilities.
    This import deliberately does not assert live build parity or completeness.
    """
    folder = Path(directory)
    if not folder.is_dir():
        raise ValueError("LibProfessionDB core directory does not exist")
    approved = {p["key"] for p in registry["professions"]}
    grouped = {}
    imported = 0
    for path in sorted(folder.glob("*.lua")):
        profession = PROFESSION_FILES.get(path.stem.lower())
        if not profession:
            continue
        if profession not in approved:
            raise ValueError(f"Register profession {profession} before importing {path.name}")
        for spell, item_id in extract_reagent_facts(path.read_text(encoding="utf-8")):
            grouped.setdefault(item_id, {}).setdefault(profession, set()).add(spell)
            imported += 1
    if not imported:
        raise ValueError("No recognized reagent relationships in source files")
    materials = []
    for item_id, jobs in sorted(grouped.items()):
        relations = []
        for job, spells in sorted(jobs.items()):
            relations.append({
                "professionKey": job, "usageKind": "ingredient",
                "source": reference_url, "recipeIDs": sorted(spells),
                "reviewedAt": review_date, "clientBuild": client_build,
                "rights": "compatible-licensed-source", "status": "verified",
            })
        materials.append({"itemID": item_id, "relations": relations})
    return materials



def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--release", action="store_true")
    parser.add_argument("--import-libprofessiondb", metavar="DIR")
    parser.add_argument("--source-url")
    parser.add_argument("--client-build")
    parser.add_argument("--reviewed-at")
    args = parser.parse_args(argv)
    data, registry = load()
    recipe_data = json.loads(RECIPE_SOURCE.read_text(encoding="utf-8"))
    if args.import_libprofessiondb:
        if not (args.source_url and args.client_build and args.reviewed_at):
            parser.error("import requires --source-url, --client-build and --reviewed-at")
        try:
            data["materials"] = import_libprofessiondb(
                args.import_libprofessiondb, args.source_url,
                args.client_build, args.reviewed_at, registry)
        except ValueError as exc:
            parser.error(str(exc))
        data["referenceUniverse"] = {
            "clientBuild": args.client_build, "sourceSnapshot": args.source_url,
            "eligibleItemIDs": None, "rights": "MIT; retain upstream LICENSE",
            "liveClientValidated": False, "completeReferenceUniverse": False
        }
        SOURCE.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    errors = validate_catalog(data, registry, release=args.release)
    errors += validate_recipe_uses(recipe_data, data, registry)
    if errors:
        parser.error("; ".join(errors))
    outputs = {
        TARGET: generate(data, registry),
        REGISTRY_LUA: generate_registry(registry),
        COVERAGE: json.dumps(coverage_report(data, registry), indent=2, ensure_ascii=False) + "\n",
        RECIPE_TARGET: generate_recipe_uses(recipe_data, registry)
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
