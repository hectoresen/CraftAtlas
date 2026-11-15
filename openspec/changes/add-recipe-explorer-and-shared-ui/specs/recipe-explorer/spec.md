# Recipe Explorer view

## ADDED Requirements

### Requirement: Browse and search recipes
CraftAtlas SHALL present a distinct Recetas/Recipes view with a functional text search, profession filter and selectable result list, using the same native layout pattern as Materials. Search SHALL match available spell/recipe names, crafted output names, numeric recipe IDs and localized profession names.

#### Scenario: Search a known recipe
- **WHEN** a player types a fragment of a recipe's client-resolved name
- **THEN** only source-backed matching recipes appear without pressing Enter
- **AND** each row shows the best available recipe/output icon and consuming profession

#### Scenario: Search the crafted product
- **WHEN** a player searches for the name of a source-identified output item
- **THEN** every source-backed recipe that produces a matching item may appear
- **AND** results are not deduplicated by output itemID

#### Scenario: Profession filter
- **WHEN** a player chooses Alchemy while searching
- **THEN** only source-backed Alchemy recipes matching the text remain visible
- **AND** the count and selected detail update coherently

#### Scenario: Unavailable client names
- **WHEN** a recipe name/output name is not yet available from the client
- **THEN** the UI distinguishes loading or incomplete matching from a confirmed empty result
- **AND** numeric spellID discovery remains available without a wall of anonymous rows

### Requirement: Display complete verified recipe detail
A selected recipe SHALL display its name or native fallback, consuming profession, all verified input materials with required quantities, and its crafted output where source-backed. Native WoW hover tooltips SHALL be used for ingredients, results and compatible recipe spells.

#### Scenario: Selected recipe has several reagents
- **WHEN** a known recipe consumes three distinct source-backed materials
- **THEN** the detail lists all three original itemIDs with their verified quantities
- **AND** the player can hover each input for native item information

#### Scenario: Output has client rarity and stats
- **WHEN** a known output item has a supported WoW-native item tooltip
- **THEN** hovering it displays rarity/statistics supplied by the client
- **AND** CraftAtlas does not construct a synthetic rarity or stats

#### Scenario: Enchantment or unknown output
- **WHEN** the recipe has no item output or source metadata is unresolved
- **THEN** the detail differentiates non-item actions from unknown results
- **AND** it does not show a fabricated crafted product
