# Tasks: add Recipe Explorer and extract shared native UI

## Gate: specification approval
- [ ] Owner reviews and merges this **spec-only** PR; implementation must reference the actual merged spec PR.
- [ ] Confirm main SHA, PR changes, current TOC, native Forever APIs and licensed source snapshot before implementation.

## A — Safe extraction and regression
- [ ] Introduce lightweight CraftAtlasShell and view registry without changing Materials default rendering or gameplay behavior.
- [ ] Extract reusable native SearchBox, ProfessionFilter, ResultList and DetailPanel/ItemCard controls behind callback/data contracts; no copy-pasted second Settings.lua.
- [ ] Extract reusable pure Pagination and native pager/card presentation while preserving Materials' six-recipe page results and close fix.
- [ ] Add tests around pre-refactor Materials behavior, state preservation, tooltip ownership and TOC module order; validate no regressions before implementing Recipes.

## B — Unique recipe catalog
- [ ] Derive all unique recipe keys from pinned licensed reagent-use source. Validate output/recipe kind consistency, quantities and provenance.
- [ ] Generate compact offline Recipes.lua and deterministic report with unique counts, no additional hand-curated source data.
- [ ] Add pure RecipeCatalog/RecipeSearch domain functions, name cache/fallback adapter and exact profession filtering.
- [ ] Test distinct recipes sharing an output, multiple reagents per recipe, unknown output, enchantments, build/check drift and source-inconsistency rejection.

## C — New view and navigation
- [ ] Add localized Materials / Recipes subnavigation with independent per-view search/filter/selection/page states.
- [ ] Implement Recipes browse/search/results and selectable details using shared controls and native client name/icon/tooltip adapters.
- [ ] Show **all verified ingredients** and exact quantities, consuming profession and actual output where known; no fabricated rarity.
- [ ] Add bidirectional navigation: material's consuming recipe → RecipeDetail and ingredient from recipe → MaterialDetail; preserve a bounded return path.
- [ ] Maintain native close/reopen, minimap, slash, settings persistence and accurate localized empty/loading states.

## D — Acceptance evidence
- [ ] Python data/compiler validation, generation check and deterministic fixtures; Lua domain, adapter, shared UI and navigation tests.
- [ ] Run `python3 scripts/validate_repo.py`, `python3 scripts/build_materials.py --check`, relevant unittest/Lua suites and strict OpenSpec/SDD CI; report exact results.
- [ ] Test in WoW Forever using owner-provided actual client version, screenshots and navigation scenarios; do not claim tests if not run.
- [ ] Update README, DATA_MODEL, ARCHITECTURE, TESTING, ROADMAP, DEVELOPMENT and CHANGELOG to reflect actual implementation.
- [ ] Open one scoped implementation PR after the approved spec; no direct changes to main or automatic merge.
