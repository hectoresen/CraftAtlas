# Honest catalog preparation progress

## ADDED Requirements

### Requirement: Display genuine per-view preparation progress
CraftAtlas SHALL show a compact native-WoW progress indicator near the header title for the **active** Materiales or Fabricables view while its scheduled first-use preparation remains active. Percent SHALL be computed solely from completed planned work units and a known unit total, clamped 0..100. It SHALL use localized language that indicates preparing local information, not remote database synchronization.

#### Scenario: Materiales is processing
- **WHEN** Materiales has completed some but not all of its scheduled itemID attempts
- **THEN** the header shows a localized material-preparation label and the corresponding arithmetic percentage
- **AND** the title stays centered and search, language, tabs and native buttons remain unobstructed

#### Scenario: Fabricables is processing
- **WHEN** the player switches to Fabricables and its unique recipe work queue is incomplete
- **THEN** the header shows Fabricables' independent preparation percentage, not Materiales' percent
- **AND** returning to Materiales restores its actual current progress without starting another worker

#### Scenario: No work or completed worker
- **WHEN** the active view has no planned work or every planned unit has been attempted
- **THEN** the indicator completes and disappears automatically
- **AND** it does not flash on subsequent panel opens while that workstream is already complete

### Requirement: Never misrepresent client-cache resolution
CraftAtlas SHALL distinguish attempted processing from successfully resolved names/icons and SHALL not claim to have imported or synchronized any database. Failed or unresolved client names SHALL retain current incomplete-data feedback and SHALL not hold the progress bar indefinitely or be counted as resolved.

#### Scenario: Cache miss after processing
- **WHEN** the last scheduled unit has been attempted but one or more item/spell names remain unavailable in the client
- **THEN** preparation progress may reach 100% and the progress indicator hides
- **AND** unresolved/incomplete-data messaging remains accurate
- **AND** later successful native metadata resolution updates results without fabricating another progress cycle

#### Scenario: Scheduler stops before processing all units
- **WHEN** a worker cannot schedule remaining units
- **THEN** the indicator does not show 100% for unattempted units
- **AND** a non-blocking, localized incomplete state is shown or the existing incomplete-data indicator remains available

### Requirement: Preserve native UI compatibility and localization
The progress indicator SHALL use native Classic/Forever-compatible visual components and localized enUS/esES text and SHALL not alter established red buttons, dropdowns, centered title, search, minimap or window close behavior.

#### Scenario: Compact resolution or locale switch
- **WHEN** the client uses a compact UI scale or the language changes while preparation is active
- **THEN** the progress label and bar remain legible and do not overlap essential header controls
- **AND** labels update to the selected locale without restarting preparation
- **AND** unsupported optional native progress templates degrade without Lua errors
