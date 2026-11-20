# Design

## Escape and window ownership

`Features/Settings/Settings.lua` owns the single, lazily created `CraftAtlasSettingsFrame`. Reuse that frame for every entry point. Use `UISpecialFrames` with an addon-owned child that is shown only with the explorer. Its dismissal closes a local fallback popup first or hides the explorer. The focused edit box calls the same dismissal function. Native menus and dialogs retain their priority. Keep addon callbacks out of the game's Escape dispatcher because the previous client capture showed a protected-action warning. The game continues to manage its native Options window.

Route the top-right X through the same window hide lifecycle. Clear owned dropdowns, search focus and any tooltip still owned by an explorer control. Retain search text and browsing state according to the current close path. Keep the existing Materials default on ordinary minimap and slash opens and preserve intentional direct item navigation. Verify close ordering and repeat opens in Forever.

## Shared layout and layering

Use one `DIALOG` frame stratum for the explorer and its descendants so they cover HUD buffs and ordinary game panels as a unit. Parent the recycled rows and scrollbar to the clipped results viewport. Apply the shared stratum to template descendants after construction. Use local frame levels and draw layers for borders, row highlights and fallback popups. Native tooltips and dropdowns retain their overlay behavior.

Reuse the Options frame and its `MinimalTabTemplate` when available, including sizing the tabs from their localized labels. Align the tabs, Back and right-aligned search on one row above the native inset. Use recessed Options category artwork for sidebar groups and detail headings. Center progress in the footer. Keep Craftables subtitles within their rows and preserve guarded fallbacks, the bounded row pool and scheduled catalog work.

Use the current source as the interaction baseline. The inline search X and bounded vertical recipe-use rows on `main` supersede earlier descriptions of a broom icon and a recipe-card grid.

## Selected language

Keep the selector in `PreferencesPanel.lua` and remove the explorer shortcut described by `upd002-native-addon-options`. The native and fallback menu states use the normalized account choice (`auto`, `esES`, or `enUS`). Language changes continue to refresh any open explorer through the existing preferences callback.

## Minimap shortcuts

Use the existing minimap button with separate left and right mouse-up events. The right-click path asks the AddOn settings adapter to open its registered category via `Settings.OpenToCategory(category:GetID())`. A missing API or category leaves the current UI usable. Preserve left-drag suppression and the saved angle. The tooltip colors only the localized gesture names in dark gold and orders them left-click, drag and right-click.

## Verification

Extend the close, layout, shared-widget, minimap and addon-options fixtures. In Forever check the exact native tab appearance, clipped row labels, right-click destination, locale switching and popup and window dismissal. Record the build, scales, results and screenshots in the implementation evidence.
