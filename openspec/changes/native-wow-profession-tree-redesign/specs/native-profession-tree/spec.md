# Native profession-grouped materials tree

## ADDED Requirements

### Requirement: Render source-backed material groups
The Materiales view SHALL display a native list tree grouped by consuming profession using the stable profession registry, with each group expandable and showing its distinct **matching** material count. The global result count SHALL count unique material itemIDs, not repeated list occurrences.

#### Scenario: Reagent belongs to two consuming professions
- **WHEN** one known material is consumed by two professions and both groups are expanded
- **THEN** a row for the same numeric itemID appears under both groups
- **AND** selecting either opens the same material detail
- **AND** the material contributes only once to the global unique results count

#### Scenario: Search and filter
- **WHEN** the user types an itemID/name/profession query and selects a profession filter
- **THEN** only source-backed materials matching both conditions remain in relevant profession groups
- **AND** displayed group counts reflect the filtered distinct items
- **AND** empty groups and unsupported profession claims are not displayed

### Requirement: Preserve intuitive tree state
Group collapse/expand, selected item, search query, profession filter and scroll state SHALL behave predictably across active searching and tab navigation.

#### Scenario: Text search reveals matches
- **WHEN** the search query changes from empty to a matching term
- **THEN** groups containing matches expand automatically unless explicitly collapsed while searching
- **AND** clearing the query restores the user's pre-search group expansion choices

#### Scenario: Collapsing a group
- **WHEN** the user collapses a profession group with selected material
- **THEN** its children disappear without deleting the selected material identity or its right-side detail

#### Scenario: Navigating to Fabricables and back
- **WHEN** the user follows a crafting-use row into Fabricables and activates Back
- **THEN** the Materiales query, filter, selected numeric itemID, visible groups and scroll/page state are restored

### Requirement: Keep large catalog UI bounded
The native grouped material tree SHALL render a bounded reusable pool of visible rows and SHALL avoid one WoW frame per catalog item or a full catalog scan on every cursor movement.

#### Scenario: Many groups and items
- **WHEN** the 593-item source-backed snapshot is filtered or expanded across multiple groups
- **THEN** the list remains scrollable and selected/hover states remain attached to the correct numeric itemID
- **AND** no duplicate frames or tooltips accumulate after repeated operations
