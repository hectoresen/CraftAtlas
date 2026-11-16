# Tasks — standardize spec IDs and branch names

## A. Governance approval
- [ ] A1 Owner reviews and merges this spec-only PR, which uses the currently valid legacy ID as its bootstrap exception.
- [ ] A2 Start a separate implementation branch from the owner-merged `main`; reference real approval PR number and respect frozen `sdd-scope.json`.

## B. SDD and naming enforcement
- [ ] B1 Add pure typed-ID parsing and proposal/implementation branch mapping helpers in `scripts/validate_sdd.py`.
- [ ] B2 Define precise `FEAT/FIX/CHORE/UPD/DEL` semantics, 3+ digit per-type monotonic allocation, collision prevention and immutable post-approval identity.
- [ ] B3 Use actual PR head/base metadata; enforce new-style proposals and implementations without trusting PR body claims or weakening approved-scope/owner-merge checks.
- [ ] B4 Implement explicit backward-compatible grandfathering using a stable rollout boundary for already-approved specs and already-open PRs; preserve historical archives and lifecycle mode.
- [ ] B5 Add positive and adversarial regressions for format, case, branch mismatches, duplicate sequence, collisions, concurrent proposals, legacy compatibility, and archive provenance.
- [ ] B6 Preserve existing `repository-validation`, `traceability`, Lua checks and spec-only CI fast path.

## C. Agent and contributor documentation
- [ ] C1 Update `AGENTS.md`, `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md`, `docs/SDD_COMPLIANCE.md` and `docs/DEVELOPMENT.md` with exact branch/ID mapping and type definitions.
- [ ] C2 Make `skills/documentation-sync/SKILL.md` audit and re-check ID/branch identity before PRs and after relevant revisions.
- [ ] C3 Document legacy exceptions, migration boundary, collision handling and examples without renaming historical specs or modifying protected `openspec/README.md`.
- [ ] C4 Review README, TESTING, ROADMAP, CHANGELOG and OPENSPEC_STATUS; update only where warranted by the governance-only implementation.

## D. Verification and owner handoff
- [ ] D1 Run SDD/Python regressions, strict OpenSpec CLI, CI and release readiness; report actual pass/fail/not-run results.
- [ ] D2 Exercise proposal, implementation, prepared/blocked archive paths with new typed IDs and existing legacy examples.
- [ ] D3 Run mandatory four-role documentation sync, then open the implementation PR with real approval and archive metadata.
- [ ] D4 Do not merge anything or archive incomplete historical changes without owner direction.
