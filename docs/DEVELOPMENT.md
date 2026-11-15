# Developer setup

CraftAtlas is currently implemented as `0.1.0-dev` and reported working in WoW Forever by the maintainer. Requirements for offline checks: Git, Python 3.11+, an optional Lua/texlua interpreter, and Node.js 22.12+ if using the official OpenSpec CLI.

```sh
git clone https://github.com/hectoresen/CraftAtlas.git
cd CraftAtlas
python3 scripts/validate_repo.py
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
texlua tests/test_addon.lua
```

To prepare approved changes: `npm install -g @fission-ai/openspec@latest`, `openspec init`, then use the official proposal → owner approval → implementation → test → PR sequence. Read [AGENTS.md](../AGENTS.md) and [SDD compliance](SDD_COMPLIANCE.md). Never push directly to `main` or merge without explicit owner permission.

Code/docs are written in English; user-facing strings are localized enUS/esES. Lua modules are loaded in dependency order in `addon/CraftAtlas/CraftAtlas.toc`. Edit `Data/materials.source.json` and regenerate with `python3 scripts/build_materials.py`, not by editing `Materials.lua` directly.

`python3 scripts/build_materials.py --release --check` is a stronger catalog acceptance gate requiring live-client validation; a functional addon alone is not proof of complete live mapping accuracy. Record each test command and the exact Forever build for game-facing PRs. [Testing matrix](TESTING.md).

## Shared native explorer development

Modify reusable UI behavior via `Features/Settings/Shared/ExplorerWidgets.lua` rather than duplicating Material and Recipe controls. Keep per-view state inside the shell and pure catalog filtering in `Domain/`. Recipe identity is always profession+spellID, even when two recipes produce an identical item. `scripts/build_materials.py` compiles both reagent→recipe and recipe→all-input indices from one pinned licensed JSON source; do not manually update generated Lua files. Run its `--check` mode and both Python/Lua tests, then verify tooltip and UI behavior in the actual Forever client before releases.
