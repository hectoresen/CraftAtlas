# Native AddOns list metadata

## Current source and client contract

`addon/CraftAtlas/Infrastructure/MinimapButton.lua` sets the icon to the client's `Trade_BlackSmithing` texture. `addon/CraftAtlas/CraftAtlas.toc` already has an `IconTexture` entry that names that resource, but has no `Category` or `Category-esES`. The [Forever AddOns list source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AddOnList/AddonList.lua) reads `IconTexture` or `IconAtlas` for the row, uses `Category` as the group heading, and matches search text against the addon name fields and category. The client builds those rows from installed addon metadata without requiring CraftAtlas Lua to load. This is source evidence, not a real-client test.

## Manifest changes

- Keep `CraftAtlas` as the manifest title and retain its existing addon identifier and folder name. Use `Category: Professions` and `Category-esES: Profesiones`, following the localized metadata pattern shown in [CraftSim's manifest](https://github.com/derfloh205/CraftSim/blob/main/CraftSim.toc). The selector is the game locale; CraftAtlas's language preference cannot drive a list that also works while the addon is disabled.
- Confirm that `IconTexture` resolves to the same `Trade_BlackSmithing` artwork as the minimap. Keep the current declaration if it renders correctly. If the client requires a different representation for the list, use a verified path or texture file ID for that same resource. The minimap's border, crop, and behavior stay as they are.
- Let the client manage category collapse, list search, and enable state. Do not add an addon-list hook, a custom row, or any code that runs when the addon is disabled. If the target client cannot meet the requirement using supported manifest metadata, record the exact build and result and bring the limitation back for spec review before expanding scope.

## Packaging and verification

`scripts/package_release.py` writes the `.toc` into `CraftAtlas/CraftAtlas.toc` in the ZIP and replaces its version header. A local package check can compare the icon and category fields with the source manifest; it cannot prove the game resolves them. Verify the actual list from a freshly started Forever client using the installable ZIP. With the category expanded, check esES and enUS, including an esES run with CraftAtlas disabled for the selected character. Compare the list icon against the minimap after enabling the addon. Record the build, locales, install type, and observed results.
