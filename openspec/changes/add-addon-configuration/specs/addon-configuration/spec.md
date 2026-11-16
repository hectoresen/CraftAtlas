# Addon configuration

## ADDED Requirements

### Requirement: Provide Configuration from the explorer

CraftAtlas SHALL provide a native Configuration view with localized General and Tooltip sections, accessible from both Materials and Craftables. The view SHALL use the effective addon locale and the existing fallback. Opening and closing it SHALL preserve each explorer view's browsing state and existing navigation history.

#### Scenario: Open Configuration from either explorer view

- **WHEN** the player opens Configuration from Materials or Craftables
- **THEN** the same CraftAtlas window presents the General and Tooltip controls
- **AND** returning to browsing restores the view's previous query, profession filter and selection

#### Scenario: Use a compact UI scale

- **WHEN** the player opens Configuration on a supported compact viewport
- **THEN** the entry, labels and controls are readable and usable without overlapping the browsing controls

### Requirement: Reuse the explorer's language selector in General

General SHALL use the same native language selector and fallback as the explorer, with Auto, Español and English and one shared account-wide language preference. The current language choice SHALL appear consistently in all views.

#### Scenario: Change language from General

- **WHEN** the player chooses Español in General
- **THEN** Configuration updates to Spanish immediately
- **AND** the explorer selector reflects the same choice and new or rebuilt tooltip annotations use Spanish
- **AND** the choice survives `/reload`

#### Scenario: Change language from a browsing view

- **WHEN** the player chooses Auto in Materials or Craftables and then opens General
- **THEN** General shows Auto
- **AND** the controls use English if the game client locale has no supported translation

### Requirement: Provide minimap and tooltip checkboxes

General SHALL provide a checkbox to show the CraftAtlas minimap button. Tooltip SHALL provide separate checkboxes to show the consuming-profession section, hide profession icons and show professions on one comma-separated line. Each SHALL reflect the corresponding saved preference and apply changes without requiring a reload.

#### Scenario: Disable the consuming-profession section

- **WHEN** the player clears the checkbox for showing consuming professions
- **THEN** the icon and single-line checkboxes are disabled and their selections are retained
- **AND** selecting the show-professions checkbox again enables the layout controls with the same selections

### Requirement: Persist safe account-wide defaults

CraftAtlas SHALL store the four checkbox preferences account-wide in SavedVariables. Missing or invalid settings SHALL default individually to minimap shown, consuming professions shown, icons shown and one row per profession. Existing valid language and minimap angle values SHALL be kept.

#### Scenario: Load a first installation or an older record

- **WHEN** the addon starts with no saved record or with an older record containing only valid language and position preferences
- **THEN** all new settings use their defaults and any valid language and position values are preserved

#### Scenario: Reload after changing settings

- **WHEN** the player changes the four checkboxes and uses `/reload`
- **THEN** Configuration reflects all saved choices, including unchecked values, and the minimap and rebuilt tooltips use them

#### Scenario: Recover invalid values individually

- **WHEN** one saved checkbox value is invalid while other values are valid
- **THEN** the invalid value uses its own default and the valid values still apply
