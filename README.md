# CraftAtlas

**CraftAtlas** is an open-source, MIT-licensed addon for **World of Warcraft: Forever** that helps players understand which professions use an item and, in future releases, how recipes and crafting dependencies connect.

> **Status: v0.0.0 — repository foundation only, not a playable addon.** The v0.1.0 code and client compatibility verification are pending.

## Planned functionality and versions

| Milestone | Planned scope |
| --- | --- |
| **0.0.0** | Agent/human collaboration framework, OpenSpec, documentation, CI and Lua folder scaffold |
| **0.1.0** | Tooltip profession identification by numeric itemID; multiple professions independent of character skills; local versioned catalog; settings panel; automatic enUS/esES detection and manual language selection; persisted preferences |
| **0.2.0** | Wider audited materials coverage, diagnostics, optimizations and UX improvements |
| **0.3.0** | Offline material search and profession filters |
| **0.4.0** | Recipes, ingredients, quantities and resulting crafted items |
| **0.5.0** | Reverse crafting/dependency explorer |
| **1.0.0** | Stable, documented and client-validated release |

No dates are promised. Data must not be presented as comprehensive unless coverage is audited. Full release gates: [Roadmap](docs/ROADMAP.md).

## New developer or AI agent: start here

1. Read [AGENTS.md](AGENTS.md), [CONTRIBUTING.md](CONTRIBUTING.md) and [Agent workflow](docs/AGENT_WORKFLOW.md).
2. Understand [Architecture](docs/ARCHITECTURE.md), [Code quality rules](docs/CODE_QUALITY.md), [Data model](docs/DATA_MODEL.md) and [Testing](docs/TESTING.md).
3. Inspect [OpenSpec workflow](openspec/README.md), accepted specs and outstanding changes before changing code.
4. Install OpenSpec (current npm package requires Node.js 22.12+), then initialize OpenCode skills where absent:

```sh
npm install -g @fission-ai/openspec@latest
openspec init
openspec list
python3 scripts/validate_repo.py
```

5. **Mandatory development workflow:** `/opsx:explore` (optional) → `/opsx:propose <change>` → **@hectoresen approval** → `/opsx:apply` → verify/tests → `/opsx:sync` → PR → owner review/merge → archive after acceptance. For documentation-only typo fixes, explain the OpenSpec exemption in the PR. Commands vary by coding agent; consult the initialization output.
6. **No agents or contributors may directly push to `main`, merge PRs or create releases without explicit owner authorization.** GitHub-side enforcement is pending ruleset configuration; see [GitHub governance](docs/GITHUB_SETTINGS.md).

## Repository layout

```text
addon/CraftAtlas/       WoW-installable Lua folder (currently stub, not functional)
  Core/                Bootstrap and lifecycle
  Domain/              Pure lookup logic
  Data/                Local offline catalog and future recipes
  Infrastructure/      WoW client API adapters and saved preferences
  Features/            Tooltip and settings presentation
  Localization/        enUS and esES
openspec/               Canonical specs, proposed changes and config
docs/                   Onboarding, code quality, architecture, testing, roadmap
scripts/                Repository and later dataset validation
tests/                  Future offline Lua tests
.github/                CI, CODEOWNERS and contributor templates
```

## Intended installation and support

See [Installation and real-client verification](docs/INSTALLATION.md). **Do not install v0.0.0 expecting tooltip features:** it is a foundation scaffold only. Final Forever interface metadata, supported hooks and full item dataset require verification before releasing v0.1.0.

## Engineering principles

- Lua runtime, minimal required dependencies, no telemetry or runtime network services.
- Numeric `itemID` for identification; never rely on localized item names or tooltip text.
- Pure domain logic distinct from game client APIs; simple modules, meaningful names, deterministic tests.
- Material → professions is many-to-many, unaffected by current character profession training.
- Unknown mapping stays unknown; externally sourced data needs provenance and compatible rights.
- enUS/esES with English fallback and saved manual override.
- Tests, manual in-game evidence, docs and specs accompany behavior changes.

## Collaboration

All contributors are welcome to fork and open PRs, but the repository owner **@hectoresen** retains the final merge/release decision. Review [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [SECURITY.md](SECURITY.md) and the [MIT License](LICENSE). The project is independent of Blizzard and Forever operators.

## Documentation index

[AGENTS](AGENTS.md) · [Agent workflow](docs/AGENT_WORKFLOW.md) · [OpenSpec](openspec/README.md) · [Development](docs/DEVELOPMENT.md) · [Clean Code](docs/CODE_QUALITY.md) · [Architecture](docs/ARCHITECTURE.md) · [Data model](docs/DATA_MODEL.md) · [Tests](docs/TESTING.md) · [Installation](docs/INSTALLATION.md) · [Roadmap](docs/ROADMAP.md) · [GitHub governance](docs/GITHUB_SETTINGS.md) · [Changelog](CHANGELOG.md)
