# Architecture — current source

CraftAtlas is an offline WoW Forever Lua addon. The maintainer has inspected and approved the overall UI through in-game screenshots; final adjustments, source-data completeness and per-client compatibility remain independent validation concerns.

## Module boundaries

| Runtime module | Responsibility |
| --- | --- |
| `Core/Init.lua`, `Core/Bootstrap.lua` | Namespace, SavedVariables lifecycle and addon bootstrap |
| `Data/Professions.lua`, `Materials.lua`, `RecipeUses.lua`, `Recipes.lua` | Generated profession, reagent, reverse-use and **2,506-recipe** local indices |
| `Domain/MaterialLookup.lua`, `MaterialSearch.lua`, `ProfessionTree.lua` | Source-backed filtering, stable profession grouping and pure expand/search-restore projection |
| `Domain/RecipeUsage.lua` | Material → actual recipe uses and pure pagination |
| `Domain/RecipeCatalog.lua` | Unique profession+spellID recipe identity, ingredient detail and recipe search |
| `Domain/CraftableTracking.lua` | Pure unit-weighted ingredient coverage, unknown-count semantics and duplicate material consolidation |
| `Domain/CatalogProgress.lua` | Pure per-view attempted-unit percentages and a one-pending-redraw coalescing gate |
| `Infrastructure/ItemInfo.lua`, `RecipeInfo.lua`, `RecipeNameCache.lua` | Guarded asynchronous client item/spell names/icons and native tooltips |
| `Infrastructure/ChatLinks.lua` | Guarded client-provided item/spell hyperlinks, Shift-click detection and native chat-edit insertion without sending |
| `Infrastructure/InventoryCounts.lua` | Guarded character bag counts, bank-open freshness gating and separate bag/bank observations |
| `Infrastructure/TooltipAdapter.lua`, `Features/Tooltip/Tooltip.lua` | One guarded item-tooltip hook and native, alphabetized profession rows with localized labels |
| `Infrastructure/Preferences.lua`, `MinimapButton.lua` | Language preference, global per-character craft-tracking mode (legacy recipe flags ignored) and movable minimap access |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | Client locale and enUS/esES strings |
| `Features/Settings/Settings.lua` | Single native window, tabs, state, selected details, cross-view navigation, working close |
| `Features/Settings/Shared/ExplorerWidgets.lua` | Reusable native search box, profession selector, result row, pager and layout helpers |
| `Features/Settings/RecipePanel.lua` | Material-detail bounded native vertical fabrication-use rows with pagination |
| `Features/Settings/RecipesView.lua` | Fabricables detail with ingredient pagination, item hover, localized optional tracker, current inventory counts and bounded native progress bars |

The loading order is declared in `addon/CraftAtlas/CraftAtlas.toc`; all addon runtime files belong under `addon/CraftAtlas/`, not in `docs/`.

## Behavior and UI

The minimap adapter projects the pointer angle onto the circular edge in the minimap's own scale. It samples the pointer only during a drag and once more on release, then stores the angle in the existing account-wide preferences. Missing geometry or a centered pointer preserves the last valid angle. A drag suppresses clicks from its own gesture; the next left-button press starts a new gesture. Hover resolves the title and two control hints in the active locale each time.

Material item tooltips render after the native item lines on the existing `TooltipDataProcessor` path. The presenter reads the CraftAtlas catalog by itemID and appends a separator, the native gold `Used in:` / `Utilizado en:` heading, and one white row per consuming profession. It tracks native clears per tooltip to keep repeat callbacks idempotent and uses the line count and hide hook when the clear script is unavailable. The Spanish tooltip uses `Costura` for Tailoring to match the reference presentation. The explorer uses its existing registry label, `Sastrería`.

