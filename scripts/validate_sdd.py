#!/usr/bin/env python3
"""CraftAtlas pull-request OpenSpec traceability gate (Python stdlib only)."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

CHANGE_ID = re.compile(r"^OpenSpec-Change:\s*([a-z0-9]+(?:-[a-z0-9]+)*)\s*$", re.I | re.M)
EXEMPTION = re.compile(r"^OpenSpec-Exemption:\s*(docs-only|maintenance|bootstrap)\s*$", re.I | re.M)
PROTECTED = (
    ".github/workflows/", ".github/CODEOWNERS", "AGENTS.md",
    "scripts/validate_sdd.py", "docs/SDD_COMPLIANCE.md",
    "openspec/config.yaml",
)

def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()

def changed_files(base, head):
    # GitHub workflow fetches the base branch explicitly, so the merge base is valid.
    return [line for line in git("diff", "--name-only", "--diff-filter=ACDMRT", f"{base}...{head}").splitlines() if line]

def proposal_artifacts(change_id):
    directory = Path("openspec/changes") / change_id
    required = [directory / name for name in ("proposal.md", "design.md", "tasks.md")]
    specs = list((directory / "specs").glob("**/spec.md"))
    return directory, [str(p) for p in required if not p.is_file()], specs

def validate(files, body, pr_number):
    errors = []
    ids = CHANGE_ID.findall(body)
    exemptions = EXEMPTION.findall(body)
    if len(ids) > 1 or len(exemptions) > 1 or (ids and exemptions):
        errors.append("Declare exactly one OpenSpec-Change OR OpenSpec-Exemption.")
    if any(f.startswith("addon/") and f.endswith(".lua") for f in files):
        functional = True
    else:
        functional = False
    # Data, tests and project scripts may alter behavior even without changing Lua.
    functional |= any(
        f.startswith(("addon/Data/", "tests/")) or
        (f.startswith("scripts/") and f != "scripts/validate_sdd.py")
        for f in files
    )
    governance = any(f == path or f.startswith(path) for f in files for path in PROTECTED)
    if exemptions:
        category = exemptions[0].lower()
        if functional:
            errors.append("A functional/code change cannot claim an OpenSpec exemption.")
        if category == "docs-only" and any(not f.endswith((".md", ".txt")) for f in files):
            errors.append("docs-only exemption includes non-documentation files.")
        if governance:
            errors.append("Governance changes require explicit OpenSpec-Change (no exemptions).")
    elif ids:
        change_id = ids[0].lower()
        directory, missing, specs = proposal_artifacts(change_id)
        if missing:
            errors.append("Missing OpenSpec artifacts: " + ", ".join(missing))
        if not specs:
            errors.append(f"Missing delta specs at {directory}/specs/**/spec.md")
        if not any(f.startswith(f"{directory}/") for f in files):
            errors.append(f"No changed files within {directory}/. Link to an active, changed proposal, not an unrelated old spec.")
        if (directory / "archive").exists():
            errors.append("Archived changes cannot back new implementation.")
    elif functional or governance:
        errors.append("Functional or governance PR requires an OpenSpec-Change: <change-id> line.")
    else:
        errors.append("Declare OpenSpec-Exemption: docs-only|maintenance or OpenSpec-Change: <change-id>.")
    return errors, functional, governance

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True, help="Fetched base ref, e.g. origin/main")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--event", required=True, help="GitHub pull_request event JSON path")
    args = parser.parse_args()
    event = json.loads(Path(args.event).read_text(encoding="utf-8"))
    body = event.get("pull_request", {}).get("body") or ""
    files = changed_files(args.base, args.head)
    errors, functional, governance = validate(files, body, event.get("number"))
    print(f"SDD compliance: {len(files)} changed files; functional={functional}; governance={governance}")
    for error in errors:
        print(f"::error::{error}")
    if errors:
        return 1
    print("SDD traceability checks passed (semantic fidelity and owner approval require human review).")
    return 0

if __name__ == "__main__":
    sys.exit(main())
