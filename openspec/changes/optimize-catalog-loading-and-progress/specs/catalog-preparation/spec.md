# Bounded catalog preparation

## ADDED Requirements

### Requirement: Bound initialization work without repeated full-view recomputation
CraftAtlas SHALL process first-use material and craftable metadata preparation incrementally, with bounded per-callback work, and SHALL coalesce unnecessary full-search and UI refreshes caused solely by background batches. It SHALL not turn unavailable client data into synchronous bulk retries.

#### Scenario: First Materiales preparation
- **WHEN** the player first opens Materiales in a fresh game session
- **THEN** source-backed itemIDs are processed in scheduled bounded batches
- **AND** redundant full-list filter/sort/tree refreshes are reduced compared with the existing per-batch redraw behavior
- **AND** the panel remains interactive during preparation

#### Scenario: First Fabricables preparation
- **WHEN** the player first opens Fabricables in a fresh session
- **THEN** source-backed recipe metadata work is scheduled in bounded batches
- **AND** full-recipe scans and visible redraws caused solely by each background batch are coalesced rather than repeated unnecessarily
- **AND** exact recipe identities and ingredient quantities are unchanged

#### Scenario: Timer or client metadata API unavailable
- **WHEN** a supported deferred scheduler or an item/spell metadata API is absent or fails
- **THEN** CraftAtlas degrades to a safe, non-blocking incomplete state with existing fallbacks
- **AND** does not synchronously loop over the entire remaining catalog or report fake completion
- **AND** does not raise unhandled Lua errors

### Requirement: Preserve correctness with cache invalidation
CraftAtlas SHALL preserve the current Materiales/Fabricables search/filter behavior and deterministic ordering, counts, selection, tooltip, navigation and translation semantics when client names/icons resolve or user state changes.

#### Scenario: New material name resolves
- **WHEN** a previously unknown item name becomes available during preparation or via a native event afterward
- **THEN** matching name searches and material group presentation update on the next appropriate coalesced refresh
- **AND** the item keeps its numeric itemID, profession memberships, actual per-group counts and global unique-ID count

#### Scenario: New spell/output name resolves
- **WHEN** an item or spell display name becomes available after its scheduled recipe attempt
- **THEN** search and visible craftable detail can incorporate the new client data without requiring a new session
- **AND** no invented name, output, rarity or recipe is displayed

#### Scenario: Switch views or revise filters during loading
- **WHEN** the player switches tabs, types a new search, changes profession/language, collapses groups or returns via Back while either worker runs
- **THEN** the active view promptly reflects the latest selection/query/state
- **AND** background work does not reset the other view's search, scroll position or selected IDs
- **AND** no duplicate timers, frames, event hooks or persistent stale results accumulate

### Requirement: Supply measurement evidence before claiming a speedup
Implementation SHALL include a reproducible way to measure first-use work and record before/after operation counts and client-frame observations where available. Any claimed FPS or elapsed-time improvement SHALL be supported by matched measured evidence, not batch-size arithmetic alone.

#### Scenario: Reproducible benchmark
- **WHEN** maintainers run a first-open Materiales/Fabricables scenario under controlled cache/build conditions
- **THEN** instrumentation can report work units, number of batches, search/rebuild/refresh counts and batch timing where the client supports it
- **AND** results explicitly distinguish objective operation-count changes from actual client FPS measurements
- **AND** tests or reports classify measurements not executed in Forever as NOT RUN
