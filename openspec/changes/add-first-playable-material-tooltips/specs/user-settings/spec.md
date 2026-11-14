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


### Requirement: Match native Forever or Classic UI styling
The settings interface SHALL use compatible native WoW Forever UI visual components and typography where available, or supported WoW Classic equivalents when necessary. It SHALL remain compact, readable and visually restrained, without non-native external fonts or unnecessary decoration.

#### Scenario: Open settings on a supported Forever client
- **WHEN** the player opens CraftAtlas settings using /craftatlas
- **THEN** the window uses supported in-game fonts, frame textures, button treatments and legible contrast consistent with the client

#### Scenario: Forever-specific visual templates unavailable
- **WHEN** the tested client does not expose special Forever settings components
- **THEN** the addon presents a compatible Classic-style interface without missing textures, fonts or Lua errors

#### Scenario: Normal UI scale
- **WHEN** the game is at its default UI scale
- **THEN** labels, selector, heading and close control are readable and usable without decorative visual clutter

### Requirement: Provide a minimal, extensible settings shell
The interface SHALL contain a clear CraftAtlas title, a visible close control, a navigation region and a content region. v0.0.1 SHALL show only the functional General category and its language setting; the layout SHALL permit additional categories in future versions without rewriting the top-level window structure.

#### Scenario: First opening of v0.0.1 settings
- **WHEN** the player opens the settings window
- **THEN** General is the active visible category and the only selectable category, showing the current language preference and a short explanatory text

#### Scenario: Future modules are not yet shipped
- **WHEN** v0.0.1 settings are displayed
- **THEN** no inactive Search, Recipes or other misleading navigation entries are presented

#### Scenario: Close and reopen
- **WHEN** the player closes settings using its close control and invokes /craftatlas again
- **THEN** the panel reopens in General with the previously selected language and without creating duplicate panels
