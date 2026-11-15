# Architecture — current implementation

CraftAtlas is an installable Lua addon with a pragmatic separation of domain, client APIs and UI. It **is implemented and reported working in Forever by the maintainer**, not an empty scaffold. It uses no runtime networking, telemetry or required third-party addon.

| Module | Runtime responsibility |
| --- | --- |
| `Core/Init.lua` / `Core/Bootstrap.lua` | Namespace, lifecycle, initialization after `ADDON_LOADED` |
| `Domain/MaterialLookup.lua` | Pure numeric itemID → ordered consuming-profession keys; no WoW API calls |
| `Data/Professions.lua` / `Data/Materials.lua` | Compact, generated offline profession registry and 593-material map |
| `Infrastructure/TooltipAdapter.lua` | Single `TooltipDataProcessor.AddTooltipPostCall` item hook and numeric itemID extraction |
| `Features/Tooltip/Tooltip.lua` | Localized two-line profession annotation and refresh deduplication |
| `Infrastructure/Preferences.lua` | Saved language choice and minimap angle in account-wide `CraftAtlasDB` |
| `Infrastructure/MinimapButton.lua` | Draggable minimap entry point to settings |
| `Localization/Locales.lua`, `ProfessionLabels.lua` | English/Spanish labels and fallback |
| `Features/Settings/Settings.lua` | Native-style General panel, language choice and `/craftatlas` command |

## Runtime flow

WoW item tooltip → numeric itemID from structured tooltip data → pure map lookup → ordered consuming professions → locale-aware tooltip lines. Missing IDs produce no annotation. Tooltip registration is guarded for unsupported APIs and callback errors. The UI panel is available via slash command and minimap.

**Settings search is not functional.** `createSearchAffordance()` creates a visual Button/label and unavailable cursor; there is **no edit box, filtering or results handler**. The current General page and language selector are functional. Material search, recipe graph and ingredient quantities are future work.

## Data architecture

A 593-item, ten-profession local index is generated from a provenance-bearing source file. The large JSON (~678 KB) is build evidence; the small Lua runtime map (~25 KB) is what the client loads. This snapshot comes from an MIT-licensed LibProfessionDB Forever beta build 69977; it is not a full live server catalog. See [Data model](DATA_MODEL.md).

## Compatibility and acceptance

The maintainer reported successful in-game operation of the current addon on **15 November 2026**. The exact tested Forever build and separate bank/auction/chat/vendor origin results have not been recorded. The approved original [v0.0.1 inventory spec](../openspec/changes/add-first-playable-material-tooltips/specs/inventory-tooltips/spec.md) formally guarantees inventory/bag behavior only; avoid silently extending its documented acceptance scope.

The tooltip API belongs at the infrastructure edge; pure lookup stays testable with Lua fixtures. Do not infer mappings from localized names or add speculative modules. Source/code/spec changes follow [OpenSpec governance](../openspec/README.md) and [code quality standards](CODE_QUALITY.md).
