#!/usr/bin/env python3
"""CraftAtlas pull-request OpenSpec traceability gate (Python stdlib only)."""
import argparse
import datetime
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


# Rollout anchored to the owner-merged correction proposal #49. Existing
# approved legacy changes must never be renamed to satisfy new naming rules.
TYPED_CHANGE = re.compile(
    r"^(feat|fix|chore|upd|del)(00[1-9]|0[1-9][0-9]|[1-9][0-9]{2,})-"
    r"([a-z0-9]+(?:-[a-z0-9]+)*)$"
)
ROLLOUT_BASE_SHA = "a2085951b4010d17b525edd6b58b13f4aff900c3"
LEGACY_OPEN_PROPOSALS = {
    43: "refine-minimap-button",
    44: "add-addon-list-identity",
    46: "add-addon-configuration",
}
REQUIRED_PR_CONTEXTS = (
    "repository-validation", "traceability",
    "lua-compatibility", "lua-regressions",
)


def typed_identity(change):
    """Return (type, sequence, slug) for an exact CLI-safe typed change."""
    match = TYPED_CHANGE.fullmatch(change or "")
    if not match:
        return None
    kind, number, slug = match.groups()
    return kind, int(number), slug


def expected_pr_branch(change, phase):
    identity = typed_identity(change)
    if not identity:
        return None
    kind, number, slug = identity
    digits = str(number).zfill(3)
    if phase == "proposal":
        return "SPEC/" + kind.upper() + digits + "-" + slug
    if phase == "implementation":
        return kind.upper() + "/" + digits + "-" + slug
    return None


def required_context_snapshot(check_runs):
    """Separate never-created checks from actual skipped/success/pending runs."""
    newest = {}
    for run in check_runs:
        name = run.get("name")
        if name in REQUIRED_PR_CONTEXTS and name not in newest:
            newest[name] = run
    missing = sorted(set(REQUIRED_PR_CONTEXTS) - set(newest))
    pending = sorted(n for n, r in newest.items()
                     if r.get("status") != "completed")
    failed = sorted(n for n, r in newest.items()
                    if r.get("status") == "completed" and
                    r.get("conclusion") not in ("success", "skipped", "neutral"))
    return {"missing": missing, "pending": pending, "failed": failed}


def _typed_reserved_ids(base, api, token, pr_number, change):
    """Inspect trusted base tree and concurrent PR heads for numeric collisions."""
    errors = []
    kind, number, _ = typed_identity(change)
    try:
        paths = subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", base, "--",
             "openspec/changes"], text=True).splitlines()
    except (OSError, subprocess.CalledProcessError) as exc:
        return ["Cannot inspect approved OpenSpec sequence reservations: " + str(exc)]
    existing = set()
    for path in paths:
        parts = path.split("/")
        if len(parts) < 4 or parts[:2] != ["openspec", "changes"]:
            continue
        old = parts[2]
        if old == "archive" and len(parts) > 4:
            old = re.sub(r"^\d{4}-\d{2}-\d{2}-", "", parts[3])
        parsed = typed_identity(old)
        if parsed and parsed[0] == kind:
            existing.add((parsed[1], old))
    for allocated, old in existing:
        if allocated == number:
            errors.append("Typed ID sequence already approved/archived: " + old)
    if existing and number <= max(x[0] for x in existing):
        errors.append("Typed ID must advance beyond the latest accepted " + kind + " sequence")
    if not token:
        return errors + ["GITHUB_TOKEN required to check concurrent OpenSpec reservations"]
    try:
        for page in range(1, 11):
            pulls = api("pulls?state=open&per_page=100&page=" + str(page), token)
            for pull in pulls:
                if pull.get("number") == pr_number:
                    continue
                branch = (pull.get("head") or {}).get("ref", "")
                m = re.fullmatch(
                    r"SPEC/((?:FEAT|FIX|CHORE|UPD|DEL)[0-9]+-[a-z0-9-]+)", branch)
                if not m:
                    continue
                reserved = typed_identity(m.group(1).lower())
                if reserved and (reserved[0], reserved[1]) == (kind, number):
                    errors.append("Typed ID reserved by open PR #" + str(pull.get("number")))
            if len(pulls) < 100:
                break
    except Exception as exc:
        errors.append("Cannot verify concurrent OpenSpec ID reservations: " + str(exc))
    return errors


