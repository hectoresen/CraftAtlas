## ADDED Requirements

### Requirement: Maintain all verifiable material relationships without inventing missing data
CraftAtlas SHALL index every eligible itemID-to-consuming-profession fact that can be legally sourced and verified for a declared Forever reference snapshot, including classic and Forever-custom items, crafted reagents and items consumed by multiple professions. Every published relationship SHALL have evidence traceable at the individual relation level.

#### Scenario: Item appears in several recipes and professions
- **WHEN** two recipes in one profession and one recipe in another consume the same itemID
- **THEN** both professions are displayed once, while all relation-level evidence remains auditable

#### Scenario: Candidate lacks proof or redistribution permission
- **WHEN** an input record lacks reliable evidence or acceptable data redistribution rights
- **THEN** the record is rejected from the runtime catalog and reported as unresolved

### Requirement: Distinguish unknown from verified negative
The addon SHALL not infer a material's lack of profession uses from an absent mapping; absent or unverified IDs SHALL remain unknown and contribute no asserted tooltip information.

#### Scenario: Unrecognized Forever item
- **WHEN** the player hovers an itemID absent from the verified catalog
- **THEN** CraftAtlas adds no profession names or false "none" claim

### Requirement: Produce deterministic offline catalogs and coverage reports
A local, repeatable build SHALL generate stable Lua runtime tables and reproducible counts, rejecting invalid IDs, duplicate facts, unsupported profession keys, incompatible source metadata and missing evidence. It SHALL require no runtime network calls.

#### Scenario: Same source snapshot processed twice
- **WHEN** the same vetted input is regenerated
- **THEN** runtime Lua and coverage figures match exactly

### Requirement: Define completeness against an audited reference universe
A claim of full coverage SHALL be allowed only if an approved, licensed and versioned reference universe is identified, the eligible denominator is known, and every eligible consuming relationship is verified. Reports SHALL include per-profession coverage, unknowns and blocked records and SHALL distinguish partial coverage from full coverage.

#### Scenario: Complete source snapshot
- **WHEN** all eligible item-profession records from the approved scoped source have verified entries
- **THEN** the report may describe complete coverage **for that snapshot and client build only**

#### Scenario: Unknown denominator
- **WHEN** no complete, legally usable Forever source snapshot can be established
- **THEN** the report marks coverage as not measurable and SHALL NOT claim to support every possible material

#### Scenario: Partially verified catalog
- **WHEN** some eligible records remain unverified
- **THEN** their count and blocker reasons are disclosed and an unqualified full-coverage release claim is rejected
