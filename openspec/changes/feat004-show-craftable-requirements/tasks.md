## 1. Verify Forever client data

- [ ] Identify and record the Forever build and confirm which guarded APIs report numeric skill-line identity, the current character's profession rank and the learned flag for a selected recipe.
- [ ] Observe those reads with the profession window closed, open on the selected profession and open on another data source. Confirm behavior for an unlearned profession, newly learned recipes and skill increases, including the notifications used for refresh.

## 2. Implement the accepted requirements

- [ ] Reuse the catalog's optional required skill and teaching-item facts and add a read-only adapter for trustworthy current-character observations and unknown states.
- [ ] Render the same numeric minimum in all skill states, and one recipe-required label when the teaching item applies. Verify dark gray, dark red and neutral states and clear previous values when selection changes.
- [ ] Match the Materials detail header and first section divider. Show `ID <spellID>` on the left and align the Track crafting control with that row on the right. Preserve the existing tracker, ingredients, navigation and native link interactions.

## 3. Validate and prepare a test build

- [ ] Extend the relevant offline fixtures for skill below, equal to and above the minimum, recipe learned and unlearned, mixed statuses, missing catalog or client data, a verified trainer alternative, exact ID and level copy, both locales and the tracking control alignment and behavior.
- [ ] Run the repository release, generated-data, Lua, documentation and strict OpenSpec/SDD checks. Record exact results.
- [ ] Build a local installable CraftAtlas ZIP from the implementation branch for Forever testing.
- [ ] In Forever, record the client build, locales and display scales tested. Verify the three header positions, colors, unknown states, selection changes, skill and learning refreshes, and existing tracking, bank, and reload interactions. Record baseline tracking failures if reproduced.
- [ ] Run `documentation-sync` after implementation and tests. Update affected documentation and record evidence and archive readiness for the implementation PR.
