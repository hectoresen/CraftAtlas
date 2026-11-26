## ADDED Requirements

### Requirement: Show the minimum profession skill for the selected recipe

CraftAtlas SHALL show the source-backed minimum below the profession. It SHALL use localized text and dark gray when verified skill meets or exceeds it, dark red when verified skill falls short or the profession is confirmed unlearned, and neutral when the minimum or skill is unknown. A known minimum SHALL remain visible.

#### Scenario: Meet the minimum exactly

- **WHEN** the selected recipe requires 15 skill and the character's verified skill in the corresponding profession is 15
- **THEN** the minimum is visible below the profession and the field shows the met state in dark gray

#### Scenario: Observe a skill deficit

- **WHEN** the character's verified profession skill is below the selected recipe's minimum, or the character is confirmed to lack that profession
- **THEN** the field shows the unmet state in dark red

#### Scenario: Exceed the minimum

- **WHEN** the character's verified profession skill is higher than the selected recipe's known minimum
- **THEN** the field shows the met state in dark gray

#### Scenario: Display missing skill information

- **WHEN** the selected recipe has no source-backed minimum or the relevant character skill cannot be verified
- **THEN** the field is neutral and the unavailable value is identified as unknown
- **AND** a known minimum remains visible when only the character skill is unavailable

### Requirement: Show recipe acquisition and learned status independently of skill

CraftAtlas SHALL show recipe information on the right. Localized text SHALL identify a verified teaching item or item-free source, or mark acquisition unknown. It SHALL show the current character's state for the selected recipe in dark gray if learned, dark red if unlearned, or neutral if unknown. It SHALL label that state independently of the profession skill.

#### Scenario: Meet the skill requirement but still need to learn the recipe

- **WHEN** the character meets the minimum profession skill and the client confirms the selected recipe is unlearned
- **THEN** the skill field is dark gray and the recipe field is dark red

#### Scenario: Know the recipe while the minimum is unmet

- **WHEN** the client confirms the recipe is learned and the character has a verified profession rank below the source-backed minimum
- **THEN** the recipe field is dark gray and the skill field is dark red

#### Scenario: Show a teaching-item association and learned status

- **WHEN** the catalog associates the recipe with a teaching item and the client confirms the character has already learned it
- **THEN** the right-hand field indicates the teaching-item association and the learned state in dark gray
- **AND** the field does not imply that the character needs to acquire the item again

#### Scenario: Show a confirmed item-free learning path

- **WHEN** trustworthy Forever evidence confirms a way to learn the selected recipe without an item
- **THEN** the field identifies that learning path and uses the color corresponding to the independently verified learned status

#### Scenario: Handle missing teaching-item data

- **WHEN** the selected recipe has no verified acquisition information and the client confirms the character has not learned it
- **THEN** the recipe field shows the unlearned state in dark red and identifies the acquisition method as unknown

#### Scenario: Handle missing character recipe data

- **WHEN** the character's learned status is unavailable or belongs to another character or recipe
- **THEN** the learned status is shown as unknown in a neutral color and any verified acquisition information remains visible

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

### Requirement: Place the tracking control beneath recipe information

CraftAtlas SHALL position the existing Track crafting checkbox and label below the recipe field on the right, above the ingredients section. The header SHALL keep the minimum skill, recipe field, existing recipe metadata, and tracking control readable with usable pointer targets in enUS and esES at supported standard and compact scales. The checkbox SHALL continue to use the existing per-character ingredient tracking preference with the selected recipe's ingredient quantities.

#### Scenario: Read the header and use tracking at different scales

- **WHEN** the player shows a selected recipe in enUS or esES at a standard or compact scale
- **THEN** the skill is below the profession, the recipe field is above the checkbox on the right, and neither section obscures existing metadata or ingredient controls
- **AND** clicking the checkbox remains possible in each of the recipe and skill states

#### Scenario: Follow the existing ingredient tracking workflow

- **WHEN** the player toggles Track crafting and navigates to a different recipe
- **THEN** the checkbox uses the existing per-character preference and material progress uses the active recipe's ingredients
