# Proposal: Harden contributor PR governance and verification

## Why

CraftAtlas now accepts external contributors. The owner wants untrusted changes reviewed by a different person, all code pull requests checked before merge, and their own PRs mergeable without an impossible self-approval. Current repository evidence (2026-11-16):
- The active repository ruleset `main protect` (ID `27371162`) contains only `deletion` and `non_fast_forward` rules. It does **not** require pull requests, approvals or status checks. Its `ref_name.include` was empty in the API response; verify exact matching in Settings before claiming it protects `main`.
- The repository reports `allow_auto_merge: false`. GitHub does not permit a pull-request author to approve their own change.
- CI already runs `bash scripts/validate_release_checks.sh` and `validate_documentation.py`; SDD Compliance validates owner-merged OpenSpec traceability and strict OpenSpec. However, CI does not systematically run all Lua 5.1 tests or compile every Lua module.
- `AGENTS.md` and `skills/documentation-sync/SKILL.md` already make documentation synchronization mandatory, but existing validation is structural and agent instructions can be reinforced against silent no-op claims.

The GitHub connector can read the ruleset but lacks permission/action to modify repository administration. **Enforcement cannot be achieved by merging a workflow alone**. The owner must configure the rulesets and repository options in GitHub Settings.

## Outcomes

1. Only reviewed and checked external contributions can reach `main`.
2. The owner `hectoresen` may merge their own reviewed-by-self PR without a second account, **by bypassing only the review requirement**, not technical checks, using GitHub's supported repository-admin bypass role. Self-approval itself remains unavailable. Avoid representing a manual owner merge as an approving review.
3. Preserve owner control of the final merge/release; optional automatic merge for the owner only after mandatory checks complete, without auto-merging contributors.
4. Stronger pull-request quality checks for Lua 5.1, Python, data/generated-output consistency, documentation, OpenSpec provenance, localized UI and packaging; security checks with least privilege and no production tokens on fork PRs.
5. Explicit agent/contributor instructions and deterministic CI fail-closed tests so feature documentation and evidence are kept aligned without fabricated test claims.

## Planned governance configuration (requires owner Settings action)

Use **separate rulesets** for the protected `main` target:
- **Review ruleset:** require pull request + **one approving review** from a permitted reviewer; dismiss stale approvals after new commits; require resolved conversations. Configure admin/owner bypass for this ruleset only. GitHub cannot allow an author to self-approve. Verify whether the UI supports exactly this bypass role and target on this personal repository; do not silently substitute an actor exception that grants write access to arbitrary contributors.
- **Technical checks ruleset:** require status checks `repository-validation`, `traceability` and the new dedicated Lua checks with stable names; block deletion and force-pushes. **No bypass actors**, including the owner, so owner-authored PRs remain tested. Require the pull request branch to be up to date when practical. Use stable check context names that exactly match actual successful GitHub Actions results.
- Restrict write/maintain/admin permissions to trusted collaborators; external contributors should propose via forks or limited permissions. A GitHub review requirement alone **does not forbid a write-permission contributor from merging an already approved PR**, so do not promise literal owner-only merging without separately enforcing role permissions. No automatic merge for contributor PRs; do not add a bot that merges unreviewed PRs.
- Enable repository auto-merge if the owner wants the standard GitHub UI's `Enable auto-merge` option. This is an owner configuration and is **not required** for manually merging own PRs.
- If Settings does not allow review bypass limited to the owner while checks are mandatory, stop and present the limitation rather than weakening the policy.

Existing owner-only release workflow remains guarded by initiating and triggering actor and exact `main` SHA; no relaxing release security.

## Technical scope

- Add deterministic Lua 5.1 syntax + runnable test coverage in PR CI; investigate and fix pre-existing failing Lua tests instead of excluding them invisibly or weakening mandatory CI.
- Enhance Python repository tests, generated-data drift checks, source license and packaging regression checks; preserve the current release-readiness parity and SDD checks.
- Distinguish governance/spec-only, docs-only and implementation PRs; do not force user-facing README edits where no user-visible behavior changed. **But functional PRs must update README/changelog/affected docs or provide a substantive, verifiable no-change rationale**.
- Require consistent PR metadata: OpenSpec phase/approved spec, documentation attestation, tests actually run, Forever NOT RUN when applicable, rollback and requested owner decision.
- Optional `.github/CODEOWNERS` can request review from `@hectoresen` for workflows, agent protocol, scripts and core functionality; it cannot make a PR author approve their own work and does not replace ruleset enforcement.
- Never execute third-party PR code with privileged `pull_request_target` write tokens. Set minimum GitHub Actions permissions, avoid unreviewed external action code execution and pin/check tool versions where practical.
- Maintain native WoW Forever/Lua 5.1 compatibility. Do not change addons' feature semantics, licensed catalog or official release tags.

## Risks and limitations

- **Owner bypass:** admin role bypass may apply to more than one administrator. Document and audit the actual bypass role and collaborator permission list.
- **Review policy:** a strict one-approval rule without the owner bypass would block the owner's own PRs. Conversely, a broad bypass of all rules would allow unchecked owner changes; separate rulesets are mandatory.
- **Automation loopholes:** a normal GitHub auto-merge setting allows eligible users with sufficient permissions to enable it, not exclusively the owner by default. Keep contributor permissions limited; do not misrepresent repository-wide auto-merge as an owner-only gate.
- **Lua baseline:** previous development noted failures in several standalone Lua scripts even when Python CI succeeded; no new required Lua job until fixture failures are genuinely resolved or documented as explicit blockers.
- **Settings API availability:** cannot programmatically apply administrative rules using the current connector. Provide an exact owner action checklist with status NOT APPLIED until owner verifies.
- **Unverified controls:** the ruleset may not currently target `main` because of its empty include list. Verify through GitHub UI and/or effective-branch ruleset endpoint.

## Delivery

Follow the established two-PR SDD process: merge this spec-only PR after owner approval, then implement in a bounded second PR. The separate GitHub Settings steps can be performed by the owner after the new CI check names are live; make the technical checks required only after successful runs are visible. No changes to settings, main, merge or releases in the proposal PR.
