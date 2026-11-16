# Design

## Configuration in the explorer

Use the existing CraftAtlas window and a localized Configuration entry accessible from Materials and Craftables. Present General and Tooltip in that view using native controls. Keep Configuration outside the material-to-recipe navigation history. Return to browsing with the view's search, filter and selection intact. Verify that the entry fits alongside the existing navigation and progress indication at supported UI scales.

Expose the same language dropdown in General and in the browsing views. Reuse the native dropdown with its current fallback and read and update the single existing language preference. In Configuration, show the control once, in General. Use the existing locale resolution for new labels and refresh the open controls on a language change.

## Persisted preferences and application

Extend the existing account-wide SavedVariables record in `Infrastructure/Preferences.lua`. Normalize each visibility or layout value as a boolean, preserving an explicit `false`. Field defaults are:

| Preference | Default |
| --- | --- |
| Show minimap button | On |
| Show consuming professions in item tooltips | On |
| Hide profession icons | Off |
| Show professions on one line | Off |

Keep the existing language and minimap angle handling. Apply the visibility preference to the existing minimap button at startup and when the setting changes. A hidden button can be restored from the explorer opened via `/craftatlas`, at its last saved angle.

## Tooltip rendering

Evaluate the saved options in the existing item-tooltip presenter. When annotations are enabled, reuse the current catalog lookup, localized heading, alphabetized profession labels and available icon prefixes. The icon option controls those prefixes in both layouts. The compact option joins the entries with a comma and space, adding one native line after the heading. Wrapping follows the client's tooltip rendering. The tooltip adapter retains its existing single hook. Derive duplicate suppression from the actual number of lines added so that rebuilds and repeat callbacks work in either layout.

When profession annotations are disabled, disable the two layout controls in Configuration and retain their saved values. Apply changes when the next supported item tooltip is opened or rebuilt without a reload.

## Verification

Use Lua mocks for preferences and legacy records, minimap visibility and angle restoration, explorer navigation and localization, and the tooltip layout combinations and duplicate handling. In Forever use a known multi-profession material such as Linen Cloth (`2589`), a single-profession material such as Copper Ore (`2770`), and an unknown item such as `25`. Check both addon languages and compact UI scales. Record the exact build and outcomes for the tested tooltip surfaces in `docs/TESTING.md`.
