# Design: atomic same-PR OpenSpec sync and archive

## Current baseline (verified in main, 2026-11-16)

- `openspec/README.md`: PROPOSE → owner merge → IMPLEMENT → VERIFY → SYNC → PR → owner acceptance/ARCHIVE.
- `scripts/validate_sdd.py`: `implementation` phase requires owner-merged proposal, approved spec artifacts present on base, and forbids edits to original delta except `tasks.md`; all paths must match approved `sdd-scope.json`.
- `lifecycle` phase is a one-time restricted historical reconciliation linked to approval PR #13. Do not reuse it for routine implementation archives.
- `docs/OPENSPEC_STATUS.md` marks several older changes OPEN due to missing historic evidence. They remain outside this change's retrospective scope.
- `skills/documentation-sync/SKILL.md` audits actual code, QA and docs but currently does not require preparation of a synchronized archive.

## Proposed normal implementation contract

Keep `OpenSpec-Phase: implementation` and `OpenSpec-Approval-PR: <merged proposal PR>` unchanged. Only the **corresponding approved change ID** may be closed as part of this implementation PR. No third `lifecycle` PR for an otherwise fully accepted new change.

Within the implementation PR:
1. Implement and verify the accepted source behaviors and per-scenario mandatory tests.
2. Run `documentation-sync` in four audit roles and distinguish user/game evidence from offline fixtures.
3. For each delta capability, compare accepted SHALL scenarios and canonical `openspec/specs/<capability>/spec.md`; synchronize without deleting or weakening unrelated canonical requirements. Fail if conflicting requirements cannot be resolved within the approved scope.
4. Only when all mandatory requirements and acceptance criteria have evidenced completion, create dated `openspec/changes/archive/YYYY-MM-DD-<change-id>/` artifacts, preserving the owner's merged `proposal.md`, `design.md`, `specs/**`, `sdd-scope.json` **byte-for-byte**, and capturing `tasks.md` as of the PR's final verified state. Remove only the corresponding original active change folder. Record disposition and linked PR/evidence in `docs/OPENSPEC_STATUS.md`. Prepare the archive **before** opening the implementation PR; the archive is not already accepted until the owner merges.
5. If *any* mandatory scenario is NOT RUN, contradicted or unverified (notably actual Forever testing required by an approved spec), **do not archive**. Preserve the active change, leave relevant tasks unchecked, describe the blocker in the PR, and do not mark it completed. When the missing acceptance is a condition of shipping, mark the implementation PR not ready to merge until it has been supplied or explicitly re-scoped in a **separate approved spec**. No auto-waiver or fabricated evidence.

## Validator design

Extend `scripts/validate_sdd.py` with a narrowly scoped, fail-closed implementation archive mode. Keep all existing approval and chronology checks. Allow the following only as a related, complete transaction:
- `openspec/changes/archive/<date>-<current-change-id>/**` where date is strict YYYY-MM-DD and every archived path maps to exactly one originally owner-approved path. Archive approved immutable contents byte-for-byte against `git show <base>:<active path>`; archived `tasks.md` may differ **only** from base's task checklist to reflect real implementation evidence and its canonical archived copy must equal the final verified task state. No other changes to approved delta artifacts, even within archive.
- Deletion of only `openspec/changes/<current-change-id>/**`, provided all expected owner-merged artifacts are fully preserved in archive and no active leftovers exist. No deletion of unrelated active changes or pre-existing archive content.
- `openspec/specs/<capability>/spec.md` updates only for capabilities named under the exact change's approved `specs/<capability>/spec.md`. No unrelated canonical file changes, and no weakening/replacing requirements outside approved deltas; validator checks bounded paths and provenance, while semantic consistency still needs human review. If a canonical file already exists, reject removal of unrelated SHALL sections; retain source+delta evidence rather than treating generated output as proof.
- `docs/OPENSPEC_STATUS.md` status record only for this change, containing acceptance evidence, links to approved proposal PR and implementation PR, and an explicit `archived` marker. Never declare owner merged before the owner acts.
- Other implementation source/tests/docs changes stay restricted by the frozen owner-approved `allowed_paths`. The archiving transaction allowance is **a generic validator policy**, not an invitation to modify historical archives or arbitrary files.
- Reject incomplete archives, missing original files, altered provenance, wrong change IDs, unrelated capability syncs, unaccepted task completion, duplicate archive destinations and partial deletions. Test malicious path traversal and deceptive patterns.

An ordinary implementation PR **without archive** remains possible only when material mandatory acceptance evidence is missing, with PR body `OpenSpec-Archive: blocked` and `OpenSpec-Archive-Evidence: ...` listing the exact incomplete scenarios/tests. An eligible implementation PR carries `OpenSpec-Archive: prepared` and evidence referencing the canonical sync and archive paths. CI validates archive/file structure and metadata and checks that `prepared` corresponds to an actual complete archival transaction, not a claim of already merged acceptance. Skill and reviewer verify semantic evidence.

Avoid treating generic `tasks.md` checkboxes as sufficient proof: task completion is backed by named tests and/or maintainer-authored client evidence, and CI cannot infer human game validation. The owner still authorizes final acceptance by merging.

## OpenSpec CLI and CI

Use supported `/opsx:verify`, `/opsx:sync`, `/opsx:archive` where available, but verify actual generated files and compare against immutable base. Do not invent or rely on unsupported CLI flags. `openspec validate --all --strict --no-interactive` remains required for changed source/specs and must validate the post-archive layout. Existing stable GitHub status-check names remain unchanged. A spec-only proposal is classified as spec-only in CI; governance implementation triggers full checks.

## Security boundaries and regressions

- Approval PR must have been merged by `hectoresen` before the implementation PR was opened; archived filenames cannot substitute for evidence of owner approval.
- Archive only the exact change named in the PR metadata and approved spec. No blanket `openspec/changes/archive/**` escape in `sdd-scope.json`.
- Source of truth is the immutable base commit; no archive file may silently change accepted proposal/design/SHALL wording/source license/scope.
- The special `lifecycle` phase for legacy repair stays unchanged, including fixed approval #13 and archived byte-for-byte requirements.
- Negative tests cover: owner-unapproved change, two changes archived at once, wrong date/ID, missing preserved file, mismatched immutable artifact, incomplete `tasks.md`, unsynchronized canonical capability, unrelated canonical edits, false archive metadata, missing evidence and attempted special-governance bypass.
- Ensure CLI archive implementation writes files safely, preserves history and does not perform merge or change main.
- Inspect branch diff and re-run documentation skill after any review changes.

## Governance rollout

This governance proposal only authorizes implementation policy/script/documentation edits in a second owner-approved PR. It does not retroactively archive older changes. Owner must review the new validator's safety tests before merge. Existing implementation branches created before the policy rollout may follow their original approved scope, but any post-rollout archived implementation must pass the new atomic archive validation.
