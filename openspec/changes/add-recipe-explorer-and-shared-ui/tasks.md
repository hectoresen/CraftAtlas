# Tasks: add Recipe Explorer and extract shared native UI

## Gate: specification approval
- [x] Owner merged spec PR #24; this implementation is based on approved main.
- [x] Confirmed main and inspected source/TOC/license. Native Forever client APIs remain a manual test gate.

## A — Safe extraction and regression
- [x] Introduce lightweight CraftAtlasShell and view registry without changing Materials default rendering or gameplay behavior.
- [x] Extract reusable native SearchBox, ProfessionFilter, ResultList and DetailPanel/ItemCard controls behind callback/data contracts; no copy-pasted second Settings.lua.
- [x] Extract reusable pure Pagination and native pager/card presentation while preserving Materials' six-recipe page results and close fix.
- [ ] Add tests around pre-refactor Materials behavior, state preservation, tooltip ownership and TOC module order; validate no regressions before implementing Recipes.

## B — Unique recipe catalog
- [x] Derive all unique recipe keys from pinned licensed reagent-use source. Validate output/recipe kind consistency, quantities and provenance.
- [x] Generate compact offline Recipes.lua and deterministic report with unique counts, no additional hand-curated source data.
- [x] Add pure RecipeCatalog/RecipeSearch domain functions, name cache/fallback adapter and exact profession filtering.
- [ ] Test distinct recipes sharing an output, multiple reagents per recipe, unknown output, enchantments, build/check drift and source-inconsistency rejection.

## C — New view and navigation
- [x] Add localized Materials / Recipes subnavigation with independent per-view search/filter/selection/page states.
- [x] Implement Recipes browse/search/results and selectable details using shared controls and native client name/icon/tooltip adapters.
- [x] Show **all verified ingredients** and exact quantities, consuming profession and actual output where known; no fabricated rarity.
- [ ] Add bidirectional navigation: material's consuming recipe → RecipeDetail and ingredient from recipe → MaterialDetail; preserve a bounded return path.
- [x] Maintain native close/reopen, minimap, slash, settings persistence and accurate localized empty/loading states.

## D — Acceptance evidence
- [ ] Python data/compiler validation, generation check and deterministic fixtures; Lua domain, adapter, shared UI and navigation tests.
- [ ] Run `python3 scripts/validate_repo.py`, `python3 scripts/build_materials.py --check`, relevant unittest/Lua suites and strict OpenSpec/SDD CI; report exact results.
- [ ] Test in WoW Forever using owner-provided actual client version, screenshots and navigation scenarios; do not claim tests if not run.
- [x] Update README, DATA_MODEL, ARCHITECTURE, TESTING, ROADMAP, DEVELOPMENT and CHANGELOG to reflect actual implementation.
- [ ] Open one scoped implementation PR after the approved spec; no direct changes to main or automatic merge.

## PR #25 owner screenshot iteration (same approved implementation scope)
- [x] Reposition the material-detail crafting-use heading and card grid below profession metadata; no overlapping headers.
- [x] Use the available left-pane height for seven compact recycled rows at standard 510px shell height.
- [x] Place Back in the navigation toolbar and hide it when no history exists.
- [x] Label the new UI view Fabricables / Craftables, keeping internal recipe spell/profession identities and explicit non-item enchantments.
- [x] Add a pure Lua layout geometry regression; game-client visual recheck remains pending.
