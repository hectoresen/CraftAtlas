# Tasks — optimize catalog loading and progress

## Approval gate
- [x] A1 Owner reviews and merges the spec-only proposal PR before any implementation.
- [x] A2 Create a fresh implementation branch from approved main; keep the approved proposal/design/specs/scope frozen.

## Research and objective baseline
- [ ] B1 Profile current first-use Materiales and Fabricables paths, capturing scheduling, full-search and refresh counts and client frame-time when available; distinguish NOT RUN real-client metrics.
- [x] B2 Add deterministic operation-count instrumentation and a repeatable benchmark fixture/procedure without normal runtime telemetry.
- [ ] B3 Record baseline, optimized evidence and compatibility assumptions before claiming improvement or selecting new batch sizes.

## Preparation and cache correctness
- [x] C1 Implement bounded, idempotent material/recipe queue lifecycle and safe timer-failure fallback without full synchronous drain.
- [x] C2 Coalesce background-triggered refreshes; avoid redundant catalog-wide filter/sort/tree rebuilds while retaining immediate user-action refresh.
- [x] C3 Add safe name/icon/search cache invalidation on client data events, query/filter/locale changes and navigation, preserving source IDs, ordering and real counts.
- [ ] C4 Validate reopening, tab switching, back/selection and no duplicated timers, frames or hooks.

## Header UI
- [x] D1 Implement per-view honest `completed/total` progress state and active/completed/incomplete transitions.
- [x] D2 Create reusable native header progress widget without moving the centered title or covering search, language or buttons at compact scales.
- [x] D3 Add enUS/esES localized preparation and incomplete text, switching-view/locale updates and automatic hiding on completion.
- [x] D4 Preserve unresolved-name messaging independently of the completed-work percentage.

## Verification, docs and PR
- [x] E1 Add pure Lua tests for progress mathematics, zero totals, separate views, terminal/incomplete states and invalidations.
- [x] E2 Add fake-timer/UI adapter tests for bounded batch work, refresh coalescing, late metadata, state preservation and repeated reopen.
- [ ] E3 Run `bash scripts/validate_release_checks.sh`, `python3 scripts/build_materials.py --check`, Python/Lua suites and strict OpenSpec validation, recording actual PASS/FAIL/NOT RUN.
- [ ] E4 Run real Forever first-use/reopen tests for both views at multiple UI scales/locales, record exact build, progress screenshots and performance deltas or mark NOT RUN.
- [ ] E5 Explicitly execute `skills/documentation-sync/SKILL.md`; synchronize README, architecture, development, testing, roadmap, changelog and relevant tasks based only on implemented behavior.
- [ ] E6 Open one implementation PR referencing the owner-merged spec PR and exact OpenSpec metadata; correct CI/SDD failures in that PR; no direct main changes, merge or release.

## Evidence ledger (implementation branch)

- Source baseline **inspection only**: 20 material IDs/0.1s and 25 recipe records/0.08s, each with a full redraw request in main. For 593/2,506 records the theoretical batch counts are 30/101. These are not FPS/time measurements; real-client baseline profiling **NOT RUN**.
- Implemented in `Domain/CatalogProgress.lua`, `Infrastructure/ItemInfo.lua`, `Infrastructure/RecipeNameCache.lua`, `Settings.lua` and shared UI widgets: work-unit counters, bounded scheduling, immediate user actions, coalesced background rendering, source-backed data-generation cache invalidation, native header status and guarded spell-data event support. Opt-in `/craftatlas perf` reports local counts, no telemetry.
- Added fake timer, no-timer, pure progress, header UI mock and source-level Python contract tests. These are created, but standalone `texlua` execution and in-game responsiveness checks remain **NOT RUN** until executed on an available checkout/Forever client. No FPS speedup claim.
