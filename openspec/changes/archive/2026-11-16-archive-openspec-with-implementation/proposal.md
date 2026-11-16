# Proposal: Archive accepted OpenSpec in the implementation PR

## Why

CraftAtlas's current two-PR SDD contract requires an owner-merged proposal followed by an implementation PR, but `openspec/README.md` schedules archive **after** acceptance and `scripts/validate_sdd.py` permits ordinary implementation PRs to update only their own `tasks.md`. As a consequence, completed implementations routinely leave active changes and require extra archival PRs. The evidence ledger `docs/OPENSPEC_STATUS.md` also identifies legacy changes with genuinely unverified acceptance gates; these must not be mass-archived for convenience.

## Goal

Make **sync + archive a transactional part of the implementation PR**, where it is justified by evidence. If the owner rejects or closes the PR, main retains the active change. If the owner merges it, implementation, canonical requirements, provenance ledger, and archived original artifacts enter main together. Keep the strict two-PR proposal/implementation approval process.

## Outcomes

- An implementation PR SHALL prepare its own accepted delta sync and archive before requesting merge, whenever every mandatory acceptance criterion has adequate evidence and owner acceptance can occur at merge.
- The standard implementation SDD validator SHALL accept a tightly defined **same-change** archive transformation without permitting edits of immutable approved proposal/design/delta/spec scope, unrelated changes, hidden policy files or undocumented canonical capability changes.
- The archival transaction SHALL be **all-or-nothing**: identical preserved historical artifacts in a dated archive, removal of the corresponding active directory, updated canonical specs and truthful status/evidence; neither silently deleting an active change nor duplicating a stale copy counts as archived.
- The documentation-sync skill SHALL be the mandatory pre-PR preparation gate for source, README, technical documentation, acceptance evidence, canonical spec sync, and archival status.
- A change with unmet mandatory tests/client acceptance SHALL remain active and explicit in the implementation PR. The reviewer SHALL be able to require missing evidence or a separately approved change of acceptance criteria; the agent SHALL NOT mark it accepted or archive it.
- Archived artifacts SHALL preserve provenance: a future change needs a fresh approved OpenSpec proposal; archival shall never retroactively broaden the current approval.
- Existing historical open changes and the restricted legacy lifecycle reconciliation SHALL remain untouched; no mass migration or cleanup is authorized by this proposal.
- For specs-only proposals, run SDD/OpenSpec checks, not Lua; keep existing cost-aware CI checks and owner-only release governance intact.

## Non-goals

No changes to Lua addon behavior, no code feature scope, no silent approval of untested Forever scenarios, no direct pushes/merges/releases, no GitHub ruleset modifications and no authorization for arbitrary OpenSpec archive/sync commands to rewrite unrelated history.

## Risk and mitigations

An automated archive can hide missing acceptance or rewrite approved requirements. Prevent via exact base-tree content equality, restricted canonical capability paths, provenance ledger and explicit evidence, and negative regression tests for unrelated or incomplete modifications. Pure CI cannot assess gameplay or human acceptance; retain owner review at merge. Conflicting canonical specs must fail and require a new owner-approved spec decision.

## Delivery

1. **Spec-only PR:** this folder only. Owner reviews/merges it into main before any implementation.
2. **Governance implementation PR:** update validator/tests and agent documentation within this spec's approved manifest. Validate both accepted and blocked archive paths. This policy PR does **not** archive itself unless the new gate and acceptance evidence genuinely support doing so.
3. **Subsequent functional PRs:** under the new protocol, prepare the archive and canonical sync in the same implementation PR where evidence permits.

All status claims must distinguish `RUN`, `NOT RUN`, implemented source, and maintainer-verified in-game tests.
