## 1. Investigate client inventory semantics

- [ ] 1.1 Verify bag-only and include-bank item count APIs in the exact supported Forever build; record whether closed-bank quantities are authoritative and how events behave.
- [x] 1.2 Define bounded and resilient client adapter behavior for unavailable/incomplete counts and bank freshness.

## 2. Implement feature

- [x] 2.1 Add pure per-ingredient and aggregate material coverage math, including duplicate IDs, unknown values and no-ingredient cases.
- [x] 2.2 Add current-character recipe tracking preferences with safe identity and persistence across reloads.
- [x] 2.3 Add client bag/bank inventory adapter and event-driven refresh with no per-frame scanning and no stale bank overclaim.
- [x] 2.4 Add the localized opt-in checkbox and compact material progress subsection in Fabricables; preserve existing detail paging, collapse behavior, hover, links and compact-layout bounds.

## 3. Verify, document and archive if accepted

- [ ] 3.1 Run Lua 5.1 tests for math, toggle persistence, character isolation, APIs/fallback, events and UI layout, and run common CI/release/strict OpenSpec checks; record commands and results.
- [ ] 3.2 Verify in Forever bags-only empty/partial/full and changes in real time, bank open/closed/unknown, changing recipes, reload/character isolation, no ingredients, compact scale and enUS/esES; record exact build and per-case outcomes, NOT RUN otherwise.
- [ ] 3.3 Run `skills/documentation-sync/SKILL.md` after implementation/tests and before the implementation PR; sync docs and perform same-change canonical sync/archive **only** if full acceptance evidence supports it, otherwise declare blocked.
- [x] 3.4 Keep previous `fix001` acceptance status explicit; do not archive that unrelated change through this feature's implementation PR.

## Implementation evidence checkpoint

- A conservative guarded bag/inventory adapter, current-bank-only observation, per-character SavedVariables tracking, pure coverage calculator, native UI and isolated Lua fixtures are present on the feature branch.
- API behavior on the **actual** Forever build is NOT RUN; task 1.1 remains open. The bank checkbox is disabled where the count API is not exposed, and a closed or inconsistent bank returns unknown instead of cached stock.
- Offline Lua test commands, full shared release checks, strict OpenSpec validation and current GitHub CI evidence are not claimed until they are executed. Tasks 3.1 and 3.2 remain unchecked.
- Since complete manual client acceptance is missing, this change is **OpenSpec-Archive: blocked**; do not sync canonical specs or archive this or any unrelated change.

## Owner validation checkpoint — 2026-11-16

- **PASS, owner-reported in Forever:** after the bank-slot scan fix, the previously failing open-bank Hojaplata/Silverleaf ingredient count now works, as confirmed in conversation. This is a targeted observation; no exact post-fix stock count or client build was supplied.
- **Previously observed:** bag count and weighted 33% progress for one material, and final compact tracker layout without overlapping lines in owner screenshots.
- **Still NOT RUN / not evidenced:** full task 1.1 version-specific bank-open/closed semantics, reload and cross-character isolation, empty/full bag cases, locale and scale matrix, all event refresh variants and full task 3.2 acceptance. Preserve those unchecked tasks and **OpenSpec-Archive: blocked** until supported.
