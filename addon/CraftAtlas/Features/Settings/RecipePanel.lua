local _, ns = ...

-- A bounded pool of native rows, never one frame per recipe use.
local MAX_ROWS = 5
local ROW_HEIGHT = 35
local state = {selectedID = nil, page = 1, pageSize = 3, uses = {}, rows = {}}

local function font(parent, style)
    return parent:CreateFontString(nil, "OVERLAY", style)
end

local function clearHover()
    ns.HideExplorerTooltip(state.grid)
end

local function rowTitle(use, info)
    if use.outputItemID then
        if info.outputName and info.outputName ~= "" then return info.outputName end
        return ns.L("ITEM_ID") .. " " .. tostring(use.outputItemID)
    end
    if info.spellName and info.spellName ~= "" then return info.spellName end
    return ns.L("RECIPE_ID") .. " " .. tostring(use.spellID)
end

local function calculatePageSize(availableHeight)
    local _, listTop = ns.MaterialDetailSectionOffsets(availableHeight)
    -- The pager occupies the bottom 39px, with no overlap.
    return math.max(1, math.min(MAX_ROWS,
        math.floor((availableHeight + listTop - 39) / ROW_HEIGHT)))
end

local function setContentVisible()
    if not state.grid then return end
    local visible = state.visible ~= false and state.section.expanded
    local method = visible and "Show" or "Hide"
    for _, frame in ipairs({state.grid, state.previous, state.next, state.pageLabel}) do
        if frame then frame[method](frame) end
    end
end

local function renderPage()
    if not state.grid then return end
    local visible, page, pages, total =
        ns.PaginateRecipeUses(state.uses, state.page, state.pageSize)
    state.page = page
    clearHover()
    for index, row in ipairs(state.rows) do
        local use = visible[index]
        row.use = use
        if use and index <= state.pageSize then
            local info = ns.GetRecipePresentation(use)
            row.name:SetText(rowTitle(use, info))
            row.professions:SetText(ns.ProfessionLabel(use.professionKey) ..
                "  " .. string.format(ns.L("RECIPE_QUANTITY"), use.quantity))
            row.icon:SetTexture((use.outputItemID and info.outputIcon)
                or info.spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row:Show()
        else
            row:Hide()
        end
    end
    state.heading:SetText(ns.L("CRAFTABLE_USES_HEADING"))
    state.count:SetText(string.format(ns.L("CRAFTABLE_USE_COUNT"), total))
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
    if state.selectedID ~= itemID then state.page = 1 end
    state.selectedID = itemID
    state.uses = ns.GetRecipeUses(itemID)
    renderPage()
end

function ns.InitRecipePanel(parent, availableHeight)
    if state.grid then return end
    local headingY, listY = ns.MaterialDetailSectionOffsets(availableHeight)
    state.availableHeight = availableHeight
    state.pageSize = calculatePageSize(availableHeight)
    state.section = ns.CreateExplorerSection(parent, "CRAFTABLE_USES_HEADING", headingY, function()
        setContentVisible()
    end)
    state.heading = state.section.label
    state.count = font(state.section, "GameFontDisableSmall")
    state.count:SetPoint("RIGHT", state.section, "RIGHT", -31, 0)

    local grid = CreateFrame("Frame", nil, parent)
    grid:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, listY)
    grid:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 39)
    state.grid = grid
    state.empty = font(grid, "GameFontDisableSmall")
    state.empty:SetPoint("TOPLEFT", grid, "TOPLEFT", 5, -8)
    state.empty:SetPoint("TOPRIGHT", grid, "TOPRIGHT", -5, -8)
    state.empty:SetJustifyH("LEFT")

    for index = 1, MAX_ROWS do
        local row = ns.CreateExplorerRow(grid, ROW_HEIGHT, function(self, button)
            if self.use and ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) then
                ns.InsertRecipeChatLink(self.use)
                return
            end
            if self.use and ns.NavigateToRecipe then ns.NavigateToRecipe(self.use) end
        end)
        row:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", grid, "TOPRIGHT", 0, -(index - 1) * ROW_HEIGHT)
        row:SetScript("OnEnter", function(self)
            local use = self.use
            if not use then return end
            if use.outputItemID and ns.ShowOutputTooltip(self, use.outputItemID) then return end
            ns.ShowRecipeTooltip(self, use)
        end)
        row:SetScript("OnLeave", ns.HideExplorerTooltip)
        state.rows[index] = row
    end

    state.pager = ns.CreateExplorerPager(parent, function()
        if state.page > 1 then state.page = state.page - 1 renderPage() end
    end, function()
        local pages = math.ceil(#state.uses / state.pageSize)
        if state.page < pages then state.page = state.page + 1 renderPage() end
    end)
    state.previous, state.next, state.pageLabel =
        state.pager.previous, state.pager.next, state.pager.label
    ns.RefreshRecipePanel(nil)
    state.visible = true
    setContentVisible()
end

-- Reclaim unused space when the profession-use section is collapsed.
function ns.SetRecipePanelCompact(compact)
    if not state.grid or state.compact == compact then return end
    state.compact = compact
    local headingY, listY = ns.MaterialDetailSectionOffsets(state.availableHeight)
    if compact then headingY, listY = headingY + 39, listY + 39 end
    local parent = state.grid:GetParent()
    state.section:ClearAllPoints()
    state.section:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, headingY)
    state.section:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, headingY)
    state.grid:ClearAllPoints()
    state.grid:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, listY)
    state.grid:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 39)
    state.pageSize = math.max(1, math.min(MAX_ROWS,
        math.floor((state.availableHeight + listY - 39) / ROW_HEIGHT)))
    renderPage()
end

function ns.SetRecipePanelVisible(visible)
    if not state.grid then return end
    state.visible = visible
    if visible then state.section:Show() else state.section:Hide() end
    setContentVisible()
    if not visible then clearHover() end
end

function ns.GetRecipePanelPage()
    return state.page
end

function ns.SetRecipePanelPage(page)
    state.page = page or 1
    renderPage()
end
