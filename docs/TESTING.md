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


## Material explorer (PR #14; not yet game-verified)

Offline test: `texlua tests/test_material_search.lua` (test by numeric itemID, client-resolved name, combined profession filter, shared-material relations, unknown items and unresolved names). Policy test: `python3 -m unittest discover -s tests -p 'test_validate_sdd.py' -v`.

**Manual Forever checks required before calling this feature compatible:** Open the window from minimap and `/craftatlas`; ensure a single centered title, native frame, correct scroll/filter area, accessible close button, no clipping at different UI scales; search by ID `2447` and by localized name once cache resolves; compare a multi-profession item and filtering results; clear only search text and verify the filter stays; try an unknown ID and a missing-name cache case; switch language, reload SavedVariables; test `/craftatlas 2447`; ensure no existing tooltip annotation regressions. Record exact client build and screenshots. Click-to-open via tooltip **not implemented**, pending safe verified API.

The PR was developed without the Forever client: all client-specific checks are **NOT RUN**. The 593-item dataset remains a bounded beta snapshot, not verified live-realm completeness.


### 2026-11-15 screenshot-driven correction (PR #14)

The first in-game screenshot showed 593 rows labeled `ID de objeto`, no icons and no Spanish material-name search. Root cause: the original candidate used obsolete `GetItemInfo`/`GetItemIcon` globals in Forever and did not request uncached item data. Revised implementation uses `C_Item.GetItemInfo`, `C_Item.GetItemInfoInstant`, `C_Item.RequestLoadItemDataByID` and `ITEM_DATA_LOAD_RESULT` (guarded compatibility fallbacks). Name browsing now excludes unknown-name rows and shows a loading notice; numeric ID lookup remains possible. Result rows have a visible separator, alternating surface and hover/selection highlights. Added `texlua tests/test_item_info.lua` for mocked adapter behavior. **These changes must be rechecked by the maintainer in the actual game; screenshot confirmation applies only to the original broken candidate.**


## Reverse reagent-use recipe browser — PR implementation candidate

Run `python3 scripts/build_materials.py --check`, `python3 -m unittest discover -s tests -p 'test_material_data.py' -v`, `texlua tests/test_recipe_usage.lua`, `texlua tests/test_recipe_info.lua`, `texlua tests/test_material_search.lua` and `python3 scripts/validate_repo.py`. Data integrity covers 8,455 source-backed uses, 593 reagent IDs, output-only exclusion, regression item `14044` → `19093` → `15138`, duplicates, unknown outputs, native tooltip mock and deterministic generation.

**Required in-game manual tests (NOT RUN by agent):** identify actual Forever client build; open /craftatlas; inspect Cindercloth Cloak 14044 and verify legitimate input use for Onyxia Scale Cloak; inspect Blackmouth Oil and compare all listed consuming recipes; check a multi-profession reagent, non-item enchantment, recipe with missing output, amounts, tooltip for output item including rarity and stats, native spell tooltip/factual fallback, mouse leaving/scrolling, enUS/esES, list clipping under UI scale, cache misses and existing tooltip/minimap regression. Document pass/fail per scenario with screenshots. The source snapshot remains a beta and cannot establish live server completeness.

## Recipe-card UI and close-control regression (post-PR #22 implementation)

Offline test commands:
```sh
texlua tests/test_recipe_pagination.lua
texlua tests/test_recipe_cards.lua
texlua tests/test_explorer_close.lua
```

The `test_toc_modules.py` test is actually **Python**, run it with `python3 -m unittest discover -s tests -p 'test_toc_modules.py' -v` instead of texlua. The added Lua tests exercise page 0/1/6/7/14, duplicate-free boundaries, recycled six-card drawing, default item tooltip vs recipe fallback, tooltip cleanup, and explicitly bound X under both native and fallback template cases.

**Manual Forever client checks required (NOT RUN by implementation agent):** Search/select `Agu(a) de manantial refrescante` (item 159) or another known 14-use reagent, see 6/6/2 cards across pages 1–3 and correct count; verify last-page Next disabled and first-page Previous disabled; hover crafted result and non-item recipe, compare displayed tooltip/rarity to WoW; change material and see page reset while search/filter stay; allow item name/icon to load while on page 2 and confirm no reset; switch language; test window X click, tooltip disappearing, slash/minimap reopening and X again; test different UI scales and window sizes. Record screenshots, build, and PASS/FAIL. Passing CI cannot establish real native UI compatibility.
