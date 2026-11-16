## 1. Implement native link support

- [x] 1.1 Inspect the Forever-compatible native APIs for obtaining valid item and spell links and inserting them into chat without sending a message; implement a defensive shared helper.
- [x] 1.2 Add Shift + left-click precedence to Materiales list entries, material recipe-use rows, Fabricables list entries, ingredient rows and interactive detail identity/icon surfaces, reusing the helper and retaining normal navigation.
- [x] 1.3 Ensure output item vs non-item spell identity is correct, recycled rows use current bindings and failures do not insert guessed links or navigate on a Shift-click.

## 2. Correct recipe icon appearance

- [x] 2.1 Inspect Fabricables detail overlay and remove/adjust the inset square while maintaining native icon framing, hover and responsive layout.

## 3. Verify and document

- [ ] 3.1 Add/run isolated Lua 5.1 tests for modifier detection, valid item/spell links, unavailable APIs/chat, click precedence and row recycling; add icon regression coverage as feasible.
- [ ] 3.2 Run `bash scripts/validate_release_checks.sh`, Lua compatibility/regressions, documentation checks and `openspec validate --all --strict --no-interactive`; record executed command outputs.
- [ ] 3.3 Manually test Shift + click in all supported clickable entity surfaces with chat open and closed, normal click and hover, non-item actions and two UI scales in Forever, noting exact build and locale; record NOT RUN cases.
- [x] 3.4 Run `skills/documentation-sync/SKILL.md` before implementation PR, reconcile README, technical/testing documentation, roadmap/changelog and accepted OpenSpec acceptance/archive status without misreporting evidence.

## Implementation evidence checkpoint

- Source wiring implemented in the FIX branch; the duplicate quickslot texture is removed.
- Added `tests/test_chat_links.lua`; actual offline execution, required GitHub check results and visual/client acceptance are not claimed before CI and owner verification.
- `3.1` remains unchecked until the Lua test is executed successfully; `3.2` remains unchecked until its listed commands execute; `3.3` remains unchecked until in-game tests are evidenced.
- Archive remains blocked: exact Forever build, chat open/closed, both locales, compact scale and visual icon verification are NOT RUN.
