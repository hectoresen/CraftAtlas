# Craftable material tracking

## ADDED Requirements

### Requirement: Tracking is optional and scoped to a character and recipe

CraftAtlas SHALL provide an initially disabled, persistent **Track crafting / Seguir fabricación** checkbox for each selected Fabricables recipe. The tracking choice SHALL be scoped to the current character and the recipe's profession-plus-spell identity. The UI SHALL restore that state after switching recipes or reloading, and SHALL not leak it to another character.

#### Scenario: Enable a recipe tracker

- **GIVEN** a selected craftable with known ingredients and tracking disabled
- **WHEN** the player enables tracking
- **THEN** CraftAtlas displays the material progress subsection below Required materials
- **AND** the original required-ingredients section remains usable

#### Scenario: Disable tracking

- **GIVEN** tracking is enabled for a recipe
- **WHEN** the player disables it
- **THEN** the progress subsection disappears without changing the original ingredient list or other recipes' tracking state

#### Scenario: Per-recipe and per-character persistence

- **GIVEN** the player enables tracking for one profession-plus-spell recipe
- **WHEN** the player browses another recipe, returns or reloads
- **THEN** only the same character's matching recipe remains tracked
- **AND** a different character has no inherited tracker state

### Requirement: Progress reflects trustworthy current-character material quantities

For a tracked recipe with known ingredient quantities, CraftAtlas SHALL show for each ingredient the needed quantity, trustworthy current bag count, confirmed available count and positive missing amount. It SHALL show per-ingredient and aggregate progress capped to 100%, calculated as the sum of covered required units divided by total required units, without double-counting duplicate ingredient itemIDs.

#### Scenario: Partial bags

- **GIVEN** a tracked recipe requires 2 units of material A and 3 of material B
- **AND** the current character has 1 unit of A and 2 of B in bags
- **WHEN** the tracker refreshes in bags-only mode
- **THEN** it shows A as 1/2 and missing 1, B as 2/3 and missing 1
- **AND** overall confirmed progress is 3/5 or 60%

#### Scenario: Fully stocked bags

- **GIVEN** trustworthy observed bags meet every known ingredient requirement
- **WHEN** the tracker refreshes without unknown quantities
- **THEN** it shows 100% ingredient coverage and zero missing
- **AND** it does not claim that the character has learned or can craft the recipe

#### Scenario: Unknown inventory count

- **GIVEN** a required ingredient's current inventory count cannot be determined reliably
- **WHEN** the tracker refreshes
- **THEN** its availability and the aggregate completion state are marked unverified
- **AND** CraftAtlas SHALL NOT replace the missing observation with an invented zero or assert a verified 100%

#### Scenario: Missing ingredient metadata

- **GIVEN** the catalog identifies an ingredient by itemID but the client has not resolved its display name or icon
- **WHEN** the tracker renders
- **THEN** it continues to use that real itemID and catalog quantity without inventing a name or rarity

### Requirement: Bank contribution is optional and freshness-aware

CraftAtlas SHALL offer an Include bank option only through a guarded supported Forever API path. Confirmed bank quantities SHALL be shown separately from bag quantities and SHALL contribute to progress only while known to be authoritative for the current character. Unavailable, closed-bank-unknown or stale bank contents SHALL be labeled unknown/excluded, never treated as a trustworthy zero or summed as current stock.

#### Scenario: Bank is open with verified stock

- **GIVEN** a tracked ingredient requires 5 units
- **AND** the character has 2 in bags and 3 in a currently accessible and verified bank
- **WHEN** Include bank is enabled
- **THEN** CraftAtlas displays bags 2 and bank 3 separately
- **AND** the combined verified progress is 5/5 without double-counting

#### Scenario: Bank is closed and not reliably readable

- **GIVEN** the bank is closed and the client does not guarantee fresh bank counts
- **WHEN** Include bank is enabled
- **THEN** CraftAtlas labels bank availability unknown
- **AND** the confirmed progress remains based on trustworthy bag contents only

#### Scenario: Bank access or API is absent

- **GIVEN** bank APIs are missing or the client does not expose trustworthy bank stock
- **WHEN** the player views the tracker
- **THEN** CraftAtlas preserves bags-only tracking and clearly disables or marks bank tracking as unavailable

### Requirement: Tracking refreshes safely and respects native explorer behavior

CraftAtlas SHALL update visible tracked quantities when relevant inventory or bank data changes, without continuous frame scanning, and SHALL preserve existing Fabricables navigation, pagination, collapsible required materials, native tooltip and Shift-click chat links. The tracker SHALL remain readable without overlapping controls at compact supported UI scales.

#### Scenario: Collect a missing ingredient

- **GIVEN** a tracked recipe is visible and a bag item count changes
- **WHEN** the relevant inventory update event is handled
- **THEN** the display updates the corresponding availability and aggregate progress without requiring a reload

#### Scenario: Collapse required materials

- **GIVEN** tracking is enabled
- **WHEN** the player collapses Required materials
- **THEN** its subordinate progress UI is hidden along with the ingredient detail
- **AND** tracker preferences are preserved

#### Scenario: Navigate and Shift-click

- **WHEN** the player navigates between recipes or Shift-clicks a displayed ingredient
- **THEN** the original navigation, item tooltips and native chat linking behave as before

#### Scenario: Compact layout and localization

- **WHEN** the tracked recipe is shown at a compact supported UI scale in esES or enUS
- **THEN** the tracking controls, material rows and progress indicators remain visible, legible and non-overlapping with localized labels

#### Scenario: No known ingredients

- **GIVEN** a catalog recipe has no verified required ingredients
- **WHEN** tracking is enabled
- **THEN** CraftAtlas reports insufficient recipe data rather than dividing by zero or claiming complete material coverage
