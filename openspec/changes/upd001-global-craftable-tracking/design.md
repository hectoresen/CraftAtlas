# Design

## Current state and discrepancy

`Infrastructure/Preferences.lua` exposes `IsCraftableTracked(recipeKey)` / `SetCraftableTracked(recipeKey, bool)` based on `CraftAtlasDB.craftTracking[realm:character][recipeKey]`. `Features/Settings/RecipesView.lua` evaluates `recipe.key` in every render, in checkbox clicks, and inventory event refresh. Therefore the checkbox turns off on any selected recipe without its own entry.

## Persistence and rendering

Implement new narrow APIs such as `IsCraftTrackingEnabled()` / `SetCraftTrackingEnabled(enabled)` scoped by the same existing `realm:character` identity helper, stored as a boolean by character in SavedVariables. Read the global flag at render time and on relevant bag/bank events, independently of the selected recipe key. On enabling, show the **currently selected** recipe's material progress. On switching recipes, retain the mode but query ingredients for the new selected recipe; use the existing bounded event-driven refresh. On disabling, hide tracker UI on every recipe. If the current character identity is unavailable, fail safely instead of leaking preferences.

Retire reads/writes of the per-recipe toggle from the UI; old keyed data is not reinterpreted as global enabled to prevent a surprising opt-in. Keep the previous data untouched for compatibility until a separately approved cleanup, if any.

Only state/global-mode behavior is modified; do not rework the native recipe layout, progress colors, bank semantics, source catalog or any other controls.

## Evidence

The approved `feat001-track-craftable-materials` delta's per-recipe scenarios are superseded **prospectively** by this owner-approved delta only after its separate implementation PR merges. Its historical implementation/evidence remains truthfully recorded. Add a new canonical change and archive this change using the normal one-change-per-PR transaction when tests and client evidence permit. Never retroactively rewrite feat001 immutable artifacts.
