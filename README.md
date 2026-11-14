# CraftAtlas

**CraftAtlas** is a community-driven, MIT-licensed World of Warcraft: Forever addon for discovering which professions use a material and, in future versions, which recipes and crafted items depend on it.

> **Current status: v0.0.0 — project foundation, NOT a working addon.** Compatibility with the actual Forever client, interface version, and supported tooltip APIs must be verified before the first functional release.

## Product roadmap

| Version | Deliverable | Exit criteria |
| --- | --- | --- |
| 0.0.0 | Repository framework, OpenSpec, agent/human documentation, CI, addon skeleton | Foundation reviewed |
| 0.1.0 | Inventory/bank tooltip profession identification by itemID; all professions independently of character skills; local catalog; ES/EN with locale auto-detection and manual override; settings panel | Real-client test, known coverage documented, unknown materials handled safely |
| 0.2.0 | Expanded audited catalog, diagnostic tooling, performance and UX refinements | Data provenance and regression tests |
| 0.3.0 | Material search and profession filtering | Offline search tested |
| 0.4.0 | Recipes, quantities and resulting items | Recipe graph verified |
| 0.5.0 | Reverse crafting/dependency explorer | Graph traversal and UI verified |
| 1.0.0 | Stable release | End-to-end compatibility, docs, data and UX review |

These are proposed scopes, not delivery dates. See [docs/ROADMAP.md](docs/ROADMAP.md).

## Quick start for contributors

1. Read [AGENTS.md](AGENTS.md) (also applicable to humans) and [CONTRIBUTING.md](CONTRIBUTING.md).
2. Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/DATA_MODEL.md](docs/DATA_MODEL.md), and [docs/TESTING.md](docs/TESTING.md).
3. Install [OpenSpec](https://github.com/Fission-AI/OpenSpec): `npm install -g @fission-ai/openspec@latest`.
4. If agent skills are missing locally, run `openspec init` and choose OpenCode (or your preferred supported agent). **Preserve the existing `openspec/config.yaml` and specs.**
5. For meaningful changes: propose → review/approve → implement → verify → sync/archive specs → PR. OpenCode can use `/opsx:propose` and `/opsx:apply` when its generated skills are installed.
6. Run `python3 scripts/validate_repo.py`. Follow `docs/TESTING.md` for real-game checks.

## Project layout

- `addon/CraftAtlas/` — game-installable Lua addon (currently only a placeholder).
- `openspec/` — canonical specification and proposed changes.
- `docs/` — architecture, installation, data, test, roadmap and development instructions.
- `scripts/` — offline validations and future build tools.
- `tests/` — offline deterministic tests (to be added with implementation).
- `.github/` — contribution templates, ownership and CI.

## Installation

The v0.0.0 foundation **does not contain a functioning addon**. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for target directory guidance and client checks before release. Never claim Forever compatibility based only on `.toc` metadata.

## Key technical decisions

- Lua, no required gameplay-time dependencies, no telemetry/network connections.
- Numeric `itemID` as stable identity; never match localized tooltip text.
- Stable profession keys, multiple professions per item, including professions not learned by the character.
- Local versioned data with documented provenance and redistribution rights; unknown item means no invented attribution.
- enUS/esES translations, automatic locale selection and a persisted manual language override.
- Isolate game-facing APIs from testable domain logic.

## Documentation

[Agent contract](AGENTS.md) · [Contributing](CONTRIBUTING.md) · [Development](docs/DEVELOPMENT.md) · [Architecture](docs/ARCHITECTURE.md) · [Data model](docs/DATA_MODEL.md) · [Testing](docs/TESTING.md) · [Installation](docs/INSTALLATION.md) · [Roadmap](docs/ROADMAP.md) · [OpenSpec guide](openspec/README.md) · [GitHub settings](docs/GITHUB_SETTINGS.md)

## Community and license

Pull requests welcome from people and agents, subject to human review. See [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) and [LICENSE](LICENSE). Third-party game databases must not be copied without compatible permissions and provenance. CraftAtlas is independent of Blizzard and Forever server operators.
