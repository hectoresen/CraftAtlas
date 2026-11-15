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
7. Re-run the documentation skill after functional review revisions and address reviewer feedback. **Only @hectoresen authorizes merges, tags and releases.** Contributors and agents may not merge or push directly to `main`.

For functional changes, use the two-PR OpenSpec process in docs/SDD_COMPLIANCE.md. The first PR has exactly these lines:

- OpenSpec-Change: your-change-id
- OpenSpec-Phase: proposal

After that specification PR is merged by @hectoresen, the implementation PR declares:

- OpenSpec-Change: your-change-id
- OpenSpec-Phase: implementation
- OpenSpec-Approval-PR: 123 (the actual merged specification PR number)

The spec PR includes an sdd-scope.json file listing explicitly allowed implementation paths. The implementation PR may update tasks.md but must not rewrite the approved proposal, design, specs or scope.

A tiny documentation-only or maintenance PR may use OpenSpec-Exemption: docs-only or OpenSpec-Exemption: maintenance only when eligible, subject to CI and maintainer review. All changes still use a PR. Follow Conventional Commits.

## Data licensing

Do not copy databases from third-party addons or sites without permission to redistribute. Include source, license, retrieval date, client version and verification technique for imported data. Unknown mappings remain unknown.

## Conduct

Be considerate and constructive. See `CODE_OF_CONDUCT.md` and `SECURITY.md`.
