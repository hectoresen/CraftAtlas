# Architecture — current source

CraftAtlas is an offline WoW Forever Lua addon. See the testing record for in-game evidence by explorer revision and client build.

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
| `Infrastructure/TooltipAdapter.lua`, `Features/Tooltip/Tooltip.lua` | One guarded item-tooltip hook and configurable localized profession annotations |
| `Infrastructure/Preferences.lua`, `MinimapButton.lua` | Account display preferences, global per-character craft tracking (legacy recipe flags ignored) and movable minimap access |
| `Infrastructure/AddonSettings.lua`, `Features/Settings/PreferencesPanel.lua` | Guarded native AddOn category registration and the General and Tooltip controls |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | Client locale and enUS/esES strings |
| `Features/Settings/Settings.lua` | Single native window, frame strata, tabs, view state, cross-view navigation and Escape/X dismissal |
| `Features/Settings/Shared/ExplorerWidgets.lua` | Reusable native search box, language and profession selectors, result row, pager and layout helpers |
| `Features/Settings/RecipePanel.lua` | Material-detail bounded native vertical fabrication-use rows with pagination |
| `Features/Settings/RecipesView.lua` | Fabricables detail with ingredient pagination, item hover, localized optional tracker, current inventory counts and bounded native progress bars |

The loading order is declared in `addon/CraftAtlas/CraftAtlas.toc`; all addon runtime files belong under `addon/CraftAtlas/`, not in `docs/`.

## Behavior and UI

The minimap adapter projects the pointer angle onto the circular edge in the minimap's own scale. It samples the pointer during a drag and on release, then stores the release angle in account-wide preferences. Missing geometry or a centered pointer preserves the last valid angle. Drag release suppresses its own left-click. Hover highlights the localized left-click, drag and right-click labels in dark gold and shows their actions in white.

After SavedVariables load, the settings adapter registers one CraftAtlas page in the game's **Options → AddOns** through the native canvas API. A minimap right-click opens that category by its registered ID through `Settings.OpenToCategory`. The page owns the language selector and refreshes when shown. The explorer reads the same saved preference when updating labels. Toggling minimap visibility reuses the existing button and restores its saved angle.

Material item tooltips render after the native item lines on the existing `TooltipDataProcessor` path. When enabled, the presenter reads the CraftAtlas catalog by itemID and appends a separator, the native gold `Used in:` / `Utilizado en:` heading, and alphabetized professions in white. It renders one row per profession by default or one comma-separated native line that the client can wrap. The icon preference applies to both layouts. The presenter tracks native clears to suppress repeat callbacks and uses the number of lines rendered and the hide hook when the clear script is unavailable. Spanish tooltips use `Costura` for Tailoring, and the explorer uses its existing registry label, `Sastrería`.

