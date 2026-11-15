# Localization

## Requirements

### Requirement: Translate all CraftAtlas user-facing labels in English and Spanish
CraftAtlas SHALL provide enUS and esES strings for its tooltip heading, profession labels, settings UI and user-facing feedback, and SHALL NOT embed localized strings in itemID lookup or catalog keys.

#### Scenario: Spanish UI
- **WHEN** the effective addon language is esES
- **THEN** each CraftAtlas-added tooltip and settings label is displayed in Spanish

#### Scenario: English UI
- **WHEN** the effective addon language is enUS
- **THEN** each CraftAtlas-added tooltip and settings label is displayed in English

### Requirement: Automatically select a supported client locale
With no explicit language override, CraftAtlas SHALL use esES for a client reporting esES, enUS for enUS, and enUS as fallback for any other client locale.

#### Scenario: Unsupported client locale
- **WHEN** the game reports frFR and no override exists
- **THEN** all CraftAtlas strings resolve to enUS without an error or missing key placeholder

#### Scenario: Language does not affect matching
- **WHEN** the effective language changes from enUS to esES
- **THEN** the set of verified profession keys for the same itemID is unchanged

### Requirement: Avoid missing translation output
The localization layer SHALL use a well-defined English fallback for missing or unsupported translations and SHALL NOT output nil, translation identifiers or Lua errors as the intended display text.

#### Scenario: Individual Spanish label missing
- **WHEN** a requested esES key is unavailable
- **THEN** the enUS translation is used instead of displaying nil or a raw key
