# Tasks — archive accepted OpenSpec in implementation PR

## A. Authorization
- [ ] A1 Owner merges this **spec-only** PR before any governance implementation.
- [ ] A2 Start a separate implementation branch from the new main and reference actual merged proposal PR.

## B. SDD lifecycle
- [ ] B1 Add generic same-change archival transaction support to `scripts/validate_sdd.py`, preserving all legacy `lifecycle` checks.
- [ ] B2 Validate immutable base-to-archive byte equality, complete file sets, correct dated destination, original removal, scope restrictions, approved capability sync and no unrelated edits.
- [ ] B3 Introduce `OpenSpec-Archive: prepared|blocked` + evidence declaration, rejecting false prepared status; keep human semantic acceptance separate from CI structural checks.
- [ ] B4 Add positive/negative Python fixtures for complete, incomplete, unrelated, altered, unauthorized and pending-evidence archive cases.

## C. Agent process
- [ ] C1 Update `AGENTS.md`, `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md`, `docs/SDD_COMPLIANCE.md` and other approved agent guidance (leave `openspec/README.md` untouched under current SDD guard) to prepare sync/archive **before** opening implementation PR when eligible.
- [ ] C2 Update `skills/documentation-sync/SKILL.md` and `docs/DOCUMENTATION_PROTOCOL.md` with evidence-to-task verification, archive eligibility and explicit non-archive blockers.
- [ ] C3 Update README/CHANGELOG/ROADMAP/TESTING and status ledger **only as warranted**; leave incomplete historical changes OPEN.
- [ ] C4 Keep updated docs compatible with Codex, Claude, Copilot and generic agents using the canonical skill file directly.

## D. Verification and owner handoff
- [ ] D1 Run SDD unit tests, documentation validator tests, release checks and strict OpenSpec; retain stable required GitHub status checks and cost-aware CI modes.
- [ ] D2 Execute the four documentation-sync audits and document each test as PASS/FAIL/NOT RUN; no unsupported client approval claims.
- [ ] D3 Open implementation PR referencing merged spec PR with exact archive status/evidence; never merge or publish without owner authorization.
- [ ] D4 Demonstrate two sample implementation PR diffs in tests: one archives transactionally, one stays OPEN because acceptance is missing.
