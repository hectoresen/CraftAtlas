# Design: Native paginated recipe cards

## Existing implementation
`Features/Settings/RecipePanel.lua` currently renders a vertically stacked list with separate recipe and output icons/labels, one row per entry plus profession headers. It stores a row-offset and a scrollbar. `Settings.lua` calls `ns.InitRecipePanel(right, panel:GetHeight() - 132)` and `ns.RefreshRecipePanel(itemID)`; the current close button is provided by `BasicFrameTemplateWithInset` and is not explicitly wired to `panel:Hide()`. Existing recipe data, `Domain/RecipeUsage.lua`, `Infrastructure/RecipeInfo.lua`, `Infrastructure/ItemInfo.lua` and `ns.GetRecipePresentation` are reusable.

## Paging model
- Use `ns.GetRecipeUses(itemID)` as the unique deterministic source; **do not** paginate `GetGroupedRecipeRows` since heading records are not recipes.
- Add a pure helper `ns.PaginateRecipeUses(uses, page, pageSize)` that always uses pageSize=6 for the UI; returns the six-item slice, clamped page, maximum page count (at least 1 for display) and actual total. Preserve global recipe order by profession then spellID.
- Rebuild the page only for selection/page change or relevant localized/name/icon refresh, never per frame. Reset to page 1 on new material, preserve page for same selected material when valid, disable next/previous at boundaries. An empty result shows 0 recipes and `0 / 0` or a localized empty message without fictitious page.
- Avoid the 2×/1× increment on item-cache event leading to accidental resets.

## Cards and layout
- Six pooled Button frames in a 3-column × 2-row grid, normally right of left results; calculate dimensions from the actual right-panel width and available height. Reserve a footer for pagination. Ensure card content remains within frame, and adapt to UI scale without overlap. If normal width becomes too narrow for three columns, select two columns × three rows while retaining six recipes per page; if no fit, cap font and icon sizes and document the minimum supported window.
- Each card owns a single icon texture and one name label plus a small metadata line. Priority: native output item icon/name (when output itemID available) → native recipe spell icon/name → neutral built-in question-mark icon and verified recipe/spell identifier. For non-item recipes, never label a non-existent output as an item.
- Metadata: consuming profession and reagent quantity, e.g. `Ingeniería · x5`, with native fonts. Show card highlight on hover and a thin border/line separating cells. Avoid duplicating the header's recipe count in each card.
- Use the existing safe native tooltip presenters: output item link/id gets `ns.ShowOutputTooltip`, fallback to `ns.ShowRecipeTooltip`. No custom imitation of rarity/stats. Call `ns.HideRecipeTooltip` when switching pages, selection or closing window.

## Window-close fix
- Reuse `panel.CloseButton` from `BasicFrameTemplateWithInset` when present; when absent, create `UIPanelCloseButton` attached to panel. In both cases set an explicit `OnClick` handler to `panel:Hide()`; no implicit `HideUIPanel` assumption.
- Ensure close button is raised above overlay frame levels at top right, while avoiding new invisible intercepting frames. The header remains below the close hit area.
- Existing `panel:SetScript("OnHide", ...)` clears search focus, hides language/profession menus and invokes recipe tooltip cleanup. Reopening does not create another close button or reset unrelated preferences.

## Tests
- Pure Lua pagination: 0/1/6/7/14 recipe cases, exact slices, page bounds, no duplicates, selection reset.
- UI mock: six recycled card controls, one icon, correct metadata, tooltip choice on hover, tooltip hidden on page/selection/close; native template close handler bound and can be fired.
- In-game on current Forever: known source reagent with 14 recipes (e.g. item 159 if still matching) expects 3 pages: six/six/two; click Next/Previous and check tooltip/hover, close via X and reopen via minimap and `/craftatlas`, check locale switching and reduced UI scale. Record precise build and screenshots. Offline mocks and CI are not proof of client support.
