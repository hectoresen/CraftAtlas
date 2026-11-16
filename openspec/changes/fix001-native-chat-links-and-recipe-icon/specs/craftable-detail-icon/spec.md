# Craftable detail icon consistency

## ADDED Requirements

### Requirement: Craftable detail icon has one coherent frame

The selected Fabricables result's large detail icon SHALL use a consistent, native-looking icon frame without an unintended smaller inset rectangle caused by overlay composition. The correction SHALL preserve the displayed output/spell icon, mouse hover tooltip and the view's responsive bounds.

#### Scenario: Item output

- **GIVEN** the selected recipe produces an item
- **WHEN** its detail icon is rendered
- **THEN** the output icon appears with a clean single frame, without an extra inset square
- **AND** the native output tooltip remains accessible

#### Scenario: Non-item action

- **GIVEN** the selected recipe does not produce an item
- **WHEN** its detail icon is rendered
- **THEN** the spell icon uses the same clean frame treatment

#### Scenario: Compact UI layout

- **WHEN** the explorer is shown at a compact supported UI scale
- **THEN** the detail icon and its hover/link hit target stay aligned within the view
- **AND** the Materiales detail icon and unrelated controls are not visually regressed
