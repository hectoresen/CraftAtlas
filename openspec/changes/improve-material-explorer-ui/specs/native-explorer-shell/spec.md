# Native material explorer shell

## ADDED Requirements

### Requirement: WoW-native, moderately enlarged layout
CraftAtlas SHALL evolve the existing native settings frame into a slightly larger material explorer while retaining the BasicFrameTemplateWithInset appearance (where available), the single centered CraftAtlas header title, the search control on the header's left, and the Auto/esES/enUS language selector on the right. It SHALL avoid new imitation/custom web-style skins and preserve window visibility at supported UI scales.

#### Scenario: Open from slash command or minimap
- **WHEN** the player uses /craftatlas or the minimap button
- **THEN** the same reusable native frame opens
- **AND** the header contains a usable search input, one centered title and the existing language selector
- **AND** the existing minimap drag position is unaffected

#### Scenario: Readable dimensions
- **WHEN** the explorer opens at a supported display resolution and UI scale
- **THEN** its content is within the visible screen bounds
- **AND** the search input, profession dropdown, list and detail do not overlap or clip

### Requirement: Two-pane material explorer
The content region SHALL allocate approximately 38% of usable width to results and 62% to the selected material's detail, with sufficient padding, scroll behavior and native controls.

#### Scenario: Long lists and labels
- **WHEN** there are more result rows or longer localized labels than can fit
- **THEN** scrolling or truncation/tooltip behavior preserves navigability without overlapping adjacent controls

### Requirement: Localized preferences remain usable
The player SHALL retain account-wide Auto/esES/enUS preferences, immediate UI/tooltip label refresh and the existing /craftatlas and minimap entry points; new explorer labels SHALL be localized in both existing locales.

#### Scenario: Language changed
- **WHEN** the player changes language in the header
- **THEN** explorer and tooltip labels update consistently
- **AND** the preference persists after reload
- **AND** the client-provided item names are not falsely translated by CraftAtlas
