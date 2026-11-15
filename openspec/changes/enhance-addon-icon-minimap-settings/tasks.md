# Implementation tasks

## 1. Compatibility discovery

- [ ] 1.1 Record the supported Forever build and interface value.
- [ ] 1.2 Verify native profession/crafting icon identifiers and addon-list metadata support.
- [ ] 1.3 Verify minimap button APIs, default placement, click handling and cursor behavior.
- [ ] 1.4 Verify native frame templates/font objects and suitable dimensions at ordinary UI scale.
- [ ] 1.5 Stop and request a spec revision if any required client capability is unavailable.

## 2. Addon identity and minimap access

- [x] 2.1 Add the native icon candidate declaration/resource wiring without external web imagery.
- [x] 2.2 Implement one idempotent minimap button with the candidate icon.
- [x] 2.3 Route primary click to the existing `ns.OpenSettings` action.
- [x] 2.4 Keep the button visible by default and omit future visibility/position settings.
- [ ] 2.5 Add offline tests for initialization idempotence and click routing.

## 3. Settings shell

- [x] 3.1 Enlarge the settings window using client-native layout primitives.
- [x] 3.2 Build the header with left search affordance, centered title and right language selector.
- [x] 3.3 Make the search affordance non-interactive and show the unavailable/prohibited pointer state.
- [x] 3.4 Move language selection out of General while preserving immediate application and persistence.
- [x] 3.5 Replace General content with a centered localized “Coming soon” message.
- [ ] 3.6 Add/update English and Spanish strings and tests.

## 4. Verification and handoff

- [ ] 4.1 Run repository validation, data checks and all relevant offline tests.
- [ ] 4.2 Run the real Forever client matrix: addon list icon, minimap visibility/click, reload idempotence, layout, language change, persistence, cursor state and no Lua errors.
- [ ] 4.3 Record exact client build, screenshots and any compatibility limitations.
- [ ] 4.4 Update relevant documentation and changelog.
- [ ] 4.5 Open a separate implementation PR referencing the merged approval PR; do not merge or archive unilaterally.
