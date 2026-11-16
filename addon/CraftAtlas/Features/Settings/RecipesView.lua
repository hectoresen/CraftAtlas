local _, ns = ...
local view = {page = 1, pageSize = 5, selected = nil, rows = {}, ingredients = {}}
local ITEMS_PER_PAGE = 5

local function font(parent, style)
    return parent:CreateFontString(nil, "OVERLAY", style)
end

local function clearTooltip()
    if ns.HideRecipeTooltip then ns.HideRecipeTooltip() end
end

local function describe(recipe)
    if not recipe then return nil end
    local name, spellIcon = ns.GetRecipeSpellPresentation(recipe.spellID)
    local outputName, outputIcon
    if recipe.outputItemID then
        outputName, outputIcon = ns.GetItemDisplay(recipe.outputItemID)
    end
    return (outputName or name or (ns.L("RECIPE_ID") .. " " .. recipe.spellID)),
        (outputIcon or spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark"), name
end

local function updateIngredientSectionVisibility()
    if not view.section or not view.itemList then return end
    local expanded = view.section.expanded
    if expanded then
        view.itemList:Show()
        view.pager.previous:Show()
        view.pager.next:Show()
        view.pager.label:Show()
    else
        view.itemList:Hide()
        view.pager.previous:Hide()
        view.pager.next:Hide()
        view.pager.label:Hide()
        clearTooltip()
    end
end

local function render()
    if not view.frame then return end
    local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
    if not recipe then
        view.title:SetText(ns.L("SELECT_RECIPE"))
        view.profession:SetText("")
        view.output:SetText("")
        view.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        view.ingredients = {}
        view.section:SetTitle(string.format(ns.L("RECIPE_INGREDIENT_COUNT"), 0))
    else
        local name, icon, spellName = describe(recipe)
        view.title:SetText(name)
        view.icon:SetTexture(icon)
        view.profession:SetText(ns.ProfessionLabel(recipe.professionKey))
        local recipeLabel = ns.L("RECIPE_ID") .. " " .. tostring(recipe.spellID)
        if recipe.outputItemID then
            view.output:SetText((spellName and (spellName .. "  |  ") or "") .. recipeLabel)
        elseif recipe.kind == "enchant" then
            view.output:SetText(ns.L("RECIPE_ENCHANT_ACTION") .. "  |  " .. recipeLabel)
        else
            view.output:SetText(ns.L("RECIPE_OUTPUT_UNKNOWN") .. "  |  " .. recipeLabel)
        end
        view.section:SetTitle(string.format(ns.L("RECIPE_INGREDIENT_COUNT"), #recipe.ingredients))
        view.ingredients = recipe.ingredients
    end
    local visible, page, pages = ns.PaginateRecipeUses(view.ingredients, view.page, view.pageSize)
    view.page = page
    clearTooltip()
    for i, row in ipairs(view.rows) do
        local ingredient = visible[i]
        row.ingredient = ingredient
        if ingredient and i <= view.pageSize then
            local name, icon = ns.GetItemDisplay(ingredient.itemID)
            row.name:SetText(name or (ns.L("ITEM_ID") .. " " .. ingredient.itemID))
            row.professions:SetText(string.format(ns.L("RECIPE_QUANTITY"), ingredient.quantity))
            row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row:Show()
        else
            row:Hide()
        end
    end
    ns.UpdateExplorerPager(view.pager, page, pages)
    updateIngredientSectionVisibility()
end

function ns.SetRecipeDetail(key)
    if view.selected ~= key then view.page = 1 end
    view.selected = key
    render()
end

function ns.ShowRecipeDetailView(visible)
    if not view.frame then return end
    if visible then view.frame:Show() else view.frame:Hide() clearTooltip() end
end

function ns.RefreshRecipeDetail()
    render()
end

function ns.InitRecipeDetail(parent)
    if view.frame then return end
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetAllPoints(parent)
    view.frame = frame
    local availableHeight = type(parent.GetHeight) == 'function' and parent:GetHeight() or 343
    view.pageSize = math.max(1, math.min(ITEMS_PER_PAGE,
        math.floor((availableHeight - 138 - 40) / 39)))

    view.icon = frame:CreateTexture(nil, "ARTWORK")
    view.icon:SetSize(52, 52)
    view.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
    -- No UI-Quickslot2 overlay: its inner slot draws a duplicate inset square.

    view.title = font(frame, "GameFontNormalLarge")
    view.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -18)
    view.title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, -18)
    view.title:SetJustifyH("LEFT")
    view.title:SetWordWrap(false)
    view.profession = font(frame, "GameFontHighlightSmall")
    view.profession:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -40)
    view.output = font(frame, "GameFontDisableSmall")
    view.output:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -76)
    view.output:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -76)
    view.output:SetJustifyH("LEFT")
    view.output:SetWordWrap(false)
    view.section = ns.CreateExplorerSection(frame, "RECIPE_INGREDIENT_COUNT", -103, function()
        updateIngredientSectionVisibility()
    end)

    local itemList = CreateFrame("Frame", nil, frame)
    view.itemList = itemList
    itemList:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -143)
    itemList:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 40)

    local count = ITEMS_PER_PAGE
    for i = 1, count do
        local row = ns.CreateExplorerRow(itemList, 39, function(self, button)
            if self.ingredient and ns.IsEntityChatLinkClick(button) then
                ns.InsertEntityChatLink("item", self.ingredient.itemID)
                return
            end
            if self.ingredient and ns.OpenMaterialFromRecipe then
                ns.OpenMaterialFromRecipe(self.ingredient.itemID)
            end
        end)
        row:SetPoint("TOPLEFT", itemList, "TOPLEFT", 0, -(i - 1) * 39)
        row:SetPoint("TOPRIGHT", itemList, "TOPRIGHT", 0, -(i - 1) * 39)
        row:SetScript("OnEnter", function(self)
            if self.ingredient then ns.ShowOutputTooltip(self, self.ingredient.itemID) end
        end)
        row:SetScript("OnLeave", clearTooltip)
        view.rows[i] = row
    end
    view.pager = ns.CreateExplorerPager(frame, function()
        if view.page > 1 then view.page = view.page - 1 render() end
    end, function()
        if view.page < math.ceil(#view.ingredients / view.pageSize) then
            view.page = view.page + 1
            render()
        end
    end)

    -- Native result tooltip; only real WoW item data can provide quality/stats.
    local outputHover = CreateFrame("Button", nil, frame)
    outputHover:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -10)
    outputHover:SetSize(66, 64)
    outputHover:SetScript("OnEnter", function()
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if not recipe then return end
        if recipe.outputItemID then
            if not ns.ShowOutputTooltip(outputHover, recipe.outputItemID) then
                ns.ShowRecipeTooltip(outputHover, recipe)
            end
        else
            ns.ShowRecipeTooltip(outputHover, recipe)
        end
    end)
    outputHover:SetScript("OnClick", function(_, button)
        if not ns.IsEntityChatLinkClick(button) then return end
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if recipe then ns.InsertRecipeChatLink(recipe) end
    end)
    outputHover:SetScript("OnLeave", clearTooltip)
    frame:SetScript("OnHide", clearTooltip)
    frame:Hide()
end
