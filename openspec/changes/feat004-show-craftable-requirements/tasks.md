## 1. Verify Forever client data

- [ ] Identify and record the Forever build and confirm which guarded APIs report numeric skill-line identity, the current character's profession rank and the learned flag for a selected recipe.
- [ ] Observe those reads with the profession window closed, open on the selected profession and open on another data source. Confirm behavior for an unlearned profession, newly learned recipes and skill increases, including the notifications used for refresh.

## 2. Implement the accepted requirements

- [x] Reuse the catalog's optional required skill and teaching-item facts and add a read-only adapter for trustworthy current-character observations and unknown states.
- [x] Render the same numeric minimum in all skill states, and one recipe-required label when the teaching item applies. Verify dark gray, dark red and neutral states and clear previous values when selection changes.
- [x] Align both detail headers and the first section divider. In Materials, render the title, client type, client item level, and `ID <itemID>` in separate rows. Show `ID <spellID>` on the left and align the Track crafting control with that row on the right. Preserve the existing tracker, ingredients, navigation and native link interactions.

## 3. Validate and prepare a test build

- [x] Extend the relevant offline fixtures for skill below, equal to and above the minimum, recipe learned and unlearned, mixed statuses, missing catalog or client data, a verified trainer alternative, exact ID and level copy, both locales and the tracking control alignment and behavior.
- [x] Run the repository release, generated-data, Lua, documentation and strict OpenSpec/SDD checks. Record exact results.
- [x] Build a local installable CraftAtlas ZIP from the implementation branch for Forever testing.
- [ ] In Forever, record the client build, locales and display scales tested. Verify the three header positions, colors, unknown states, selection changes, skill and learning refreshes, and existing tracking, bank, and reload interactions. Record baseline tracking failures if reproduced.
- [x] Run `documentation-sync` after implementation and tests. Update affected documentation and record evidence and archive readiness for the implementation PR.

## Implementation evidence

- Approved specification: [PR #77](https://github.com/hectoresen/CraftAtlas/pull/77), approved by `@hectoresen` before its merge into `main` on 2026-11-27.
- Local verification passed: release readiness, generated-data drift, 151 Python tests, 56 Lua 5.1 syntax checks, 25 Lua 5.1 fixtures, and strict OpenSpec validation for 38 items. The SDD scope and documentation attestation preflights passed using public GitHub approval evidence. GitHub Actions verifies the submitted PR independently.
- The local test ZIP matched all 33 runtime files on the rebased implementation branch. The contributor reported the final layout satisfactory. See `docs/TESTING.md` for scope and limitations of that feedback.
- Documentation audit: README, architecture, testing and changelog describe the code and observed evidence. The data model, installation and development procedures are unchanged by these display changes. The roadmap remains the maintenance baseline.
- Archive blocked pending documented Forever client acceptance. Outstanding evidence includes character data with the profession window closed, open and linked to another source, skill and recipe refresh events, both locales and scales, and tracker, bank and reload behavior.
