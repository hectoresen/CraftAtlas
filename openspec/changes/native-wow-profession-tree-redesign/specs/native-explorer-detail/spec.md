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

### Requirement: Replace textual clear control with native broom icon
The search-clear control SHALL use a WoW-native, recognizable **broom icon** matching the provided visual reference rather than the current textual `X`. The icon SHALL preserve the already functional search-clear behavior and be distinct from the window-close button.

#### Scenario: Clearing populated material or craftable search
- **WHEN** the user types a query in either Materiales or Fabricables and clicks the broom
- **THEN** only that view's active search query is cleared and its matching results are refreshed
- **AND** the other view's stored search, profession filter and Back history remain intact

#### Scenario: Empty search and tooltip
- **WHEN** the active query is empty
- **THEN** the broom control is visually disabled or harmlessly inert
- **AND** hovering over it provides an enUS/esES localized clear-search tooltip where the Forever client supports tooltips

#### Scenario: Native broom asset unavailable
- **WHEN** the target client does not expose the proposed broom icon path/template
- **THEN** a safe native clear/action icon is used instead of missing artwork or Lua errors
- **AND** the control still clears the search without showing a textual `X`

### Requirement: Display only an installed official release version
The explorer SHALL never show the development-only `-dev` version caption. For an official packaged addon it SHALL display only the installed, locally stamped numeric release version; the source checkout SHALL not claim to be a published release.

#### Scenario: Official v0.1.0 package installed
- **WHEN** the installed addon manifest contains `## Version: 0.1.0` from the official release packager
- **THEN** any version indicator reads `v0.1.0` with no `-dev` suffix

#### Scenario: Newer or older official release package
- **WHEN** the installed addon manifest contains another valid release SemVer
- **THEN** the UI displays that installed version rather than a hardcoded or remotely assumed latest tag

#### Scenario: Development or unverifiable build
- **WHEN** the local manifest version contains `-dev` or metadata cannot safely be read
- **THEN** the version footer is hidden or contains no numeric release claim
- **AND** the addon performs no network request to resolve GitHub Releases

### Requirement: Preserve current navigation and controls
The redesigned native shell SHALL preserve functional search, clear, profession filter, language choice, Materiales/Fabricables tabs, Back history, mouse-wheel scrolling, slash/minimap opening and close/reopen behavior across supported Forever UI scales.

#### Scenario: Default and compact UI
- **WHEN** the player opens the explorer at normal or reduced viewport size
- **THEN** both panes, controls, selected detail and any pager remain usable without overlapping text, invisible close targets or clipped essential controls
- **AND** unsupported optional native WoW templates degrade to safe Classic-compatible styling without client Lua errors
