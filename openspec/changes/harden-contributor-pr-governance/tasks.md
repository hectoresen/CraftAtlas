# Implementation tasks — harden contributor PR governance

## Approval
- [x] A1 Owner reviews/merges spec-only PR.
- [x] A2 Create implementation branch from approved main; leave approved design, specs and scope unchanged.

## Owner GitHub Settings (manual administrative actions)
- [ ] B1 Verify current `main protect` ruleset targeting and list actual collaborator permissions.
- [x] B2 Set a PR-review ruleset on `main`: one independent approval, stale-dismissal, resolved conversations and owner/admin **For pull requests only** review bypass (if supported); verify no direct pushes become allowed.
- [ ] B3 Set a second technical-checks ruleset on `main` without bypass, requiring stable CI/SDD/Lua check contexts only after those jobs exist and pass.
- [ ] B4 Confirm external contributors lack merge-capable permissions; optionally enable GitHub auto-merge in repository settings for owner's eligible PRs.
- [ ] B5 Test contributor versus owner PR merge eligibility and record results; do not claim effective protection until confirmed.

## CI hardening
- [x] C1 Inventory baseline CI/SDD/Lua failures and justify exact new required check contexts.
- [x] C2 Add Lua 5.1 syntax compilation and deterministic domain/UI Lua execution with regression fixtures and documented reproducibility.
- [x] C3 Fix baseline Lua fixture failures before promoting to required checks; keep Python/catalog/license/packaging checks as strict as existing release gate.
- [x] C4 Strengthen documentation/agent attestation validator, including meaningful README synchronization or explicit no-change rationale.
- [x] C5 Add workflow security/path/permissions tests and verify fork PR event safety.
- [x] C6 Keep OpenSpec/SDD approval workflow intact, avoid check-name churn and prevent unauthorized release automation.

## Agents and contributor documentation
- [x] D1 Update AGENTS, CONTRIBUTING, agent workflow and documentation protocol to require explicit documentation-sync execution before functional PR creation or updates.
- [x] D2 Clarify responsibilities for README current features, docs technical/evidence, CHANGELOG releases, OpenSpec tasks and approval/archival lifecycle.
- [x] D3 Add CODEOWNERS for governance and core code where useful; document limitations with owner-authored PRs.
- [x] D4 Document exact GitHub Settings click-by-click checklist and what was/was not applied.

## Validation and owner handoff
- [x] E1 Execute documentation-sync in four audit roles, update affected docs, identify unchanged docs and reasons.
- [x] E2 Run local available Python/Lua checks, review GitHub CI & SDD results and report Forever NOT RUN if no game changes need testing.
- [x] E3 Validate implementation diff against frozen scope and open ONE implementation PR with real approval metadata; never merge without owner direction.
- [ ] E4 Report proof of actual GitHub Settings enforcement separately from merged files, and request owner verification.

## Implementation evidence snapshot (2026-11-16; subject to CI verification)

- Spec PR #41 was merged by the repository owner. Implementation branch created separately from current `main`; approved proposal/design/delta specs/scope unchanged.
- Owner-configured review ruleset `27376786` and no-bypass technical checks ruleset `27371162` were read and verified via GitHub API before implementation. The two-author merge-eligibility test matrix and independent verification of collaborator permissions **NOT RUN**; the Lua check contexts cannot be made mandatory until they exist on `main`.
- CI now defines `lua-compatibility` (explicit Lua 5.1 parser, all addon/test Lua files), `lua-regressions` (all isolated Lua fixtures, no silent exclusions), and Python workflow-security regression tests; existing `repository-validation` and `traceability` retained. Previously `tests/test_addon.lua` was Markdown; replaced with a real 5.1 smoke fixture. CI exposed further stale fixtures in tests/test_item_info.lua (missing verified-reagent guard), tests/test_recipe_cards.lua (missing native mock SetAllPoints) and tests/test_release_version.lua (assertion counted only the metadata helper calls): all were corrected without changing addon runtime behavior. The final Lua 5.1 regression suite passed in GitHub Actions.
- Governance policy exception is restricted to the exact owner-approved `harden-contributor-pr-governance` change and explicitly scoped root `CODEOWNERS`/`AGENTS.md`. README reviewed against source and unchanged because addon gameplay behavior did not change. `docs/ARCHITECTURE.md`, `DATA_MODEL.md` and `INSTALLATION.md` reviewed and unchanged for the same reason; current technical updates in DEVELOPMENT, TESTING, GITHUB_SETTINGS, CODE_QUALITY, DOCUMENTATION_PROTOCOL and SDD_COMPLIANCE. CHANGELOG and ROADMAP updated with unreleased policy improvements.
- The four canonical documentation-sync audits completed serially: current feature reality (README vs production paths); technical architecture and installed-data provenance (unchanged); QA and empirical limits (TESTING); milestones/acceptance (CHANGELOG, ROADMAP, OpenSpec tasks). No real WoW gameplay changes; Forever client tests **NOT RUN**, not claimed required for governance.
- Local cloned checkout, Python/unittest, standalone Lua 5.1, bash release gate and OpenSpec CLI **NOT RUN** in connector-only environment; GitHub PR workflows will provide actual CI/SDD validation. No merge, settings modification, release or archive performed by the agent.

## Verified GitHub Actions evidence (2026-11-16)

- Commit `b87b10f54161758033494241a1dfd23c8d7cd8bc` on PR #42: `classify-pr`, `repository-validation`, `lua-compatibility`, `lua-regressions` and `traceability` each **PASS** in GitHub Actions. Source code did not change; isolated Lua fixture/mock failures were corrected without suppressing tests.
- User-requested cost optimization: `.github/workflows/ci.yml` now identifies **spec-only**, **Markdown/text-only** and **code/mixed** diffs; it retains a minimal fail-closed `repository-validation` required check on spec-only PRs, runs lightweight Markdown validation for docs-only PRs, and executes full Python/release plus Lua checks only on code/mixed changes. `spec-compliance.yml` skips OpenSpec Node/npm installation on docs-only PRs but retains SDD provenance. Tests in `tests/test_ci_governance.py` guard both fast paths. Future real spec-only/doc-only PRs should verify the skip behavior; those independent PR scenarios are **NOT RUN** in this implementation branch.
- Remaining manual owner tasks: verify collaborator permissions and contributor/owner two-account behavior, then add `lua-compatibility` and `lua-regressions` to no-bypass `main — mandatory CI` after implementation merge and live checks. The agent did not change repository settings or merge.
