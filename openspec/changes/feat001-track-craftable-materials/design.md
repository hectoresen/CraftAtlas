# Design — opt-in, one-recipe material tracking

## Pure domain

Use a pure `ComputeCraftableCoverage(ingredients, observedCounts)`-style function in `Domain/`, with ingredient identities from the catalog and nonnegative integer quantities. For ingredient i, required r, trustworthy observed available a: covered = min(r, a); missing = max(0, r - a). Aggregate = sum(covered) / sum(required), capped to [0,1], weighted by **units** rather than ingredient rows. Deduplicate duplicate itemID ingredient requirements before aggregation to avoid counting a shared stack twice. If ingredient data or observed counts are incomplete, mark the aggregate as **unverified**; never show a misleading confirmed 100%. Handle no-ingredient and unknown-quantity recipes without division by zero or invented requirements. Show the required amount even if names/icons have not yet resolved.

## Inventory and bank adapter

A small `Infrastructure/` module probes the available supported Forever API (prefer `C_Item.GetItemCount`; guard `GetItemCount` fallback only where present) for **current character** counts, using itemID and a false includeBank flag for bag count. Avoid counting item charges as items. Querying with includeBank true may return combined counts; bank-only = max(0, combined - bag) **only when both numbers are trustworthy for the same observation and current bank access semantics have been validated**.

Do not assume that includeBank true at any time means a fresh bank read: when bank is closed and the API's freshness is not demonstrated, bank-only is **unknown** and excluded from confirmed coverage. When bank is open, establish a current bank observation, or use scoped bank slot APIs if needed by Forever's behavior. Do not silently preserve a guessed previous bank value. A future saved bank snapshot is explicitly out of scope for this first feature; label missing bank information rather than zeroing it.

Guard every API call and event registration. Debounce or coalesce bag and bank update events (e.g. BAG_UPDATE_DELAYED, BANKFRAME_OPENED/CLOSED, PLAYERBANKSLOTS_CHANGED as supported) and refresh only the selected tracked detail. On error, return an unavailable observation, not zero.

## Tracking state

Extend existing `CraftAtlasDB` via `Infrastructure/Preferences.lua` with a safe per-character tracking map keyed by a stable character/realm identity, and each recipe keyed by its **profession + spellID** catalog identity, not recipe display name or transient result position. Switching selected recipe restores the correct toggle state; reloading on the same character preserves it; a different character does not inherit it. If character identity cannot be determined safely at initialization, defer persistence rather than alias two characters. Limit storage to booleans for explicitly tracked recipes, rather than saving inventory counts. Toggle is off by default. The Include bank display preference may persist per character, but cannot override the source's freshness/availability status.

## Native UI and layout

In `Features/Settings/RecipesView.lua`, place a compact checkbox near the selected recipe identity. It must not overlap the output tooltip/link hit targets, profession text, material header, list or pager at compact UI scales.

When enabled, show a distinct compact status subsection **after the required-material list** with a progress summary plus per-item "Have X / Need Y / Missing Z" lines and small native status bars, using a bounded row pool that follows the ingredient pager or a deliberate scrolling arrangement rather than stretching the existing 343px detail region. Keep existing collapsible material header and ingredient pagination behavior intact; collapsing the ingredients should also hide the subordinate progress content. If the UI cannot fit side-by-side ingredient bars without clipping, use progress in the same paged ingredient rows and reserve the subsection for one aggregate bar and bank/stock breakdown. This layout constraint must be assessed in Forever before implementation commits to a fixed height.

If bank inclusion is selected and bank data is unknown/stale, distinguish "Bags: X; Bank: unknown" and compute a **bag-only confirmed baseline**, never label the total as verified. Where bank is freshly readable, display bags and bank separately and compute combined available count, avoiding double-counting the item when bank was included by the API. The progress indicator uses native StatusBar and existing WoW textures. Tooltip and Shift + click remain unchanged for material and recipe objects.

## Locales, test seams and performance

Add only necessary localized strings in enUS/esES with consistent English fallback. Separate counting, storage and UI so Lua 5.1 tests can fake item count APIs, character identity and inventory event bursts. Avoid expensive all-recipe scan; only read the selected recipe ingredient IDs when visible and tracked, on first show and relevant events. Cache invalidation must be bounded and show unknown when untrusted.

## Acceptance and archive

Require CI source, domain, adapter and UI regressions, plus manual Forever testing for the exact bank-open and bank-closed semantics before declaring that optional bank values are supported. Documentation sync and the same-PR archive protocol apply to this change alone. If the game or bank cases remain NOT RUN, use `OpenSpec-Archive: blocked`; do not archive different existing changes.
