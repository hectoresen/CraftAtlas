# Minimap button

## MODIFIED Requirements

### Requirement: Default minimap entry point

CraftAtlas SHALL create one minimap button during initialization using the existing client-supported mechanism and native profession artwork. It SHALL follow the saved visibility preference at initialization and when the setting changes. The default is visible. Restoring visibility SHALL use the last saved minimap angle.

#### Scenario: First initialization

- **WHEN** CraftAtlas finishes loading without a saved visibility preference
- **THEN** one CraftAtlas button is visible on the minimap with the native profession icon

#### Scenario: Hide the button and reload

- **WHEN** the player clears the minimap checkbox in Options → AddOns → CraftAtlas
- **THEN** the button is hidden immediately and stays hidden after `/reload`

#### Scenario: Restore the button from native options

- **GIVEN** the minimap button is hidden and a position was previously saved
- **WHEN** the player selects the minimap checkbox in Options → AddOns → CraftAtlas
- **THEN** the button appears immediately at the last saved angle
- **AND** left-click opens the same explorer as `/craftatlas`

#### Scenario: Repeated initialization

- **WHEN** initialization or reload paths execute more than once
- **THEN** CraftAtlas does not create duplicate minimap buttons

#### Scenario: Repeated toggling

- **WHEN** the player repeatedly changes visibility
- **THEN** CraftAtlas reuses the existing minimap button

### Requirement: Minimap click opens settings

The minimap button SHALL open the same CraftAtlas explorer as `/craftatlas` when clicked with the primary mouse button.

#### Scenario: Primary click

- **WHEN** the player left-clicks the CraftAtlas minimap button
- **THEN** CraftAtlas opens or focuses its explorer through the same path as `/craftatlas`

## REMOVED Requirements

### Requirement: No premature minimap setting

**Reason**: CraftAtlas now supports configuring minimap visibility in native options.

**Migration**: General exposes the checkbox and records without a saved visibility preference keep the visible default.
