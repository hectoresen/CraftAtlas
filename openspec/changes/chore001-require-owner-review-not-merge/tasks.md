# Tasks

- [x] Implement owner-review verification in `scripts/validate_sdd.py`, removing the owner-only merger check.
- [x] Add regression tests for owner-approved contributor merges, missing/dismissed/retracted owner approval, forged metadata and owner-authored PRs.
- [x] Preserve frozen OpenSpec scope, chronology, branch identity, archive and mandatory CI gates.
- [x] Update AGENTS.md, CONTRIBUTING.md and docs/SDD_COMPLIANCE.md / docs/AGENT_WORKFLOW.md / docs/GITHUB_SETTINGS.md to explain roles and the owner-authored exception.
- [ ] Verify owner CODEOWNERS rule is enabled in GitHub, without granting CI bypass.
- [ ] Assess legacy #44 against actual owner review evidence and document #57 disposition.
- [ ] Run Python SDD tests, strict OpenSpec validation and required GitHub checks.
