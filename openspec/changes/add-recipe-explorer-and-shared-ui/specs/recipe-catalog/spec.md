# Unique recipe catalog

## ADDED Requirements

### Requirement: Build a source-backed recipe index
CraftAtlas SHALL derive a deterministic offline index of unique recipes keyed by profession and spellID from the already pinned, licensed reagent-use dataset. Each recipe SHALL include all known input itemIDs and quantities, verified consuming profession, optional crafted itemID and a truthful recipe kind.

#### Scenario: Multiple ingredients for one recipe
- **WHEN** source records contain multiple distinct reagents for a recipe
- **THEN** the generated recipe detail includes every verified reagent with exact quantity
- **AND** the recipe appears only once in the global Recipes list

#### Scenario: Multiple recipes produce the same item
- **WHEN** two spellIDs have the same crafted output itemID
- **THEN** both valid recipes remain distinct entries
- **AND** neither is silently merged by output itemID

#### Scenario: Contradictory source records
- **WHEN** rows for one profession/spellID disagree about output identity, kind or an input quantity
- **THEN** generation rejects the contradiction rather than choosing arbitrary metadata

### Requirement: Preserve source integrity and release limits
The recipe index SHALL preserve attributable source/build/license evidence and SHALL NOT infer recipes, input counts, learned status or current live-realm availability that the source does not prove.

#### Scenario: Incomplete client or source coverage
- **WHEN** a source-backed recipe name or item output cannot be resolved in WoW
- **THEN** the view shows a localized pending/unavailable state
- **AND** does not invent an item, rarity, spell name or claim complete live coverage

#### Scenario: Deterministic generated output
- **WHEN** the same pinned source is recompiled
- **THEN** the generated runtime recipe index and report are stable
- **AND** generated drift or orphaned input relationships fails the checks
