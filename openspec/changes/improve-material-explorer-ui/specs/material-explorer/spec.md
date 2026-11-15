# Material explorer

## ADDED Requirements

### Requirement: Search known catalog materials
CraftAtlas SHALL provide a functional text input in the existing header that filters the local catalog immediately by numeric itemID or client-available material names. The catalog's numeric itemID SHALL remain canonical, and the feature SHALL NOT invent localized names or item mappings.

#### Scenario: Search a known material by itemID
- **WHEN** the player types a known numeric itemID
- **THEN** its material appears in the results if it meets the active profession filter
- **AND** the selected result resolves to that itemID

#### Scenario: Search by a resolved name
- **WHEN** the player enters a fragment of a material name available from the client
- **THEN** matching known catalog materials are shown without requiring Enter

#### Scenario: Material name unavailable from client cache
- **WHEN** the client has not supplied a catalog item's name
- **THEN** CraftAtlas SHALL continue to support numeric itemID discovery
- **AND** SHALL show a safe itemID placeholder where needed
- **AND** SHALL distinguish incomplete name matching from a confirmed zero-match result

#### Scenario: Unknown material
- **WHEN** a query references an itemID absent from the local catalog
- **THEN** no fabricated result or profession mapping appears

### Requirement: Filter by consuming profession
The explorer SHALL offer a compact profession selector using the existing profession registry. The selector SHALL combine with the text query and SHALL NOT depend on professions learned by the current character.

#### Scenario: Profession selected
- **WHEN** the player selects a profession
- **THEN** only catalog items consumed by that profession and matching the current query appear
- **AND** the result count reflects the visible result set

#### Scenario: Clear search
- **WHEN** the player activates the accessible clear icon/button
- **THEN** only the text query resets
- **AND** the selected profession remains in effect
- **AND** focus returns to search

### Requirement: Compact results and material detail
The explorer SHALL show a scrollable results list and an adjacent detail pane. Each result SHALL use a client item icon if available, a localized client item name or itemID fallback, and known consuming professions. The detail SHALL show the selected item's icon, name/fallback, numeric ID and all known consuming professions from the offline catalog.

#### Scenario: Select a result
- **WHEN** the player selects a material in the results list
- **THEN** its detail replaces the previous material
- **AND** the current query and profession filter are preserved

#### Scenario: Multi-profession item
- **WHEN** the selected catalog item is consumed by multiple professions
- **THEN** the detail shows each known profession exactly once in deterministic order

#### Scenario: No matching results
- **WHEN** search and profession filters yield no items with sufficient name data
- **THEN** the list and detail show localized empty states without stale content

### Requirement: Honest recipe availability
The explorer SHALL NOT show recipe lists or ingredient quantities unless backed by a separately approved and verified recipe feature.

#### Scenario: Recipe data is unavailable
- **WHEN** the player views a material detail without approved recipe browsing support
- **THEN** the UI presents only a localized unavailable-state message, not made-up recipes or quantities

### Requirement: Stable navigation
The explorer SHALL preserve valid selection across list refreshes and SHALL expose a way to return to the previously filtered results after a direct entry from a tooltip.

#### Scenario: Selection persists
- **WHEN** an asynchronous item-name update refreshes the result rows
- **THEN** the selected material remains selected if it still matches
- **AND** outdated requests cannot overwrite newer UI state

#### Scenario: Selection no longer matches
- **WHEN** the current filter excludes the selected material
- **THEN** the UI selects a visible result deterministically or shows the empty detail state
