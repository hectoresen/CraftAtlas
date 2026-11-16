# Design: incremental catalog preparation and accurate progress

## Observed code path versus hypotheses

`OpenSettings` invokes `PreloadMaterialInfo` and `RefreshSettings`. Materials process up to 20 IDs per 0.1 s timer callback and refresh Materiales each batch. `switchView("recipes")` calls `PreloadRecipeNames`; recipes process up to 25 records per 0.08 s timer callback and refresh the explorer each batch. Each refresh may scan/filter/sort, build profession groups and update rows and selected detail. Roughly 593 material IDs and 2,506 recipe records are in the pinned source snapshot; these counts are **not measured frame-time metrics**. A repeated full scan is demonstrably present in code; whether it is the dominant source of the reported FPS drop must be measured.

## Module ownership and contracts

- `Infrastructure/ItemInfo.lua`: item-data request state, bounded work progress, client events/cached names; never full UI logic. Preserve existing `GetMaterialLoadProgress` compatibility or explicitly migrate all consumers and tests.
- `Infrastructure/RecipeNameCache.lua`: independently bounded recipe spell/output metadata work, progress and outstanding names; no inferred output item data. Ensure each record's identity is processed at most once per session unless a meaningful retry is requested by a native client event.
- `Domain/`: pure progress arithmetic/scheduler decision or search-result invalidation helpers when needed; no WoW APIs or `CreateFrame`. Avoid new modules absent clear testable value.
- `Features/Settings/Settings.lua`: coordinate view-local busy/progress state, debounce/coalesce refresh requests, preserve searches, filters, selections, tree expansion and history. Render only the active view's progress.
- `Features/Settings/Shared/ExplorerWidgets.lua`: reusable native progress bar and stable header layout component, with safe show/hide and no new recurring frame allocations.
- `Localization/Locales.lua`: enUS and esES progress label(s), separate incomplete/unresolved data feedback.

Keep module boundaries and source-backed numeric material identity / profession+spellID recipe identity unchanged. `CraftAtlas.toc` may add a small new Lua module only if warranted, in load order. Do not alter generated `Data/` files.

## Profiling and acceptance approach

Define a controlled experiment with exact client build, locale, UI scale and hardware metadata (as shared voluntarily by the maintainer). Compare a fresh `/reload` run on original main against optimized branch with identical cache conditions as practicable. Capture:
- Work units attempted/completed, batches, batch duration distribution and worst observed batch.
- Number of `FilterMaterials` and `SearchCatalogRecipes` calls and visible-tree rebuilds.
- UI refresh count, elapsed preparation time and subjective/recorded FPS or frame-time spikes.
- First opening of Materiales, first switch to Fabricables, second opening and return to previously prepared view.

Use `debugprofilestop` or a guarded equivalent **only if available**, otherwise use compatible `GetTime` (coarser) or instrumentation-independent operation counts. Dev diagnostics must not print per item, collect user data, introduce network calls or impose significant work in release mode. Report baseline and optimized evidence, including unchanged/worse results, and never claim a numeric improvement if not measured. Test the known repeated-refresh inefficiency as an objective reduction in unnecessary full-view recomputation without requiring a specific FPS gain.

## Incremental work scheduling

1. Build a deterministic queue of unique source IDs/records once, without reading client metadata during queue construction. Preserve current catalog ordering/identity semantics.
2. On first use, process a bounded slice per timer callback. Start from conservative existing batch sizes, then tune only if profiling supports it. No scanning of entire remaining queue on every frame and no parallel duplicate workers.
3. Separate metadata work from view refresh. Batch callbacks update an incremental dirty-generation counter and request a **single coalesced** visible refresh within an explicitly bounded UI cadence, with prompt refresh for user-initiated search/filter/selection. A hidden view does not need a full redraw per background batch.
4. Cache or memoize stable filtered/projection state using explicit dependencies (query, profession, view, resolved-name generation, locale/profession labels). No stale query/cache after an item/spell name becomes available. Reuse existing row frames; never allocate one frame per catalog entry.
5. On completion, flush any pending visible refresh once, finalize progress, hide the header indicator for that view and preserve fallback/incomplete data messages.
6. If `C_Timer.After` is missing or fails, use a safe supported deferred alternative if proven on Forever, or stop gracefully with an honest incomplete state. Do **not** synchronously run the entire queue in an unbounded loop.

## Meaning and calculation of progress

Each view has `totalUnits`, `completedUnits` and a lifecycle `notStarted | active | complete | incomplete`. For materials, each unique relevant source itemID is one attempted unit. For recipes, each recipe work record is one attempted unit; a record's spell/output metadata attempts are part of that unit. Pure mapping `percent = floor(100 * completed / total)` (clamped to 0..100), with total zero treated as 100% immediately. No timer-based synthetic progress.

- Count a unit completed when the planned *attempt* for that unit has executed, not when native cache data became available. Native asynchronous resolution is separately pending/unavailable and may later invalidate presentation caches.
- While a worker is active, display `Preparing materials… N%` or `Preparing craftables… N%` (localized). Optional concise status `N / total` can be displayed if it fits. Hide when complete, and do not keep a bar at 100% indefinitely.
- On missing scheduling APIs, transition to `incomplete` with honest fallback/incomplete data feedback; **never display 100%** for unattempted units.
- Report progress independently for Materiales and Fabricables. Switching tabs does not restart already attempted work. When returning, reflect remaining work if active; if complete, no bar.
- When an item or spell resolves after the preparation attempt, update results through coalesced invalidation rather than decrementing progress or starting a fictitious second load.

## Header visual constraints

Keep `CraftAtlas` centered in the native header in both axes. A narrow gold-toned native progress bar and `GameFontDisableSmall` label occupy a measured safe strip **below** the title without covering the existing edit box, language dropdown, tabs or close button. If insufficient vertical space, prefer a compact single-line overlay in an available dedicated header/status region, not a resized/clipped native control. An inactive or complete view hides the indicator. No busy modal, screen-wide blocking, progress fake animation, dependency on external artwork or corruption of native red button/dropdown styling.

## Tests and failure cases

- Pure percent calculations (0/0, initial, partial, last, zero totals, invalid values), terminal states, cancellation/no-duplicate worker, and proper independent view progress.
- Fake timer that releases batches in controlled order; verify bounded units per callback, single coalesced refresh per window, event-driven refresh on cache changes, no repeated full-search calls per item and no starvation on user search/filter.
- Search results and sorting update when client names resolve; preserve numeric IDs, deterministic material profession counts/duplicates, recipe+spell identity and ingredient quantities.
- Reopen and view switch mid-load, lifecycle event duplication, absent `C_Timer` and missing item/spell info APIs, enUS/esES, and no progress stuck at 100% with an active/incomplete worker.
- UI mocks for header/title/search/dropdown alignment at supported normal/compact sizes and for no new frame creation after repeated loads.
- Real Forever smoke/performance tests after implementation with explicit **NOT RUN** if agent lacks the client. Distinguish real FPS measurements from theoretical operation-count improvements.

## Documentation and rollout

Implementation PR invokes `skills/documentation-sync/SKILL.md`; update README, testing, architecture, development, roadmap and changelog only for verified behavior. Record source provenance unchanged. Roll back by reverting implementation PR. No shipping readiness until owner verifies in-game responsiveness and both progress indicators.
