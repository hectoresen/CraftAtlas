# Material tooltip presentation

## ADDED Requirements

### Requirement: Apply material tooltip visibility

CraftAtlas SHALL apply the annotation visibility preference when a supported item tooltip opens or rebuilds. When enabled, CraftAtlas SHALL append a separator, a localized gold heading and the catalog-backed profession list. When disabled, it SHALL omit the entire annotation and preserve the native tooltip content.

#### Scenario: Hide the annotation

- **WHEN** the player disables the consuming-profession section and opens or rebuilds a supported material tooltip
- **THEN** CraftAtlas adds no separator, heading or list and the native tooltip content remains intact

#### Scenario: Unknown item

- **WHEN** the player opens an item tooltip for an item outside the CraftAtlas material catalog
- **THEN** the tooltip receives no CraftAtlas annotation in either layout

### Requirement: Apply material tooltip layout preferences

When the annotation is rendered, CraftAtlas SHALL apply icon visibility and the layout independently. The default layout SHALL have one white row per profession. The single-line layout SHALL append the ordered professions to one white native line with a comma and space between entries. With icons enabled, each available native 14 × 14 icon SHALL precede its profession name. The client controls visual wrapping.

#### Scenario: Default layout for a single consuming profession

- **WHEN** the player opens a supported tooltip for Copper Ore (`2770`) in enUS with default preferences
- **THEN** the native item lines are followed by the separator, gold heading and a white Mining row with its available native icon

#### Scenario: Default layout for multiple consuming professions

- **WHEN** the player opens a supported tooltip for Linen Cloth (`2589`) in esES with default preferences
- **THEN** the gold `Utilizado en:` heading is followed by four separate white profession rows with their available icons

#### Scenario: Hide icons in the expanded layout

- **WHEN** the player selects Hide profession icons and opens or rebuilds a supported multi-profession material tooltip with single-line mode off
- **THEN** each profession still has its own white row and the rows contain only the localized profession names

#### Scenario: Use the single-line layout with icons

- **WHEN** the player enables single-line mode while profession icons are enabled and opens or rebuilds a supported multi-profession material tooltip
- **THEN** the heading is followed by one line of comma-separated professions with their available icons

#### Scenario: Combine single-line layout and hidden icons

- **WHEN** the player enables single-line mode and hides icons, then opens or rebuilds the Linen Cloth tooltip in esES
- **THEN** the heading is followed by one white tooltip line containing `Costura, Herrería, Ingeniería, Primeros auxilios`

#### Scenario: Missing icon

- **WHEN** a profession's icon is unavailable with icons enabled
- **THEN** the profession name remains readable in the selected layout without a placeholder
