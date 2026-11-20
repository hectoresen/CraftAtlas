# Native explorer UI

## ADDED Requirements

### Requirement: Close the explorer with Escape or the native close button

CraftAtlas SHALL allow the native Escape action and the native top-right X to close the same explorer window. Both SHALL run the explorer's normal hide cleanup and follow the existing reopen behavior. The explorer SHALL respect game UI that has native dismissal priority and SHALL relinquish control of Escape when hidden.

#### Scenario: Close from either view

- **WHEN** Materials or Craftables is visible, with no popup that takes dismissal priority, and the player presses Escape or clicks the top-right X
- **THEN** the single explorer window hides without a Lua error or opening the game menu as part of the same action
- **AND** CraftAtlas clears its search focus, open explorer dropdowns and any owned hover tooltip

#### Scenario: Close while typing a search

- **WHEN** the explorer search field has focus, no dropdown takes priority and the player presses Escape
- **THEN** the window closes on that press and the text is retained as it is on an X close

#### Scenario: Dismiss a dropdown before the window

- **WHEN** the profession dropdown in the explorer is open and the player presses Escape
- **THEN** the dropdown closes without changing its selection and the explorer remains visible
- **AND** pressing Escape again closes the explorer when it is the next window eligible for dismissal

#### Scenario: Reopen and let the game handle Escape when hidden

- **WHEN** the player closes and reopens CraftAtlas repeatedly using the minimap or `/craftatlas`
- **THEN** one usable explorer reopens on Materials with its ordinary X-close browsing and preference behavior
- **AND** Escape continues to work without duplicate registration, and CraftAtlas does not intercept it while the explorer is hidden

#### Scenario: Return Escape to the game menu

- **WHEN** the explorer is closed and the game would normally open its menu on Escape
- **THEN** the game menu opens without a CraftAtlas protected-action warning
- **AND** Escape can close the game menu normally

### Requirement: Keep persistent explorer controls in the same frame strata

CraftAtlas SHALL keep the results list, scrollbar, header, detail area and other persistent explorer controls in one frame stratum above the HUD and ordinary game panels. The list SHALL render within its own pane. Frame levels and anchors SHALL keep adjacent controls visible and interactive. Temporary dropdown popups and tooltips SHALL follow native overlay behavior.

#### Scenario: Overlap the explorer with HUD buffs or an ordinary game panel

- **WHEN** CraftAtlas overlaps HUD buffs or an ordinary game panel such as Options
- **THEN** the explorer frame, tabs, sidebar and detail rows stay above the overlapping UI together
- **AND** the explorer controls in the overlap respond to pointer input

#### Scenario: Scroll a full Craftables list

- **WHEN** Fabricables or Craftables shows enough results to scroll at a standard or supported compact UI scale
- **THEN** rows, selection highlights and the scrollbar remain inside the results pane
- **AND** rows never paint over or capture input intended for the search field, tabs, selectors, Back, close button or recipe details
- **AND** scrolling, selecting a row and switching tabs keep each control usable

#### Scenario: Use native popups over a populated list

- **WHEN** the player opens an explorer dropdown or hovers a row that provides a tooltip
- **THEN** the popup or tooltip is readable above the applicable content and dismisses normally
- **AND** rows and neighboring controls remain usable after dismissal

### Requirement: Use a minimalist native presentation in both explorer views

CraftAtlas SHALL use one Options-inspired native shell for Materials and Craftables, with a translucent body, a narrow results sidebar and a wider detail pane. Native and fallback controls SHALL preserve the same interactions.

#### Scenario: Browse in English and Spanish at different scales

- **WHEN** the player switches between Materials and Craftables at a standard or supported compact scale with enUS or esES selected
- **THEN** the explorer shows one title and aligns the search field with the same native tabs as Options when available
- **AND** the shared inset and section headings use the recessed style, and active catalog progress appears in the footer
- **AND** the controls remain readable and reachable with distinct selected, hover, disabled, loading, empty and incomplete states
- **AND** the search X appears only for a nonempty query, and the version footer appears only for an installed official release

#### Scenario: Show the profession inside a Craftables result row

- **WHEN** a Craftables result shows the recipe name and profession at a supported scale
- **THEN** both labels stay inside the row and its selection highlight without encroaching on the next row

### Requirement: Preserve existing explorer workflows and addon integrations

CraftAtlas SHALL preserve the current results and behaviors for browsing, direct entry, tooltips, settings and tracking. Material identity SHALL remain numeric itemID and recipe identity SHALL remain profession plus spellID. UI changes SHALL preserve bounded list reuse and per-view catalog preparation behavior.

#### Scenario: Browse and cross-navigate without losing view state

- **WHEN** the player searches and filters each view, expands or collapses Materiales profession groups, then follows a crafting use to Craftables and an ingredient back to Materials
- **THEN** profession grouping, per-group and deduplicated result counts, exact ingredient quantities, detail sections, pagination and scroll interactions remain available
- **AND** Back restores the existing view-specific query, filter and browsing context
- **AND** ordinary clicks navigate and Shift + left-click inserts a native link when available

#### Scenario: Inspect shared, unknown and non-item data

- **WHEN** the player inspects a reagent used by multiple professions, tries an unknown item or opens a recipe that performs a non-item action
- **THEN** the shared reagent keeps one identity across all matching groups, the unknown item yields no invented facts, and the non-item recipe retains its distinction
- **AND** catalog-loading progress and unavailable-name feedback retain their separate meanings

#### Scenario: Keep tracker and game integrations working

- **WHEN** the player uses Track crafting, changes recipes, opens or closes the bank, and reloads the addon
- **THEN** the existing per-character opt-in, per-recipe quantities, native progress and bank availability rules still apply
- **AND** `/craftatlas`, `/craftatlas <itemID>`, `/craftatlas perf`, the movable minimap launcher, native item tooltips and the native AddOn options retain their current behavior
