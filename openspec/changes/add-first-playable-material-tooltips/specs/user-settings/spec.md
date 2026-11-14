## ADDED Requirements

### Requirement: Provide a discoverable in-game language selector
CraftAtlas SHALL register the /craftatlas slash command and open a simple in-game settings interface with language options Auto, English and Español.

#### Scenario: Opening preferences
- **WHEN** the player enters /craftatlas
- **THEN** a working settings interface appears with the currently selected language preference

#### Scenario: Selecting Spanish manually
- **WHEN** the player selects Español in the settings interface
- **THEN** subsequent CraftAtlas labels display in Spanish regardless of the game client locale

### Requirement: Persist a safe account-wide language preference
The addon SHALL persist one of auto, enUS, or esES across reloads using a client-supported account-wide SavedVariables mechanism, with auto as default. Missing or corrupted state SHALL recover without client Lua errors.

#### Scenario: First installation
- **WHEN** a user has no CraftAtlas SavedVariables
- **THEN** the language setting defaults to auto

#### Scenario: Preference survives reload
- **WHEN** a player selects enUS and runs /reload
- **THEN** the selected setting remains enUS and CraftAtlas strings remain English

#### Scenario: Invalid persisted language
- **WHEN** SavedVariables contain a value outside auto, enUS and esES
- **THEN** the addon normalizes it to auto and continues safely

### Requirement: Updated settings affect new tooltips without restarting
A language change SHALL affect newly rendered CraftAtlas tooltip and settings labels without needing to restart WoW.

#### Scenario: Switching languages while logged in
- **WHEN** the player changes their preference in the settings UI and subsequently hovers an item
- **THEN** its annotation uses the newly selected language
