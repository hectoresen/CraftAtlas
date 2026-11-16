# Proposal: Optimize catalog preparation and show truthful progress

## Why

The maintainer reports severe, short-lived FPS degradation (approximately ten seconds by observation, **not a measured benchmark**) on the first Materiales and Fabricables exploration in a WoW Forever session. A progress indicator would make the operation understandable, but should not conceal avoidable frame stalls.

Current source inspection identifies repeated full-view work as a plausible source of overhead:
- `Infrastructure/ItemInfo.lua::PreloadMaterialInfo` schedules batches of 20 item lookups every 0.1 seconds, then invokes `RefreshMaterialResults` after **every** batch.
- `Infrastructure/RecipeNameCache.lua::PreloadRecipeNames` schedules batches of 25 recipe-name/output lookups every 0.08 seconds, then invokes `RefreshExplorer` after **every** batch.
- `Features/Settings/Settings.lua::refreshResults` re-filters and re-projects results, updates visible rows, and redraws detail; `Domain/MaterialSearch.lua` sorts material results and `Domain/RecipeCatalog.lua` scans recipes.
- Client cache misses, WoW API cost and event-triggered refreshes may add overhead. These are **hypotheses** until profiled in the game.

The catalog is already embedded offline: **no database download/import or network sync** occurs at runtime. A UI string must not imply remote synchronization.

## Intended outcome

Reduce avoidable first-use work and improve responsiveness, with measurements and regression protection, while showing a compact, localized, **real** progress indicator in the header for the active view.

## In scope

1. **Instrumentation first:** measure per-batch duration, work items visited, full-search executions, UI refresh counts and elapsed time to initial completion for both views. Keep instrumentation opt-in/dev-only and low-overhead; publish baseline vs optimized evidence from the same Forever build/hardware/scenario where possible. If the real client cannot be run by the agent, mark measurements **NOT RUN** rather than claim speedups.
2. **Controlled incremental preparation:** schedule bounded work through guarded Classic/Forever-compatible timing APIs; avoid repeated full-index searches and costly visual updates per batch; coalesce redundant refresh requests and reuse existing visible frame pools. Favor changes with an evidence-backed reduction in redundant work before tuning batch size.
3. **Cache correctness:** reuse search/projection/label work only where safe. Invalidate on newly resolved names/icons, profession labels/locale, active query/filter, source data changes where applicable, and view restoration. Keep numeric itemID and profession+spellID identity and deterministic counts/order.
4. **Truthful progress:** each view tracks independent progress from actual completed preparation units and known totals (material itemIDs, unique recipe records/required lookup units). Display a compact native WoW progress bar/label under the centered header title only while that view has an active preparation phase. Hide at completion; do not invent percentages or show fake elapsed progress. Make clear it is **preparing local catalog information** rather than downloading/synchronizing a database.
5. **Outstanding asynchronous client data:** distinguish completed scheduled attempts from name/icon resolution. A processed item with an unavailable/cached-miss name must not block progress indefinitely or be presented as successfully resolved. Keep existing incomplete-results messages and allow subsequent client event-driven correction.
6. **Lifecycle:** idempotent per-session preparation, no duplicate schedulers/callbacks on reopen or tab switches, sensible behavior if the timer/API is unavailable, and no intrusive bar after a view is ready.
7. **Tests/documentation:** deterministic fake-timer/UI tests, cache invalidation, progress calculations, frame/refresh bounds, localization enUS/esES, long lists, unknown names, navigation and a documented real-client performance test matrix. Run documentation-sync before implementation PR.

## Out of scope

- New data imports/generator changes, new professions/recipes, claimed live-realm coverage, crafting eligibility, server synchronization, network calls, telemetry, SavedVariables-based cross-session cache of client names, or third-party libraries.
- Replacing the approved WoW Classic shell, red native controls, search/filter semantics, tree/detail designs or release workflows.
- A guaranteed fixed FPS improvement or hardcoded completion time without benchmark evidence.
- Reporting percentages for network fetching, full name resolution, or overall item correctness when the metric is scheduled work completion.

## Risks, compatibility and mitigations

- **Client API cost:** WoW name/texture APIs can dominate regardless of Lua algorithm changes; measure separately and use guarded fallbacks.
- **Stale caches:** targeted invalidation and regression tests are required to avoid incorrect search results, grouping, order or missing newly resolved names.
- **Starvation/bursting:** avoid rescheduling unbounded OnUpdate loops or work bursts that degrade frame time; enforce one active worker per workstream.
- **Misleading progress:** 100% means attempted processing completed, not that all client names were resolved. Pending/failed metadata remains represented honestly.
- **Header overlap:** use bounded geometry; progress must not obscure the centered title, tabs, search, language dropdown or close button, especially at low resolutions/UI scale.
- **Lua 5.1/Forever:** only supported native APIs with explicit fallback, no Retail-only assumptions.

## Delivery and rollback

Target a subsequent performance-focused release after v0.2.0, **without promising a version number**. Follow the standard two-PR lifecycle: merge this spec-only PR only with owner approval, then implement within the frozen scope in a separate PR. Revert the implementation PR to roll back; leave licensed catalog, UI styling and release machinery intact.
