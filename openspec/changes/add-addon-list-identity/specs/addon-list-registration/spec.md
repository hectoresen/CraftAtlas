# AddOns list registration

## ADDED Requirements

### Requirement: CraftAtlas is discoverable under Professions

The native WoW: Forever AddOns list SHALL show one entry titled `CraftAtlas` under `Profesiones` on an esES game client and `Professions` on an enUS game client. Discovery SHALL work whether or not the installed addon is enabled for the selected character. The native list SHALL retain control of category collapse and enable state.

#### Scenario: Find the disabled addon in Spanish

- **GIVEN** CraftAtlas is installed and disabled for the selected character on an esES client
- **WHEN** the player opens the native AddOns list at character selection and expands `Profesiones`
- **THEN** the category contains one entry named `CraftAtlas`, marked disabled by the client
- **AND** searching the list for `CraftAtlas` still includes that entry under `Profesiones` when expanded

#### Scenario: Find the enabled addon in English

- **GIVEN** CraftAtlas is installed and enabled on an enUS client
- **WHEN** the player opens the native AddOns list in game and expands `Professions`
- **THEN** the category contains one entry named `CraftAtlas`, marked enabled by the client

### Requirement: The AddOns list and minimap share the same artwork

The CraftAtlas row SHALL show the existing native `Trade_BlackSmithing` artwork used by the minimap button. The artwork SHALL render even when the addon is disabled. The list may apply its own size and framing.

#### Scenario: Compare the two icons

- **GIVEN** CraftAtlas is installed and enabled and its minimap button is visible
- **WHEN** the player compares the CraftAtlas row in the native AddOns list with the minimap button
- **THEN** both show the same blacksmithing artwork, with no blank or default question-mark icon in the list

#### Scenario: Show the icon before CraftAtlas loads

- **GIVEN** CraftAtlas is installed from its installable ZIP and is disabled for the selected character
- **WHEN** the player views its row in the expanded category on the native AddOns list
- **THEN** the row still shows the blacksmithing artwork
