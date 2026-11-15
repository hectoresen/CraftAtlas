local _, ns = ...

local PAGE_SIZE = 6
local state = {
    selectedID = nil,
    page = 1,
    uses = {},
    cards = {},
    columns = 3,
}

local function font(parent, style)
    return parent:CreateFontString(nil, "OVERLAY", style)
end

local function clearHover()
    if ns.HideRecipeTooltip then ns.HideRecipeTooltip() end
end

local function cardTitle(use, info)
    if use.outputItemID then
        if info.outputName and info.outputName ~= "" then return info.outputName end
        return ns.L("ITEM_ID") .. " " .. tostring(use.outputItemID)
    end
    if info.spellName and info.spellName ~= "" then return info.spellName end
    return ns.L("RECIPE_ID") .. " " .. tostring(use.spellID)
end

local function layoutCards()
    if not state.grid then return end
    local width = math.max(1, state.grid:GetWidth())
    local height = math.max(1, state.grid:GetHeight())
    local columns = width < 210 and 2 or 3
    local rows = PAGE_SIZE / columns
    local gap = 6
    local cardWidth = math.max(1, math.floor((width - (columns - 1) * gap) / columns))
    local cardHeight = math.max(1, math.floor((height - (rows - 1) * gap) / rows))
    state.columns = columns

    for index, card in ipairs(state.cards) do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", state.grid, "TOPLEFT",
            column * (cardWidth + gap), -row * (cardHeight + gap))
        card:SetSize(cardWidth, cardHeight)

        card.icon:ClearAllPoints()
        local iconSize = math.min(34, math.max(18, math.floor(cardHeight * 0.37)))
        card.icon:SetSize(iconSize, iconSize)
        card.icon:SetPoint("TOP", card, "TOP", 0, -5)

        card.name:ClearAllPoints()
        card.name:SetPoint("TOPLEFT", card, "TOPLEFT", 4, -(iconSize + 8))
        card.name:SetPoint("TOPRIGHT", card, "TOPRIGHT", -4, -(iconSize + 8))
        card.name:SetHeight(math.max(14, math.min(27, cardHeight - iconSize - 27)))
        card.meta:ClearAllPoints()
        card.meta:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 3, 5)
        card.meta:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 5)
        card.meta:SetHeight(13)
    end
end

local function renderPage()
    if not state.grid then return end
    local visible, page, pages, total =
        ns.PaginateRecipeUses(state.uses, state.page, PAGE_SIZE)
    state.page = page
    clearHover()

    for index, card in ipairs(state.cards) do
        local use = visible[index]
        card.use = use
        if use then
            local info = ns.GetRecipePresentation(use)
            card.name:SetText(cardTitle(use, info))
            card.meta:SetText(ns.ProfessionLabel(use.professionKey) ..
                "  " .. string.format(ns.L("RECIPE_QUANTITY"), use.quantity))
            card.icon:SetTexture(
                (use.outputItemID and info.outputIcon)
                or info.spellIcon
                or "Interface\\Icons\\INV_Misc_QuestionMark")
            card:Show()
        else
            card.name:SetText("")
            card.meta:SetText("")
            card.icon:SetTexture(nil)
            card:Hide()
        end
    end

    state.heading:SetText(ns.L("RECIPES_HEADING"))
    state.count:SetText(string.format(ns.L("RECIPE_USE_COUNT"), total))
    ns.UpdateExplorerPager(state.pager, page, pages)
    if total == 0 then
        state.empty:SetText(ns.L("NO_VERIFIED_RECIPES"))
        state.empty:Show()
    else
        state.empty:Hide()
    end
end

function ns.RefreshRecipePanel(itemID)
    if not state.grid then return end
    if state.selectedID ~= itemID then
        state.page = 1
    end
    state.selectedID = itemID
    state.uses = ns.GetRecipeUses(itemID)
    renderPage()
end

function ns.HideRecipePanelTooltip()
    clearHover()
end

function ns.InitRecipePanel(parent, availableHeight)
    if state.grid then return end

    local compact = availableHeight < 370
    local headingY = compact and -119 or -142
    local gridY = compact and -141 or -164

    state.heading = font(parent, "GameFontNormal")
    state.heading:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, headingY)
    state.count = font(parent, "GameFontDisableSmall")
    state.count:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, headingY - 1)

    local grid = CreateFrame("Frame", nil, parent)
    grid:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, gridY)
    grid:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 39)
    state.grid = grid

    state.empty = font(grid, "GameFontDisableSmall")
    state.empty:SetPoint("TOPLEFT", grid, "TOPLEFT", 5, -8)
    state.empty:SetPoint("TOPRIGHT", grid, "TOPRIGHT", -5, -8)
    state.empty:SetJustifyH("LEFT")

    for index = 1, PAGE_SIZE do
        local card = CreateFrame("Button", nil, grid)
        card:EnableMouse(true)

        local surface = card:CreateTexture(nil, "BACKGROUND")
        surface:SetAllPoints()
        surface:SetColorTexture(0.12, 0.10, 0.07, 0.90)

        local edge = card:CreateTexture(nil, "BORDER")
        edge:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0, 0)
        edge:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", 0, 0)
        edge:SetHeight(2)
        edge:SetColorTexture(0.58, 0.45, 0.26, 0.9)
        local hover = card:CreateTexture(nil, "BACKGROUND")
        hover:SetAllPoints()
        hover:SetColorTexture(0.39, 0.30, 0.15, 0.48)
        card:SetHighlightTexture(hover)

        card.icon = card:CreateTexture(nil, "ARTWORK")
        card.name = font(card, "GameFontHighlightSmall")
        card.name:SetJustifyH("CENTER")
        card.name:SetWordWrap(false)
        card.meta = font(card, "GameFontDisableSmall")
        card.meta:SetJustifyH("CENTER")
        card.meta:SetWordWrap(false)
        card:SetScript("OnEnter", function(self)
            local use = self.use
            if not use then return end
            if use.outputItemID then
                if not ns.ShowOutputTooltip(self, use.outputItemID) then
                    ns.ShowRecipeTooltip(self, use)
                end
            else
                ns.ShowRecipeTooltip(self, use)
            end
        end)
        card:SetScript("OnLeave", clearHover)
        card:SetScript("OnClick", function(self)
            if self.use and ns.NavigateToRecipe then ns.NavigateToRecipe(self.use) end
        end)
        state.cards[index] = card
    end

    local pager = ns.CreateExplorerPager(parent, function()
        if state.page > 1 then state.page = state.page - 1 renderPage() end
    end, function()
        local pages = math.ceil(#state.uses / PAGE_SIZE)
        if state.page < pages then state.page = state.page + 1 renderPage() end
    end)
    state.pager = pager
    state.previous, state.next, state.pageLabel = pager.previous, pager.next, pager.label

    grid:SetScript("OnSizeChanged", function()
        layoutCards()
    end)
    layoutCards()
    ns.RefreshRecipePanel(nil)
end

function ns.SetRecipePanelVisible(visible)
    if not state.grid then return end
    local method = visible and "Show" or "Hide"
    for _, frame in ipairs({state.grid, state.heading, state.count,
        state.previous, state.next, state.pageLabel}) do
        frame[method](frame)
    end
    if not visible then clearHover() end
end

function ns.GetRecipePanelPage()
    return state.page
end

function ns.SetRecipePanelPage(page)
    state.page = page or 1
    renderPage()
end
