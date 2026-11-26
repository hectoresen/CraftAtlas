## 1. Verify Forever client data

- [ ] Identify and record the Forever build and confirm which guarded APIs report numeric skill-line identity, the current character's profession rank and the learned flag for a selected recipe.
- [ ] Observe those reads with the profession window closed, open on the selected profession and open on another data source. Confirm behavior for an unlearned profession, newly learned recipes and skill increases, including the notifications used for refresh.

## 2. Implement the accepted requirements

- [ ] Reuse the catalog's optional required skill and teaching-item facts and add a read-only adapter for trustworthy current-character observations and unknown states.
- [ ] Render the independent skill and recipe states in the specified header positions with localized text, dark gray, dark red and neutral colors. Verify that selection changes clear previous status.
- [ ] Re-anchor the existing Track crafting checkbox and its label below the recipe field. Preserve the existing tracker, ingredients, navigation and native link interactions.

## 3. Validate and prepare a test build

- [ ] Extend the relevant offline fixtures for skill below, equal to and above the minimum, recipe learned and unlearned, mixed statuses, missing catalog or client data, context changes, both locales and the tracking control position and behavior.
- [ ] Run the repository release, generated-data, Lua, documentation and strict OpenSpec/SDD checks. Record exact results.
- [ ] Build a local installable CraftAtlas ZIP from the implementation branch for Forever testing.
- [ ] In Forever, record the client build, locales and display scales tested. Verify the three header positions, colors, unknown states, selection changes, skill and learning refreshes, and existing tracking, bank, and reload interactions. Record baseline tracking failures if reproduced.
- [ ] Run `documentation-sync` after implementation and tests. Update affected documentation and record evidence and archive readiness for the implementation PR.
