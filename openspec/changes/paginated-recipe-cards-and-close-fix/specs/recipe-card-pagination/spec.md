# Recipe card pagination

## ADDED Requirements

### Requirement: Display recipe uses as native cards
The material detail SHALL display recipe uses as a compact grid of six native WoW-style cards per page. Each card SHALL represent one unique recipe and show exactly one primary icon, a readable recipe/result name, consuming profession and verified material quantity.

#### Scenario: Item output available
- **WHEN** a recipe produces a source-identified output item and WoW supplies its icon/name
- **THEN** the card displays the output item icon/name as primary content
- **AND** does not duplicate the recipe icon/name below it

#### Scenario: No item output
- **WHEN** the recipe is an enchantment, a non-item action or has unknown output
- **THEN** the card displays the known recipe/spell icon/name or a safe native placeholder
- **AND** does not fabricate an output item or quality

#### Scenario: Small window
- **WHEN** the frame uses a smaller supported UI scale
- **THEN** six cards and the pagination footer fit without overlapping the material header, other cards or window border

### Requirement: Deterministic pagination
The detail SHALL paginate actual recipe-use records (not profession heading rows), show the total recipe count and current/total pages, and offer enabled/disabled Previous and Next buttons.

#### Scenario: Fourteen recipes
- **WHEN** a selected material has 14 distinct source-backed recipes
- **THEN** the first page shows six recipes, the second six and the third two
- **AND** the footer reads page 1 of 3 initially
- **AND** the total remains 14

#### Scenario: Navigation boundaries
- **WHEN** a player is on the first or last page
- **THEN** Previous or Next respectively is disabled
- **AND** navigation cannot exceed valid pages or repeat entries

#### Scenario: Material changes
- **WHEN** the player selects another material
- **THEN** the recipe grid resets to the first page
- **AND** existing material search and profession filters remain unchanged

#### Scenario: Async item information changes
- **WHEN** the client supplies an item name/icon after a page has been selected
- **THEN** the visible cards update without resetting the current valid page

#### Scenario: Zero recipes
- **WHEN** no verified recipe uses are available
- **THEN** an informative localized empty state appears without fake cards or misleading page counts

### Requirement: Preserve native tooltips
Each card SHALL use the supported native WoW tooltip for its output item, falling back to the supported recipe tooltip when no item output is known; it SHALL never manufacture rarity or statistics.

#### Scenario: Hover output card
- **WHEN** the pointer enters a card with a verified output itemID
- **THEN** CraftAtlas attempts the supported game item tooltip with quality/statistics from the client

#### Scenario: Tooltip lifecycle
- **WHEN** the pointer leaves a card, pages change, a different material is selected or the panel closes
- **THEN** the old tooltip is hidden without leaving stale data
