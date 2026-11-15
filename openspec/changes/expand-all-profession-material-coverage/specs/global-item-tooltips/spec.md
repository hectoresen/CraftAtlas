## ADDED Requirements

### Requirement: Annotate all safely supported item tooltip origins
CraftAtlas SHALL use a centralized, client-verified item tooltip integration to annotate any safely supported tooltip surface that exposes a numeric itemID, including inventory, equipment, personal/guild banks, merchant, auction, chat item links, crafting, mail and quest reward item previews. Unsupported origins SHALL be documented explicitly, never assumed.

#### Scenario: Item link in chat
- **WHEN** the player hovers a linked known material in chat and the client exposes a supported structured item tooltip
- **THEN** the same complete profession list is displayed as in the inventory tooltip

#### Scenario: Item in the bank
- **WHEN** the player hovers a supported bank item and the itemID has verified consuming professions
- **THEN** the tooltip lists the same profession set as other supported origins

#### Scenario: Origin uses protected or unsupported API
- **WHEN** a tooltip origin cannot be safely annotated with supported APIs
- **THEN** no protected game behavior is modified and the origin is identified as unsupported

### Requirement: Avoid duplicate or stale annotations
Tooltip insertion SHALL be idempotent and resilient to rerender, tooltip reuse, different itemIDs, callback repetition and locale changes; it SHALL not leave stale profession lines on another item.

#### Scenario: Rapid item changes
- **WHEN** the player rapidly hovers two different items in the same reused tooltip
- **THEN** each tooltip instance shows only information for its own current itemID

#### Scenario: Repeated callback
- **WHEN** an item tooltip refreshes multiple times
- **THEN** a profession annotation is added at most once per rendered item state

### Requirement: Keep hover performance bounded and offline
The callback SHALL use direct itemID lookup and bounded formatting with no remote calls, expensive scans of all recipes or polling.

#### Scenario: Large catalog and rapid hover
- **WHEN** a verified large catalog is loaded and the player rapidly hovers items
- **THEN** no per-hover full-catalog scan occurs and documented performance tests meet their measured limits
