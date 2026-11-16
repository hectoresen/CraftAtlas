# Contributing to CraftAtlas

**Everyone is welcome to submit issues, discussions and pull requests.** The project is MIT-licensed. Code, documentation, issues and PRs use English as the shared development language; addon translations cover English and Spanish.

## Start here

Read `README.md`, `AGENTS.md`, `docs/AGENT_WORKFLOW.md`, `docs/CODE_QUALITY.md`, `docs/DEVELOPMENT.md`, `docs/ARCHITECTURE.md` and existing OpenSpec specs/changes. Check existing issues/PRs before proposing duplicate work.

## Contribution process

1. Create a fork/branch from current `main`, e.g. `feat/<topic>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
2. For any new behavior, material schema, game compatibility or nontrivial refactor, first use `/opsx:propose` and present proposal/specs/design/tasks to **@hectoresen**. **Wait for approval before implementing**.
3. Implement only approved tasks following Clean Code rules in `docs/CODE_QUALITY.md`. Document every new data source and license.
4. Run `python3 scripts/validate_repo.py`, all relevant Lua tests and lint introduced with implementation, and actual Forever client smoke tests for game-facing changes. Clearly report *not run* tests.
5. **Before opening the PR, explicitly read and execute `skills/documentation-sync/SKILL.md`.** Compare source and accepted spec with README current features, relevant technical docs, changelog, tests and evidence. Update affected documentation; leave `AGENTS.md` as agent instructions only. Follow `docs/DOCUMENTATION_PROTOCOL.md` and include `Documentation-Review: updated|not-applicable` plus a substantive `Documentation-Evidence: ...` declaration for functional PRs.
6. Open a PR with rationale, OpenSpec change ID, tests/results, Forever build, screenshots where appropriate, risks and rollback.
7. Re-run the documentation skill after functional review revisions and address reviewer feedback. **@hectoresen must approve contributor PRs with a GitHub APPROVED review.** Contributors with merge permission may then merge after all required checks pass. Only @hectoresen may create tags and publish releases; never push directly to `main`.

For functional changes, use the two-PR OpenSpec process in docs/SDD_COMPLIANCE.md. The first PR has exactly these lines:

- OpenSpec-Change: your-change-id
- OpenSpec-Phase: proposal

After that specification PR is approved by @hectoresen and merged by an authorized contributor or the owner, the implementation PR declares:

- OpenSpec-Change: your-change-id
- OpenSpec-Phase: implementation
- OpenSpec-Approval-PR: 123 (the actual merged specification PR number)

The spec PR includes an sdd-scope.json file listing explicitly allowed implementation paths. The implementation PR may update tasks.md but must not rewrite the approved proposal, design, specs or scope.

A tiny documentation-only or maintenance PR may use OpenSpec-Exemption: docs-only or OpenSpec-Exemption: maintenance only when eligible, subject to CI and maintainer review. All changes still use a PR. Follow Conventional Commits.

## Review and merge requirements

The default branch is covered by independent GitHub rulesets: contributors need an APPROVED review from @hectoresen as code owner, stale approvals are dismissed after new commits, conversations must be resolved, and every PR must pass mandatory CI/SDD checks. The repository owner may use the **PR-only admin bypass for review**, not for technical validation. No contributor may approve their own PR. A GitHub auto-merge toggle, if enabled, does not waive review/check rules or give contributors merge rights. See `docs/GITHUB_SETTINGS.md`.

Every code PR must pass Lua 5.1 syntax and isolated Lua regression jobs as well as Python/documentation, OpenSpec/SDD and release-readiness validation. Existing test failures are blocking work, never an excuse to remove tests. Run the canonical documentation-sync skill again after review revisions and state exactly what was tested; real WoW Forever tests remain distinct from CI.

## Data licensing

Do not copy databases from third-party addons or sites without permission to redistribute. Include source, license, retrieval date, client version and verification technique for imported data. Unknown mappings remain unknown.

## Conduct

Be considerate and constructive. See `CODE_OF_CONDUCT.md` and `SECURITY.md`.

## Same-PR OpenSpec archive protocol

For approved implementation PRs, the contributor must run the documentation-sync skill and report whether the accepted spec is eligible for an **atomic archive in this PR**. Use `OpenSpec-Archive: prepared` with code/test evidence and synchronized canonical capability specs only when every mandatory acceptance criterion is evidenced. Prepare the dated archive before PR review; preserve owner-approved artifacts byte-for-byte. Otherwise use `OpenSpec-Archive: blocked`, name the exact `NOT RUN` or missing client check, leave the active change folder and tasks truthful. A blocked implementation may require additional testing or a separately approved spec revision before the owner may accept it. Neither the author nor CI can substitute offline tests for Forever client proof.

## Branch and spec identity convention

For new proposals, use `feat001-improve-materials-menu` as the lowercase OpenSpec change directory/PR identifier and `SPEC/FEAT001-improve-materials-menu` as its proposal branch. After the owner merges the proposal, implement from `FEAT/001-improve-materials-menu`. Allowed types: `FEAT`, `FIX`, `CHORE`, `UPD`, `DEL`; allocate the next free type-local three-digit number after checking active/archived specs and open PRs. The official OpenSpec CLI accepts lowercase change IDs only. Existing approved change IDs are grandfathered; never rename owner-approved specs to satisfy new naming.

After opening or updating a PR, inspect the **latest head SHA** check-runs and confirm all four mandatory contexts exist. A present skipped Lua job is acceptable for a spec-only PR; a missing check stuck at `Expected` is not. If contexts are absent, do **one safe PR body edit** through the connected GitHub integration, preserve original metadata, and re-query. If still absent/failed, mark the PR blocked and give the owner exact context names. Check creation and passing are separate requirements, and GitHub's review rule is independent.


## Mandatory owner review (approved governance spec #58)

Every contributor-authored PR needs an actual APPROVED review from @hectoresen and green required checks before anyone with merge rights merges it. The author and merger may be contributors. A specification PR merged by a contributor remains valid approval evidence if the owner reviewed it before merge; do not duplicate proposals because of merger identity (legacy #44 is one such reviewed PR). Owner-authored PRs use the existing review-only admin bypass, never a technical CI bypass. CODEOWNERS must be enforced by the main review ruleset; being listed as a reviewer is not enforcement. Releases remain owner-only.
