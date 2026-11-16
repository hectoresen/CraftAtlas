# Design: contributor protections, reliable CI and agent documentation protocol

## Permissions and GitHub rulesets

The repository is a **user-owned** GitHub repository (`hectoresen/CraftAtlas`), not an organization team repository. The `main protect` ruleset (ID `27371162`) is active but currently lacks a PR requirement, approval threshold and required checks, and its API `ref_name.include` is empty. The branch-protection endpoint returns `403 Resource not accessible by integration`; treat it as unreadable, not absent.

The owner must open `Settings → Rules → Rulesets` and explicitly target `refs/heads/main`. Recommended:
1. **main — review gate:** `Require a pull request before merging`; required approving reviews = 1; dismiss stale reviews; conversation resolution. Grant bypass **only** to the owner/admin role on this review ruleset. Confirm the actual GitHub personal-repository bypass UI; if admins besides owner exist, role-based bypass affects them too. The author cannot approve their own PR, including an owner.
2. **main — mandatory checks:** `Require status checks to pass` for exact check-run names after new CI is merged, including the existing `repository-validation` and `traceability`, plus dedicated `lua-compatibility` and `lua-regressions` if implemented as distinct jobs. Also prevent deletion/force-push, and require PR branch freshness if supported. Set **no bypass** on this checks rule to ensure owner and contributors both run CI.
3. **Repo settings:** check `Allow auto-merge` if desired; keep external contributors without merge-capable rights where owner-only merge authority is desired. Do not enable auto-merge for contributor PRs via automation.
4. Use `.github/CODEOWNERS` for governance/workflows and optional broader owner review, but explicitly distinguish review request from security enforcement. An owner-authored PR cannot be self-approved even if CODEOWNERS requires owner review, so the review-rule bypass is still necessary.
5. Add `docs/GITHUB_SETTINGS.md` precise setup/checklist and an explicit verification matrix using two test PRs (one contributor-authored, one owner-authored). Observe actual required checks and review/bypass behavior on each; record enforcement as pending until Settings applied. Do not assert owner-only final merge if collaborators retain write/maintain permissions.

No action in this project can silently modify GitHub Settings through the current connector. User must act in the Settings UI.

**SDD validator constraint (confirmed in main):** `scripts/validate_sdd.py` currently accepts modification of `AGENTS.md` only for the historical change ID `mandatory-multiagent-documentation-gate`, and permits only explicitly scoped `.github/workflows/*.yml` files under `.github/`. The approved implementation MUST extend this validator with a **narrow, exact change-ID and path allowlist** for `harden-contributor-pr-governance`, covering `AGENTS.md` and `.github/CODEOWNERS`, without weakening the existing safeguards. Add negative tests proving unrelated PRs remain rejected. The owner must review this exception as part of this specification and the subsequent implementation PR.


## CI layout and fail-closed validation

Existing `.github/workflows/ci.yml` runs `repository-validation`: shared release-readiness script and the PR documentation validator. `.github/workflows/spec-compliance.yml` runs `traceability`, including Python validator tests, approved-spec PR provenance and OpenSpec CLI strict validation.

Add separate, stable and mandatory-ready jobs (names verified in GitHub UI):
- **Lua 5.1 compatibility:** `luac5.1 -p` for each tracked addon and relevant Lua test module; no Retail-only APIs assumed. Confirm environment installs Lua 5.1 explicitly; avoid relying on a rolling default Lua interpreter.
- **Lua regressions:** run all appropriate `tests/test_*.lua` with a compatible `lua5.1` interpreter, using isolated process invocations. First reproduce known baseline failures and repair test harness/mock assumptions with justified code/spec scope; never silently exclude failing tests. If a test cannot be supported on Lua 5.1, record a transparent exception and block mandatory promotion until resolved.
- **Python/data/release:** retain `scripts/validate_release_checks.sh` shared between PR and release; preserve deterministic generated-data verification, package installability, dataset license checks, PR documentation and SDD verification. Run dedicated tests for new release, doc and governance gates, not just matching filename patterns.
- **Static/security policy:** read-only PR events, shell `set -euo pipefail` where applicable, explicit `permissions: contents: read` (and `pull-requests: read` only where required), avoid `pull_request_target` for untrusted branches, no GitHub PAT/secrets, no unsolicited auto-merge or rule changes.
- **Coverage:** source/fixture tests for material lookup, recipe search/pagination, cache invalidation, progress, native UI mock, enUS/esES, tooltip idempotence and generated catalogs. Prefer simple deterministic assertions rather than flaky end-to-end client claims.
- **No fake green:** if Lua tests fail, the PR remains red. Do not remove a test or mark it `NOT RUN` while requiring a green job. Fix code/fixtures or explicitly hold the implementation PR for owner review.

A spec-only PR (only new `openspec/changes/<id>/` files) should pass schema/SDD and the ordinary CI without relying on a user-visible changelog update. Workflow changes must be scoped by an approved `sdd-scope.json` and reviewed.

## Documentation and agent enforcement

Edit `AGENTS.md`, `CONTRIBUTING.md`, `docs/DOCUMENTATION_PROTOCOL.md`, `docs/AGENT_WORKFLOW.md`, `skills/documentation-sync/SKILL.md` and relevant adapter guidance if present, to state:
- **Before opening or updating every functional PR:** read the exact canonical skill file; execute sequential four-auditor checklist if no subagents; update README and appropriate technical docs based on code; update changelog, roadmap and OpenSpec tasks truthfully; run checks; include evidence.
- **Not-applicable attestation:** allowed only when the PR genuinely has no user-facing documentation impact, with specific changed-source paths and documentation pages reviewed; Python validation rejects token explanations like "N/A" or "docs fine".
- **Never edit AGENTS to embed feature changelogs:** its role is protocol. Every functional feature is documented in README; technical design in docs; acceptance claims in TESTING, not mere green CI.
- **PR metadata and actual results:** `Documentation-Review: updated|not-applicable`, substantive `Documentation-Evidence`, OpenSpec approval metadata and evidence for client testing `PASS/FAIL/NOT RUN`; owner controls release/tag and merge.
- **CI validates artifact evidence, not agents' private behavior.** A bot cannot prove a human/agent read a skill; instead validate expected file changes, PR statement quality and test output, with transparent limits.

## Quality tests and acceptance

- Python fixtures for contributor PR missing approval claim, owner authored PR bypass-versus-required checks narrative, required status contexts, PR metadata/skill obligation and path-changing documentation behavior.
- Workflow static tests: `pull_request` trigger, pinned Lua version, subprocess exit propagation, no unsafe `pull_request_target` or secret exposure, SDD/release-readiness retained, release workflow actor protection unchanged.
- Owner-only manual GitHub UI test: inspect ruleset applies to `main`; open contributor PR without approval (blocked), approve with separate authorized account (merge eligibility only if checks green), owner-authored PR has review bypass but checks required, verify stale approvals after new push, verify admin merge expectations. Do not fake UI observations.
- Report GitHub plan-dependent feature limitations, admin actions NOT APPLIED, and pre-existing failing Lua fixtures until fixed.

## Rollback

Revert implementation PR to restore prior workflows/docs. Ruleset changes are separate owner-admin operations; export/screenshot their configurations before changing and revert manually in GitHub UI if needed. Never weaken release authentication, tokens or default-branch protection to make checks green.
