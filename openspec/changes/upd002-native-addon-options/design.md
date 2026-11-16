# Design

## Native addon settings

Use a guarded registration through the client's native AddOn settings API. Register one category named CraftAtlas under Options → AddOns during addon initialization after SavedVariables are ready. Use the client's native canvas registration where supported and only use a legacy native registration path if verified for a supported client. Keep registration idempotent. If a required API is unavailable, skip registration and keep addon startup and browsing available.

Build the panel with native controls. The game owns category navigation, opening, closing and scrolling. The panel refreshes from SavedVariables when shown, and its labels and selector update when the addon language changes. The explorer keeps its existing language dropdown and navigation. Share the dropdown implementation, including its fallback, and bind both controls to the existing account language preference. Opening options does not create or navigate the explorer.

## Persistence and runtime

Extend the existing account-wide SavedVariables record with four boolean preferences. Default to a visible minimap button, enabled profession annotations, visible icons and expanded rows. Normalize missing or invalid values individually and keep explicit false values, language, minimap angle and existing recipe tracking records. Apply minimap visibility immediately and during initialization using the same button instance. Reapply the saved angle when showing it.

Use the existing item-tooltip hook. Read the saved preferences when a supported tooltip opens or rebuilds. Reuse localized alphabetical ordering and available profession artwork. For the compact mode, join the entries with a comma and space and ask the native tooltip to wrap the line. Track the number of lines rendered for duplicate suppression on clients where clear events are unavailable. Keep disabled layout controls checked or unchecked according to the saved values.

## Verification

Use Lua mocks for registration, repeated initialization, unavailable APIs, language synchronization, account preference migration, visibility, minimap recovery and tooltip rebuilding. In Forever, open CraftAtlas from the game's Options → AddOns and verify native category navigation, normal and compact UI scales, both addon languages, persistence after `/reload`, and minimap recovery without opening the explorer first. Inspect Copper Ore (`2770`), Linen Cloth (`2589`) and unknown item `25` on the tested tooltip surfaces. Record the exact build and outcomes in `docs/TESTING.md`.
