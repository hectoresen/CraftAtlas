## ADDED Requirements

### Requirement: Identify materials using numeric item IDs
The addon SHALL identify an item by its numeric WoW itemID and SHALL NOT derive identity from localized item names, tooltip text or the player's currently learned professions.

#### Scenario: Known numeric item
- **WHEN** a valid itemID with verified profession relations is supplied
- **THEN** the lookup returns exactly the related stable profession keys

#### Scenario: Item name changes by locale
- **WHEN** the same itemID is presented in enUS and esES
- **THEN** the returned profession keys are identical

#### Scenario: Character has not learned professions
- **WHEN** the character knows no profession and a known material is inspected
- **THEN** the lookup returns the same professions as for a character with trained professions

### Requirement: Return complete verified many-to-many relations for each known item
For a known itemID, lookup SHALL return all *verified* consuming professions represented in the local catalog, deduplicated and ordered deterministically. One profession SHALL appear no more than once, regardless of how many recipes consume the item.

#### Scenario: Material has two verified consuming professions
- **WHEN** an itemID is recorded as consumed by two professions
- **THEN** the result contains both distinct professions once each in the documented order

#### Scenario: Several recipes use the same item within one profession
- **WHEN** source data links a material to multiple recipes of the same profession
- **THEN** the profession appears once

### Requirement: Unknown or invalid IDs are safe
The lookup SHALL return an empty result for an unknown, nil, nonnumeric, invalid or not-yet-resolved itemID and SHALL NOT invent a profession association.

#### Scenario: Item is absent from local catalog
- **WHEN** the player inspects an unrecognized itemID
- **THEN** the lookup returns no professions and the UI adds no CraftAtlas profession claim

#### Scenario: Item identity is temporarily unavailable
- **WHEN** the client has not supplied a usable numeric itemID
- **THEN** CraftAtlas does not throw a Lua error, infer from text or display guessed relations

### Requirement: Lookup has no client-side dependencies
The domain lookup SHALL function against bundled Lua data without requiring WoW UI objects, remote APIs or a player's state.

#### Scenario: Pure lookup executed offline
- **WHEN** offline tests invoke the domain module with catalog fixtures
- **THEN** results are deterministic without a running game client
