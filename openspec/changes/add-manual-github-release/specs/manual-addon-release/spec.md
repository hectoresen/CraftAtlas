# Manual addon releases

## ADDED Requirements

### Requirement: Owner-triggered source selection
The system SHALL expose a manually dispatched release workflow that packages only main and SHALL NOT publish on regular pushes or pull requests.

#### Scenario: Manually release from main
- **WHEN** the maintainer runs the publish action on main selecting a SemVer increment
- **THEN** validation executes and a new GitHub Release is created only if every check succeeds.

#### Scenario: Dispatch from another branch
- **WHEN** a manual dispatch is started from a non-main ref
- **THEN** the publishing job is rejected without creating a tag or release.

### Requirement: Installable minimal archive
The system SHALL attach a versioned ZIP containing precisely one top-level CraftAtlas directory with its referenced runtime Lua modules, toc file and necessary redistribution attribution, and SHALL omit repository-only files.

#### Scenario: Extract into AddOns
- **WHEN** a user extracts the release ZIP under Interface/AddOns
- **THEN** Interface/AddOns/CraftAtlas/CraftAtlas.toc exists with the complete files referenced by the manifest and no extra CraftAtlas folder nesting.

#### Scenario: Source has missing Lua dependency
- **WHEN** a file referenced in CraftAtlas.toc is unavailable
- **THEN** packaging fails before publishing.

#### Scenario: Development assets
- **WHEN** a release archive is built
- **THEN** docs, tests, scripts, OpenSpec files and non-runtime source data are not included.

### Requirement: Safe reproducible versioning
The system SHALL resolve a unique vMAJOR.MINOR.PATCH tag from existing SemVer tags, beginning at v0.1.0 when none exists, and SHALL set the packaged .toc version to the release version without editing tracked addon source.

#### Scenario: First release
- **WHEN** no SemVer release tags exist
- **THEN** v0.1.0 is selected and treated as prerelease.

#### Scenario: Increment existing release
- **WHEN** the latest tag is v0.1.0 and patch is selected
- **THEN** the release is tagged v0.1.1 and the packaged toc declares 0.1.1.

#### Scenario: Already published
- **WHEN** the target tag or release already exists
- **THEN** the workflow fails safely without overwriting it.

### Requirement: Validated publication
The system SHALL run existing repository and material-data checks plus packaging tests before creating a tag or release, and SHALL limit GitHub write permissions to publishing.

#### Scenario: Failed validation
- **WHEN** any required check fails
- **THEN** no GitHub Release is published.

#### Scenario: Development milestone
- **WHEN** the selected version is below 1.0.0
- **THEN** the release is flagged as prerelease and does not assert live-client or catalog completeness.
