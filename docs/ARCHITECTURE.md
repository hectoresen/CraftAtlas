# Architecture — current implementation

CraftAtlas is an installable Lua addon with a pragmatic separation of domain, client APIs and UI. It **is implemented and reported working in Forever by the maintainer**, not an empty scaffold. It uses no runtime networking, telemetry or required third-party addon.

| Module | Runtime responsibility |
| --- | --- |
| `Core/Init.lua` / `Core/Bootstrap.lua` | Namespace, lifecycle, initialization after `ADDON_LOADED` |
| `Domain/MaterialLookup.lua` | Pure numeric itemID → ordered consuming-profession keys; no WoW API calls |
| `Domain/MaterialSearch.lua` | Pure local material filtering by itemID/name, consuming profession and source-backed reagent eligibility |
| `Domain/RecipeUsage.lua` | Pure source-verified reagent → sorted distinct recipe uses, grouped by profession |
| `Infrastructure/ItemInfo.lua` | Native asynchronous item names/icons for both reagents and crafted outputs |
| `Infrastructure/RecipeInfo.lua` | Spell/recipe info adapter and native item/spell tooltip adapters with factual fallbacks |
| `Data/Professions.lua` / `Data/Materials.lua` / `Data/RecipeUses.lua` | Generated registry, 593-item catalog and 8,455 reverse recipe-use entries |
| `Infrastructure/TooltipAdapter.lua` | Single `TooltipDataProcessor.AddTooltipPostCall` item hook and numeric itemID extraction |
| `Features/Tooltip/Tooltip.lua` | Localized two-line profession annotation and refresh deduplication |
| `Infrastructure/Preferences.lua` | Saved language choice and minimap angle in account-wide `CraftAtlasDB` |
| `Infrastructure/MinimapButton.lua` | Draggable minimap entry point to settings |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | English/Spanish labels and fallback |
| `Features/Settings/Settings.lua` / `RecipePanel.lua` | Native material explorer and six-card paginated recipe-use detail; no automatic crafting |

## Runtime flow

WoW item tooltip → numeric itemID from structured tooltip data → pure map lookup → ordered consuming professions → locale-aware tooltip lines. Missing IDs produce no annotation. Tooltip registration is guarded for unsupported APIs and callback errors. The UI panel is available via slash command and minimap.

**New material explorer implementation (Forever game QA pending):** Settings search uses an EditBox, instant itemID/name filtering, profession dropdown, recycled item rows, icon/name fallbacks, material detail and the source-backed reverse recipe list. Search depends on client-cached names; an itemID fallback remains. Source-proven recipe quantities and outputs are shown in a compact six-card paginated native grid, with a single output icon or recipe fallback. The explorer's X has an explicit standalone-window close handler. Full dependency graphs and clickable game-item tooltip navigation are not implemented. Direct command entry `/craftatlas 2447` selects a known material by itemID, as a safe alternative.

## Data architecture

A 593-item, ten-profession local index is generated from a provenance-bearing source file. The large JSON (~678 KB) is build evidence; the small Lua runtime map (~25 KB) is what the client loads. This snapshot comes from an MIT-licensed LibProfessionDB Forever beta build 69977; it is not a full live server catalog. See [Data model](DATA_MODEL.md).

## Compatibility and acceptance

The maintainer reported successful in-game operation of the pre-PR-14 addon on **15 November 2026**. The new material explorer has **not** been verified in the Forever client. The exact tested Forever build and separate bank/auction/chat/vendor origin results have not been recorded. The approved original [v0.0.1 inventory spec](../openspec/changes/add-first-playable-material-tooltips/specs/inventory-tooltips/spec.md) formally guarantees inventory/bag behavior only; avoid silently extending its documented acceptance scope.

The tooltip API belongs at the infrastructure edge; pure lookup stays testable with Lua fixtures. Do not infer mappings from localized names or add speculative modules. Source/code/spec changes follow [OpenSpec governance](../openspec/README.md) and [code quality standards](CODE_QUALITY.md).

### Recipe presentation and pagination

`Domain/RecipeUsage.lua` provides a pure deterministic six-use pagination helper, independent of visual profession headings. `Features/Settings/RecipePanel.lua` keeps a fixed pool of six WoW Button cards, draws one icon/name and profession/quantity per recipe, retains a valid page when item-info refreshes, and resets when the material changes. The existing native item/spell tooltip adapters are reused. The main `Settings.lua` binds native `CloseButton` explicitly to `panel:Hide()`, raises it over decorative frames, and clears owned tooltips on hide. No recipe data or material mappings change.

## Shared Recipes/Materials explorer (unreleased candidate)

The native shell in `Features/Settings/Settings.lua` now exposes two view modes with view-local query, profession selection, selected identity and scroll offset. A single physical search input, profession selector and recycled result list are reused by both. `Features/Settings/Shared/ExplorerWidgets.lua` owns reusable native row/search/filter/pager factories; both `Features/Settings/RecipePanel.lua` (material-consuming recipe cards) and `Features/Settings/RecipesView.lua` (selected recipe's full ingredient list) use the pager. `Domain/RecipeCatalog.lua` is a pure recipe identity/ingredient and filter adapter; `Infrastructure/RecipeNameCache.lua` bounds asynchronous client spell/output resolution, independently of character-known professions. `Data/Recipes.lua` contains **2,506** generated distinct records from the same source-backed **8,455** reagent uses. Native client tooltips still own rarity/equipment statistics; no external UI framework or runtime networking is used.

Materials remains the default on `/craftatlas`, and `/craftatlas <itemID>` still deep-links to a valid source-backed reagent. Clicking a consuming recipe opens Recipes and clicking a recipe ingredient opens Materials. An eight-entry maximum history keeps Back bounded. Each view retains its filters and selection. Actual UI scale behavior, async spell cache coverage and tooltip compatibility are **not yet verified in Forever**.

### In-PR layout and terminology correction

The Recipes domain remains keyed by spellID+profession. The **user-facing** second view is **Fabricables / Craftables** because it explores crafted outputs and the inputs needed to make them; non-item enchantment actions remain explicitly labeled. `Shared/ExplorerWidgets.lua` exposes pure `ExplorerVisibleRowCount` and `MaterialDetailSectionOffsets` helpers, used by the existing native shell and material-recipe grid. Standard window height 510px → seven 36px rows. The material metadata ends before the usage section begins, and Back anchors into the top navigation, not the detail cards.
