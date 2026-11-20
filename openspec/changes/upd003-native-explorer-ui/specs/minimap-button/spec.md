# Minimap button

## ADDED Requirements

### Requirement: Secondary click opens native CraftAtlas options

The minimap button SHALL open the registered CraftAtlas category in Options → AddOns on right-click when the client provides the category-opening API. Left-click and drag SHALL retain their existing explorer and position behaviors.

#### Scenario: Open the category directly

- **WHEN** the player right-clicks the CraftAtlas minimap button
- **THEN** the native Options window opens directly to the CraftAtlas category
- **AND** the explorer is neither opened nor reset by the shortcut

#### Scenario: Missing native category opener

- **WHEN** the player right-clicks on a client without a supported category opener
- **THEN** the current UI stays usable and the click produces no Lua error

### Requirement: Highlight minimap gestures in the tooltip

The hover tooltip SHALL show the localized gestures in left-click, drag and right-click order. Each gesture label SHALL use dark gold and its action description SHALL use the normal tooltip text color.

#### Scenario: Hover in Spanish

- **WHEN** the effective addon locale is esES and the player hovers the button
- **THEN** the tooltip starts its three instruction lines with `Clic izquierdo:`, `Arrastrar:`, and `Clic derecho:` in that order
