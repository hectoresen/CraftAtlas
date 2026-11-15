# Native recipe detail and tooltips

## ADDED Requirements

### Requirement: Show a readable recipe-use list
The current native CraftAtlas material detail SHALL show a scrollable compact list of verified recipe uses, grouped by profession, with recipe name, available icon, quantity, output name/icon and explicit unavailable states. The existing material-search shell and language selector SHALL remain usable.

#### Scenario: Select material
- **WHEN** a player clicks a material row
- **THEN** the right pane displays its known consuming professions and grouped recipe uses
- **AND** the left search, profession filter and scroll state are not cleared

#### Scenario: Many recipes
- **WHEN** a material is consumed by more recipes than fit in the detail area
- **THEN** the recipe list scrolls without clipping the native window or overlapping its controls

### Requirement: Native item tooltip for recipe outputs
The UI SHALL use the Forever client's supported native item tooltip interface when hovering an output item that has a verified itemID or valid item link. It SHALL NOT fabricate item rarity, stats, effects or tooltip appearance.

#### Scenario: Hover output item
- **WHEN** a player hovers an output item with an available native item hyperlink or supported itemID
- **THEN** the standard game tooltip displays the information available from the client, including quality and stats when supplied
- **AND** the tooltip is cleared on leave or selection change

#### Scenario: Output information is uncached or unknown
- **WHEN** the item's native data is unavailable
- **THEN** the addon shows a safe localized loading/unavailable state
- **AND** does not invent item quality or tooltip information

### Requirement: Recipe tooltip without unsupported hooks
The UI SHALL attempt to use a client-verified native recipe or spell tooltip only where its API is safe and available. Otherwise it SHALL provide a factual fallback using known recipe ID/name/profession, without altering protected frames.

#### Scenario: Hover recipe
- **WHEN** a recipe row is hovered and the Forever client exposes a supported native recipe/spell tooltip API
- **THEN** the game-native recipe/spell tooltip is shown

#### Scenario: Native recipe hover unsupported
- **WHEN** no supported native recipe tooltip API is available
- **THEN** a factual localized fallback is available
- **AND** no protected frame is patched, and no unsupported tooltip content is invented

### Requirement: Localization and client safety
The feature SHALL preserve enUS/esES fallback and existing material and minimap behavior and SHALL avoid external network calls, per-frame scans or mandatory third-party addon dependencies.

#### Scenario: Switch language
- **WHEN** the user changes CraftAtlas language
- **THEN** UI labels and profession names update immediately
- **AND** client item names and tooltips remain those supplied by WoW
