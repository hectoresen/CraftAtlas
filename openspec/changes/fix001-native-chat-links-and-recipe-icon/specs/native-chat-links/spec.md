# Native chat links for CraftAtlas entities

## ADDED Requirements

### Requirement: Shift-click links clickable item entities

CraftAtlas SHALL support Shift + left-click on clickable item entities in its material and craftable explorer views to insert the **native, valid item hyperlink** into the WoW chat editor, using available client APIs and the item's actual identity. It SHALL NOT fabricate hyperlinks or send a chat message.

#### Scenario: Material row

- **GIVEN** a clickable Materiales row represents a known reagent item
- **WHEN** the player Shift + left-clicks that row
- **THEN** CraftAtlas attempts to insert that material's valid native item link into chat
- **AND** does not open its detail as a side effect

#### Scenario: Ingredient row

- **GIVEN** a Fabricables ingredient row is bound to an itemID
- **WHEN** the player Shift + left-clicks that row
- **THEN** the native ingredient item link is inserted when supported
- **AND** the player is not navigated to Materiales

#### Scenario: Craftable output

- **GIVEN** a Fabricables row or interactive recipe identity presents a recipe with outputItemID
- **WHEN** the player Shift + left-clicks it
- **THEN** CraftAtlas inserts the output item's native link, not a fabricated spell link
- **AND** the currently displayed recipe remains selected

### Requirement: Non-item recipes use native spell links when supported

For clickable recipes without an output item, CraftAtlas SHALL attempt a native spell hyperlink only if the client can provide and insert a valid supported spell link.

#### Scenario: Non-item action

- **GIVEN** a clickable recipe represents a non-item profession action with spellID
- **WHEN** the player Shift + left-clicks it
- **THEN** a valid spell link is inserted if supported by Forever
- **AND** no invented item link is inserted

#### Scenario: Recipe use on a material

- **GIVEN** a clickable recipe-use row in the material detail maps to a real output item or non-item action
- **WHEN** the player Shift + left-clicks it
- **THEN** CraftAtlas uses the actual output item link when available, otherwise a valid native spell link for non-item actions
- **AND** normal recipe navigation does not run

### Requirement: Native clicks and unsupported cases are safe

Shift + left-click handling SHALL apply to all clickable item/recipe entities of CraftAtlas consistently, including interactive entity identity/icon surfaces. An ordinary click SHALL retain the existing navigation behavior. Non-entity controls SHALL remain unchanged. Missing client APIs, uncached link data or unavailable chat insertion SHALL fail safely without made-up link text, navigation or automatic sending.

#### Scenario: Normal click is unchanged

- **WHEN** the player clicks a clickable material, recipe, output or ingredient without Shift
- **THEN** the existing selection, navigation and hover behavior is preserved

#### Scenario: Missing native link support

- **GIVEN** the target item/spell link or native chat insertion API is unavailable
- **WHEN** the player Shift + left-clicks a clickable entity
- **THEN** no invalid chat text is inserted or message sent
- **AND** the action does not trigger ordinary navigation

#### Scenario: Reused row identity

- **GIVEN** a visible result row has been recycled for a different item or recipe after filtering or scrolling
- **WHEN** the player Shift + left-clicks the row
- **THEN** CraftAtlas uses only its currently bound entity identity

#### Scenario: Open or closed chat

- **WHEN** the player Shift + left-clicks a valid entity with chat already open or currently closed
- **THEN** the insertion follows the supported native WoW chat-edit behavior for that state
- **AND** CraftAtlas never automatically sends the chat message
