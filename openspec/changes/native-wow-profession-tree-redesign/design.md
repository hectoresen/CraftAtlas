# Design: WoW-native grouped profession browser

## Reference analysis → actual application behavior

| Concept image element | Proposed implementation | Evidence constraint |
| --- | --- | --- |
| Dark metal/stone border, gold header, large crafting emblem | Native window with Blizzard/Classic-compatible NineSlice/texture or a restrained game-native fallback | Use supported client assets; do not bundle/extract copyrighted UI resources |
| Top-left magnifying-glass search | Keep **functional** `CreateExplorerSearchBox`, clear button and view-local query | Existing search cannot become decorative |
| Profession dropdown above left list | Keep actual source-backed profession filter | Existing selected filter and full list semantics persist |
| Grouped Alquimia / Sastrería / Herrería sections | New profession-key grouped tree, expand/collapse, counts | Only catalog relations; duplicates across groups remain itemID-identical |
| Large selected item icon/name, secondary info | Existing client item name/icon, numeric ID, client-verified optional type/item level/quality | Do not hardcode any field shown in image |
| "Utilizado en profesiones" section | Native icon/label rows from actual consuming profession keys | No invented profession icon if unsupported |
| "Recetas (2)" section with single-line result entries | **Se utiliza para fabricar** with count of actual source-backed uses, selectable rows and pagination/scroll | Consistent product terminology; source-backed amounts |
| Item type and level panel | Conditional **Detalles** panel when real client item metadata is available | Hide or say unavailable, never invent |
| Missing tabs in concept screenshot | Preserve **Materiales** and **Fabricables** tab navigation, Back and language selector | Existing approved behavior cannot regress |

## Data and domain

Retain `Data/Materials.lua`, `Data/RecipeUses.lua`, `Data/Recipes.lua`, stable profession registry, all data provenance, and `Domain/MaterialLookup.lua` semantics unchanged.

Add a pure function such as `BuildProfessionTree(filteredItemIDs, materials, professionOrder, expandedKeys, knownNames)`. It returns an ordered sequence of `{kind='group', professionKey, count}` and `{kind='material', professionKey, itemID}` nodes, with:
- Groups in the stable registered profession order; each distinct itemID counted once **per group**.
- Material children sorted by available localized client name with stable itemID tie-breaker; if missing, numeric fallback; avoid locale-dependent domain identity.
- No empty groups unless needed to show a no-results explanatory state; global result count uses **unique itemIDs**, not total visible occurrences.
- A material with multiple profession keys appears in each applicable expanded group, but navigation and detail selection always use its single itemID.
- Global selected profession filter and search are applied by existing `FilterMaterials` first; expanding a group shows only filtered matches.
- When query becomes non-empty, relevant groups auto-expand for discoverability **unless the user explicitly collapses them while searching**. On clearing query, restore the pre-search expanded-state snapshot. A filter change retains meaningful collapsed keys where possible.
- Existing async name cache invalidation rebuilds group labels/order deterministically and preserves selected itemID/scroll anchor where possible.

Render only the visible row window (virtualized list or fixed reusable row pool) using a flattened projection; rows can represent group headers or child entries and must be recycled. The native ScrollBar and mouse wheel track the projection length, never count duplicated IDs as additional search results.

## Native shell and detail layout

Keep `Features/Settings/Settings.lua` as the view/state coordinator, with a single main frame. Allocate header/toolbar/tabs and content area from measured window bounds; prefer adaptable anchors rather than magic constants. The new left pane should occupy roughly one-third of the usable width (about 32–40%), right pane the remainder. A reference-like large window is the preferred desktop presentation, but **must** fit supported smaller game viewports without controls disappearing.

- Shared native frame treatments and section bars live in `Shared/ExplorerWidgets.lua` or a dedicated `Shared/NativeTheme.lua` if needed. Do not depend on Retail-only templates.
- Header: centered gold title, working search, clear, language; tabs and Back remain accessible and visibly distinguish selected state.
- Material detail: icon/title/ID top block; non-overlapping profession-use panel; explicit fabrication-use panel; conditional native item metadata details. Collapsible **section headings** may be added only where tested and with safe defaults. The left profession tree has expandable group headers.
- Replace six-card recipe grid with readable native **recipe rows**, preserving click to Fabricables, material-used quantity, item/spell hover, pagination and empty/no-output states. Use a fixed visible page size or responsive scrolling, tested with 0/1/many uses; don't clip pager.
- Fabricables detail reuses section styling and ingredient rows, showing **all source-backed ingredients/quantities**, with paging/scroll and cross-navigation.
- All visible labels localized; no screenshot-only fake quality (green item title), type, item level, profession icon, counts or decoration.

## State and navigation

Store per-view search/filter, selection by numeric itemID or profession+spellID, scroll offset, recipe/ingredient page and left-tree expanded group keys. Cross-view Back must restore exactly the prior selection/page/filter; manually switching tabs preserves each tab's state. Avoid recursive search callbacks, duplicate frames/close handlers and dangling item hover overlays.

## Verification

- **Pure Lua:** grouping order, multi-profession duplicates, distinct counts, filter+search+collapse/restore, stable selection on async name load, no empty/hardcoded groups, pagination and preserved recipe quantities.
- **UI mocks:** group click behavior, row recycling, section visibility, close/reopen, tab switch/Back, no tooltip duplicates, item metadata conditionality and enUS/esES.
- **Layout:** two representative window sizes (standard and minimum) and multiple UI scales; no header overlap, scrollbar obscuring clickable rows, clipped footer or phantom hover.
- **In-game manual matrix:** exact Forever build, item 2447 (Peacebloom), item 159, material 14044/recipe 19093, multi-profession material 14341, unknown item, non-item enchantment, long recipes, fast search/filter, item cache unavailable/reload and tooltip behavior; record screenshots and outcomes. These IDs are fixtures/examples, not proof of live coverage.
- **Documentation:** `documentation-sync` before implementation PR; README, testing, architecture, installation, changelog and roadmap, preserving clear distinction between beta source and real-client evidence.

## Rollback

Revert implementation PR to restore flat list and six-card view; leave licensed data and current domain recipe indices untouched. Do not revert the approved spec during code rollback.
