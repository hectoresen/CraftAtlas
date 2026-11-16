## Implementation

- [x] 1.1 Add persistent, current-character global Track crafting boolean; no implicit migration from per-recipe records.
- [x] 1.2 Switch Fabricables checkbox render/click, selected recipe transitions and event guards to the global toggle while retaining per-recipe ingredient progress values.
- [x] 1.3 Keep Include bank independent, Ingredients unmodified, native tooltip/Shift-click/pagination preserved.

## Verification and lifecycle

- [ ] 2.1 Add/run Lua 5.1 tests for state across multiple recipes, default off, reload, identity isolation and missing character ID; include UI and event regressions.
- [ ] 2.2 Test the global toggle in actual Forever with switching, reopen/reload, and another character where possible; record real build and outcomes or NOT RUN.
- [ ] 2.3 Run documentation-sync and full relevant CI, record evidence and choose prepared/blocked archive only for upd001. Do not archive unrelated feat001/fix001 artifacts.

## Implementation evidence checkpoint — 2026-11-16

- `Preferences.lua` now stores `craftTrackingEnabled[realm:character]` as a single explicit boolean, default off, with no implicit migration from earlier `craftTracking[character][recipeKey]` values. The old map is left untouched.
- `RecipesView.lua` uses the global opt-in for checkbox state, click handling, selected-recipe redraw and inventory-event refresh; requirement and stock computation continue to use only the selected recipe, and Include bank retains its independent preference.
- `tests/test_craftable_tracking.lua` extends offline regression scenarios for global opt-in, character identity, reload, independent bank preferences, switching two recipes, global off/on and original Ingredients. GitHub Actions evidence for the final commit must be recorded after the implementation PR is created.
- **Forever global-toggle acceptance: NOT RUN**; task 2.2 stays open. **OpenSpec-Archive: blocked** for upd001 only. No unrelated accepted spec or archived change modified.
