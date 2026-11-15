# Testing strategy

## Foundation
`python3 scripts/validate_repo.py` verifies required files, Markdown formatting and OpenSpec config; CI runs it for PRs/pushes to main. This does NOT validate playable functionality.

## v0.0.1 implementation candidate

From the repository root, run:

```sh
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
python3 scripts/build_materials.py --release --check
texlua tests/test_addon.lua
```

The `--release` command is **expected to fail** until the signed-off
30-item minimum is complete. `texlua` runs the pure Lua fixtures and mocks;
it **cannot** substitute for the game client or prove compatibility with
Forever's UI/security APIs. No in-game tests have been run by the implementation agent.

The source of profession relationships is
`addon/CraftAtlas/Data/materials.source.json`, with human-readable references
and review dates. These references are *not* client proof. Curate the remaining
items and verify each included association with actual Forever recipes.

## Future automated tests
Use deterministic Lua tests for material lookup, multi-profession resolution, unknown IDs, localization fallback and SavedVariables preference behavior. Static analysis (Luacheck) and dataset/schema validation must be introduced with the first implementation. CI must fail on invalid data, tests or lint errors.

## Manual Forever-client matrix (required for game-facing changes)
- Exact client build + interface version recorded
- Addon detected/enabled, no Lua startup errors
- Player inventory/bag item tooltip behavior (bank/global tooltips require later approved scope)
- Known single-profession and multi-profession materials
- Unrecognized item adds no false information
- No duplicate lines on repeated hovers/reloads
- enUS/esES and unknown-locale fallback
- Manual language override survives reload/restart
- Performance acceptable under rapid tooltip changes
- Addon list shows the profession/crafting icon
- Exactly one minimap button appears after load/reload
- Minimap primary click opens the same settings window as `/craftatlas`
- Search affordance is not editable, with unavailable cursor
- Expanded header is readable at standard UI scale
- Screenshots or reproducible evidence attached to PR

Mark each test *passed*, *failed* or *not run*. Never present an unrun game test as passing.

## v0.1.0 development candidate

Run from repository root: `python3 -m unittest discover -s tests -p 'test_material_data.py' -v`, `python3 scripts/build_materials.py --check`, and `texlua tests/test_addon.lua`. The release gate `python3 scripts/build_materials.py --release --check` is deliberately failing while 30 verified items are unavailable. Test bank, guild bank, inventory, chat item links, auction, vendors, mail, crafting and quest rewards individually in a real Forever build; report each as passed/failed/not run. Existing client testing covered only initial v0.0.1. Do not claim all origins tested or all professions catalogued.

## MIT catalog expansion QA (pending real client)

Imported dataset: 593 item IDs, 10 consuming professions, 237 shared materials, indexed by numeric itemID. The source is the **beta Forever 1.60.1.69977 LibProfessionDB** core data (MIT, Pimptasty), not a live-server capture. The current published LibProfessionDB v1.10.0 uses live build 1.60.1.70938 and includes Herbalism/Skinning; obtaining and comparing that snapshot remains open.

Execute the following against the candidate branch:

```sh
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
texlua tests/test_addon.lua
python3 scripts/build_materials.py --release --check  # MUST fail until Forever QA recorded
```

The in-game matrix must test **new materials beyond the six prototype entries**, multi-profession overlaps, Mining smelting, Fishing crafts, displayed enUS/esES names, item tooltips in bag/bank/chat/AH/merchant, unknown items, reload and rapid hover. At present these checks are not reported as passed. A 593-material import does **not** imply a release-ready build.
