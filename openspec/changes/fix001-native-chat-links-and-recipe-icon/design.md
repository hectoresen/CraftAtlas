# Design

## Existing paths

`Features/Settings/Settings.lua` builds common explorer rows and routes normal selection/cross-navigation. `Features/Settings/Shared/ExplorerWidgets.lua` builds reusable clickable rows. `Features/Settings/RecipePanel.lua` builds material-to-recipe clickable uses; `Features/Settings/RecipesView.lua` owns the recipe detail, clickable ingredient rows and output hover. `Infrastructure/RecipeInfo.lua` already distinguishes outputItemID and spellID for tooltips and presentation. `RecipesView.lua` currently draws the recipe icon at 52×52 and overlays `Interface\\Buttons\\UI-Quickslot2` at 58×58, unlike the material detail.

## Interaction and linking contract

Introduce a small, shared, guarded link helper (in an existing appropriate infrastructure adapter or a dedicated module registered in the TOC) that accepts an **explicit** typed target: itemID or spellID, and attempts the client's native hyperlink retrieval and insertion. Prefer native APIs that produce a complete valid link, including the item's actual enchant/random/quality metadata when available; never manually manufacture `|Hitem:` / `|Hspell:` markup or use a localized name as a fake hyperlink. Reuse the client-supported chat insertion mechanism with normal chat focus/open behavior, without sending any message automatically. Test supported Classic/Forever paths and treat absent APIs, unknown data or a rejected insertion as a safe no-op.

At click entry points, check the relevant modifier via a guarded native API before normal navigation. A Shift + **left**-click attempts insertion and must **not** additionally navigate, even when insertion is unsupported. A plain left-click follows current behavior; avoid interfering with right-click or other gestures. Keep row recycling safe: resolve the currently bound item/recipe only at click time, not when creating the row.

Targets by surface:
- Materiales result row, material detail item identity/icon if interactive: item target for its actual reagent itemID.
- Materiales > Se utiliza para fabricar row: output item target when its recipe has an outputItemID, otherwise spell target if the supported client can provide a valid spell link.
- Fabricables result row and selected recipe detail icon/title surface: output item if available, else spell link for non-item recipe actions; do not confuse recipe spellID with an output itemID.
- Fabricables > Materiales necesarios row: actual ingredient itemID.
- Other CraftAtlas clickable entries that represent an item/recipe should reuse the same helper; tabs, paging, filters, close, Back and section disclosure are not linkable entities.

Do not convert plain decorative text or non-clickable elements into unrelated controls solely to meet a universal phrasing. If making a detail title clickable is appropriate, it must not obscure other controls, keyboard focus, native tooltip, or existing identity content.

## Icon fix

Inspect the difference between the material and Fabricables detail textures in the live client. Replace or correctly crop/anchor the extra `UI-Quickslot2` overlay so no smaller interior square remains. Preserve the 52px presentation and a single visually coherent border, and keep pointer hover and click hit regions consistent with the visible icon. Do not add external art. Validate both output-item and spell-only icons and relevant UI scales.

## Quality and evidence

Add Lua 5.1 regression tests for every interactive class, Shift/ordinary click behavior, native link availability, no fabricated links, wrong-identity prevention after row reuse, and no game message being sent. Add a layout/texture regression where feasible. The implementation PR must run `skills/documentation-sync/SKILL.md`, update README/TESTING/changelog as necessary, record actual commands/results, and explicitly record Forever tests as NOT RUN when not performed. This proposal makes no runtime changes.
