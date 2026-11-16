## 1. Investigate client inventory semantics

- [ ] 1.1 Verify bag-only and include-bank item count APIs in the exact supported Forever build; record whether closed-bank quantities are authoritative and how events behave.
- [ ] 1.2 Define bounded and resilient client adapter behavior for unavailable/incomplete counts and bank freshness.

## 2. Implement feature

- [ ] 2.1 Add pure per-ingredient and aggregate material coverage math, including duplicate IDs, unknown values and no-ingredient cases.
- [ ] 2.2 Add current-character recipe tracking preferences with safe identity and persistence across reloads.
- [ ] 2.3 Add client bag/bank inventory adapter and event-driven refresh with no per-frame scanning and no stale bank overclaim.
- [ ] 2.4 Add the localized opt-in checkbox and compact material progress subsection in Fabricables; preserve existing detail paging, collapse behavior, hover, links and compact-layout bounds.

## 3. Verify, document and archive if accepted

- [ ] 3.1 Run Lua 5.1 tests for math, toggle persistence, character isolation, APIs/fallback, events and UI layout, and run common CI/release/strict OpenSpec checks; record commands and results.
- [ ] 3.2 Verify in Forever bags-only empty/partial/full and changes in real time, bank open/closed/unknown, changing recipes, reload/character isolation, no ingredients, compact scale and enUS/esES; record exact build and per-case outcomes, NOT RUN otherwise.
- [ ] 3.3 Run `skills/documentation-sync/SKILL.md` after implementation/tests and before the implementation PR; sync docs and perform same-change canonical sync/archive **only** if full acceptance evidence supports it, otherwise declare blocked.
- [ ] 3.4 Keep previous `fix001` acceptance status explicit; do not archive that unrelated change through this feature's implementation PR.
