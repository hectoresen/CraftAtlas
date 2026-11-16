# Native chat links and consistent craftable detail icon

## Why

CraftAtlas lets players explore materials, craftable results and ingredients, but Shift + left-click on its clickable entries does not insert a usable item or recipe link into WoW chat. This breaks the native interaction expected from bags, profession windows and spell books. The Fabricables detail icon also shows an unexpected inset rectangle; its view adds a UI-Quickslot2 overlay that the Materiales detail does not use.

## Scope

- Make **Shift + left-click** on every clickable material, recipe, resulting item and ingredient in CraftAtlas insert the appropriate *native, validated* WoW chat hyperlink when supported. This covers explorer rows in Materiales and Fabricables, material-to-recipe uses, recipe ingredient rows, and interactive detail icon/identity surfaces. Ordinary clicks and existing hover/tooltips/navigation remain unchanged.
- Prefer an actual output **item** link for craftables producing an item; use a native **spell** link only for non-item profession actions when supported. Never synthesize a link from a numeric ID, locally translated label or incomplete client metadata. Explicitly define graceful behavior when the chat editor or link API is unavailable.
- Remove the unintended inset rectangle in the Fabricables detail icon while preserving one coherent, native-looking icon frame and intact output hover.
- Keep layout, searches, result counts, recipe data, SavedVariables, language choice and release behavior unchanged.

## Out of scope

Inventory/character craftability, learned recipes, recipe-book links where client APIs cannot produce them, new data sources, full UI redesign, chat automation, external addons and unrelated minimap/configuration work (#43/#44/#46).

## Impact and risks

Small, bounded native UI/adapter change. The critical compatibility risk is which link APIs and chat edit behavior World of Warcraft: Forever exposes; the implementation must guard them and be tested in the real client. Item and spell links must be accepted by WoW itself, not guessed. If native integration is unsupported for a kind of entity, preserve ordinary click and report that case as unsupported rather than inserting broken text. No network, licensing, generated dataset or migration changes.

Rollback: revert the implementation PR. No persistent-state migration is required.

## Verification

Test shift/click precedence and the correct item-vs-spell choice with isolated Lua 5.1 fakes; test no-op behavior when native link data or chat insertion is absent, and ensure hover/tooltips and normal navigation continue to work. Inspect icon layering with a UI regression. Run the shared release, SDD and strict OpenSpec checks. Manually validate on Forever in enUS/esES with an open and closed chat edit box and record the exact build; unexecuted cases remain NOT RUN.
