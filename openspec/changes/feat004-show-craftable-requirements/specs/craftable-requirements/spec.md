## ADDED Requirements

### Requirement: Show the minimum profession skill for the selected recipe

CraftAtlas SHALL show the source-backed minimum below the profession as `Crafting level <level>` in enUS and `Nivel de fabricación <level>` in esES. The text SHALL stay the same whether the color is dark gray for a met minimum, dark red for an unmet minimum, or neutral for unverified character skill. If the minimum is unknown, a neutral localized placeholder SHALL appear.

#### Scenario: Meet the minimum exactly

- **WHEN** the selected recipe requires 15 skill and the character's verified skill in the corresponding profession is 15
- **THEN** the minimum is visible below the profession and the field shows the met state in dark gray

#### Scenario: Observe a skill deficit

- **WHEN** the character's verified profession skill is below the selected recipe's minimum, or the character is confirmed to lack that profession
- **THEN** the field displays the localized level and numeric minimum in dark red

#### Scenario: Exceed the minimum

- **WHEN** the character's verified profession skill is higher than the selected recipe's known minimum
- **THEN** the field shows the met state in dark gray

#### Scenario: Display missing skill information

- **WHEN** the selected recipe has no source-backed minimum or the relevant character skill cannot be verified
- **THEN** the field shows the same known minimum in a neutral color if only the character's skill is unverified
- **AND** the field shows a neutral placeholder when the catalog minimum is unknown

### Requirement: Show a single recipe-item requirement independently of skill

CraftAtlas SHALL show only the localized Recipe required label (Se necesita receta in esES) on the right when the catalog identifies a teaching item and the client has not verified an item-free path. For the selected recipe and current character, the label SHALL be dark gray if learned, dark red if unlearned, and neutral if unknown. This color SHALL be independent of the profession skill.

#### Scenario: Meet the skill requirement but still need to learn the recipe

- **WHEN** the character meets the minimum skill and the game confirms an unlearned recipe with a catalog teaching item and no verified item-free path
- **THEN** the skill field is dark gray and the recipe-required label is dark red

#### Scenario: Know the recipe while the minimum is unmet

- **WHEN** the game confirms that a character learned a recipe with a catalog teaching item and no verified item-free path, and the character's verified skill is below the minimum
- **THEN** the recipe-required label is dark gray and the skill field is dark red

#### Scenario: Omit the label for an item-free path or missing teaching-item data

- **WHEN** the client verifies an item-free way to learn the recipe or the catalog lacks a teaching-item ID
- **THEN** the recipe-required label is hidden

#### Scenario: Handle missing character recipe data

- **WHEN** a recipe qualifies for the label and the character's learned state is unavailable or belongs to another character or recipe
- **THEN** the same recipe-required label is neutral

### Requirement: Refresh verified requirements for the active detail

CraftAtlas SHALL evaluate the requirements for the selected recipe when displaying its detail and refresh them when relevant verified player data becomes available or changes. It SHALL clear these fields when no recipe is selected. It SHALL render source-backed information even when the game's profession data is unavailable.

#### Scenario: Browse without opening the profession window

- **WHEN** the player selects a recipe in Craftables without opening the game's profession window
- **THEN** the source-backed facts are available in the detail
- **AND** character states are shown only when the client can verify them for the current character

#### Scenario: Learn a recipe or increase profession skill

- **WHEN** the game reports that the character learned the selected recipe or reached its minimum profession skill
- **THEN** CraftAtlas refreshes the corresponding field to dark gray when the verified state is available

#### Scenario: Switch recipes or clear the selection

- **WHEN** the selection changes to another recipe or is cleared
- **THEN** facts and states from the previous selection are absent from the new detail

### Requirement: Match the Materials detail layout

Craftables SHALL match the Materials detail icon, title, subtitle, lower metadata row, and first section divider positions and use the same native heading and metadata styles. The level SHALL have a full-width row below the profession. If present, the recipe-required label SHALL sit to the right of the profession.

#### Scenario: Compare both detail tabs at standard and compact widths

- **WHEN** the player selects a material and then a craftable at a supported standard or compact width
- **THEN** the shared rows and first divider align and the crafting-level text is fully visible

### Requirement: Align tracking with the recipe ID

CraftAtlas SHALL show only `ID <spellID>` in the lower left of the selected recipe header. It SHALL align the existing Track crafting checkbox and label with the vertical center of the ID row on the right. Both controls SHALL remain readable and usable in enUS and esES at supported scales. The checkbox SHALL use the existing per-character ingredient tracking preference with the selected recipe's quantities.

#### Scenario: Read the header and use tracking at different scales

- **WHEN** the player shows a selected recipe in enUS or esES at a standard or compact scale
- **THEN** the skill is below the profession and the lower left shows only the ID, such as `ID 12088`, without a repeated name
- **AND** the checkbox is on the same row on the right, remains below the recipe-required label when present, and is usable in each requirement state

#### Scenario: Follow the existing ingredient tracking workflow

- **WHEN** the player toggles Track crafting and navigates to a different recipe
- **THEN** the checkbox uses the existing per-character preference and material progress uses the active recipe's ingredients
