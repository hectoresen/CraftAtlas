#!/usr/bin/env python3
"""CraftAtlas pull-request OpenSpec traceability gate (Python stdlib only)."""
import argparse
import json
import os
import urllib.request
import re
import subprocess
import sys
from pathlib import Path

CHANGE_ID = re.compile(r"^OpenSpec-Change:\s*([a-z0-9]+(?:-[a-z0-9]+)*)\s*$", re.I | re.M)
EXEMPTION = re.compile(r"^OpenSpec-Exemption: (docs-only|maintenance|bootstrap)$", re.M)
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

BOOTSTRAP_ALLOWED = {
    "AGENTS.md", "CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/workflows/spec-compliance.yml", "scripts/validate_sdd.py",
    "docs/SDD_COMPLIANCE.md", "tests/test_validate_sdd.py",
}
METADATA = {
    "change": re.compile(r"^OpenSpec-Change: ([a-z0-9]+(?:-[a-z0-9]+)*)$", re.M),
    "phase": re.compile(r"^OpenSpec-Phase: (proposal|implementation)$", re.M),
    "approval": re.compile(r"^OpenSpec-Approval-PR: ([1-9][0-9]*)$", re.M),
    "exemption": EXEMPTION,
}


def parse_metadata(body):
    # Remove fenced code blocks so sample values cannot count as declarations.
    body = re.sub(r"(?ms)^(\x60{3,}|~{3,})[^\n]*\n.*?^\1[^\n]*$", "", body)
    return {k: pattern.findall(body) for k, pattern in METADATA.items()}


def scope_patterns(directory):
    try:
        patterns = json.loads((directory / "sdd-scope.json").read_text())["allowed_paths"]
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return [], ["Missing/invalid sdd-scope.json: " + str(exc)]
    if not isinstance(patterns, list) or not patterns:
        return [], ["allowed_paths must be a nonempty array"]
    errors = []
    for p in patterns:
        if (not isinstance(p, str) or p.startswith(("/", ".", "openspec/"))
                or ".." in p or p in ("*", "**")
                or ("*" in p and not p.endswith("/**")) or "?" in p):
            errors.append("Unsafe scope pattern: " + repr(p))
    return patterns, errors


def github_api(path, token):
    req = urllib.request.Request(
        "https://api.github.com/repos/hectoresen/CraftAtlas/" + path,
        headers={"Authorization": "Bearer " + token,
                 "Accept": "application/vnd.github+json",
                 "X-GitHub-Api-Version": "2022-11-28"})
    with urllib.request.urlopen(req, timeout=15) as response:
        return json.load(response)


def verify_approval(pr_number, change_id, token, api=github_api, implementation_created=None):
    if not token:
        return ["GITHUB_TOKEN is required to verify owner-merged specification PR"]
    try:
        pr = api("pulls/" + str(pr_number), token)
        errors = []
        if not pr.get("merged_at") or (pr.get("merged_by") or {}).get("login") != "hectoresen":
            errors.append("Specification PR must be merged by @hectoresen")
        if implementation_created and pr.get("merged_at") and pr["merged_at"] >= implementation_created:
            errors.append("Specification must have been merged before implementation PR creation")
        if (pr.get("base") or {}).get("ref") != "main":
            errors.append("Specification PR must target main")
        related = False
        for page in range(1, 11):
            items = api("pulls/" + str(pr_number) + "/files?per_page=100&page=" +
                        str(page), token)
            related |= any(x.get("filename", "").startswith(
                "openspec/changes/" + change_id + "/") for x in items)
            if len(items) < 100:
                break
        if not related:
            errors.append("Referenced PR does not contain this OpenSpec change")
        return errors
    except Exception as exc:
        return ["Cannot check approval: " + str(exc)]


