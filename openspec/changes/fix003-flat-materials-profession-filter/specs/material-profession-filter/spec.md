# Materiales profession filter presentation

## ADDED Requirements

### Requirement: Present a single list for a selected consuming profession

When a specific consuming profession is selected in Materiales, the results pane SHALL show one scrollable list of the materials returned by the existing profession and query filter. Each numeric itemID SHALL appear once in the existing result order as a top-level material row. The results pane SHALL omit profession headers, disclosure controls and child indentation in this mode. The result count SHALL equal the number of distinct matching itemIDs across the full list.

#### Scenario: Select a profession with a shared reagent

- **GIVEN** a reagent is consumed by the selected profession and another profession, and a second reagent is consumed only by the other profession
- **WHEN** the player selects the first profession in Materiales
- **THEN** the shared reagent appears once and the second reagent is excluded
- **AND** every matching material is reachable by scrolling, even if its group was collapsed before selecting the profession

#### Scenario: Search within a selected profession

- **WHEN** the player enters a supported query while a profession is selected
- **THEN** the flat list shows exactly the materials that satisfy both the query and the selected profession
- **AND** clearing the query restores the flat list for that profession

#### Scenario: Handle no matches or unavailable names

- **WHEN** the current profession and query produce no displayable results
- **THEN** the pane displays the existing localized empty or unresolved-name feedback as applicable, with no leftover row or header

#### Scenario: Look up an eligible material by itemID while its name is unresolved

- **GIVEN** the client has yet to resolve the name of a material consumed by the selected profession
- **WHEN** the player searches for its numeric itemID
- **THEN** its row appears in the flat list with the existing fallback

### Requirement: Restore the tree for all professions

When All professions is selected in Materiales, the results pane SHALL use the existing collapsible tree of source-backed consuming professions. The profession selector SHALL preserve the search query. Applicable expansion choices SHALL carry across presentation changes.

#### Scenario: Return to grouped browsing

- **GIVEN** the player has collapsed a group in the all-professions tree and kept the same query
- **WHEN** the player selects a specific profession and then returns to All professions
- **THEN** the group resumes its prior expansion state, including any applicable search-time override
- **AND** a shared reagent can appear in each of its expanded groups while contributing once to the global count

#### Scenario: Search without setting a profession filter

- **WHEN** the dropdown remains on All professions and a query happens to yield materials from only one consuming profession
- **THEN** the results remain grouped and use the existing search expansion behavior

### Requirement: Preserve material row interactions in filtered mode

The filtered list SHALL reuse a bounded pool of material rows and preserve material detail selection, supported native hover and chat-link interactions, and existing Materiales navigation.

#### Scenario: Scroll and select a material

- **WHEN** the player scrolls a filtered list that exceeds the visible row capacity and clicks a recycled row
- **THEN** the detail opens for the numeric itemID currently displayed on that row
- **AND** the row has the usual selection and hover behavior and inserts the native item link on Shift + left-click when available

#### Scenario: Return from a crafting use

- **WHEN** the player opens Fabricables from the selected material's crafting uses and activates Back
- **THEN** Materiales restores its profession filter, query, valid selected item and scroll position within the current list bounds
- **AND** the results are still presented as a flat list

#### Scenario: Change the selected profession

- **GIVEN** the selected material is absent from the results for another profession
- **WHEN** the player switches to that profession
- **THEN** the results are still presented as a flat list and the search query is preserved
- **AND** the detail selects a matching material or shows the empty state when there are no results
