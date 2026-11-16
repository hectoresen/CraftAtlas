# Addon configuration

## ADDED Requirements

### Requirement: Register CraftAtlas under native AddOn options

CraftAtlas SHALL register one page named CraftAtlas under the game's Options → AddOns on supported Forever clients. The page SHALL present localized General and Tooltip sections using native controls. CraftAtlas SHALL keep these sections out of the Materials and Craftables explorer.

#### Scenario: Find CraftAtlas in the game options

- **WHEN** the player opens Options → AddOns and selects CraftAtlas
- **THEN** the native options window shows the General and Tooltip controls in the effective addon locale
- **AND** the page can be reached without first opening the CraftAtlas explorer

#### Scenario: Return to the explorer

- **GIVEN** the player has an explorer query, profession filter and selected detail
- **WHEN** the player visits and closes the native options page
- **THEN** the explorer retains that browsing state and existing Back history
- **AND** neither Materials nor Craftables contains a separate Configuration page

#### Scenario: Use a compact UI scale

- **WHEN** the player opens the CraftAtlas page at a supported compact UI scale
- **THEN** each control remains readable and reachable within the native options window

#### Scenario: Repeated initialization

- **WHEN** initialization runs more than once on a supported client
- **THEN** the game still lists exactly one CraftAtlas category

#### Scenario: Unavailable native registration

- **WHEN** the required native registration API is unavailable
- **THEN** CraftAtlas skips unsupported registration without a Lua error
- **AND** the existing explorer remains usable

### Requirement: Share the existing language preference

General SHALL expose Auto, Español and English with the same account-wide language preference as the explorer's existing selector. Both controls SHALL show the saved choice and use the existing locale fallback.

#### Scenario: Change language from native options

- **WHEN** the player selects Español on the CraftAtlas options page
- **THEN** the page updates to Spanish immediately
- **AND** the explorer selector reflects the choice and new or rebuilt tooltip annotations use Spanish
- **AND** the choice survives `/reload`

#### Scenario: Change language from the explorer

- **WHEN** the player chooses Auto in the explorer and opens the CraftAtlas options page on a client reporting an unsupported locale
- **THEN** the options page shows the automatic choice and uses English labels

### Requirement: Provide minimap and tooltip checkboxes

General SHALL provide a checkbox for showing the CraftAtlas minimap button. Tooltip SHALL provide separate checkboxes for showing consuming professions, hiding their icons and showing the professions on one comma-separated line. Each checkbox SHALL reflect the saved preference and apply changes without requiring a reload.

#### Scenario: Disable the consuming-profession section

- **WHEN** the player clears the checkbox for showing consuming professions
- **THEN** both layout checkboxes are disabled and retain their saved selections
- **AND** enabling the consuming-profession section again restores the layout controls with those selections

### Requirement: Persist safe account-wide defaults

CraftAtlas SHALL store the four checkbox preferences account-wide in SavedVariables. Missing or invalid settings SHALL default individually to minimap shown, consuming professions shown, icons shown and one row per profession. Existing valid language and minimap angle values SHALL be kept.

#### Scenario: Load a first installation or an older record

- **WHEN** the addon starts without saved preferences or with an older record
- **THEN** missing checkbox settings use their defaults and existing valid language and minimap angle values are preserved

#### Scenario: Reload after changing settings

- **WHEN** the player changes the four checkboxes and uses `/reload`
- **THEN** the Options → AddOns page reflects the saved choices, including unchecked values
- **AND** the minimap and rebuilt tooltips use those choices

#### Scenario: Recover invalid values individually

- **WHEN** one saved checkbox value is invalid while other values are valid
- **THEN** the invalid value uses its own default and valid values still apply
