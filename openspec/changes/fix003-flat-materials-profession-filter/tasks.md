## 1. Materiales results presentation

- [x] 1.1 Render the existing unique filtered results as top-level item rows for a specific profession. Keep the current grouped projection for All professions.
- [x] 1.2 Apply row reuse, scrolling, count and selection to the active presentation. Preserve grouped expansion state, cache feedback and normal Materiales navigation and item interactions.

## 2. Verification

- [x] 2.1 Add an offline UI regression that exercises the Materiales filter from its normal entry point. Cover a shared reagent, filtered counts and scrolling, stale group controls, search and name-cache cases, return to the grouped tree and Back.
- [x] 2.2 Run the targeted Lua suites for the Materiales view, material search and profession tree, plus the shared release-readiness gate and strict OpenSpec and SDD checks.
- [ ] 2.3 Verify in Forever with enUS and esES. Record the exact build and addon revision. Check specific-profession lists, a shared reagent, search, scrolling, row selection and native interactions, Back, and restoration of the all-professions tree.

## 3. Documentation and acceptance

- [x] 3.1 Update affected browsing guidance and test evidence, run `documentation-sync` and assess same-PR archive readiness against the accepted scenarios.

## Verification evidence

Lua 5.1 parsed 57 files and all 26 isolated fixtures passed after aligning the explorer fixture with the localized detail ID label from PR #80. The 151 Python tests, release-readiness script, generated-data check, strict OpenSpec validation, and local SDD and documentation checks passed. The SDD check used the recorded owner approval and merge for [spec PR #78](https://github.com/hectoresen/CraftAtlas/pull/78).

The change stays active while task 2.3 remains open. See the [Forever acceptance checklist](../../../docs/TESTING.md#materiales-profession-filter) for the required enUS and esES evidence.
