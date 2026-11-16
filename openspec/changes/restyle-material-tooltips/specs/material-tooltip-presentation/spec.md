# Expanded material tooltip presentation

## ADDED Requirements

### Requirement: Present consuming professions in the default expanded layout

CraftAtlas SHALL append one blank separator line, a localized heading in the native normal gold font color, and one white row per catalog-backed consuming profession to a supported material tooltip. Each row SHALL place its available native 14 × 14 profession icon immediately before its name. An unavailable or unmapped icon SHALL leave a readable text-only row.

#### Scenario: Known material with one consuming profession

- **WHEN** the player opens a supported item tooltip for Copper Ore (`2770`) in enUS
- **THEN** the native item lines are preserved and the annotation contains a blank separator, the gold `Used in:` heading and a white `Mining` row with its native profession icon

#### Scenario: Known material with multiple consuming professions

- **WHEN** the player opens a supported item tooltip for Linen Cloth (`2589`) in esES
- **THEN** the gold `Utilizado en:` heading is followed by four separate white rows
- **AND** each row has its available native icon, with no comma-separated list

#### Scenario: Profession artwork is unavailable

- **WHEN** a consuming profession has no usable client icon
- **THEN** its localized name still appears as its own white row, with no placeholder icon or broken texture markup

### Requirement: Localize the heading and profession order

CraftAtlas SHALL use `Used in:` in enUS and `Utilizado en:` in esES for the tooltip heading. Profession names SHALL use the existing localized labels and follow alphabetical order in the effective addon language, with a deterministic tie-breaker.

#### Scenario: Sort the same professions in both languages

- **WHEN** the player inspects Linen Cloth (`2589`) in enUS and then in esES
- **THEN** the rows appear as Blacksmithing, Engineering, First Aid and Tailoring in enUS
- **AND** the rows appear as Costura, Herrería, Ingeniería and Primeros auxilios in esES

#### Scenario: Language is changed

- **WHEN** the effective CraftAtlas language changes and the player reopens or rebuilds the tooltip
- **THEN** the heading and profession labels use the new language and are ordered for it
- **AND** an unsupported client locale in automatic mode follows the existing enUS fallback

### Requirement: Preserve catalog membership and native tooltip behavior

The material tooltip presenter SHALL use the current CraftAtlas itemID lookup and SHALL append at most one section per rendered tooltip state. It SHALL leave other native tooltip content intact and fail safely when item data or supported tooltip methods are unavailable. Rendering SHALL remain offline and bounded to the current item's consuming professions.

#### Scenario: The reference and CraftAtlas have different catalog entries

- **WHEN** the player opens a supported item tooltip for Silverleaf (`765`)
- **THEN** CraftAtlas renders its Alchemy row using the new presentation and adds no other profession from the reference catalog

#### Scenario: Item or tooltip cannot be annotated

- **WHEN** the item is absent from the catalog, the itemID is missing or invalid, or the tooltip cannot safely accept lines
- **THEN** CraftAtlas adds no section, including no blank separator, and raises no Lua error

#### Scenario: A supported tooltip is processed repeatedly and reused

- **WHEN** the callback repeats for the same rendered tooltip, or the tooltip is then cleared and rebuilt for the same or a different item
- **THEN** each rendered state contains at most one complete section with the current item's localized professions and no stale rows
- **AND** the existing native callback path serves supported item tooltip origins without introducing separate hooks per origin
