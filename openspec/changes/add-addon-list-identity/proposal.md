# Show CraftAtlas under Professions in the AddOns list

## Why

Players should be able to find CraftAtlas in WoW: Forever's native AddOns list and recognize it by the same blacksmithing artwork they see on the minimap. The current manifest declares the same named texture as the minimap adapter but has no category. The declaration alone does not establish that the icon renders in the list on the target client.

## Scope

- Make the installed addon discoverable as a single `CraftAtlas` entry in the native AddOns list under `Profesiones` on esES and `Professions` on enUS, including while the addon is disabled.
- Display the minimap's existing blacksmithing artwork next to the entry using native manifest metadata. The list uses its own icon sizing and framing.
- Keep the icon and category metadata in the installable release ZIP as well as the source installation.

This proposal complements the addon identity requirement from merged spec PR #7. It covers the native AddOns list, separate from the minimap interaction proposed in PR #43. The minimap button, explorer settings, and external addon manager listings are outside scope.

## Impact and rollback

Target the next development increment after owner approval. Reuse client artwork and the existing install layout; this adds no packaged art, dependencies, runtime hooks, or data. The target Forever build must demonstrate that the client resolves the texture and the localized category from the packaged manifest. If the result regresses discovery, revert the manifest and its associated documentation changes. No player data migration is required.
