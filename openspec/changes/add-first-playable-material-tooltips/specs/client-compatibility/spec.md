## ADDED Requirements

### Requirement: Install as a self-contained Forever addon
The released package SHALL contain a properly structured CraftAtlas addon directory and a .toc metadata file with interface compatibility verified against an actual World of Warcraft: Forever client build. It SHALL load without third-party addon dependencies.

#### Scenario: Fresh supported-client installation
- **WHEN** the released addon folder is placed in the verified Forever AddOns directory
- **THEN** the client recognizes and enables CraftAtlas without a startup Lua error

#### Scenario: Incorrect assumed interface API
- **WHEN** an API or .toc interface number has not been validated on a current Forever build
- **THEN** a release SHALL NOT claim verified client compatibility

### Requirement: Client-specific integration has recorded manual acceptance evidence
Before publishing v0.0.1, maintainers SHALL record the tested client build, UI integration mechanism, inventory itemID retrieval, tooltip behavior, slash command, locale detection, settings persistence and any Lua errors or limitations.

#### Scenario: Acceptance matrix incomplete
- **WHEN** in-game inventory, multi-profession, unknown item, enUS/esES, persistence or idempotence checks are unperformed
- **THEN** the version is not marked as a verified playable v0.0.1 release

### Requirement: Addon behavior is safe and reversible
CraftAtlas SHALL NOT require networking, modify game items, access private user data, or persist non-settings character content. Disabling the addon SHALL restore the original UI behavior without affecting game progression.

#### Scenario: Player disables the addon
- **WHEN** CraftAtlas is disabled and the client is restarted
- **THEN** the addon no longer annotates item tooltips and no game item data is changed

### Requirement: Release artifacts reflect verified scope
The v0.0.1 release SHALL include install instructions, local catalog coverage description, change log and automated-test results, and SHALL exclude future unimplemented recipe/search capabilities.

#### Scenario: Release candidate is packaged
- **WHEN** CI and manual Forever tests have passed and the owner approves the release
- **THEN** the package contains only the required addon files and accurately describes current behavior
