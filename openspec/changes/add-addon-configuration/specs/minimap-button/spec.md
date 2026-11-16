# Minimap button

## MODIFIED Requirements

### Requirement: Default minimap entry point

The addon SHALL create one minimap button during initialization using the existing client-supported mechanism and its native profession artwork. The button SHALL be shown by default and SHALL follow the saved minimap visibility preference on initialization and when the preference changes. Restoring visibility SHALL use the last saved minimap angle.

#### Scenario: First initialization

- **WHEN** CraftAtlas finishes loading without a saved visibility preference
- **THEN** one CraftAtlas button is visible at the minimap with the native profession icon

#### Scenario: Hide the button and reload

- **WHEN** the player clears the minimap checkbox in General
- **THEN** the button is hidden immediately and stays hidden after `/reload`

#### Scenario: Restore the button from the slash command

- **GIVEN** the minimap button is hidden and a position was previously saved
- **WHEN** the player opens CraftAtlas with `/craftatlas` and selects the minimap checkbox in General
- **THEN** the button appears immediately at its last saved angle
- **AND** left-click opens the explorer

#### Scenario: Repeated initialization

- **WHEN** initialization or reload paths execute more than once
- **THEN** CraftAtlas does not create duplicate minimap buttons

#### Scenario: Repeated toggling

- **WHEN** the visibility preference is changed more than once
- **THEN** at most one CraftAtlas minimap button exists

## REMOVED Requirements

### Requirement: No premature minimap setting

**Reason**: The addon now supports configuring minimap visibility.

**Migration**: General exposes the checkbox and the existing visible default applies to records without a saved visibility preference.
