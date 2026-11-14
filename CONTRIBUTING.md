# Contributing to CraftAtlas

Everyone may open issues, suggest improvements, fork and submit Pull Requests. English is the working language for code, documentation, commit messages and PRs; the addon supports Spanish and English.

## Before starting

Read `README.md`, `AGENTS.md`, `docs/DEVELOPMENT.md`, `docs/ARCHITECTURE.md`, and the appropriate OpenSpec specs. Discuss major behavior or design changes in an issue. Check existing PRs to avoid duplicate work.

## Workflow

1. Fork/branch from up-to-date `main`; use `feat/<topic>`, `fix/<topic>`, `docs/<topic>` or `chore/<topic>`.
2. For behavior, compatibility and dataset changes, write an OpenSpec proposal with testable WHEN/THEN scenarios; get maintainer approval before coding.
3. Implement minimal well-scoped changes; add/update automated tests, both locales, docs and changelog as relevant.
4. Run `python3 scripts/validate_repo.py`, plus any Lua tests and static checks introduced by the relevant change.
5. For client integrations, run `docs/TESTING.md` in World of Warcraft: Forever and report version, observations and errors. Do not mark unrun tests as passing.
6. Open a PR with problem, spec/change ID, solution, tests, source licensing/provenance and screenshots where UX changes.
7. Resolve review comments. Maintainers merge; contributors/agents never self-merge without explicit permission.

Conventional Commits recommended: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`. Breaking changes require documentation and version planning. Keep each PR focused.

## Third-party data and rights

Source code is MIT; external recipe or profession datasets may have other terms. Do not copy third-party addon databases or scrape proprietary sources without documented redistribution rights. Record original source, retrieval date, license and verification approach for each dataset.

## Community expectations

Be respectful and constructive. See `CODE_OF_CONDUCT.md` and `SECURITY.md`.
