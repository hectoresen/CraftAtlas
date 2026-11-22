# Avoid slash command taint

## Why

A player reported a protected-action warning after clicking Azshir the Sleepless in the dungeon tracker. The supplied Forever log from 2026-11-21 records three blocks of `SetRaidTarget()` attributed to CraftAtlas. Each follows a tainted read of the global `SlashCmdList` in Blizzard's command parser during `RunMacroText()`. The inspected installs report CraftAtlas 0.4.1 and DungeonJournal 2.1.0. The tracker uses `/targetexact` followed by `/tm 8` to select and mark a rare. The log identifies the blocked marking action and does not record whether selection succeeded.

CraftAtlas reassigns `SlashCmdList` during addon startup as part of registering `/craftatlas`. The proposed fix removes that write to the shared global. The captured failures establish the baseline. A retest in Forever is required to verify the fix.

## What changes

- Register the existing command in the client-provided registry without assigning the registry global.
- Keep the explorer, direct material lookup and performance diagnostics available through their existing command forms.
- Skip registration safely when the native registry is unavailable so the other addon entry points can initialize.

## Capabilities

- `slash-command-registration` defines safe command registration, preserved command behavior and compatibility with the reported marking action.

## Impact

The change is limited to CraftAtlas command registration, its Lua regression fixture and verification documentation. The dungeon tracker is used to reproduce the compatibility issue. Its code and assets, the CraftAtlas data and saved preferences are outside the scope.
