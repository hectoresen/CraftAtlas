# Reverse recipe usage

## ADDED Requirements

### Requirement: Resolve the recipes consuming a material
CraftAtlas SHALL provide a deterministic offline mapping from a verified reagent itemID to known profession recipes that consume it. Every displayed recipe use SHALL retain a recipe spellID and consuming profession key.

#### Scenario: A material used in multiple recipes
- **WHEN** a player selects a verified reagent consumed by several distinct recipes
- **THEN** the detail shows each validated recipe once
- **AND** groups uses by consuming profession
- **AND** reports the number of verified distinct recipe uses

#### Scenario: No verified recipes
- **WHEN** the item has no confirmed recipe-use data
- **THEN** the detail communicates that no verified recipe use is currently available
- **AND** does not confuse unknown coverage with zero possible uses

### Requirement: Preserve verified quantities and output identities
Each supported recipe use SHALL display ingredient quantity and crafted output item when those values are available from validated source evidence; missing values SHALL be explicitly unavailable rather than inferred.

#### Scenario: Known input quantity and output item
- **WHEN** a recipe contains a verified positive reagent quantity and a verified crafted output itemID
- **THEN** the material detail shows the correct input quantity, output item icon and client-resolved name

#### Scenario: Unknown or non-item output
- **WHEN** a recipe produces no item or its output itemID cannot be verified
- **THEN** the UI describes the recipe without fabricating a crafted object
- **AND** differentiates non-item recipes from unresolved output metadata

#### Scenario: Data does not match client build
- **WHEN** source recipes are known only from a different beta build and cannot be verified against the supported build
- **THEN** the UI and documentation SHALL NOT assert that those recipes are craftable on the current live server
