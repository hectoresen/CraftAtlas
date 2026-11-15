# Lifecycle reconciliation tasks

## A. Owner approval
- [x] A1 Spec PR #13 was owner-merged on 2026-11-15.
- [ ] A2 Confirm original spec SHOULD/SHALL exceptions explicitly when required (not inferred from client smoke tests).

## B. Implement safe lifecycle validation (separate implementation PR)
- [x] B1 Implemented restricted lifecycle phase with exact PR #13 owner approval and fixed allowed paths.
- [x] B2 Added immutable historical artifact checks, archive-source exact copy checks, scope and owner approval validation; acceptance ledger remains required and semantic review remains human.
- [x] B3 Added new lifecycle, archive, owner, canonical scope, stale-context and ordinary PR regression cases; CI execution pending.
- [ ] B4 Updated docs/SDD_COMPLIANCE.md; CI/tests must pass on implementation PR before checking complete.
- [ ] B5 Governance implementation PR to be opened; owner merge required.

## C. Reconcile records (separate lifecycle PR after B)
- [ ] C1 Update AGENTS.md and openspec/config.yaml to current dev reality.
- [ ] C2 Create evidence ledger for PRs #3–#12, code, user-reported client test and absent exact-build evidence.
- [ ] C3 Update tasks for all three existing changes, checking only substantiated work and recording explicit unresolved gates.
- [ ] C4 Sync implemented/accepted requirements to canonical openspec/specs with OpenSpec CLI.
- [ ] C5 Archive fully accepted changes only with full traceability; keep unaccepted catalog/live-origin obligations tracked.
- [ ] C6 Validate OpenSpec, CI, docs and generator drift; record executed and not-run checks.
- [ ] C7 Open lifecycle PR for owner review and merge; no direct main edits.

## D. Remaining acceptance
- [ ] D1 Record exact Forever build and per-origin hover tests if broad compatibility is to be claimed.
- [ ] D2 Obtain/reconcile current licensed data or approve narrowed coverage before full catalog claims.
