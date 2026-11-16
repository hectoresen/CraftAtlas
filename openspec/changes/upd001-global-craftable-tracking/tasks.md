## Implementation

- [ ] 1.1 Add persistent, current-character global Track crafting boolean; no implicit migration from per-recipe records.
- [ ] 1.2 Switch Fabricables checkbox render/click, selected recipe transitions and event guards to the global toggle while retaining per-recipe ingredient progress values.
- [ ] 1.3 Keep Include bank independent, Ingredients unmodified, native tooltip/Shift-click/pagination preserved.

## Verification and lifecycle

- [ ] 2.1 Add/run Lua 5.1 tests for state across multiple recipes, default off, reload, identity isolation and missing character ID; include UI and event regressions.
- [ ] 2.2 Test the global toggle in actual Forever with switching, reopen/reload, and another character where possible; record real build and outcomes or NOT RUN.
- [ ] 2.3 Run documentation-sync and full relevant CI, record evidence and choose prepared/blocked archive only for upd001. Do not archive unrelated feat001/fix001 artifacts.
