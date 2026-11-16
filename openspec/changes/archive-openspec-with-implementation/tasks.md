# Tasks — archive accepted OpenSpec in implementation PR

## A. Authorization
- [x] A1 Owner merges this **spec-only** PR before any governance implementation.
- [x] A2 Start a separate implementation branch from the new main and reference actual merged proposal PR.

## B. SDD lifecycle
- [x] B1 Add generic same-change archival transaction support to `scripts/validate_sdd.py`, preserving all legacy `lifecycle` checks.
- [x] B2 Validate immutable base-to-archive byte equality, complete file sets, correct dated destination, original removal, scope restrictions, approved capability sync and no unrelated edits.
- [x] B3 Introduce `OpenSpec-Archive: prepared|blocked` + evidence declaration, rejecting false prepared status; keep human semantic acceptance separate from CI structural checks.
- [x] B4 Add positive/negative Python fixtures for complete, incomplete, unrelated, altered, unauthorized and pending-evidence archive cases.

## C. Agent process
- [x] C1 Update `AGENTS.md`, `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md`, `docs/SDD_COMPLIANCE.md` and other approved agent guidance (leave `openspec/README.md` untouched under current SDD guard) to prepare sync/archive **before** opening implementation PR when eligible.
- [x] C2 Update `skills/documentation-sync/SKILL.md` and `docs/DOCUMENTATION_PROTOCOL.md` with evidence-to-task verification, archive eligibility and explicit non-archive blockers.
- [x] C3 Update README/CHANGELOG/ROADMAP/TESTING and status ledger **only as warranted**; leave incomplete historical changes OPEN.
- [x] C4 Keep updated docs compatible with Codex, Claude, Copilot and generic agents using the canonical skill file directly.

## D. Verification and owner handoff
- [ ] D1 Run SDD unit tests, documentation validator tests, release checks and strict OpenSpec; retain stable required GitHub status checks and cost-aware CI modes.
- [ ] D2 Execute the four documentation-sync audits and document each test as PASS/FAIL/NOT RUN; no unsupported client approval claims.
- [ ] D3 Open implementation PR referencing merged spec PR with exact archive status/evidence; never merge or publish without owner authorization.
- [x] D4 Demonstrate two sample implementation PR diffs in tests: one archives transactionally, one stays OPEN because acceptance is missing.

## Implementation evidence (pending PR checks)

- Original policy spec PR #45 merged by owner on main; distinct implementation branch created.
- SDD parser supports `prepared|blocked` archive status and immutable base comparisons; tests include lossless archived fixtures, missing/altered file rejection, wrong change/date, canonical spec restrictions and explicit blocked acceptance.
- Documentation-sync reviewed README against source: unchanged because no player-facing Lua/runtime behavior changed. The Architecture/Data Model/Installation documents also remain source-accurate; updates are in SDD_COMPLIANCE, AGENT_WORKFLOW, DOCUMENTATION_PROTOCOL, TESTING, DEVELOPMENT, CODE_QUALITY, ROADMAP, CHANGELOG, AGENTS, CONTRIBUTING and the skill itself.
- Real-client Forever testing NOT RUN (governance-only change). CLI/local validation NOT RUN before live GitHub Actions; do not claim acceptance or prepare archival transaction until tests pass.
