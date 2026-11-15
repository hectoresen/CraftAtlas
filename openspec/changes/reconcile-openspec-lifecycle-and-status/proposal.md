# Reconcile CraftAtlas OpenSpec lifecycle with accepted implementations

## Problem
CraftAtlas 0.1.0-dev is reported working in the Forever client and PRs #4, #6, #8 and subsequent fixes were merged by the owner. README and functional docs reflect the current runtime, but AGENTS.md and openspec/config.yaml still describe the initial non-playable scaffold. Three accepted change directories remain in openspec/changes/ with stale, incomplete task checklists; canonical openspec/specs/ is empty and none has been archived.

The current SDD validator allows only proposal or implementation PRs. It expressly forbids AGENTS.md from an implementation PR, forbids openspec/ in sdd-scope.json, and forbids changes to unrelated OpenSpec directories. This blocks ordinary OpenSpec sync/archive and governance updates. No change may bypass CI or misrepresent unverified catalog/source/client claims.

## Outcome
Establish a narrowly scoped, owner-approved, CI-enforced lifecycle procedure for:
1. maintaining governance onboarding docs consistent with the implemented addon;
2. recording honest acceptance evidence, explicitly incomplete checks and the exception to the originally required 30 live-verified materials;
3. synchronizing **accepted** capabilities into canonical openspec/specs/ and archiving only changes with documented acceptance or explicitly approved scope exceptions;
4. keeping partially verified expanded-catalog/live-origin claims open in a follow-up change rather than silently closing them.

## In scope
- Extend the existing SDD validation/test harness with an auditable owner-approved lifecycle path and strict, explicit allowlists; preserve existing two-PR governance for behavioral changes.
- Document that accepted runtime functionality and live-server catalog verification are distinct.
- Repair stale AGENTS.md, openspec/config.yaml, relevant agent workflow and OpenSpec lifecycle docs.
- Record decisions for three existing merged changes:
  - add-first-playable-material-tooltips (approved spec PR #3; implemented PR #4);
  - enhance-addon-icon-minimap-settings (approved spec PR #7; implemented PR #8; later fixes);
  - expand-all-profession-material-coverage (approved spec PR #5; implementation PR #6).
- Reconcile task checkboxes against concrete code/merged-PR/maintainer-client evidence without claiming unperformed command executions, specific client build, complete live dataset coverage or support for untested tooltip origins.
- Sync accepted requirements into canonical specs and archive eligible change folders with preserved artifacts and traceability. For each unmet requirement, either retain an open change or record a separately owner-approved explicit deferral without changing historical requirements.

## Out of scope
- New gameplay functions, search implementation, recipe UI, broader live catalog imports.
- Declaring a stable release or full server coverage.
- Altering past merged PRs, their approval history, existing historical proposal/spec requirements or QA results.
- Direct commits to main, disabling CI checks or unreviewed GitHub rule changes.

## Delivery and approvals
**Stage A (this PR):** proposal-only OpenSpec artifacts, no code or governance changes. Owner reviews and merges before implementation.

**Stage B (implementation PR after owner approval):** update scripts/validate_sdd.py, its tests and docs/SDD_COMPLIANCE.md to add the tightly scoped lifecycle policy. The existing validator can accept these paths via this proposal's approved sdd-scope.json. All checks must pass; owner merges.

**Stage C (separate lifecycle PR after Stage B):** with the new validator active, update governance onboarding, verified task statuses, canonical specs, and archives; attach a manifest of allowed source change IDs, target capability paths and archived artifacts. It requires approval PR linkage, specific allowed paths, same-owner approval and tests. Do not archive changes with unresolved SHALL gates unless explicit owner-approved exception/follow-up record is included.

## Risks and rollback
- **Audit loss:** copying/archiving must retain complete delta specs, history and source approvals. Test moves and compare content before/after.
- **Policy weakening:** new lifecycle validation must reject unrelated changes, changed historical acceptance text, arbitrary openspec paths and all unauthorized work; previous PR traceability remains intact.
- **Overclaiming:** distinguish user-reported working client runtime from exact build/per-origin test matrix and individual dataset relation verification.
- **CI hazards:** start by adding validator tests and keep implementation staged, so normal CI never needs a bypass.
- **Rollback:** revert the lifecycle implementation PR and/or reconciliation PR independently; their underlying historical spec artifacts remain retrievable from Git and archive paths.
