# Minimap button

## MODIFIED Requirements

### Requirement: Minimap click opens settings

The minimap button SHALL open the same CraftAtlas explorer through the same entry point as `/craftatlas` on an ordinary left-click. A left-button drag SHALL affect only the button position.

#### Scenario: Primary click

- **WHEN** the player left-clicks the CraftAtlas minimap button without dragging
- **THEN** CraftAtlas opens or focuses its explorer as it does for `/craftatlas`

#### Scenario: First click after a drag

- **GIVEN** the explorer is closed
- **WHEN** the player releases a minimap button drag
- **THEN** the explorer remains closed
- **AND** the first subsequent ordinary left-click opens it

## ADDED Requirements

### Requirement: Drag stays on the minimap edge

The CraftAtlas minimap button SHALL keep its center on the circular minimap edge throughout a left-button drag, follow the pointer's angle relative to the minimap center, and stay at the angle where the player releases it. CraftAtlas SHALL save the angle on release in its existing minimap preference and restore it on reload.

#### Scenario: Drag and release outside the minimap

- **WHEN** the player drags the button around the minimap and releases it with the pointer outside the map
- **THEN** the button tracks the pointer's angle on the minimap edge throughout the drag
- **AND** it stays on the edge at the release angle after the pointer moves away

#### Scenario: Pointer at the minimap center

- **GIVEN** the button is at a valid angle during a drag
- **WHEN** the pointer reaches the exact minimap center
- **THEN** the button keeps its last valid angle until the pointer leaves the center or the player releases it

#### Scenario: Reload restores the release angle

- **GIVEN** the player has dragged and released the button at a new angle
- **WHEN** the player runs `/reload`
- **THEN** the button appears on the minimap edge at the saved angle

### Requirement: Minimap hover describes the controls

The native minimap hover tooltip SHALL display the title `CraftAtlas` followed by the open and move instructions on separate lines in the effective addon locale. The tooltip SHALL close when the pointer leaves the button.

#### Scenario: Spanish instructions

- **WHEN** the player hovers over the button with esES active
- **THEN** the tooltip shows `CraftAtlas` as its title
- **AND** it shows `Click izq.: Abrir CraftAtlas` followed by `Arrastrar: Mover icono`

#### Scenario: English instructions and locale fallback

- **WHEN** the player hovers over the button with enUS active or with Automatic on a client locale other than esES
- **THEN** the tooltip shows `CraftAtlas` as its title
- **AND** it shows `Left-click: Open CraftAtlas` followed by `Drag: Move icon`

#### Scenario: Pointer leaves the button

- **GIVEN** the minimap tooltip is visible
- **WHEN** the pointer leaves the button
- **THEN** the minimap tooltip closes