def validate_pr_identity(change, phase, pr_number, head_ref, base,
                         token, api, exists_in_base):
    """Apply the new convention without renaming already-approved legacy specs."""
    identity = typed_identity(change)
    if phase not in ("proposal", "implementation"):
        return []
    if identity:
        expected = expected_pr_branch(change, phase)
        errors = []
        if head_ref != expected:
            errors.append("Branch must be " + expected + " for OpenSpec change " + change)
        if phase == "proposal":
            errors.extend(_typed_reserved_ids(base, api, token, pr_number, change))
        return errors
    # A legacy implementation is valid only for a change present at rollout.
    if phase == "implementation":
        try:
            subprocess.check_output(["git", "cat-file", "-e",
                                     ROLLOUT_BASE_SHA + ":openspec/changes/" +
                                     change + "/proposal.md"], stderr=subprocess.DEVNULL)
            return []
        except (OSError, subprocess.CalledProcessError):
            return ["New implementation needs a CLI-safe typed OpenSpec ID"]
    if pr_number in LEGACY_OPEN_PROPOSALS and change == LEGACY_OPEN_PROPOSALS[pr_number]:
        return []
    return ["New proposal must use lowercase typed OpenSpec ID (e.g. feat001-menu) "
            "and SPEC/TYPEddd-slug branch; existing legacy PRs are grandfathered"]


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
    "phase": re.compile(r"^OpenSpec-Phase: (proposal|implementation|combined|lifecycle)$", re.M),
    "approval": re.compile(r"^OpenSpec-Approval-PR: ([1-9][0-9]*)$", re.M),
    "exemption": EXEMPTION,
    "archive": re.compile(r"^OpenSpec-Archive: (prepared|blocked)$", re.M),
    "archive_evidence": re.compile(r"^OpenSpec-Archive-Evidence: (.+)$", re.M),
}


def parse_metadata(body):
    # Remove fenced code blocks so sample values cannot count as declarations.
    body = re.sub(r"(?ms)^(\x60{3,}|~{3,})[^\n]*\n.*?^\1[^\n]*$", "", body)
    return {k: pattern.findall(body) for k, pattern in METADATA.items()}


def is_explicit_workflow_path(path):
    """Permit only individually named YAML workflows, never directory globs."""
    return bool(re.fullmatch(r"\.github/workflows/[A-Za-z0-9_-]+\.ya?ml", path))


def scope_patterns(directory):
    try:
        patterns = json.loads((directory / "sdd-scope.json").read_text())["allowed_paths"]
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return [], ["Missing/invalid sdd-scope.json: " + str(exc)]
    return validate_scope_values(patterns)


