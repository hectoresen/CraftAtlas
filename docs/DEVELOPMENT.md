# Developer setup and repository conventions

CraftAtlas is a **Lua World of Warcraft: Forever addon**, source version `0.1.0-dev`. Source code, PRs, agent instructions and engineering documentation use English; user-facing strings support enUS/esES. The maintainer has accepted the Materiales/Fabricables UI in-game, but dataset completeness, every tooltip origin and exact game-build compatibility remain separate QA tasks.

## Local environment

Use Git, Python 3.11+, and a Lua/texlua interpreter for offline Lua tests. The official OpenSpec CLI requires its supported Node.js version (currently documented as Node 22.12+ in project governance). Start by reading [AGENTS.md](../AGENTS.md), [OpenSpec](../openspec/README.md), [architecture](ARCHITECTURE.md) and [data model](DATA_MODEL.md).

```sh
git clone https://github.com/hectoresen/CraftAtlas.git
cd CraftAtlas
bash scripts/validate_release_checks.sh
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
texlua tests/test_addon.lua
texlua tests/test_recipe_catalog.lua
texlua tests/test_explorer_layout.lua
texlua tests/test_profession_tree.lua
texlua tests/test_release_version.lua
texlua tests/test_recipe_cards.lua
```

The shared shell script runs the same **Python release-readiness tests** required by both PR CI and manual release; individual Lua tests and actual game-client smoke tests must be executed and reported separately. For the full matrix see [testing](TESTING.md).

## Implementation boundaries

- `Core/`: initialization, wiring and lifecycle.
- `Data/`: pinned source/license evidence and deterministic generated runtime indices.
- `Domain/`: pure material lookup, filtering, profession grouping/expansion and recipe identity/ingredient logic, no WoW globals.
- `Infrastructure/`: guarded client APIs, asynchronous names/icons/tooltips, minimap and preferences.
- `Features/`: native Materiales and Fabricables UI and tooltip annotation.
- `Features/Settings/Shared/ExplorerWidgets.lua`: reusable native search, broom/icon fallback, filter, virtualized rows, pager and layout; avoid duplicating a separate explorer implementation.
- `Localization/`: enUS/esES client-facing text and fallbacks.

Use `scripts/build_materials.py` to regenerate source-backed data; never edit `Materials.lua`, `RecipeUses.lua` or `Recipes.lua` by hand. Recipe identity is profession+spellID, not output itemID. Never infer recipe availability/quality or learned-status from the imported dataset.

## Spec-first workflow and PR quality

For behavior or source changes, propose an OpenSpec change, obtain its **owner-merged specification PR**, then implement in a separate PR within the approved `sdd-scope.json`. An implementation PR may update the change's `tasks.md`, but not silently change its approved spec/design/scope. The single PR #14 combined exception is historical and nonreusable. Only @hectoresen may decide merges, release publication, repository permissions or protected settings.

Before opening any PR, compare new behavior with README, architecture, data model, installation, testing, roadmap, changelog and relevant specs. Reconcile only factual updates; do not call unrun tests passed. Each PR must declare exact test commands/results, unrun Forever checks, relevant source rights, rollback and a clear review request. More precise rules live in [AGENTS.md](../AGENTS.md), [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) and [SDD compliance](SDD_COMPLIANCE.md).
