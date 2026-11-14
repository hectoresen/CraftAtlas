# Contributing to CraftAtlas

**Everyone is welcome to submit issues, discussions and pull requests.** The project is MIT-licensed. Code, documentation, issues and PRs use English as the shared development language; addon translations cover English and Spanish.

## Start here

Read `README.md`, `AGENTS.md`, `docs/AGENT_WORKFLOW.md`, `docs/CODE_QUALITY.md`, `docs/DEVELOPMENT.md`, `docs/ARCHITECTURE.md` and existing OpenSpec specs/changes. Check existing issues/PRs before proposing duplicate work.

## Contribution process

1. Create a fork/branch from current `main`, e.g. `feat/<topic>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
2. For any new behavior, material schema, game compatibility or nontrivial refactor, first use `/opsx:propose` and present proposal/specs/design/tasks to **@hectoresen**. **Wait for approval before implementing**.
3. Implement only approved tasks following Clean Code rules in `docs/CODE_QUALITY.md`. Document every new data source and license.
4. Run `python3 scripts/validate_repo.py`, all relevant Lua tests and lint introduced with implementation, and actual Forever client smoke tests for game-facing changes. Clearly report *not run* tests.
5. Update both locales, architecture, specs, changelog and roadmap as relevant. Synchronize accepted OpenSpec changes.
6. Open a PR with rationale, OpenSpec change ID, tests/results, Forever build, screenshots where appropriate, risks and rollback.
7. Address review feedback. **Only @hectoresen authorizes merges, tags and releases.** Contributors and agents may not merge or push directly to `main`.

Tiny documentation-only/typo changes can skip OpenSpec when the PR states why. A PR is still expected. Follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).

## Data licensing

Do not copy databases from third-party addons or sites without permission to redistribute. Include source, license, retrieval date, client version and verification technique for imported data. Unknown mappings remain unknown.

## Conduct

Be considerate and constructive. See `CODE_OF_CONDUCT.md` and `SECURITY.md`.