def validate_scope_values(patterns):
    if not isinstance(patterns, list) or not patterns:
        return [], ["allowed_paths must be a nonempty array"]
    errors = []
    for p in patterns:
        if (not isinstance(p, str) or (p.startswith(("/", ".", "openspec/")) and not is_explicit_workflow_path(p))
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


# Historical governance reconciliation is a separately approved lifecycle operation.
# The allowlist is intentionally fixed in this validator, not a user-supplied glob.
LIFECYCLE_CHANGE = "reconcile-openspec-lifecycle-and-status"
LIFECYCLE_APPROVAL_PR = "13"
LIFECYCLE_LEGACY_IDS = {
    "add-first-playable-material-tooltips",
    "enhance-addon-icon-minimap-settings",
    "expand-all-profession-material-coverage",
}
LIFECYCLE_FIXED_PATHS = {
    "AGENTS.md", "openspec/config.yaml", "openspec/README.md",
    "docs/AGENT_WORKFLOW.md", "docs/OPENSPEC_STATUS.md",
    "docs/ROADMAP.md", "docs/TESTING.md", "README.md", "CHANGELOG.md",
}
LIFECYCLE_CANONICAL_PATH = re.compile(r"^openspec/specs/[a-z0-9-]+/spec\.md$")
LIFECYCLE_ARCHIVE_PATH = re.compile(
    r"^openspec/changes/archive/[0-9]{4}-[0-9]{2}-[0-9]{2}-"
    r"([a-z0-9-]+)/(.+)$"
)


def validate_lifecycle(paths, approval, change, root, base, exists_in_base):
    """Restrict a one-time, explicitly approved archival/sync operation."""
    errors = []
    if change != LIFECYCLE_CHANGE or approval != LIFECYCLE_APPROVAL_PR:
        errors.append("Lifecycle phase is restricted to approved change/PR #13")
        return errors

    outside_scope = set()
    archived = {}
    deleted = set()
    for path in paths:
        if path in LIFECYCLE_FIXED_PATHS:
            continue
        if LIFECYCLE_CANONICAL_PATH.fullmatch(path):
            # Canonical capability name must correspond to an accepted legacy delta.
            capability = path.split("/")[2]
            expected = any(
                (root / "openspec/changes" / legacy / "specs" / capability / "spec.md").is_file()
                for legacy in LIFECYCLE_LEGACY_IDS
            )
            if not expected:
                errors.append("Canonical spec not supported by approved legacy deltas: " + path)
            continue
        match = LIFECYCLE_ARCHIVE_PATH.fullmatch(path)
        if match:
            legacy = match.group(1)
            if legacy not in LIFECYCLE_LEGACY_IDS:
                errors.append("Cannot archive unrelated change: " + path)
                continue
            relative = match.group(2)
            if relative.startswith("/") or ".." in relative.split("/"):
                errors.append("Unsafe archive path: " + path)
                continue
            archived.setdefault(legacy, []).append((path, relative))
            continue
        for legacy in LIFECYCLE_LEGACY_IDS:
            prefix = "openspec/changes/" + legacy + "/"
            if path.startswith(prefix):
                if path == prefix + "tasks.md":
                    break
                # Archive moves may delete legacy source artifacts, but not edit
                # existing immutable proposal/design/delta/spec/scope contents.
                if (root / path).exists():
                    errors.append("Historical OpenSpec artifacts are immutable: " + path)
                else:
                    deleted.add(path)
                break
        else:
            outside_scope.add(path)

    if outside_scope:
        errors.append("Lifecycle changed unapproved paths: " + ", ".join(sorted(outside_scope)))

    if archived or deleted:
        if not (root / "docs/OPENSPEC_STATUS.md").is_file():
            errors.append("Archiving requires an OpenSpec evidence/status ledger")
        # Each archived file must match its original in the base, byte-for-byte.
        for legacy, entries in archived.items():
            for dest, relative in entries:
                original = "openspec/changes/" + legacy + "/" + relative
                if not exists_in_base(original):
                    errors.append("Archive has no approved original: " + dest)
                    continue
                try:
                    original_bytes = subprocess.check_output(
                        ["git", "show", base + ":" + original])
                    if (root / dest).read_bytes() != original_bytes:
                        errors.append("Archive copy differs from accepted original: " + dest)
                except (OSError, subprocess.CalledProcessError) as exc:
                    errors.append("Cannot verify archive source: " + str(exc))
        # An original artifact may only be deleted once its exact dated archive
        # counterpart is provided in the same PR and verified above.
        for original in deleted:
            if not any(
                "openspec/changes/" + legacy + "/" + relative == original
                for legacy, entries in archived.items()
                for _, relative in entries
            ):
                errors.append("Historical artifact deleted without matching archive: " + original)

    if "openspec/config.yaml" in paths:
        current = (root / "openspec/config.yaml")
        if not current.exists():
            errors.append("OpenSpec config must not be deleted")
        else:
            content = current.read_text(encoding="utf-8")
            if "schema: spec-driven" not in content:
                errors.append("OpenSpec schema must remain spec-driven")
            if "v0.0.0 is documentation and folder structure only" in content:
                errors.append("OpenSpec configuration still declares a non-playable scaffold")
    return errors



# Same-PR archive policy: bounded to the owner-approved implementation's change.
# It never grants an exemption for arbitrary paths under openspec/.
ARCHIVE_ROOT = "openspec/changes/archive/"
CANONICAL_SPEC = re.compile(r"^openspec/specs/([a-z0-9-]+)/spec\.md$")
ARCHIVED_FILE = re.compile(
    r"^openspec/changes/archive/(\d{4}-\d{2}-\d{2})-([a-z0-9-]+)/(.+)$"
)
TASK_MARKER = re.compile(r"(?m)^\s*- \[([ xX])\] ")


def base_archive_files(base, change, file_list=None, file_read=None):
    """Return immutable base artifacts using git (or injected offline fixtures)."""
    prefix = "openspec/changes/" + change + "/"
    if file_list is None:
        file_list = lambda base_ref, path: subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", base_ref, "--", path],
            text=True).splitlines()
    if file_read is None:
        file_read = lambda base_ref, path: subprocess.check_output(
            ["git", "show", base_ref + ":" + path])
    return {p[len(prefix):]: file_read(base, p)
            for p in file_list(base, prefix) if p.startswith(prefix)}


