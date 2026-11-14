## ADDED Requirements

### Requirement: Annotate supported inventory item tooltips
When the real Forever client supplies a known itemID from a standard player inventory or bag tooltip, CraftAtlas SHALL append a localized profession-usage annotation showing each verified consuming profession. Other tooltip origins are outside v0.0.1.

#### Scenario: Known ingredient in a bag
- **WHEN** the player hovers a bag slot containing a catalogued material
- **THEN** the ordinary tooltip remains intact and the addon displays its verified consuming professions

#### Scenario: Known item in an equipped inventory slot
- **WHEN** a supported player inventory tooltip has a valid known itemID
- **THEN** the same itemID mapping and presentation rules apply

#### Scenario: Unknown item
- **WHEN** the tooltip itemID is absent from the catalog
- **THEN** CraftAtlas adds no unsupported profession annotation

#### Scenario: Bank tooltip
- **WHEN** an item is inspected only in the bank UI
- **THEN** v0.0.1 makes no guarantee of CraftAtlas annotation, because bank support is outside its acceptance scope

### Requirement: Preserve normal tooltip behavior and avoid duplicate output
The addon SHALL use a client-verified compatible tooltip integration that does not modify item properties, duplicate CraftAtlas lines, or prevent the underlying tooltip from displaying. The same itemID and tooltip may refresh repeatedly.

#### Scenario: Repeated hover or tooltip refresh
- **WHEN** a known item tooltip is processed repeatedly without changing the item
- **THEN** each verified profession appears in the tooltip no more than once

#### Scenario: Switching between items
- **WHEN** a tooltip switches from item A to item B or is hidden and reused
- **THEN** the output reflects only the current item and contains no stale CraftAtlas annotation

#### Scenario: Missing client data or callback error
- **WHEN** item data is unavailable or a callback receives incomplete data
- **THEN** the addon fails safely without breaking the ordinary game tooltip or producing fabricated text

### Requirement: Keep tooltip work bounded
Processing SHALL use in-memory local lookups and SHALL NOT require per-frame polling, network requests, synchronous external dependencies or unbounded scanning.

#### Scenario: Rapid bag hovering
- **WHEN** the player moves rapidly between supported item slots
- **THEN** CraftAtlas remains responsive and does not emit Lua errors or duplicate lines
