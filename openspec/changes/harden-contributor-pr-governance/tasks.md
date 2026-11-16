# Implementation tasks — harden contributor PR governance

## Approval
- [ ] A1 Owner reviews/merges spec-only PR.
- [ ] A2 Create implementation branch from approved main; leave approved design, specs and scope unchanged.

## Owner GitHub Settings (manual administrative actions)
- [ ] B1 Verify current `main protect` ruleset targeting and list actual collaborator permissions.
- [ ] B2 Set a PR-review ruleset on `main`: one independent approval, stale-dismissal, resolved conversations and owner/admin review-only bypass (if supported).
- [ ] B3 Set a second technical-checks ruleset on `main` without bypass, requiring stable CI/SDD/Lua check contexts only after those jobs exist and pass.
- [ ] B4 Confirm external contributors lack merge-capable permissions; optionally enable GitHub auto-merge in repository settings for owner's eligible PRs.
- [ ] B5 Test contributor versus owner PR merge eligibility and record results; do not claim effective protection until confirmed.

## CI hardening
- [ ] C1 Inventory baseline CI/SDD/Lua failures and justify exact new required check contexts.
- [ ] C2 Add Lua 5.1 syntax compilation and deterministic domain/UI Lua execution with regression fixtures and documented reproducibility.
- [ ] C3 Fix baseline Lua fixture failures before promoting to required checks; keep Python/catalog/license/packaging checks as strict as existing release gate.
- [ ] C4 Strengthen documentation/agent attestation validator, including meaningful README synchronization or explicit no-change rationale.
- [ ] C5 Add workflow security/path/permissions tests and verify fork PR event safety.
- [ ] C6 Keep OpenSpec/SDD approval workflow intact, avoid check-name churn and prevent unauthorized release automation.

## Agents and contributor documentation
- [ ] D1 Update AGENTS, CONTRIBUTING, agent workflow and documentation protocol to require explicit documentation-sync execution before functional PR creation or updates.
- [ ] D2 Clarify responsibilities for README current features, docs technical/evidence, CHANGELOG releases, OpenSpec tasks and approval/archival lifecycle.
- [ ] D3 Add CODEOWNERS for governance and core code where useful; document limitations with owner-authored PRs.
- [ ] D4 Document exact GitHub Settings click-by-click checklist and what was/was not applied.

## Validation and owner handoff
- [ ] E1 Execute documentation-sync in four audit roles, update affected docs, identify unchanged docs and reasons.
- [ ] E2 Run local available Python/Lua checks, review GitHub CI & SDD results and report Forever NOT RUN if no game changes need testing.
- [ ] E3 Validate implementation diff against frozen scope and open ONE implementation PR with real approval metadata; never merge without owner direction.
- [ ] E4 Report proof of actual GitHub Settings enforcement separately from merged files, and request owner verification.
