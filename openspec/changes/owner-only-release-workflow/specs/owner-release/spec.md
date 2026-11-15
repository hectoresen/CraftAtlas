# Owner-only installable Releases

## ADDED Requirements

### Requirement: Owner-only publishing
The system SHALL offer an explicitly manual release workflow on main and SHALL prevent any actor other than @hectoresen from publishing a release, including workflow reruns by another actor.

#### Scenario: Maintainer dispatch
- **WHEN** github.actor and github.triggering_actor are hectoresen and the workflow ref is refs/heads/main in hectoresen/CraftAtlas
- **THEN** validation and publication may run, subject to all release checks.

#### Scenario: Other actor attempts publication
- **WHEN** any of github.actor, github.triggering_actor, repository identity or branch identity fails the owner-only gate
- **THEN** no publishing job executes and no tag or release is created.

### Requirement: Minimal ready-to-install artifact
The system SHALL create a ZIP asset containing a single top-level CraftAtlas/ folder with the .toc, each runtime Lua file referenced by that manifest and any required redistribution license files, excluding repository-only materials.

#### Scenario: Installed by unzipping
- **WHEN** the user extracts the release ZIP into Interface/AddOns/
- **THEN** Interface/AddOns/CraftAtlas/CraftAtlas.toc exists and all referenced Lua modules are present.

#### Scenario: Development-only sources
- **WHEN** the ZIP is built
- **THEN** source JSON data, repository documentation, tests, scripts and OpenSpec artifacts are excluded.

#### Scenario: Bad manifest
- **WHEN** a manifest path is missing, unsafe, repeated or invalid
- **THEN** the release fails before publishing.

### Requirement: Safe manually selected release version
The system SHALL select a unique SemVer tag based on existing tags and the maintainer's patch/minor/major selection, with v0.1.0 as initial tag when no stable-form SemVer tags exist, and SHALL rewrite only the packaged toc version.

#### Scenario: First publication
- **WHEN** no vMAJOR.MINOR.PATCH tags exist
- **THEN** the first release is tagged v0.1.0 with toc version 0.1.0.

#### Scenario: Increment
- **WHEN** latest tag is v0.1.0 and patch is selected
- **THEN** next release is v0.1.1 with toc version 0.1.1.

#### Scenario: Duplicate tag
- **WHEN** selected tag already exists
- **THEN** the workflow refuses to overwrite an existing release or tag.

### Requirement: Validate before writing releases
The system SHALL execute existing repository/data checks and packaging tests successfully before creating any tag or GitHub Release, and SHALL mark releases below v1.0.0 as prerelease.

#### Scenario: Failed data validation
- **WHEN** any required check fails
- **THEN** publishing does not run.

#### Scenario: Development release
- **WHEN** the selected version has major version 0
- **THEN** the GitHub Release is marked prerelease and makes no unverified live-client compatibility claim.