def validate(files, body, pr_number, root=Path("."), base="origin/main",
             token=None, api=github_api, exists_in_base=None, implementation_created=None):
    errors = []
    info = parse_metadata(body)
    if any(len(x) > 1 for x in info.values()):
        errors.append("Duplicate PR OpenSpec metadata")
    change, phase, approval, exemption = (
        info[k][0] if info[k] else None for k in ("change", "phase", "approval", "exemption"))
    if not files:
        errors.append("Empty PR")
    if exemption:
        if change or phase or approval:
            errors.append("Exemption may not include change metadata")
        if exemption == "bootstrap":
            if pr_number != 2 or not set(files) <= BOOTSTRAP_ALLOWED:
                errors.append("Bootstrap exemption is valid only for PR #2 and exact approved files")
        elif exemption == "docs-only":
            if any(not p.endswith((".md", ".txt")) or p.startswith((
                    ".github/", "addon/", "scripts/", "tests/", "openspec/")) or
                   p in ("AGENTS.md", "CONTRIBUTING.md", "docs/SDD_COMPLIANCE.md",
                         "docs/CODE_QUALITY.md", "docs/AGENT_WORKFLOW.md",
                         "docs/GITHUB_SETTINGS.md", "openspec/README.md")
                   for p in files):
                errors.append("docs-only exemption cannot change runtime/governance")
        elif exemption == "maintenance":
            if not set(files) <= {".gitignore", ".editorconfig", ".luacheckrc"}:
                errors.append("maintenance exemption limited to safe dotfiles")
        else:
            errors.append("Unknown exemption")
        return errors
    if not change or not phase:
        return errors + ["OpenSpec-Change and OpenSpec-Phase are mandatory"]
    base_path = "openspec/changes/" + change + "/"
    folder = root / base_path
    for name in ("proposal.md", "design.md", "tasks.md", "sdd-scope.json"):
        if not (folder / name).is_file():
            errors.append("Missing " + base_path + name)
    if not list((folder / "specs").glob("**/spec.md")):
        errors.append("Missing delta spec.md")
    allowed, scope_errors = scope_patterns(folder)
    errors.extend(scope_errors)
    changed = set(files)
    own = {p for p in changed if p.startswith(base_path)}
    outside = changed - own
    if any(p.startswith("openspec/changes/") for p in outside):
        errors.append("Cannot change unrelated OpenSpec work")
    if exists_in_base is None:
        def exists_in_base(path):
            try:
                git("cat-file", "-e", base + ":" + path)
                return True
            except subprocess.CalledProcessError:
                return False
    if phase == "proposal":
        if approval:
            errors.append("Proposal may not claim pre-approval")
        if base_path + "proposal.md" not in changed:
            errors.append("Proposal PR must change its own proposal.md")
        if outside:
            errors.append("Proposal PR must not include code or unrelated files")
        if exists_in_base(base_path + "proposal.md"):
            errors.append("Proposal ID already on base; create a new change")
    elif phase == "implementation":
        if not approval:
            errors.append("Implementation requires OpenSpec-Approval-PR")
        else:
            errors.extend(verify_approval(approval, change, token, api, implementation_created))
        for name in ("proposal.md", "design.md", "tasks.md", "sdd-scope.json"):
            if not exists_in_base(base_path + name):
                errors.append("Approved " + name + " not present on main")
        if any(p != base_path + "tasks.md" for p in own):
            errors.append("Implementation cannot rewrite approved spec, design or scope")
        if not outside:
            errors.append("Implementation PR must contain non-spec changes")
        if any(not (p in allowed or any(
                x.endswith("/**") and p.startswith(x[:-2]) for x in allowed))
                for p in outside):
            errors.append("Changed files outside approved sdd-scope.json")
        if any(p.startswith(".github/") or p == "AGENTS.md" for p in outside):
            errors.append("Governance changes require a separate spec proposal")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--event", required=True)
    args = parser.parse_args()
    event = json.loads(Path(args.event).read_text(encoding="utf-8"))
    body = (event.get("pull_request") or {}).get("body") or ""
    errors = validate(changed_files(args.base, args.head), body,
                      event.get("number"), base=args.base,
                      token=os.getenv("GITHUB_TOKEN"),
                      implementation_created=(event.get("pull_request") or {}).get("created_at"))
    for error in errors:
        print("::error::" + error)
    print("SDD: " + ("FAIL" if errors else "PASS") +
          " (semantic compliance still requires human review)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
