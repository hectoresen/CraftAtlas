# Localization

## ADDED Requirements

### Requirement: Mark the saved language choice in native AddOn options

The language selector under Options → AddOns → CraftAtlas SHALL display and mark the saved account choice. It SHALL use a native selection indicator or an equivalent visible fallback. This page SHALL be the sole language selection surface and SHALL preserve existing locale fallback behavior.

#### Scenario: Select a manual language from options

- **WHEN** the player chooses Español or English in native AddOn options and reopens the dropdown
- **THEN** only the newly saved option is marked and the button displays that choice in the active addon language
- **AND** the explorer labels update while preserving browsing state, and the selected indicator remains correct after `/reload`

#### Scenario: Auto resolves to a supported language or fallback

- **WHEN** Auto is saved and the client reports esES, enUS or an unsupported locale
- **THEN** only the localized Auto entry is marked in the dropdown
- **AND** the interface uses Spanish for esES and English for enUS or an unsupported locale

#### Scenario: Use the fallback selector

- **WHEN** the native dropdown template or required API is unavailable and the player opens the fallback selector
- **THEN** all three choices are usable and exactly the saved choice has a distinct selection indicator
- **AND** choosing an option updates the preference and localized explorer labels as on the native path
