# forever-screenshot-documentation Specification

## Purpose

Make the contributed CraftAtlas interface captures easy to find and view in the repository documentation.

## Requirements

### Requirement: Version the six contributed CraftAtlas captures

The repository SHALL store the six contributed screenshots as PNG files under `docs/v0.5.0/`. The files SHALL retain the contributor's filenames and bytes. The screenshot directory SHALL be outside the installable CraftAtlas package.

#### Scenario: Find the contributor's original captures

- **WHEN** a reader browses the documentation folder
- **THEN** the folder contains `materials_menu.png`, `craftables_menu.png`, `craftables_tracking.png`, `options_menu.png`, `icon_minimap_tooltip.png`, and `item_tooltip.png`
- **AND** each file matches the corresponding contributor-supplied PNG

#### Scenario: Build the addon package

- **WHEN** the installable addon is built with the repository packager
- **THEN** the package excludes the documentation screenshots

### Requirement: Present a discoverable screenshot gallery

The root README SHALL link to a gallery under `docs/v0.5.0/`. The gallery SHALL display each of the six local images with descriptive alt text and identify the captures as visual examples from the contributor. Gallery links SHALL resolve to the repository copies.

#### Scenario: Follow the gallery from the README

- **WHEN** a reader follows the gallery link from the root README
- **THEN** the gallery displays all six action or interface examples using relative image paths
- **AND** the visual examples are distinct from the published release and Forever acceptance records
