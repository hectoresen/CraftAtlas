# Addon identity

## ADDED Requirements

### Requirement: Native profession icon

The addon SHALL declare or provide a client-supported icon that represents professions or crafting rather than the default question-mark icon.

#### Scenario: Addon list displays CraftAtlas identity

- **WHEN** the player opens the client's addon list
- **THEN** CraftAtlas displays the verified native profession/crafting icon
- **AND** it does not display the default question-mark icon

#### Scenario: Unsupported icon mechanism

- **WHEN** the target client does not support the selected icon declaration or resource
- **THEN** initialization reports the compatibility issue through the documented development path
- **AND** the implementation does not silently ship an unrelated web-style replacement icon
