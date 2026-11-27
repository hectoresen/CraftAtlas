## Context

`Domain/MaterialSearch.lua` already returns one result per eligible numeric itemID and applies both the selected consuming profession and the query. `Features/Settings/Settings.lua` currently passes every Materiales result set to `BuildProfessionGroups` and `FlattenProfessionGroups`. Those functions intentionally retain every source-backed profession membership, so using their output after a specific profession is selected can introduce unrelated headers, repeated rows and hidden matches.

The historical `native-profession-tree` requirements from `native-wow-profession-tree-redesign` are still in an accepted active delta. This proposal adds a separately synchronizable capability and supersedes that delta's grouped presentation only while a specific profession is selected. The historical delta remains intact.

## Decisions

- Use the existing ordered result IDs directly for a specific profession. Use the existing grouped projection for All professions. Choose the presentation from the dropdown value, including when the current query would match only one profession.
- Render flat results with the bounded Materiales row pool. Use compact item rows at the list level. Clear any recycled header, disclosure and group click state before displaying a material. Use the active presentation for row indexing and scroll limits.
- Keep the existing filtered result count, name-cache feedback, itemID fallbacks and background refresh path. Preserve a valid selected item across mode changes and refreshes. When a user changes the query or filter and excludes the selected item, follow the existing matching-selection or empty-detail behavior.
- Keep grouped expansion choices and active-query collapse overrides available when returning from a specific profession. Apply the existing override reset rules when the query changes to or from empty. Preserve the Materiales query, filter and eligible browsing context through the existing navigation path.

## Verification

Exercise the actual Materiales dropdown, search and row handlers in an offline UI fixture, using a shared reagent, a profession-exclusive reagent and enough matches to scroll. Check both presentation modes, row reuse, count, empty and unresolved states, selection and Back. Keep the existing material search and profession tree regression suites. Reproduce the report and verify the corrected behavior in Forever using enUS and esES. Record the tested client build, addon revision and observed results.
