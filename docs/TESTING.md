# Testing strategy and evidence

## Reported in-game acceptance

On **15 November 2026**, the maintainer confirmed that the **current addon is tested and functional in WoW Forever**, including its present tooltip/settings/minimap experience. This is **user-reported manual acceptance**, not an automated test result or a recorded full matrix. The exact client build, screenshots and results by individual tooltip origin (bank, vendor, auction, chat, etc.) were not supplied. Do not mark those individual cases as passed without evidence.

The settings **search affordance is intentionally visual only**. Testing must assert that it is not presented as an operational search control; the actual search feature is planned for a later milestone.

## Automated/offline checks

Run from the repo root:

```sh
python3 scripts/validate_repo.py
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
texlua tests/test_addon.lua
python3 scripts/build_materials.py --release --check
```

The first repository validator runs in existing CI; **this does not prove Lua gameplay functionality**. The other commands need to be run and reported for each candidate PR. This documentation update does not assert that they have been executed. The `--release --check` gate also requires `referenceUniverse.liveClientValidated`, independent of whether the addon itself loads and runs successfully.

## Client test checklist — record pass/fail/not run for each

- Exact Forever build, `.toc` interface metadata and Lua startup errors
- Inventory and bag tooltips: one consuming profession, multiple consuming professions, unknown itemID
- Rapid tooltip refresh/item switching: no stale labels or duplicates
- Bank, guild bank, chat links, auction, vendor, mail, quest rewards and crafting: **separate** origin checks
- enUS/esES and auto language resolution; manual language change and persistence across `/reload`
- `/craftatlas` opens the General settings page and closes/reopens without duplicate frames
- Minimap button opens the same settings, is draggable and persists its position
- Search placeholder is visual and does **not** perform a search
- At least several materials introduced by the expanded 593-item catalog match actual current-server recipes

Collect client build, reproducible results and screenshots for the release record. For data integrity review `addon/CraftAtlas/Data/coverage-report.json`: 593 candidates, 237 multi-profession IDs, and `liveClientValidated: false` regarding **the imported relations**, not whether the Lua addon works.

## Important distinction

**Working addon** means its runtime/UI have been successfully exercised by the maintainer. **Live-verified dataset** means the individual imported item-to-profession mappings have been corroborated against actual current-server recipes. The first has been reported; the second is still an open release-quality task.
