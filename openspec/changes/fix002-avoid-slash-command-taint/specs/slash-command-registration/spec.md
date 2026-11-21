# Slash command registration

## ADDED Requirements

### Requirement: Use the client's slash command registry

CraftAtlas SHALL register its command through the existing client-provided `SlashCmdList` table and SHALL leave the binding of that global and other commands intact. If the registry is unavailable, CraftAtlas SHALL skip command registration and continue addon startup.

#### Scenario: Native registry is present

- **GIVEN** the client provides a `SlashCmdList` table containing other commands
- **WHEN** CraftAtlas initializes
- **THEN** `/craftatlas` is registered in that table
- **AND** no assignment is made to the global `SlashCmdList` binding
- **AND** other command entries are preserved

#### Scenario: Native registry is unavailable

- **GIVEN** `SlashCmdList` is absent or is not a table
- **WHEN** CraftAtlas initializes
- **THEN** it does not assign or replace the global registry
- **AND** startup continues and the minimap launcher remains available when enabled and supported

### Requirement: Keep the existing CraftAtlas command forms

When the client registry is available, CraftAtlas SHALL retain the existing behavior of its explorer, direct material lookup and performance diagnostics commands.

#### Scenario: Use the registered command

- **WHEN** the player enters `/craftatlas`, `/craftatlas 159` or `/craftatlas perf`
- **THEN** the corresponding action opens the explorer, shows the known material, or prints the local performance diagnostics

### Requirement: Allow the reported dungeon marking action

CraftAtlas registration SHALL allow DungeonJournal's rare-targeting macro to mark a valid target in a supported Forever client with ordinary targeting and marking permissions.

#### Scenario: Click a rare portrait after a fresh UI load

- **GIVEN** CraftAtlas and DungeonJournal are loaded, a listed rare is present and targetable, and the player can assign a raid target marker
- **WHEN** the player clicks the rare portrait to target it and mark it with a skull
- **THEN** the rare is targeted and marked with a skull
- **AND** the client shows no CraftAtlas protected-action warning
- **AND** the current session's taint log contains no CraftAtlas-attributed `SetRaidTarget()` block for that click
