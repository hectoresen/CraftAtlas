# Keep the CraftAtlas button on the minimap edge

## Why

The minimap button currently follows the pointer freely during a drag and snaps to the circular edge on release. Its hover tooltip uses the opening action as its title and gives players no indication that they can move the button.

## Scope

- Keep the existing native button on the circular edge throughout a left-button drag. Settle it at the release angle and preserve that angle across `/reload`.
- Show `CraftAtlas` as the hover title, followed by separate localized instructions for opening the explorer and moving the icon.
- Keep ordinary left-click routed to the existing explorer action, including the first click after a drag.

## Impact

Target the next development increment after spec approval. The implementation uses the native minimap frame, current icon textures, existing SavedVariables angle and addon locale selection. The change introduces zero external assets, dependencies or data sources.

Verify the pointer coordinate conversion and release event order in the Forever client, especially at a different UI scale and when the pointer is outside the minimap. If a regression warrants rollback, revert the implementation commit. Its saved angle remains compatible with the previous adapter.