The 14 × 14 inline icons use native `SkillLine.SpellIconFileID` identifiers from Forever build `1.60.1.70938`, documented by Profession Reagents 1.0.0 (MIT, copyright 2026 sebasgrios). Detected missing icons fall back to text. [Pinned Profession Reagents reference](https://github.com/sebasgrios/profession-util/tree/66555a5c5c1d4ad3d3c2f8d5d0982beb2b23a4b8/addons/ProfessionReagents) · [CraftAtlas catalog provenance](DATA_MODEL.md)

`/craftatlas` and the minimap button open the **Materiales** tab. It filters only items known to be actual recipe **inputs**, by itemID/name and consuming profession. With a specific profession selected, the left pane renders the ordered filtered itemIDs directly. With **All professions**, it projects those IDs into source-backed collapsible groups. Both presentations use the same bounded row pool and scroll against the active result rows. The tree preserves expansion choices across view navigation and profession changes and restores pre-search collapse state after clearing a query. The right pane shows client-provided item metadata when available, a collapsible profession-use section with client icons, four entries across on normal panes and a compact two-column fallback (arrows only when professions exceed visible capacity), and a separate collapsible section of paginated vertical crafting-use rows. Collapsing professions reflows the recipe section and its bounded page size. Hover uses the game client; clicking a use opens its **Fabricables** detail.

**Fabricables** presents a native-bordered output icon and a collapsible gold-divided ingredient section with a count taken from the catalog. It browses unique recipe keys (`professionKey:spellID`) with client-resolved spell/output names, profession filter and numeric spellID search. The detail presents its consuming profession, actual output where known, and all recorded ingredient itemIDs with exact quantities. Enchantments/non-item actions are identified rather than invented as physical items. Clicking an ingredient navigates back to Materiales. Cross-navigation keeps view-local query/filter and a bounded Back history. Some spell/item names can be unavailable in the client cache; this limits text searches and is surfaced as incomplete results.

The Craftables header reads its source-backed minimum skill and teaching-item ID from the selected catalog record. `Infrastructure/ProfessionRequirements.lua` uses guarded player profession and recipe reads keyed by numeric skill line and spell ID. An exact offer in the open trainer window is evidence of an item-free learning path. The recipe-required label is shown only for a catalog teaching item without an observed trainer alternative. An unavailable learned state uses a neutral color. Profession and trainer events refresh the displayed requirements without redrawing the ingredient list. The title, subtitle, lower metadata row, and first section divider follow the Materials detail layout. The level has a full-width row below the profession. The `ID <spellID>` line anchors the right-hand **Track crafting** checkbox on the same row.

The explorer uses `SettingsFrameTemplate`, `MinimalTabTemplate` and the native `Options_InnerFrame` artwork where available. The shared inset divides the dark translucent body into a narrow results sidebar and a wider detail area. The tabs size to their localized labels and sit in the same row as the search field and Back. Sidebar groups, collapsible detail sections and tracking headings reuse the native Options category artwork. A clipped viewport owns the recycled rows and scrollbar. Each Craftables profession subtitle has a bounded area inside the row highlight. The explorer and its descendants use the same `DIALOG` stratum so the entire window sits above the HUD and ordinary game panels. Native dropdowns and tooltips retain their overlay behavior.

The native AddOn options language selector builds its selection indicator from the saved account value, including `auto` when the effective locale resolves to English or Spanish. The client dismisses the explorer through an addon-owned child registered in `UISpecialFrames`. That child is armed only while the explorer is visible. It dismisses a local fallback popup before closing the window. The search box uses the same dismiss action. Both Escape and the window X clear owned menus, search focus and tooltips when hiding the window.

## First-use preparation and performance

`Infrastructure/ItemInfo.lua` processes up to 20 material itemIDs per 0.1-second timer callback; `Infrastructure/RecipeNameCache.lua` processes up to 25 recipe records per 0.08-second callback, when supported by Forever. Each publishes separate attempted-work progress and avoids calling a full catalog search directly per batch. The view coordinator coalesces background/cache-event redraw requests within a 0.4-second window, while user actions (search, filter, language, Back, selection) refresh immediately. Results are memoized by active view, query, profession, effective locale and data-generation counter, and invalidated when client names/icons resolve. The footer centers the active view's progress in a width-capped gold track with the percentage immediately above it. After scheduled attempts complete the bar hides, while unresolved client metadata remains indicated independently. Missing deferred APIs stop after a bounded initial batch, visibly recording incomplete preparation rather than draining synchronously. `/craftatlas perf` exposes local counters without saved statistics or telemetry. No generated data, itemID or profession+spellID identities are changed. Native tooltips, not CraftAtlas, supply equipment statistics/rarity.

## Data integrity and limits

A deterministic offline generator `scripts/build_materials.py` compiles `Materials.lua`, `Professions.lua`, `RecipeUses.lua`, `Recipes.lua` and coverage evidence from licensed pinned JSON source records. **593** distinct inputs, **8,455** reagent-use rows and **2,506** unique recipes are source-snapshot counts. Do not conflate source verification with testing each recipe on the current Forever server. A recipe may produce an item that itself is an ingredient. The selected Craftables detail reads the current character's recipe state from the client when available. A full dependency graph, crafting automation and persistent inventory history are outside the current implementation. Opt-in Fabricables progress does calculate observed bag and conditionally available open-bank counts for the currently selected recipe.

## Validation and change control

`bash scripts/validate_release_checks.sh` is the common PR/release gate. `.github/workflows/spec-compliance.yml` separately enforces the OpenSpec approval chain. Python and Lua fixtures supplement these; exact Forever build/manual acceptance and untested item-tooltip origins should be recorded in `docs/TESTING.md`. See [data model](DATA_MODEL.md), [development](DEVELOPMENT.md) and [SDD policy](SDD_COMPLIANCE.md).

## Current pinned catalog contract (UPD005, implementation pending client acceptance)

`Data/recipes.source.json` is the canonical source for all recipe identities, including zero-reagent actions and two new source-backed camp professions, HERBALISM and SKINNING. `recipe-uses.source.json` and `materials.source.json` are strictly positive-input projections. The generator validates canonical/projection equality before writing Lua. Existing 10 profession indices remain stable; two new keys are appended, preventing record-index shifts. `Domain/RecipeCatalog.lua` exposes optional required skill, teaching item, camping classification, difficulty and vendor IDs. Character learned status comes from guarded client reads. The 28 legacy discrepancy records remain flagged and are not accepted as current live source facts. See `docs/DATA_MODEL.md` and `Data/reconciliation-report.json` for provenance. Real-client tests are NOT RUN.
