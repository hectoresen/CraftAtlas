# Design: shared view shell and recipe catalog

## Audited baseline
- PR #23 is merged and the maintainer reported its native Material explorer, 6-card recipe detail pagination, close and tooltips working in-game.
- `Features/Settings/Settings.lua` (~19 KB) currently owns window creation, header EditBox, language control, profession selector, material list, results state and material detail. `Features/Settings/RecipePanel.lua` owns fixed-size six-recipe cards and footer pagination.
- `Infrastructure/ItemInfo.lua` and `Infrastructure/RecipeInfo.lua` already resolve client names/icons and attempt native item/spell tooltips.
- `Data/RecipeUses.lua` (generated from `Data/recipe-uses.source.json`) is keyed by reagent itemID and has compact records `{spellID, professionOrderIndex, quantity, outputItemID|0, kindIndex}`. 8,455 source-backed uses come from the pinned MIT Forever beta corpus. Existing `ns.GetRecipeUses(itemID)` is a reverse material lookup, not a global recipe catalog.
- No existing global recipe-by-ID index or per-recipe reagent list is loaded by the client.

## Architecture (Lua 5.1 / WoW-native)
```text
CraftAtlasShell (window, title, language, minimap/slash, working X)
  -> ViewNavigation (Materials | Recipes)
  -> Shared/ExplorerLayout (search, profession selector, list/detail slots)
  -> Shared/SearchBox; ProfessionFilter; ResultList; Pagination; ItemCard
       -> MaterialsView (material search + selected MaterialDetail)
             -> RecipeUseCards (existing six-card grid, extracted shared paging/cards)
       -> RecipesView (recipe search + selected RecipeDetail)
             -> IngredientRows / shared ItemCard where appropriate
Domain/MaterialSearch        Domain/RecipeCatalog and RecipeSearch
Data/Materials, RecipeUses   Data/Recipes (generated, same source evidence)
Infrastructure/ItemInfo, RecipeInfo (single shared adapters)
```
Shared widgets are parameterized by explicit value/callback/data adapters and only manage rendering and events; each view owns its state, key identity and domain lookup. Avoid a generic engine or extensive new framework. Retain existing module ordering and addon namespace initialisation; update TOC and module-load regression tests.

## Data compilation and identity
Derive `recipeKey = professionKey .. ":" .. spellID`. Traverse existing authoritative `recipe-uses.source.json` rows and group `[reagentItemID, spellID, professionKey, quantity, outputItemID, kind]`. For a given key, verify stable output identity/kind across every input; inconsistent records fail validation rather than arbitrarily picking an output. Inputs are deduplicated by reagent ID; duplicate or contradictory counts fail. A recipe with zero known ingredients is not invented; each included recipe must have at least one verified input. Sort stable profession registry order then numeric spell ID; ingredients by itemID. Emit compact `Data/Recipes.lua` from `scripts/build_materials.py` or a clearly scoped deterministic companion script, validate drift with `--check`, and document unique recipe count computed from the source (not from raw use count).
Use output IDs only for presentation; two spell IDs producing the same item are distinct recipe entries. Preserve source, license and build metadata in the JSON source and documentation. Current runtime itemID/profession map and RecipeUses.lua are kept compatible. No separate manually maintained recipes.source.json.

## Search, filtering and async data
- Materials view retains current behavior and label search.
- Recipes search: localized client spell names via guarded `C_Spell.GetSpellInfo` / `GetSpellInfo`; output names/icons via existing `ns.GetItemDisplay(itemID)` and C_Item APIs. Numeric recipe spellID matching. Also profession name search and shared profession filter; neither depends on learned profession. Filter after normalizing Unicode-compatible client strings without fabricating translations; no runtime network.
- Name availability may be partial: render known named entries, an explicit localized "loading / names incomplete" notice, and an unknown-ID fallback only for numeric search. Do not show thousands of "Recipe #ID" rows on initial browse. Re-evaluate only on relevant async item/spell data signals or bounded preload; avoid synchronous catalog-wide frame creation and per-frame polling.
- Results are stable and deterministic; preserve selection if it still matches, reset/correct paging when filter changes, and clear stale details otherwise. View switch restores previously selected material or recipe.

## Shared native UI component contract
- `CraftAtlasShell`: maintains one window, title/language, tabs or native subnavigation "Materiales" and "Recetas", close, minimap/slash, frame layering. Default Materials. Slash retains `/craftatlas` and `/craftatlas <itemID>`; optionally explicit `/craftatlas recipes` if tested. No duplicate frames.
- `ExplorerLayout`: split result list/detail, search header and profession filter, empty/loading/result-count states. Component identity and state are explicit; UI reads bound adapter callbacks rather than accessing Materials globals.
- `SearchBox`, `ProfessionFilter`, `ResultList`: native EditBox/buttons/list, no CSS/web runtime; stable callbacks, localized placeholders, rows with border/hover/selection, recycled slots and scope-specific display records.
- `Pagination`: shared pure paging helper and native Prev/Next label/buttons, all counts refer to actual domain items. RecipeUseCards retain six per page. Recipes list may use recycling and/or paging as appropriate, but must reuse the same component/control, not duplicate a second pager.
- `DetailPanel` / `ItemCard`: shared icons/name/metadata/native hover conventions, with specific MaterialDetail vs RecipeDetail content owned by each view. "Shared" does not mean identical fields or duplicated UI context.

## Recipe detail and cross-navigation
RecipeDetail header: native recipe spell icon/name or output icon/name, profession, optional output item rarity/stats **only by native tooltip**, verified provenance note as appropriate. Ingredients list uses actual source-backed itemID and quantity (e.g. Silk Cloth ×6), original icon/name, native item tooltip, and clickable navigation to MaterialDetail. If an ingredient is a valid catalog reagent but its name cache is unavailable, show localized loading/ID fallback without inventing a name. If a recipe has no crafted item (e.g. enchantment), state this honestly. If item IDs are known but client tooltips fail, preserve a safe factual display.
MaterialDetail's existing consuming-recipe cards become navigable to the corresponding RecipeDetail by explicit click, while hover remains native tooltip. Cross-links preserve source view's query/filter/selection/page. Keep a bounded return stack or one-step back link; prevent loops, stale hover, and unexpected return-state loss.
Use native game tooltips and item/spell APIs only if guarded; never claim rarity or equipment stats locally.

## Verification plan
- Compiler tests: 8,455 use rows → unique recipe keys (count computed during implementation), all material IDs/quantities preserved, stable order and output conflict failures, duplicate inputs, unknown kinds, data provenance, generated drift.
- Pure Lua domain tests: text search names/output, profession filter, exact recipe keys, equal output different recipes, incomplete name caches, zero-result state, input sorting and selected-detail quantities.
- Shared UI mocks: navigation switching and independent state; search/focus/clear; recycled row click; pagination 0/1/6/7/14; tooltips/close cleanup; no panel duplication; link material ↔ recipe ↔ back.
- Regression: existing Materials search/list, consuming recipe count/card paging, itemID slash, minimap, enUS/esES/auto, dragging/X, tooltip annotations. Enforce new TOC paths exist.
- Forever manual QA (owner): same Materials behavior as PR #23; new Recipes browse/search for an alchemy potion by spell/result name and filter; output tooltip quality/stats; all ingredients/quantities for source-backed recipe; cross-navigation in both directions; a non-item enchantment; unknown source output and missing client cache; long names; dense recipe; pages and UI scale 80–120%. Record exact build and screenshots; unrun tests are reported as unrun.
