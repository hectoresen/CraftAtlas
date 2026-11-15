# Shared native explorer UI

## ADDED Requirements

### Requirement: Provide reusable native explorer components
CraftAtlas SHALL use one native window shell and reusable search, profession selector, result-list, detail-content, pagination and item/recipe card components for Materials and Recipes. Shared controls SHALL accept view-specific data/callbacks without embedding material-only or recipe-only business logic.

#### Scenario: Switch from Materials to Recipes
- **WHEN** a player chooses Recipes in the shared navigation
- **THEN** the Recipes view uses the same CraftAtlas shell and visual controls
- **AND** the Materials screen is hidden, not recreated as a second window

#### Scenario: Independent view states
- **WHEN** the user applies a Materials search/filter, visits Recipes and returns
- **THEN** the Materials query, profession filter and valid selection/page remain
- **AND** the Recipes state is retained independently

#### Scenario: Shared control evolution
- **WHEN** a third future explorer view is introduced
- **THEN** it can instantiate the shared search/list/pager controls with its own adapter
- **AND** no clone of Settings.lua or RecipePanel.lua is required

### Requirement: Preserve existing Materials behavior
The Materials view SHALL retain source-backed reagent search, profession filtering, selected detail, six-per-page consuming-recipe grid, WoW tooltips, language settings, minimap/slash entry points and working X.

#### Scenario: Default open
- **WHEN** a player uses /craftatlas without an explicit target
- **THEN** the native explorer opens with Materials as its default view
- **AND** there is one functioning close button and no duplicate frames

#### Scenario: Existing material paging
- **WHEN** a material has 14 source-backed consuming recipes
- **THEN** the existing cards remain pageable as 6, 6 and 2
- **AND** existing tooltip and button semantics remain intact
