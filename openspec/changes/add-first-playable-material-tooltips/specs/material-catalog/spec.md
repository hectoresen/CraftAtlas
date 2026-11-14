## ADDED Requirements

### Requirement: Bundle a local starter catalog with traceable relationships
The addon SHALL ship an offline, versioned mapping from numeric itemIDs to verified consuming profession keys. No profession relationship SHALL be invented to fill a coverage target.

#### Scenario: No network connectivity
- **WHEN** the player is logged into WoW without any third-party data service
- **THEN** known material lookups still work using bundled data

#### Scenario: Catalog contains a Forever-custom item
- **WHEN** a Forever-specific itemID has reliable source evidence and redistribution rights
- **THEN** it MAY be included with explicit compatibility provenance

### Requirement: Starter dataset meets measurable minimum quality gates
Before v0.0.1 release, the dataset SHALL include at least 30 distinct verified material IDs, cover at least five consuming professions, and include at least two verified materials related to more than one profession. If lawful verification cannot meet those thresholds, the release SHALL be blocked pending a separately approved scope change.

#### Scenario: Coverage threshold passes
- **WHEN** data validation processes the candidate release catalog
- **THEN** it confirms item counts, profession diversity and multi-profession counts meet all three minimums

#### Scenario: Verification does not meet target
- **WHEN** any target or source evidence fails validation
- **THEN** the build/release is rejected rather than inventing data or claiming comprehensive coverage

### Requirement: Every mapping has recorded, redistributable provenance
Canonical source data SHALL record the supporting source or evidence, review date, relevant client version/scope and redistribution rights for every included item-to-profession relation. Unlicensed external databases SHALL NOT be copied into the distributed addon.

#### Scenario: Imported material lacks licensing evidence
- **WHEN** a candidate record lacks an acceptable provenance or rights entry
- **THEN** it is excluded from distribution and data validation fails

### Requirement: Catalog generation is deterministic and validated
A repeatable local build SHALL produce a stable Lua runtime mapping and fail on duplicate IDs, invalid profession keys, inconsistent relationships, absent provenance, or divergence between source and generated runtime data.

#### Scenario: Source is regenerated unchanged
- **WHEN** the same audited input is processed repeatedly
- **THEN** output is byte-for-byte equivalent and CI does not detect drift

#### Scenario: Duplicate or unsupported ID
- **WHEN** invalid catalog input is introduced
- **THEN** validation reports an actionable error and fails

### Requirement: Catalog coverage is communicated accurately
Installation/release documentation SHALL describe that v0.0.1 coverage is a verified starter subset, not every material or custom Forever item.

#### Scenario: User sees release notes
- **WHEN** a v0.0.1 package is released
- **THEN** the documentation states supported client build, coverage counts and known limitations
