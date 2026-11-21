# Design

## Registration at startup

Keep registration in `InitSettings()` and leave the existing command handler behavior in place. Read the client-provided `SlashCmdList` once. When it is a table, set the CraftAtlas alias and its entry through the existing registry. Preserve the global binding and other command entries. Treat an absent or non-table registry as unavailable and skip registration so the normal startup sequence can continue.

The existing `SlashCmdList = SlashCmdList or {}` assignment writes the global even when it already contains a table. This matches the global named in the taint trace. Avoid writes to Blizzard's command parser and protected action APIs.

## Verification

Extend the existing Lua addon configuration fixture to detect an assignment to the registry global even if the value being assigned is the same table. A table identity comparison alone would miss the original defect. Also exercise the missing registry and supported command dispatch.

Use a fresh Forever UI session with CraftAtlas and DungeonJournal enabled for the client check. With a valid nearby rare and permission to mark it, repeat the tracker click with taint logging enabled and confirm the selection and skull. Record the exact client build, versions, result and relevant log evidence. The offline regression covers registration. Forever provides evidence for the protected-action behavior.
