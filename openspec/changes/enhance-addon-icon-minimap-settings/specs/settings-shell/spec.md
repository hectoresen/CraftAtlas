# Settings shell

## ADDED Requirements

### Requirement: Expanded header

The settings window SHALL be larger than the current window and SHALL present a header with a centered `CraftAtlas` title.

#### Scenario: Settings opened from either entry point

- **WHEN** the player opens settings through `/craftatlas` or the minimap button
- **THEN** the same expanded settings shell is shown
- **AND** `CraftAtlas` is centered in the header

### Requirement: Header language selector

The settings header SHALL place the existing language selector on the right side and SHALL continue to offer Auto, English and Español.

#### Scenario: Language changed from header

- **WHEN** the player selects a different language in the header selector
- **THEN** the language applies immediately to subsequent CraftAtlas UI and tooltip text
- **AND** the preference persists using the existing preferences behavior
- **AND** no duplicate language selector remains in the General content area

### Requirement: Non-functional search affordance

The settings header SHALL show a non-interactive search affordance on the left with the exact placeholder `Buscar objetos, profesiones..`.

#### Scenario: Search affordance is inspected

- **WHEN** the player views or hovers the header search affordance
- **THEN** no search is executed and no object/profession filtering occurs
- **AND** the pointer indicates that the control is unavailable
- **AND** the affordance does not accept text input

### Requirement: Empty General section

The General section SHALL remain available but SHALL not contain the language selector after this change.

#### Scenario: General section is opened

- **WHEN** the player selects General
- **THEN** the content area is otherwise empty except for a centered localized “Coming soon” message