def _requirements(content):
    """Conservatively preserve pre-existing named SHALL requirements."""
    return set(re.findall(r"(?m)^### Requirement: (.+?)\s*$", content))


def validate_implementation_archive(
    paths, change, root, base, archive_state, evidence,
    file_list=None, file_read=None, pr_number=None, approval=None,
):
    """Fail closed if a same-change archive is incomplete or contradicts base."""
    errors = []
    changed = set(paths)
    active_prefix = "openspec/changes/" + change + "/"
    archived = [p for p in changed if p.startswith(ARCHIVE_ROOT)]
    own = {p for p in changed if p.startswith(active_prefix)}
    canonical = {p for p in changed if p.startswith("openspec/specs/")}
    status_path = "docs/OPENSPEC_STATUS.md"
    evidence = (evidence or "").strip()
    if archive_state not in ("prepared", "blocked"):
        return ["Implementation requires OpenSpec-Archive: prepared|blocked"]
    if len(evidence) < 70 or not re.search(
        r"(?:tests/|docs/|\.md|\b(?:test|scenario|client|NOT RUN|PASS|FAIL|scope|CI)\b)",
        evidence, re.I
    ):
        errors.append("OpenSpec-Archive-Evidence must name concrete acceptance/tests and documentation (70+ chars)")
    if archive_state == "blocked":
        if archived or canonical or status_path in changed:
            errors.append("Blocked implementation cannot alter archive, canonical specs or status ledger")
        if any(p != active_prefix + "tasks.md" for p in own):
            errors.append("Blocked implementation may only update its own tasks.md")
        if not re.search(r"(?:NOT RUN|blocked|missing|pending|unverified|incomplete)", evidence, re.I):
            errors.append("Blocked archive must identify missing mandatory acceptance evidence")
        return errors

    # Prepared means a complete archive in this PR, not a claim of prior merge.
    if not archived or status_path not in changed:
        errors.append("Prepared archive requires dated files and updated docs/OPENSPEC_STATUS.md")
    if own and any((root / p).exists() for p in own):
        errors.append("Prepared archive must remove entire active change")
    if (root / active_prefix).exists():
        errors.append("Prepared archive still contains active change directory")

    destinations = {}
    dates = set()
    for path in archived:
        match = ARCHIVED_FILE.fullmatch(path)
        if not match or match.group(2) != change:
            errors.append("Archive changes unrelated or unsafe path: " + path)
            continue
        date, _, relative = match.groups()
        try:
            if datetime.date.fromisoformat(date).isoformat() != date:
                raise ValueError("noncanonical date")
        except ValueError:
            errors.append("Invalid archive date: " + path)
        if relative.startswith("/") or any(x in ("", ".", "..") for x in relative.split("/")):
            errors.append("Invalid relative archive path: " + path)
            continue
        dates.add(date)
        destinations[relative] = path
    if len(dates) != 1:
        errors.append("Prepared archive must use exactly one YYYY-MM-DD date")

    try:
        base_files = base_archive_files(base, change, file_list, file_read)
    except (OSError, subprocess.CalledProcessError, UnicodeError) as exc:
        return errors + ["Cannot read owner-approved archive source: " + str(exc)]
    if not base_files or not all(x in base_files for x in
                                 ("proposal.md", "design.md", "tasks.md", "sdd-scope.json")):
        errors.append("Approved change archive source incomplete on base")
    if set(destinations) != set(base_files):
        errors.append("Archive must preserve exactly every approved file (no omissions or extras)")
    for relative, target in destinations.items():
        if relative not in base_files:
            continue
        try:
            contents = (root / target).read_bytes()
        except OSError:
            errors.append("Missing archived file: " + target)
            continue
        if relative != "tasks.md" and contents != base_files[relative]:
            errors.append("Archived approved artifact differs from base: " + target)
        if relative == "tasks.md":
            task_text = contents.decode("utf-8")
            base_text = base_files[relative].decode("utf-8")
            if len(TASK_MARKER.findall(task_text)) != len(TASK_MARKER.findall(base_text)):
                errors.append("Archive tasks checklist changed count; task provenance must be retained")
            if re.sub(r"(?m)(^\s*- \[)[ xX](\] )", r"\1 \2", task_text) != re.sub(
                r"(?m)(^\s*- \[)[ xX](\] )", r"\1 \2", base_text):
                # Extra evidence paragraphs after checklists are allowed only
                # if actual task text retains original names/order.
                original_items = re.findall(r"(?m)^\s*- \[[ xX]\] (.+)$", base_text)
                current_items = re.findall(r"(?m)^\s*- \[[ xX]\] (.+)$", task_text)
                if original_items != current_items:
                    errors.append("Archived tasks must preserve approved task descriptions/order")
            if any(x.lower() != "x" for x in TASK_MARKER.findall(task_text)):
                errors.append("Cannot archive a change with incomplete implementation tasks")

    delta_capabilities = {
        rel.split("/")[1] for rel in base_files
        if rel.startswith("specs/") and rel.endswith("/spec.md") and len(rel.split("/")) == 3
    }
    expected = {"openspec/specs/" + cap + "/spec.md" for cap in delta_capabilities}
    if canonical != expected:
        errors.append("Canonical spec sync must update exactly the approved capabilities")
    for path in canonical:
        match = CANONICAL_SPEC.fullmatch(path)
        if not match or match.group(1) not in delta_capabilities:
            errors.append("Unapproved canonical spec update: " + path)
            continue
        try:
            current = (root / path).read_text(encoding="utf-8")
            approved_delta = base_files["specs/" + match.group(1) + "/spec.md"].decode("utf-8")
            if not _requirements(approved_delta) <= _requirements(current):
                errors.append("Canonical spec missing approved requirements: " + path)
            if file_read is None:
                try:
                    prior = subprocess.check_output(["git", "show", base + ":" + path],
                                                    text=True)
                except subprocess.CalledProcessError:
                    prior = ""
            else:
                try:
                    prior = file_read(base, path).decode("utf-8")
                except (KeyError, FileNotFoundError):
                    prior = ""
            if not _requirements(prior) <= _requirements(current):
                errors.append("Canonical spec drops existing requirements: " + path)
        except (KeyError, OSError, UnicodeError):
            errors.append("Cannot verify canonical spec: " + path)

    ledger = root / status_path
    if not ledger.is_file():
        errors.append("Archive status ledger missing")
    else:
        content = ledger.read_text(encoding="utf-8")
        if change not in content or not re.search(r"archiv(?:ed|e)", content, re.I):
            errors.append("Ledger must record this change's archived disposition")
        if approval and "#" + str(approval) not in content:
            errors.append("Ledger must cite approved specification PR")
        if pr_number and "#" + str(pr_number) not in content:
            errors.append("Ledger must cite implementation PR")
        if not re.search(r"(?:tests/|NOT RUN|PASS|acceptance|evidence)", content, re.I):
            errors.append("Ledger must describe acceptance evidence")
    return errors


