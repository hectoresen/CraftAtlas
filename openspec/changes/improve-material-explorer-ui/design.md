# Design: native material explorer

## Baseline and visual authority
The existing Settings.lua builds a BasicFrameTemplateWithInset frame, header, left visual-only search Button, centered GameFontNormalLarge CraftAtlas title, right language selector and empty General area. The approved V3 interactive mockup is a layout/interaction reference (moderately larger window, more breathing room, left list/right detail), **not** a source of production WoW textures or styles. Preserve native WoW appearance and existing header placement. Do not reconstruct an imitation CSS theme or introduce a second title.

## Proposed modules and responsibilities
- Domain: pure itemID-based matching/filtering/selection rules, with stable profession keys and deterministic ordering; never use translated names as material identity.
- Data: use the existing numeric catalog and profession registry. Derive searchable material ID lists from it, not a new fabricated dataset.
- Infrastructure: small client adapter to request/read cached item names/icons safely and to expose supported, non-invasive tooltip interaction. Cache reads by itemID and update results when data becomes available; no network or per-frame polling.
- Features/Settings: adapt the existing panel and localization to house a reusable material explorer. A separate thin MaterialExplorer presenter may be introduced if warranted; keep the original settings entry points and preferences. Avoid unnecessary abstraction.
- Features/Tooltip: retain the current annotation logic and deduplication; integrate opening of the explorer only when a player explicitly invokes an interaction verified safe for Forever.

## UI layout and interaction
1. Retain the window's native frame/title area, no duplicated header title; header contains search (left), centered CraftAtlas text, language control (right). The search area includes a compact clear control with a **verified native** icon/texture; do not claim a broom asset exists until confirmed. If none is available, use a native clear button with an accessible label.
2. Resize to a moderately larger default than 560x340 (initial target approximately 740x460 UI units, adjustable for the client), with a bounded/clamped frame for available screen size and UI scale. The content beneath the header comprises a ~38% results column and ~62% detail pane, enough padding to avoid crowding.
3. The left pane contains one profession dropdown, a localized results count, and a scrollable compact list of item icons, names/itemID fallback and compact consuming-profession text. A selected result uses a standard client-native highlight.
4. Search updates promptly after text changes without pressing Enter, preserves user text and current profession filter, matches normalized client-visible names and exact/partial numeric itemID input; restrict scanning to local catalog. When names are not yet in the client cache, communicate incomplete name matching and keep itemID lookup available. Do not silently invent names, display false empty-state certainty, or require a synchronous 593-item fetch. If the client emits supported item-info-ready events, coalesce refreshes and prevent stale asynchronous updates.
5. Clicking a result shows one detail pane: item icon, localized name or itemID placeholder, numeric ID and all consuming professions. Do not render fake recipe items/counts; a localized unavailable-state message is acceptable.
6. Switching results does not clear the query or filter. Changing a filter refreshes the list while selecting a visible item or presenting an empty detail; clear removes query only and focuses the search. Keep selection when still valid. Direct tooltip navigation selects its itemID and provides a clear return to prior list/query/filter without destroying the previous state.
7. Existing language selection immediately refreshes labels, search text matching as names become available, list labels and current detail. Preserve account-wide language persistence. Changing UI locale does not magically translate the client's item name; it remains the name provided by the game client.

## Tooltip safety
The current global item TooltipDataProcessor post-call is informational, not a guaranteed clickable region. Verify a supported event or deliberate click action in the actual Forever client, without hijacking ordinary item-click or protected frame behavior. If no safe direct interaction exists, this requirement is gated for owner review: do not implement an unsafe hook or falsely mark it completed. Keep existing tooltip annotations unchanged.

## Performance and error handling
Precompute/copy lightweight search fields by itemID on init or lazily; do not trigger item-info retrieval on every keystroke. Debounce/coalesce only when supported and needed; cap synchronous UI work and avoid unbounded frame allocation, scanning every frame or chat spam. Cache misses, unknown IDs, missing APIs, nil textures and bad data must have deterministic fallbacks. No hard runtime dependency or internet connection.

## Verification
Use Python data tests for catalog integrity, Lua pure-domain/mock tests for search/filter/selection and adapter behavior, repository validation and OpenSpec strict validation. Manually test real Forever frame/template availability, item cache and locale behaviors, tooltip entry safety, resolutions/UI scales, min/max string widths, minimap and slash command, and regression of standard tooltip annotation. Record exact client build and per-case pass/fail/not-run; web mockup is not in-game evidence.
