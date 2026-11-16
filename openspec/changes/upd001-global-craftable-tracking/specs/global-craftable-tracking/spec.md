# Global craftable tracking preference

## MODIFIED Requirements

### Requirement: Tracking is optional and scoped to a character across all Fabricables recipes

CraftAtlas SHALL provide an initially disabled, persistent **Track crafting / Seguir fabricación** checkbox controlling the Material progress display for **all Fabricables recipes of the current character**, rather than requiring the player to opt in separately for each recipe. Choosing a different recipe SHALL preserve the toggle and show the currently selected recipe's progress. Other characters SHALL have independent choices. Ingredient requirements, progress values and optional bank inclusion SHALL remain tied to the selected recipe and available current-character inventory.

#### Scenario: Enable tracking and switch fabricables

- **GIVEN** tracking is off and recipe A is selected
- **WHEN** the player checks Track crafting, then selects recipe B
- **THEN** tracking remains on in recipe B without another click
- **AND** Material progress shows recipe B's requirements and observed stock rather than recipe A's

#### Scenario: Disable across all fabricables

- **GIVEN** tracking is on while viewing recipe B
- **WHEN** the player unchecks Track crafting and selects recipe A
- **THEN** tracking remains off and Material progress is hidden on both
- **AND** the normal Ingredients list and browsing are unaffected

#### Scenario: Reopen or reload

- **GIVEN** the current character enabled Track crafting
- **WHEN** the player closes and reopens CraftAtlas or reloads the UI
- **THEN** the current character's checked state is restored on every Fabricables recipe

#### Scenario: Character isolation and safe defaults

- **GIVEN** the current character has tracking enabled
- **WHEN** the player logs into a different character without an explicit tracking choice
- **THEN** that character starts with tracking disabled
- **AND** missing character identity does not cause two characters to share state

#### Scenario: Legacy per-recipe records do not auto-enable

- **GIVEN** SavedVariables include historical per-recipe tracking records but no explicit global tracking preference
- **WHEN** CraftAtlas initializes the tracking preference
- **THEN** the global Track crafting mode defaults disabled until actively enabled
- **AND** the old data is not interpreted as a global opt-in

### Requirement: Independent bank option and per-recipe counts are preserved

The Include bank preference SHALL remain independent from the global Track crafting preference and SHALL retain freshness-aware bank semantics. Enabling tracking globally SHALL NOT merge inventory requirements from separate recipes, and SHALL NOT change native item tooltips, Shift-click chat links, recipe paging or the existing Ingredients presentation.

#### Scenario: Bank selection persists across recipe switches

- **GIVEN** tracking is on and Include bank is selected
- **WHEN** the player switches recipes
- **THEN** the mode and bank option remain checked
- **AND** the new recipe's quantities are computed from its own ingredients with currently trustworthy bag and bank observations
