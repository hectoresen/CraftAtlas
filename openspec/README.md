# OpenSpec workflow

This project uses OpenSpec **spec-driven** schema. Canonical requirements reside in `openspec/specs/`; proposed changes live in `openspec/changes/<change-id>/`; accepted changes are synced and archived in `openspec/changes/archive/`.

1. Install the official CLI: `npm install -g @fission-ai/openspec@latest`.
2. If missing, initialize agent skills using `openspec init` (choose OpenCode), preserving existing config and specs.
3. Start a named change with OpenCode `/opsx:propose <name>` or official equivalent.
4. Review proposal, delta specs, design and tasks; **get maintainer approval before code changes**.
5. Implement via `/opsx:apply` or the official task workflow, with tests and docs.
6. Verify implementation, sync accepted deltas into canonical specs, archive the change after acceptance.
7. Submit a PR; maintainers alone decide on merging and releasing.

No specs exist yet: the first behavioral proposal will cover the v0.1.0 tooltip and data foundation. Do not manufacture claims of implemented behavior.

For small documentation-only or typo changes, a PR without OpenSpec is acceptable when explained.
