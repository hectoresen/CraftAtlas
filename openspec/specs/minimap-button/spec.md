# Minimap button

## Purpose

Defines the native minimap entry point and its connection to the same CraftAtlas window opened by /craftatlas. The current view layout evolved in subsequent approved changes.

## Requirements

### Requirement: Default minimap entry point

The addon SHALL create one visible minimap button during initialization using a verified client-supported mechanism.

#### Scenario: First initialization

- **WHEN** CraftAtlas finishes loading
- **THEN** one CraftAtlas button is visible at the minimap
- **AND** the button uses the verified native profession/crafting icon

#### Scenario: Repeated initialization

- **WHEN** initialization or reload paths execute more than once
- **THEN** CraftAtlas does not create duplicate minimap buttons

### Requirement: Minimap click opens settings

The minimap button SHALL open the same settings window and state path as `/craftatlas` when clicked with the primary mouse button.

#### Scenario: Primary click

- **WHEN** the player left-clicks the CraftAtlas minimap button
- **THEN** CraftAtlas opens or focuses its settings window
- **AND** the result is equivalent to entering `/craftatlas`

### Requirement: No premature minimap setting

The initial minimap implementation SHALL not expose a visibility or position toggle before the future settings change is approved and implemented.

#### Scenario: Current settings are inspected

- **WHEN** the player opens the current CraftAtlas settings
- **THEN** no operational minimap visibility/position option is shown
