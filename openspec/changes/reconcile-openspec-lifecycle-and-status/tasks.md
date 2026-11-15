# Lifecycle reconciliation tasks

## A. Owner approval
- [ ] A1 Review and merge this spec-only proposal PR as @hectoresen.
- [ ] A2 Confirm original spec SHOULD/SHALL exceptions explicitly when required (not inferred from client smoke tests).

## B. Implement safe lifecycle validation (separate implementation PR)
- [ ] B1 Add owner-approved, allowlisted lifecycle phase with approval PR linkage and distinct allowed path rules.
- [ ] B2 Reject changed historical proposal/design/delta specs, incomplete archives, unauthorized scope, unverified closure and wrong owner.
- [ ] B3 Add regression tests for old proposal/implementation behavior and new lifecycle cases.
- [ ] B4 Update docs/SDD_COMPLIANCE.md and run SDD tests/CI.
- [ ] B5 Open implementation PR, pass checks and wait for owner merge.

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
