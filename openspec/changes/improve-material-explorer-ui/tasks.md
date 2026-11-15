# Tasks — material explorer UI

## A. Approved change gate
- [x] A1 Owner explicitly authorized a combined specification + implementation on existing PR #14 (2026-11-15); merge remains owner-only.
- [x] A2 Verified main and current OpenSpec before writing code.

## B. Search and data adapter
- [x] B1 Build deterministic numeric itemID search/filter logic with stable consuming profession keys.
- [x] B2 Implement safe client item-name/icon lookup and cache-miss/unknown fallback without fabricated names.
- [x] B3 Support query by known localized name or numeric itemID, and report incomplete name coverage honestly.
- [ ] B4 Add tests for unknown IDs, multi-profession, query/filter conjunction, name-loading, locale changes and stale updates.

## C. Native explorer UI
- [x] C1 Preserve BasicFrameTemplateWithInset when available, existing header search/title/language positions and single title.
- [x] C2 Moderately enlarge window, accommodate viewport/UI scale, and size ~38/62 results/detail panes with adequate spacing.
- [x] C3 Replace disabled search affordance with functional instant search, plus a small native clear control.
- [x] C4 Build profession dropdown, localized result count, scrollable icon/name rows, native selection highlight and empty states.
- [x] C5 Build detail pane showing icon, name/itemID fallback, all consuming professions, and honest recipe-unavailable state.
- [ ] C6 Preserve selection, filters, search text and meaningful return navigation; ensure no overflow with long strings.
- [x] C7 Preserve Auto/esES/enUS behavior and persistence, slash command, minimap button position and existing annotations.
- [x] C8 Add/adjust enUS and esES strings and UI tests/mocks.

## D. Tooltip navigation
- [x] D1 Investigate safe supported Forever tooltip-to-explorer interaction; record actual client APIs and constraints.
- [x] D2 Tooltip click not enabled: supported safe interaction could not be verified without the real client. Existing annotations remain unchanged; /craftatlas <itemID> is a safe direct-entry alternative.
- [ ] D3 Verify repeated hovers, tooltip refresh, protected UI frames, keyboard/mouse interaction and return flow.

## E. Quality and release handoff
- [ ] E1 Run repository validation, source generation checks, relevant Python and Lua tests, and OpenSpec strict validation.
- [ ] E2 Record actual Forever client build and a manual matrix for layouts/UI scale, item loading, locale, filters, mouse/keyboard and tooltip behavior.
- [x] E3 Update README, architecture, roadmap, testing, functional docs and changelog to distinguish real implementation from planned recipe browsing.
- [x] E4 Updated existing PR #14 with OpenSpec-Change/Phase=combined; explicitly owner-authorized SDD exception, no direct main changes or release.
