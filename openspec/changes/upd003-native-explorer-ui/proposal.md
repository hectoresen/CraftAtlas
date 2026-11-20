# Refine the native CraftAtlas explorer

## Why

CraftAtlas already uses several native WoW controls, but its explorer combines them with custom framing and decoration. Players report that the Craftables list appears above the rest of the interface. The explorer's top-right X closes the window, while pressing Escape in the search box only removes focus and the window has no explicit native Escape registration. The language button displays the saved choice, but native menu entries carry no checked state.

## What changes

- Close the explorer with Escape through the game's special-window path and normal popup dismissal order. Avoid the protected-action warning reported in the client. Keep the native top-right X and use the same cleanup for both close paths.
- Keep result and detail rows, tabs and the rest of the explorer in a single window layer above HUD buffs and ordinary game panels. Native dropdowns and tooltips retain their temporary overlay behavior.
- Use the native WoW Forever Options tabs, inset and recessed section treatments. Align search with the tabs and keep the Craftables profession label inside its row highlight.
- Move language selection exclusively to Options → AddOns → CraftAtlas and mark its saved choice, including Auto.
- Open the CraftAtlas AddOn category on minimap right-click. Highlight the tooltip gestures in left-click, drag and right-click order. Preserve the left-click explorer shortcut, dragging and current browsing, tracking and item tooltip behavior.

## Capabilities

### New Capabilities

- `native-explorer-ui` specifies native close behavior, shared frame layering, the minimalist explorer presentation and its functional regression baseline.

### Modified Capabilities

- `localization` limits language selection to the native AddOn page and defines its selected indicator.
- `minimap-button` adds the right-click shortcut to native AddOn options.

## Impact

This is an explorer usability and defect-correction proposal for the maintenance cycle, with no assigned release version. It uses client-provided UI assets and adds no dataset, third-party artwork or dependency. Catalog rules, recipe identities, SavedVariables formats and the addon's global settings registration remain as specified today.

The main risks are Escape precedence in the actual client, template internals placing controls in unexpected strata, and overlap at compact scales. The reported list issue and the supported native APIs need confirmation on a recorded Forever client build. If a regression requires rollback, revert the implementation without migrating any saved data.
