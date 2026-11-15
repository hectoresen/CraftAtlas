# Cross-explorer navigation

## ADDED Requirements

### Requirement: Navigate between Materials and Recipes
CraftAtlas SHALL let players open a consuming recipe from a material's recipe cards, and open the corresponding material from a selected recipe's ingredient rows. The navigation SHALL preserve the prior view's search, profession filter, selection and valid page for return.

#### Scenario: Open recipe from a material
- **WHEN** a player clicks a source-backed recipe card in MaterialDetail
- **THEN** the Recipes view opens that exact profession/spellID identity
- **AND** a Back action can restore the previous MaterialDetail and recipe page

#### Scenario: Open material from a recipe
- **WHEN** a player clicks a verified ingredient of RecipeDetail
- **THEN** Materials opens the selected ingredient itemID
- **AND** returning restores the recipe, its filters and selection

#### Scenario: Repeated navigation and missing target
- **WHEN** the user navigates repeatedly or encounters a now-unavailable target
- **THEN** the client limits history growth and shows a safe empty/fallback state
- **AND** there is no infinite navigation loop or stale tooltip

### Requirement: Maintain view-scoped behavior
Direct navigation SHALL NOT silently overwrite a view's existing search/filter preferences. The explorer SHALL keep one shared window and shall clear native tooltip ownership on any view transition.

#### Scenario: Filter excludes cross-link target
- **WHEN** the target item or recipe is excluded by that view's current filter
- **THEN** the target detail still opens via a deliberate direct-navigation state
- **AND** the previous query/filter can be restored without being silently deleted
