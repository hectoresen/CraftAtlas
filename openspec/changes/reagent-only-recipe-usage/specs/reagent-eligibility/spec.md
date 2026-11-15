# Reagent eligibility

## ADDED Requirements

### Requirement: Restrict material discovery to recipe inputs
CraftAtlas SHALL expose only itemIDs supported by a validated reagent/input relation for a profession recipe in the default material list, search results, filters and counts. Output-only items SHALL NOT be exposed as profession materials.

#### Scenario: Finished craft output only
- **WHEN** an item is craftable but no validated profession recipe consumes it as a reagent
- **THEN** it is excluded from the normal material results and count
- **AND** it is not presented as a profession ingredient

#### Scenario: Crafted item also used as a reagent
- **WHEN** a crafted/equippable item is independently verified as an input to another profession recipe
- **THEN** it remains eligible for search and browsing
- **AND** its consuming recipe and profession are visible

#### Scenario: Source evidence uncertain
- **WHEN** a material-to-recipe input link has not been verified or is contradicted
- **THEN** the default results SHALL exclude that unverified relationship
- **AND** the data quality report identifies the outstanding uncertainty without claiming an exhaustive catalog

### Requirement: Prevent output-to-input import confusion
The offline importer and generated runtime catalog SHALL preserve a strict distinction between recipe reagent itemIDs and crafted output itemIDs using source schema provenance.

#### Scenario: Input and output fields
- **WHEN** a source recipe contains both reagent and crafted-output fields
- **THEN** only reagent fields establish the material→recipe input relationship
- **AND** crafted-output fields populate output metadata only

#### Scenario: Regression material
- **WHEN** the suspect crafted cloak identified in maintainer testing is audited
- **THEN** its numeric ID, source recipe IDs and verified classification are recorded in a deterministic test
- **AND** any reproduced false-positive input inclusion is prevented

### Requirement: Preserve validated catalog metadata
Generated data SHALL identify source version, client applicability, license and relationship verification status; it SHALL NOT claim full live-realm completeness from a beta snapshot.

#### Scenario: Unknown item or missing source
- **WHEN** no licensed verified reagent relationship exists for an itemID
- **THEN** no profession/material association or recipe usage is fabricated
