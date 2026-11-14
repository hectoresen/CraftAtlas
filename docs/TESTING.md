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
- Screenshots or reproducible evidence attached to PR

Mark each test *passed*, *failed* or *not run*. Never present an unrun game test as passing.
