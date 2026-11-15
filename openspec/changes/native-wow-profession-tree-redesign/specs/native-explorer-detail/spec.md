# Native material and craftable detail redesign

## ADDED Requirements

### Requirement: Present reference-inspired but factual material detail
The material detail SHALL present a recognizable item icon/name and itemID, the actual consuming professions, and a visually separate **Se utiliza para fabricar / Used to craft** section with navigable rows of genuine source-backed crafting uses.

#### Scenario: Material with several source-backed crafting uses
- **WHEN** the selected reagent has multiple recipe uses
- **THEN** each visible recipe row shows a client-resolved crafted-result/spell fallback, profession and exact selected-material quantity
- **AND** the user can page or scroll through all uses, hover for client-native tooltip and click into Fabricables

#### Scenario: Client item metadata available
- **WHEN** the client supplies a trusted item type, level or quality for the selected item
- **THEN** optional item metadata is displayed according to that client information only

#### Scenario: Metadata or names unavailable
- **WHEN** the client does not resolve an item/spell name, type, item level or quality
- **THEN** the UI uses a safe numeric-ID or unavailable-data fallback
- **AND** does not fabricate a green quality title, an herb type, an item level or an output item

### Requirement: Preserve source-backed craftable inspection
The Fabricables view SHALL retain searchable/filterable recipe browsing with unique profession+spellID identity and present all known ingredients/quantities in a consistent native visual style.

#### Scenario: Craftable with many ingredients
- **WHEN** a selected craftable has more ingredients than fit in its detail panel
- **THEN** every recorded ingredient remains accessible by scrolling or pagination
- **AND** clicking an ingredient opens Materiales for that numeric itemID

#### Scenario: Non-item profession action
- **WHEN** a source-backed recipe represents an enchantment or unknown output rather than a physical crafted item
- **THEN** the detail shows an honest non-item/unresolved label
- **AND** a fake physical item, rarity, learned-recipe or craftability state is not created

### Requirement: Preserve current navigation and controls
The redesigned native shell SHALL preserve functional search, clear, profession filter, language choice, Materiales/Fabricables tabs, Back history, mouse-wheel scrolling, slash/minimap opening and close/reopen behavior across supported Forever UI scales.

#### Scenario: Default and compact UI
- **WHEN** the player opens the explorer at normal or reduced viewport size
- **THEN** both panes, controls, selected detail and any pager remain usable without overlapping text, invisible close targets or clipped essential controls
- **AND** unsupported optional native WoW templates degrade to safe Classic-compatible styling without client Lua errors
