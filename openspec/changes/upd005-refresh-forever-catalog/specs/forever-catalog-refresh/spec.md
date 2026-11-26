# Forever catalog refresh

## ADDED Requirements

### Requirement: Pinned and attributable current Forever catalog

CraftAtlas SHALL compile an offline catalog from a verifiable licensed pinned WoW Forever source, retaining exact source release, client build, review date and license attribution without live network requirements.

#### Scenario: New source differs from older beta

- **WHEN** a refresh is generated against the previously pinned beta snapshot
- **THEN** a reproducible report SHALL separately list added, removed, changed and ambiguous recipe, ingredient and metadata records with provenance.

### Requirement: Complete source-backed recipe identities including reagent-free actions

CraftAtlas SHALL store unique `professionKey:spellID` recipe entries independently of ingredient relationships, preserving legitimate zero-reagent and non-item actions without inventing materials, outputs or client names.

#### Scenario: A camp recipe has zero materials

- **WHEN** a source-backed camp recipe has an empty reagent set
- **THEN** Fabricables catalog SHALL retain its recipe identity and category, while Materials lookup SHALL not emit invented material-use records.

#### Scenario: Positive quantities

- **WHEN** an accepted recipe uses ingredient itemID N in quantity Q
- **THEN** the recipe detail, reverse use index, source JSON and generated runtime Lua SHALL agree on the exact integer itemID and positive quantity.

### Requirement: Forever camp profession coverage

CraftAtlas SHALL include the source-backed Herbalism and Skinning camp professions and preserve existing camp recipes in other categories; profession identity, localized registry and search/filter behavior SHALL remain consistent.

#### Scenario: Herbalism camp object

- **WHEN** a pinned licensed Forever source contains a Herbalism camp recipe
- **THEN** the recipe SHALL be represented under a stable HERBALISM profession key, with its source-backed reagent/output/action semantics and no implied learned-recipe status.

### Requirement: Source-backed optional planning metadata

CraftAtlas SHALL preserve optional source-backed recipe skill/difficulty, camping classification and acquisition information (e.g. teaching item, vendor, trainer, quest and documented faction/cost) for future consumers, distinguishing unknown from confirmed empty values. It SHALL NOT invent corresponding UI or claim player learning/eligibility.

#### Scenario: Acquisition source not documented

- **WHEN** no reliable acquisition source is available for a recipe
- **THEN** the stored value SHALL remain unknown rather than being presented as freely learnable or vendor-sold.

### Requirement: Conservative deletion and conflict handling

CraftAtlas SHALL NOT delete or clear existing ingredient facts solely because a partial secondary source omits a recipe or reports an empty reagent set. A changed or removed fact SHALL require explicit evidence and be traceable in the diff report.

#### Scenario: Secondary source has no ingredients

- **WHEN** an older recipe has three recorded reagents and a newer secondary source lists none
- **THEN** the discrepancy SHALL be flagged as ambiguous until the pinned authoritative source or direct client evidence establishes the correct behavior.

### Requirement: Catalog and tracker backward compatibility

Catalog refresh SHALL retain stable recipe keys and character tracking preferences, preserve Materiales/Fabricables browsing semantics and pass catalog/release regression gates.

#### Scenario: Existing tracked recipe survives dataset update

- **WHEN** a user opens a previously cataloged recipe after updating data
- **THEN** recipe identity and the character-global tracking preference SHALL remain stable, with progress recalculated from the accepted refreshed ingredient quantities.

### Requirement: No unsupported completeness claims

Coverage metrics SHALL distinguish total source recipes, recipes with real ingredients, unique reagent itemIDs and relationships, and SHALL NOT assert exhaustive live Forever coverage without verified reference denominator and client QA.

#### Scenario: Source imported but live matrix incomplete

- **WHEN** deterministic import checks pass but game-client acceptance is incomplete
- **THEN** the coverage report SHALL describe source-backed counts while leaving full live validation explicitly false or unknown.
