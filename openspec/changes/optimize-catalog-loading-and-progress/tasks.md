# Tasks — optimize catalog loading and progress

## Approval gate
- [ ] A1 Owner reviews and merges the spec-only proposal PR before any implementation.
- [ ] A2 Create a fresh implementation branch from approved main; keep the approved proposal/design/specs/scope frozen.

## Research and objective baseline
- [ ] B1 Profile current first-use Materiales and Fabricables paths, capturing scheduling, full-search and refresh counts and client frame-time when available; distinguish NOT RUN real-client metrics.
- [ ] B2 Add deterministic operation-count instrumentation and a repeatable benchmark fixture/procedure without normal runtime telemetry.
- [ ] B3 Record baseline, optimized evidence and compatibility assumptions before claiming improvement or selecting new batch sizes.

## Preparation and cache correctness
- [ ] C1 Implement bounded, idempotent material/recipe queue lifecycle and safe timer-failure fallback without full synchronous drain.
- [ ] C2 Coalesce background-triggered refreshes; avoid redundant catalog-wide filter/sort/tree rebuilds while retaining immediate user-action refresh.
- [ ] C3 Add safe name/icon/search cache invalidation on client data events, query/filter/locale changes and navigation, preserving source IDs, ordering and real counts.
- [ ] C4 Validate reopening, tab switching, back/selection and no duplicated timers, frames or hooks.

## Header UI
- [ ] D1 Implement per-view honest `completed/total` progress state and active/completed/incomplete transitions.
- [ ] D2 Create reusable native header progress widget without moving the centered title or covering search, language or buttons at compact scales.
- [ ] D3 Add enUS/esES localized preparation and incomplete text, switching-view/locale updates and automatic hiding on completion.
- [ ] D4 Preserve unresolved-name messaging independently of the completed-work percentage.

## Verification, docs and PR
- [ ] E1 Add pure Lua tests for progress mathematics, zero totals, separate views, terminal/incomplete states and invalidations.
- [ ] E2 Add fake-timer/UI adapter tests for bounded batch work, refresh coalescing, late metadata, state preservation and repeated reopen.
- [ ] E3 Run `bash scripts/validate_release_checks.sh`, `python3 scripts/build_materials.py --check`, Python/Lua suites and strict OpenSpec validation, recording actual PASS/FAIL/NOT RUN.
- [ ] E4 Run real Forever first-use/reopen tests for both views at multiple UI scales/locales, record exact build, progress screenshots and performance deltas or mark NOT RUN.
- [ ] E5 Explicitly execute `skills/documentation-sync/SKILL.md`; synchronize README, architecture, development, testing, roadmap, changelog and relevant tasks based only on implemented behavior.
- [ ] E6 Open one implementation PR referencing the owner-merged spec PR and exact OpenSpec metadata; correct CI/SDD failures in that PR; no direct main changes, merge or release.