def context_regression_errors(current_config, baseline_config):
    """Reject obsolete version claims once the parent branch has been repaired.

    A preexisting inconsistency on main is grandfathered only during this
    transitional governance PR; it cannot be reintroduced after lifecycle sync.
    """
    stale = "v0.0.0 is documentation and folder structure only"
    if stale in current_config and stale not in baseline_config:
        return ["OpenSpec context regressed to non-playable v0.0.0 scaffold"]
    if stale not in baseline_config:
        if ("schema: spec-driven" not in current_config or
                "README.md" not in current_config):
            return ["OpenSpec context must remain spec-driven and refer to README.md"]
        # Context is a stable agent briefing, not a second changelog. References
        # to version-stamped product state would inevitably become obsolete.
        if re.search(r"\bv[0-9]+\.[0-9]+(?:\.[0-9]+)?(?:-dev)?\b", current_config, re.I):
            return ["OpenSpec config must not pin product versions; point to README.md"]
    return []


def validate(files, body, pr_number, root=Path("."), base="origin/main",
             token=None, api=github_api, exists_in_base=None, implementation_created=None,
             head_ref=None):
    errors = []
    # Existing stale main context is a tracked debt; once removed via the
    # approved lifecycle PR, fail every PR trying to reintroduce it.
    current_config = root / "openspec/config.yaml"
    if current_config.is_file():
        try:
            baseline_config = subprocess.check_output(
                ["git", "show", base + ":openspec/config.yaml"], text=True)
        except (OSError, subprocess.CalledProcessError):
            baseline_config = current_config.read_text(encoding="utf-8")
        errors.extend(context_regression_errors(
            current_config.read_text(encoding="utf-8"), baseline_config))
    info = parse_metadata(body)
    if any(len(x) > 1 for x in info.values()):
        errors.append("Duplicate PR OpenSpec metadata")
    change, phase, approval, exemption, archive_state, archive_evidence = (
        info[k][0] if info[k] else None for k in (
            "change", "phase", "approval", "exemption", "archive", "archive_evidence"))
    if not files:
        errors.append("Empty PR")
    if exemption:
        if change or phase or approval or archive_state or archive_evidence:
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
    if phase == "implementation" and archive_state == "prepared":
        # The active directory is intentionally absent when archived. Load
        # the frozen owner-approved scope and artifacts from the base ref,
        # never from untrusted archive copies.
        try:
            scoped = subprocess.check_output(
                ["git", "show", base + ":" + base_path + "sdd-scope.json"], text=True)
            manifest = json.loads(scoped)
            allowed, scope_errors = validate_scope_values(manifest.get("allowed_paths"))
            errors.extend(scope_errors)
        except (OSError, subprocess.CalledProcessError, ValueError, TypeError) as exc:
            allowed = []
            errors.append("Cannot load approved scope from base: " + str(exc))
    else:
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
    if phase != "lifecycle" and any(
        p.startswith("openspec/changes/") and not (
            phase == "implementation" and archive_state == "prepared"
            and p.startswith(ARCHIVE_ROOT))
        for p in outside
    ):
        errors.append("Cannot change unrelated OpenSpec work")
    if exists_in_base is None:
        def exists_in_base(path):
            try:
                git("cat-file", "-e", base + ":" + path)
                return True
            except subprocess.CalledProcessError:
                return False
    if head_ref is not None or typed_identity(change):
        errors.extend(validate_pr_identity(
            change, phase, pr_number, head_ref, base, token, api, exists_in_base))
    if phase == "proposal":
        if approval:
            errors.append("Proposal may not claim pre-approval")
        if base_path + "proposal.md" not in changed:
            errors.append("Proposal PR must change its own proposal.md")
        if outside:
            errors.append("Proposal PR must not include code or unrelated files")
        if exists_in_base(base_path + "proposal.md"):
            errors.append("Proposal ID already on base; create a new change")
    elif phase == "combined":
        # Narrow owner-authorized pilot: PR #14 only. Keep future two-PR gates intact.
        if pr_number != 14 or change != "improve-material-explorer-ui":
            errors.append("Combined phase is authorized only for CraftAtlas PR #14")
        if approval:
            errors.append("Combined phase cannot claim a separately merged approval")
        if base_path + "proposal.md" not in changed:
            errors.append("Combined PR must add its own proposal.md")
        if exists_in_base(base_path + "proposal.md"):
            errors.append("Combined PR must introduce a new change ID")
        if not outside:
            errors.append("Combined PR must include implementation outside its specs")
        # These three governance files and AGENTS.md are required to document
        # the exact one-time policy exception; no other special paths allowed.
        special = {"scripts/validate_sdd.py", "tests/test_validate_sdd.py",
                   "docs/SDD_COMPLIANCE.md", "AGENTS.md"}
        for path in outside:
            if path not in special and not (path in allowed or any(
                    x.endswith("/**") and path.startswith(x[:-2]) for x in allowed)):
                errors.append("Combined PR changed file outside its approved sdd-scope.json: " + path)
        if any(path.startswith(".github/") for path in outside):
            errors.append("Combined PR cannot modify workflow enforcement")
    elif phase == "lifecycle":
        if not approval:
            errors.append("Lifecycle requires OpenSpec-Approval-PR")
        else:
            errors.extend(verify_approval(
                approval, change, token, api, implementation_created))
        errors.extend(validate_lifecycle(
            changed, approval, change, root, base, exists_in_base))
    elif phase == "implementation":
        if not approval:
            errors.append("Implementation requires OpenSpec-Approval-PR")
        else:
            errors.extend(verify_approval(approval, change, token, api, implementation_created))
        for name in ("proposal.md", "design.md", "tasks.md", "sdd-scope.json"):
            if not exists_in_base(base_path + name):
                errors.append("Approved " + name + " not present on main")
        if archive_state == "prepared":
            errors.extend(validate_implementation_archive(
                changed, change, root, base, archive_state, archive_evidence,
                pr_number=pr_number, approval=approval))
        else:
            if any(p != base_path + "tasks.md" for p in own):
                errors.append("Implementation cannot rewrite approved spec, design or scope")
            errors.extend(validate_implementation_archive(
                changed, change, root, base, archive_state, archive_evidence,
                pr_number=pr_number, approval=approval))
        if not outside:
            errors.append("Implementation PR must contain non-spec changes")
        archive_extras = set()
        if archive_state == "prepared":
            archive_extras = {p for p in outside if (
                p.startswith(ARCHIVE_ROOT) or p.startswith("openspec/specs/")
                or p == "docs/OPENSPEC_STATUS.md")}
        if any(not (p in allowed or any(
                x.endswith("/**") and p.startswith(x[:-2]) for x in allowed))
                for p in outside - archive_extras):
            errors.append("Changed files outside approved sdd-scope.json")
        # This one owner-approved governance change may update protected agent
        # instructions, but only inside its own explicitly scoped implementation.
        # Every other implementation continues to reject AGENTS.md unconditionally.
        special_agent_change = change in (
            "mandatory-multiagent-documentation-gate",
            "harden-contributor-pr-governance",
            "archive-openspec-with-implementation",
            "resolve-typed-openspec-cli-compatibility",
        )
        # Only this explicitly owner-approved change may introduce the root
        # CODEOWNERS file; hidden .github policy files remain forbidden.
        special_codeowners_change = change == "harden-contributor-pr-governance"
        if any((p.startswith(".github/") and not (is_explicit_workflow_path(p) and p in allowed))
               or (p == "AGENTS.md" and not (special_agent_change and p in allowed))
               or (p == "CODEOWNERS" and not (special_codeowners_change and p in allowed))
               for p in outside):
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
                      implementation_created=(event.get("pull_request") or {}).get("created_at"),
                      head_ref=(event.get("pull_request") or {}).get("head", {}).get("ref"))
    for error in errors:
        print("::error::" + error)
    print("SDD: " + ("FAIL" if errors else "PASS") +
          " (semantic compliance still requires human review)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
