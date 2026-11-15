# Tasks — material explorer UI

## A. Approved change gate
- [ ] A1 Have owner review and merge this proposal PR before implementation.
- [ ] A2 Recheck current main and accepted OpenSpec deltas immediately before the implementation PR.

## B. Search and data adapter
- [ ] B1 Build deterministic numeric itemID search/filter logic with stable consuming profession keys.
- [ ] B2 Implement safe client item-name/icon lookup and cache-miss/unknown fallback without fabricated names.
- [ ] B3 Support query by known localized name or numeric itemID, and report incomplete name coverage honestly.
- [ ] B4 Add tests for unknown IDs, multi-profession, query/filter conjunction, name-loading, locale changes and stale updates.

## C. Native explorer UI
- [ ] C1 Preserve BasicFrameTemplateWithInset when available, existing header search/title/language positions and single title.
- [ ] C2 Moderately enlarge window, accommodate viewport/UI scale, and size ~38/62 results/detail panes with adequate spacing.
- [ ] C3 Replace disabled search affordance with functional instant search, plus a small native clear control.
- [ ] C4 Build profession dropdown, localized result count, scrollable icon/name rows, native selection highlight and empty states.
- [ ] C5 Build detail pane showing icon, name/itemID fallback, all consuming professions, and honest recipe-unavailable state.
- [ ] C6 Preserve selection, filters, search text and meaningful return navigation; ensure no overflow with long strings.
- [ ] C7 Preserve Auto/esES/enUS behavior and persistence, slash command, minimap button position and existing annotations.
- [ ] C8 Add/adjust enUS and esES strings and UI tests/mocks.

## D. Tooltip navigation
- [ ] D1 Investigate safe supported Forever tooltip-to-explorer interaction; record actual client APIs and constraints.
- [ ] D2 Implement click-to-open only if safe/approved; otherwise record explicit unmet gate and preserve non-interactive tooltip behavior.
- [ ] D3 Verify repeated hovers, tooltip refresh, protected UI frames, keyboard/mouse interaction and return flow.

## E. Quality and release handoff
- [ ] E1 Run repository validation, source generation checks, relevant Python and Lua tests, and OpenSpec strict validation.
- [ ] E2 Record actual Forever client build and a manual matrix for layouts/UI scale, item loading, locale, filters, mouse/keyboard and tooltip behavior.
- [ ] E3 Update README, architecture, roadmap, testing, functional docs and changelog to distinguish real implementation from planned recipe browsing.
- [ ] E4 Open implementation PR citing approved spec PR with OpenSpec-Change/Phase/Approval metadata; no direct main changes or release.
