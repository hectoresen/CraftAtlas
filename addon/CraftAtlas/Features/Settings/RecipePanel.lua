local _, ns = ...

local state = {
    selectedID = nil,
    offset = 0,
    rows = {},
    visibleRows = 4,
    entries = {},
}

local ROW_HEIGHT = 43

local function font(parent, style)
    return parent:CreateFontString(nil, "OVERLAY", style)
end

local function clearHover()
    if ns.HideRecipeTooltip then ns.HideRecipeTooltip() end
end

local function displayRecipeName(use, info)
    if info.spellName and info.spellName ~= "" then return info.spellName end
    if info.outputName and info.outputName ~= "" then return info.outputName end
    return ns.L("RECIPE_ID") .. " " .. tostring(use.spellID)
end

local function drawRows()
    if not state.panel then return end
    local maxOffset = math.max(0, #state.entries - state.visibleRows)
    state.offset = math.min(state.offset, maxOffset)
    for i, row in ipairs(state.rows) do
        local entry = state.entries[state.offset + i]
        row.recipeUse = nil
        row.outputItemID = nil
        row.icon:Hide()
        row.outputIcon:Hide()
        row.recipeButton:Hide()
        row.outputButton:Hide()
        row.heading:Hide()
        row:Hide()
        if entry then
            row:Show()
            if entry.kind == "heading" then
                row.heading:SetText(ns.ProfessionLabel(entry.professionKey))
                row.heading:Show()
            else
                local use = entry.use
                local info = ns.GetRecipePresentation(use)
                row.recipeUse = use
                row.recipeButton:SetText(displayRecipeName(use, info))
                row.recipeButton:Show()
                if info.spellIcon then
                    row.icon:SetTexture(info.spellIcon)
                    row.icon:Show()
                end
                row.quantity:SetText(string.format(ns.L("RECIPE_QUANTITY"), use.quantity))
                row.quantity:Show()
                if use.outputItemID then
                    row.outputItemID = use.outputItemID
                    row.outputButton:SetText(info.outputName or (ns.L("ITEM_ID") .. " " .. use.outputItemID))
                    if info.outputIcon then row.outputIcon:SetTexture(info.outputIcon) row.outputIcon:Show() end
                    row.outputButton:Show()
                elseif use.kind == "enchant" then
                    row.outputButton:SetText(ns.L("RECIPE_ENCHANT_ACTION"))
                    row.outputButton:Show()
                else
                    row.outputButton:SetText(ns.L("RECIPE_OUTPUT_UNKNOWN"))
                    row.outputButton:Show()
                end
            end
        end
        if not entry or entry.kind == "heading" then row.quantity:Hide() end
    end
    if state.scrollbar then
        state.scrollbar:SetMinMaxValues(0, maxOffset)
        state.scrollbar:SetValue(state.offset)
        if maxOffset > 0 then state.scrollbar:Show() else state.scrollbar:Hide() end
    end
end

local function setOffset(offset)
    local nextOffset = math.max(0, math.min(math.floor(offset), #state.entries - state.visibleRows))
    if nextOffset ~= state.offset then
        state.offset = nextOffset
        clearHover()
        drawRows()
    end
end

function ns.RefreshRecipePanel(itemID)
    if not state.panel then return end
    local changed = itemID ~= state.selectedID
    if changed then
        state.offset = 0
        clearHover()
    end
    state.selectedID = itemID
    local count
    state.entries, count = ns.GetGroupedRecipeRows(itemID)
    state.heading:SetText(ns.L("RECIPES_HEADING"))
    state.count:SetText(string.format(ns.L("RECIPE_USE_COUNT"), count))
    if count == 0 then
        state.empty:SetText(ns.L("NO_VERIFIED_RECIPES"))
        state.empty:Show()
    else
        state.empty:Hide()
    end
    drawRows()
end

function ns.InitRecipePanel(parent, availableHeight)
    if state.panel then return end
    local heading = font(parent, "GameFontNormal")
    heading:SetPoint("TOPLEFT", parent, "TOPLEFT", 17, -152)
    state.heading = heading
    local count = font(parent, "GameFontDisableSmall")
    count:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -18, -153)
    state.count = count

    local list = CreateFrame("Frame", nil, parent)
    list:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -175)
    list:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    state.panel = list
    local empty = font(list, "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", list, "TOPLEFT", 5, -8)
    empty:SetWidth(260)
    empty:SetJustifyH("LEFT")
    state.empty = empty

    -- Recycled rows keep frame allocation independent of catalog size.
    state.visibleRows = math.max(2, math.min(7,
        math.floor((availableHeight - 188) / ROW_HEIGHT)))
    for index = 1, state.visibleRows do
        local row = CreateFrame("Frame", nil, list)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", list, "TOPLEFT", 3, -(index - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", list, "TOPRIGHT", -21, -(index - 1) * ROW_HEIGHT)
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.11, 0.09, 0.06, index % 2 == 0 and 0.65 or 0.43)
        local rule = row:CreateTexture(nil, "BORDER")
        rule:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT")
        rule:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT")
        rule:SetHeight(1)
        rule:SetColorTexture(0.44, 0.36, 0.25, 0.7)
        row.heading = font(row, "GameFontNormal")
        row.heading:SetPoint("LEFT", row, "LEFT", 6, 0)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(22, 22)
        row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -3)
        row.recipeButton = CreateFrame("Button", nil, row)
        row.recipeButton:SetPoint("TOPLEFT", row, "TOPLEFT", 30, -1)
        row.recipeButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -48, -1)
        row.recipeButton:SetHeight(21)
        row.recipeButton:SetNormalFontObject("GameFontHighlightSmall")
        local recipeText = row.recipeButton:GetFontString()
        if recipeText then recipeText:SetJustifyH("LEFT") end
        row.recipeButton:SetScript("OnEnter", function()
            if row.recipeUse then ns.ShowRecipeTooltip(row.recipeButton, row.recipeUse) end
        end)
        row.recipeButton:SetScript("OnLeave", clearHover)

        row.outputIcon = row:CreateTexture(nil, "ARTWORK")
        row.outputIcon:SetSize(14, 14)
        row.outputIcon:SetPoint("TOPLEFT", row, "TOPLEFT", 31, -24)
        row.outputButton = CreateFrame("Button", nil, row)
        row.outputButton:SetPoint("TOPLEFT", row, "TOPLEFT", 48, -23)
        row.outputButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -23)
        row.outputButton:SetHeight(18)
        row.outputButton:SetNormalFontObject("GameFontDisableSmall")
        local outputText = row.outputButton:GetFontString()
        if outputText then outputText:SetJustifyH("LEFT") end
        row.outputButton:SetScript("OnEnter", function()
            if row.outputItemID then
                ns.ShowOutputTooltip(row.outputButton, row.outputItemID)
            elseif row.recipeUse then
                ns.ShowRecipeTooltip(row.outputButton, row.recipeUse)
            end
        end)
        row.outputButton:SetScript("OnLeave", clearHover)

        row.quantity = font(row, "GameFontNormalSmall")
        row.quantity:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -4)
        row:Hide()
        state.rows[index] = row
    end

    local scrollbar = CreateFrame("Slider", nil, list, "UIPanelScrollBarTemplate")
    scrollbar:SetPoint("TOPRIGHT", list, "TOPRIGHT", -2, -2)
    scrollbar:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 2)
    scrollbar:SetWidth(15)
    scrollbar:SetValueStep(1)
    scrollbar:SetMinMaxValues(0, 0)
    scrollbar:SetScript("OnValueChanged", function(_, value)
        local offset = math.floor(value + 0.5)
        if offset ~= state.offset then setOffset(offset) end
    end)
    state.scrollbar = scrollbar
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, delta)
        setOffset(state.offset - delta * 2)
    end)
    state.entries = {}
    ns.RefreshRecipePanel(nil)
end
