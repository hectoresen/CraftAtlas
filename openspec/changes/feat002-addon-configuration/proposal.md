# Add CraftAtlas configuration

This proposal carries forward the requirements, design, and implementation scope from [PR #46](https://github.com/hectoresen/CraftAtlas/pull/46). It provides a new change ID and an owner-merged approval reference for the implementation PR.

## Why

Players can change the addon language from the explorer. Showing the minimap button and displaying one icon-labeled profession per tooltip row are fixed behaviors. A Configuration view gives players a place to change those preferences.

## What changes

- Add a localized Configuration entry to the CraftAtlas explorer with General and Tooltip sections.
- In General, reuse the explorer's Auto, Español and English selector and add a checkbox for minimap button visibility.
- In Tooltip, add checkboxes to show or hide the consuming-profession section, hide profession icons, and display the profession names on one comma-separated line. Icon visibility and line layout can be combined.
- Save the choices account-wide. Existing installations keep the language and minimap position they saved and start with the existing minimap and tooltip appearance.

## Capabilities

### New Capabilities

- `addon-configuration` covers access to Configuration, its controls, localization and preference persistence.

### Modified Capabilities

- `minimap-button` makes visibility configurable while keeping the existing default and open action.
- `material-tooltip-presentation` makes the expanded layout the default and defines the optional presentations.

## Scope and rollout

Target the next development increment after owner approval. The change affects addon UI, SavedVariables, the minimap button and the CraftAtlas contribution to supported item tooltips. Catalog data, profession memberships, explorer filters, native item tooltip content and minimap drag behavior are outside the change scope.

Use the existing native WoW controls and profession artwork. This proposal adds no data source, artwork or dependency. Verify layout, widget availability, and tooltip rendering on the target Forever build. Reverting the implementation restores the prior display behavior, and the prior code can still read the existing language and position fields from the same SavedVariables table.
