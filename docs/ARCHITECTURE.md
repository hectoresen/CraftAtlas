# Architecture — current implementation

CraftAtlas is an installable Lua addon with a pragmatic separation of domain, client APIs and UI. It **is implemented and reported working in Forever by the maintainer**, not an empty scaffold. It uses no runtime networking, telemetry or required third-party addon.

| Module | Runtime responsibility |
| --- | --- |
| `Core/Init.lua` / `Core/Bootstrap.lua` | Namespace, lifecycle, initialization after `ADDON_LOADED` |
| `Domain/MaterialLookup.lua` | Pure numeric itemID → ordered consuming-profession keys; no WoW API calls |
| `Domain/MaterialSearch.lua` | Pure local material filtering by itemID/name and consuming profession; no WoW APIs |
| `Infrastructure/ItemInfo.lua` | Client item-name and icon adapter with bounded one-time background requests and cache-miss fallbacks |
| `Data/Professions.lua` / `Data/Materials.lua` | Compact, generated offline profession registry and 593-material map |
| `Infrastructure/TooltipAdapter.lua` | Single `TooltipDataProcessor.AddTooltipPostCall` item hook and numeric itemID extraction |
| `Features/Tooltip/Tooltip.lua` | Localized two-line profession annotation and refresh deduplication |
| `Infrastructure/Preferences.lua` | Saved language choice and minimap angle in account-wide `CraftAtlasDB` |
| `Infrastructure/MinimapButton.lua` | Draggable minimap entry point to settings |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | English/Spanish labels and fallback |
| `Features/Settings/Settings.lua` | Native frame material explorer, search/list/detail UI, language selector and `/craftatlas [itemID]` command |

## Runtime flow

WoW item tooltip → numeric itemID from structured tooltip data → pure map lookup → ordered consuming professions → locale-aware tooltip lines. Missing IDs produce no annotation. Tooltip registration is guarded for unsupported APIs and callback errors. The UI panel is available via slash command and minimap.

**New material explorer implementation (Forever game QA pending):** Settings search uses an EditBox, instant itemID/name filtering, profession dropdown, recycled item rows, icon/name fallbacks, material detail and unavailable-recipes state. Search depends on client-cached names; an itemID fallback remains. Recipe graph, recipe quantities and clickable tooltip navigation are not implemented. Direct command entry `/craftatlas 2447` selects a known material by itemID, as a safe alternative.

## Data architecture

A 593-item, ten-profession local index is generated from a provenance-bearing source file. The large JSON (~678 KB) is build evidence; the small Lua runtime map (~25 KB) is what the client loads. This snapshot comes from an MIT-licensed LibProfessionDB Forever beta build 69977; it is not a full live server catalog. See [Data model](DATA_MODEL.md).

## Compatibility and acceptance

The maintainer reported successful in-game operation of the pre-PR-14 addon on **15 November 2026**. The new material explorer has **not** been verified in the Forever client. The exact tested Forever build and separate bank/auction/chat/vendor origin results have not been recorded. The approved original [v0.0.1 inventory spec](../openspec/changes/add-first-playable-material-tooltips/specs/inventory-tooltips/spec.md) formally guarantees inventory/bag behavior only; avoid silently extending its documented acceptance scope.

The tooltip API belongs at the infrastructure edge; pure lookup stays testable with Lua fixtures. Do not infer mappings from localized names or add speculative modules. Source/code/spec changes follow [OpenSpec governance](../openspec/README.md) and [code quality standards](CODE_QUALITY.md).
