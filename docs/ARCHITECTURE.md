# Architecture — current source

CraftAtlas is an offline WoW Forever Lua addon. User-visible functionality has been accepted in-game by the maintainer; current data completeness and per-client compatibility are independent validation concerns.

## Module boundaries

| Runtime module | Responsibility |
| --- | --- |
| `Core/Init.lua`, `Core/Bootstrap.lua` | Namespace, SavedVariables lifecycle and addon bootstrap |
| `Data/Professions.lua`, `Materials.lua`, `RecipeUses.lua`, `Recipes.lua` | Generated profession, reagent, reverse-use and **2,506-recipe** local indices |
| `Domain/MaterialLookup.lua`, `MaterialSearch.lua`, `ProfessionTree.lua` | Source-backed filtering, stable profession grouping and pure expand/search-restore projection |
| `Domain/RecipeUsage.lua` | Material → actual recipe uses and pure pagination |
| `Domain/RecipeCatalog.lua` | Unique profession+spellID recipe identity, ingredient detail and recipe search |
| `Infrastructure/ItemInfo.lua`, `RecipeInfo.lua`, `RecipeNameCache.lua` | Guarded asynchronous client item/spell names/icons and native tooltips |
| `Infrastructure/TooltipAdapter.lua`, `Features/Tooltip/Tooltip.lua` | One guarded item-tooltip hook and localized profession annotations |
| `Infrastructure/Preferences.lua`, `MinimapButton.lua` | Language preference and movable minimap access |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | Client locale and enUS/esES strings |
| `Features/Settings/Settings.lua` | Single native window, tabs, state, selected details, cross-view navigation, working close |
| `Features/Settings/Shared/ExplorerWidgets.lua` | Reusable native search box, profession selector, result row, pager and layout helpers |
| `Features/Settings/RecipePanel.lua` | Material-detail bounded native vertical fabrication-use rows with pagination |
| `Features/Settings/RecipesView.lua` | Fabricables detail with complete known inputs, item hover and ingredient pagination |

The loading order is declared in `addon/CraftAtlas/CraftAtlas.toc`; all addon runtime files belong under `addon/CraftAtlas/`, not in `docs/`.

## Behavior and UI

`/craftatlas` and the minimap button open the **Materiales** tab. It filters only items known to be actual recipe **inputs**, by itemID/name and consuming profession. The left pane projects filtered unique itemIDs into source-backed collapsible profession groups, virtualizing the visible row pool. It preserves group expansion across view navigation and restores pre-search collapse state after clearing a query. The right pane shows client-provided item metadata when available, a collapsible profession-use section with native client icons and bounded navigation, and a separate collapsible section of paginated vertical crafting-use rows. Collapsing professions reflows the recipe section and its bounded page size. Hover uses the game client; clicking a use opens its **Fabricables** detail.

**Fabricables** browses unique recipe keys (`professionKey:spellID`) with client-resolved spell/output names, profession filter and numeric spellID search. The detail presents its consuming profession, actual output where known, and all recorded ingredient itemIDs with exact quantities. Enchantments/non-item actions are identified rather than invented as physical items. Clicking an ingredient navigates back to Materiales. Cross-navigation keeps view-local query/filter and a bounded Back history. Some spell/item names can be unavailable in the client cache; this limits text searches and is surfaced as incomplete results.

UI uses WoW-native frames, no CSS framework or external runtime API. Reusable gold divider rows distinguish profession groups from material results; material entries omit redundant profession subtitles while retaining icon/name and selected-ID highlight. Their collapse affordance and selected-item highlight are independent. The shared clear control uses the bundled broom icon texture path directly instead of an item-icon cache that can return a question-mark placeholder (and a native cleansing-action fallback otherwise); the version footer derives only from a locally installed numeric release SemVer, never the tracked development manifest. The compact shell uses a bounded scale rather than clipping its fixed control regions. Blizzard native UIDropDownMenuTemplate is used for language and profession selection on supported clients, with original clickable Classic red-button selectors as fallbacks. Tabs, search clear, Back and paging retain UIPanelButtonTemplate. The custom section/divider layout uses native plus/minus artwork; all original callbacks are preserved. The shared controls are factored out of a single shell, not duplicated between Materiales and Fabricables. The window's X explicitly hides the standalone frame. Native tooltips, not CraftAtlas, supply equipment statistics/rarity.

## Data integrity and limits

A deterministic offline generator `scripts/build_materials.py` compiles `Materials.lua`, `Professions.lua`, `RecipeUses.lua`, `Recipes.lua` and coverage evidence from licensed pinned JSON source records. **593** distinct inputs, **8,455** reagent-use rows and **2,506** unique recipes are source-snapshot counts. Do not conflate source verification with testing each recipe on the current Forever server. A recipe may produce an item that itself is an ingredient. A full dependency graph, crafting automation, player-known recipes and inventory stock calculations are outside the current implementation.

## Validation and change control

`bash scripts/validate_release_checks.sh` is the common PR/release gate. `.github/workflows/spec-compliance.yml` separately enforces the OpenSpec approval chain. Python and Lua fixtures supplement these; exact Forever build/manual acceptance and untested item-tooltip origins should be recorded in `docs/TESTING.md`. See [data model](DATA_MODEL.md), [development](DEVELOPMENT.md) and [SDD policy](SDD_COMPLIANCE.md).