The 14 × 14 inline icons use native `SkillLine.SpellIconFileID` identifiers from Forever build `1.60.1.70938`, documented by Profession Reagents 1.0.0 (MIT, copyright 2026 sebasgrios). Detected missing icons fall back to text. [Pinned Profession Reagents reference](https://github.com/sebasgrios/profession-util/tree/66555a5c5c1d4ad3d3c2f8d5d0982beb2b23a4b8/addons/ProfessionReagents) · [CraftAtlas catalog provenance](DATA_MODEL.md)

`/craftatlas` and the minimap button open the **Materiales** tab. It filters only items known to be actual recipe **inputs**, by itemID/name and consuming profession. The left pane projects filtered unique itemIDs into source-backed collapsible profession groups, virtualizing the visible row pool. It preserves group expansion across view navigation and restores pre-search collapse state after clearing a query. The right pane shows client-provided item metadata when available, a collapsible profession-use section with client icons, four entries across on normal panes and a compact two-column fallback (arrows only when professions exceed visible capacity), and a separate collapsible section of paginated vertical crafting-use rows. Collapsing professions reflows the recipe section and its bounded page size. Hover uses the game client; clicking a use opens its **Fabricables** detail.

**Fabricables** presents a native-bordered output icon and a collapsible gold-divided ingredient section with a count taken from the catalog. It browses unique recipe keys (`professionKey:spellID`) with client-resolved spell/output names, profession filter and numeric spellID search. The detail presents its consuming profession, actual output where known, and all recorded ingredient itemIDs with exact quantities. Enchantments/non-item actions are identified rather than invented as physical items. Clicking an ingredient navigates back to Materiales. Cross-navigation keeps view-local query/filter and a bounded Back history. Some spell/item names can be unavailable in the client cache; this limits text searches and is surfaced as incomplete results.

UI uses WoW-native frames, no CSS framework or external runtime API. Reusable gold divider rows distinguish profession groups from material results; material entries omit redundant profession subtitles while retaining icon/name and selected-ID highlight. Their collapse affordance and selected-item highlight are independent. The shared clear control uses a native panel-close X texture embedded inside the edit box rather than an unreliable broom icon; it appears only for a nonempty query, preserves the other view's search and retains the localized tooltip; the discreet bottom-right version footer derives only from a locally installed numeric release SemVer, never the tracked development manifest. The compact shell uses a bounded scale rather than clipping its fixed control regions. Blizzard native UIDropDownMenuTemplate is used for language and profession selection on supported clients, with original clickable Classic red-button selectors as fallbacks. Tabs, Back and paging retain UIPanelButtonTemplate; the inline search X uses Blizzard's existing panel-close texture. The custom section/divider layout uses native plus/minus artwork; all original callbacks are preserved. The shared controls are factored out of a single shell, not duplicated between Materiales and Fabricables. The window's X explicitly hides the standalone frame.

## First-use preparation and performance

`Infrastructure/ItemInfo.lua` processes up to 20 material itemIDs per 0.1-second timer callback; `Infrastructure/RecipeNameCache.lua` processes up to 25 recipe records per 0.08-second callback, when supported by Forever. Each publishes separate attempted-work progress and avoids calling a full catalog search directly per batch. The view coordinator coalesces background/cache-event redraw requests within a 0.4-second window, while user actions (search, filter, language, Back, selection) refresh immediately. Results are memoized by active view, query, profession, effective locale and data-generation counter, and invalidated when client names/icons resolve. The native header shows only the currently active view's work progress in a compact width-capped gold track with high-contrast text immediately above it, centered in the toolbar between the native tabs and Back so the title and header divider remain unobstructed; after its scheduled attempts complete the bar hides, while unresolved client metadata remains indicated independently. Missing deferred APIs stop after a bounded initial batch, visibly recording incomplete preparation rather than draining synchronously. `/craftatlas perf` exposes local counters without saved statistics or telemetry. No generated data, itemID or profession+spellID identities are changed. Native tooltips, not CraftAtlas, supply equipment statistics/rarity.

## Data integrity and limits

A deterministic offline generator `scripts/build_materials.py` compiles `Materials.lua`, `Professions.lua`, `RecipeUses.lua`, `Recipes.lua` and coverage evidence from licensed pinned JSON source records. **593** distinct inputs, **8,455** reagent-use rows and **2,506** unique recipes are source-snapshot counts. Do not conflate source verification with testing each recipe on the current Forever server. A recipe may produce an item that itself is an ingredient. A full dependency graph, crafting automation, player-known recipes and inventory stock calculations are outside the current implementation.

## Validation and change control

`bash scripts/validate_release_checks.sh` is the common PR/release gate. `.github/workflows/spec-compliance.yml` separately enforces the OpenSpec approval chain. Python and Lua fixtures supplement these; exact Forever build/manual acceptance and untested item-tooltip origins should be recorded in `docs/TESTING.md`. See [data model](DATA_MODEL.md), [development](DEVELOPMENT.md) and [SDD policy](SDD_COMPLIANCE.md).
