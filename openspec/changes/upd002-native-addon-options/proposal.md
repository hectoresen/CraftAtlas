# Put CraftAtlas configuration in native AddOn options

## Why

Players expect to find addon preferences under the game's Options → AddOns. The approved `add-addon-configuration` change (PR #46) placed a Configuration page inside the CraftAtlas explorer. Its implementation is still in draft PR #65. This proposal supersedes that unshipped change and uses the game's native settings location.

## What changes

- Register one CraftAtlas settings page under Options → AddOns with localized General and Tooltip sections.
- In General, offer the shared language preference and the minimap visibility checkbox. Players can restore the button here even if it is hidden.
- In Tooltip, offer controls for annotation visibility, profession icons and the comma-separated layout. Preserve the layout selections while annotations are disabled.
- Save all four checkbox preferences for the account with the appearance and behavior approved in PR #46. Keep the existing explorer language selector synchronized with the native page.

## Capabilities

### New Capabilities

- `addon-configuration` covers discovery, controls, localization and persistence from the native Options interface.
- `material-tooltip-presentation` specifies the expanded default and configurable annotation, icon visibility and layout.

### Modified Capabilities

- `minimap-button` specifies the configurable visibility and recovery path through native options.

## Scope and rollout

Implement this proposal in a separate PR from current `main` after owner approval and merge. Use the account preference and tooltip behavior from PR #46 as the starting point. The explorer continues to handle browsing and its existing language shortcut. Catalog data, recipes, minimap drag behavior and AddOns list metadata are outside this scope. The earlier approved artifacts remain available as history. This change adds no data source, artwork or dependency.
