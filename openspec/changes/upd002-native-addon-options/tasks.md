# Tasks

## 1. Approval and native registration

- [ ] 1.1 Obtain owner approval and merge of this spec before creating the implementation branch from `main`.
- [ ] 1.2 Register one CraftAtlas panel under the game's Options → AddOns. Verify idempotency and startup with unavailable registration APIs.
- [ ] 1.3 Add localized General and Tooltip controls to the native page and synchronize both language selectors. Verify the explorer has no separate configuration page and retains its browsing and Back state.

## 2. Preferences and tooltip presentation

- [ ] 2.1 Add four account-wide flags with independent defaults. Preserve valid existing fields and explicit false settings.
- [ ] 2.2 Apply minimap visibility immediately and after reload. Verify restoration from native options at the saved angle without creating a duplicate.
- [ ] 2.3 Bind the tooltip checkboxes and retain layout selections while disabled. Verify all icon and layout combinations, localized order, unknown items, missing icons, repeated callbacks and tooltip rebuilds.

## 3. Validation and documentation

- [ ] 3.1 Run the shared release gate, Lua 5.1 compatibility and fixtures, and strict OpenSpec and SDD checks.
- [ ] 3.2 Verify native settings entry, compact layout, language synchronization, checkbox persistence, minimap recovery and tooltip variants in Forever. Record exact build, locales, scales and tested tooltip surfaces, and mark unexecuted cases NOT RUN.
- [ ] 3.3 Execute documentation-sync, update user and technical documentation, assess archive readiness and open the implementation PR with approved spec and verification evidence.
