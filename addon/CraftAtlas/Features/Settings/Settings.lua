local _, ns = ...
local panel
local ui = {}
local searchQuery = ""
local selectedID
local selectedProfession = ""
local results = {}
local treeEntries = {}
local treeState = ns.NewProfessionTreeState and ns.NewProfessionTreeState()
    or {expanded = {}, searchOverrides = {}}
local unresolved = 0
local scrollOffset = 0
local currentView = "materials"
local selectedRecipe
local switching = false
local catalogGenerations = {materials = 0, recipes = 0}
local cachedSearch = {materials = nil, recipes = nil}
local refreshGate
local catalogMetrics = {materialsSearch = 0, recipesSearch = 0,
    materialProjections = 0, fullRefreshes = 0, backgroundRefreshes = 0}
local forcedSelection = false
local viewState = {
    materials = {query = "", profession = "", selected = nil, offset = 0},
    recipes = {query = "", profession = "", selected = nil, offset = 0},
}
local history = {}
local switchView
local ROW_HEIGHT = 34
local VISIBLE_ROWS = 6
local WINDOW_NAME = "CraftAtlasSettingsFrame"
local ESCAPE_FRAME_NAME = "CraftAtlasExplorerEscapeFrame"
local PROFESSION_POPUP = "CraftAtlasProfessionPopup"
local CONTENT_TOP, CONTENT_BOTTOM = 68, 36
local LIST_TOP, LIST_BOTTOM = 64, 18
-- Keep the explorer above the HUD and ordinary panels, below native tooltips.
local WINDOW_STRATA = "DIALOG"
local TAB_HEIGHT = 37

local function font(parent, fontName)
    return parent:CreateFontString(nil, "OVERLAY", fontName)
end

local function addPanelBackground(parent)
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    texture:SetVertexColor(0.09, 0.09, 0.09, 0.96)
end

local function labelProfession(key)
    return ns.ProfessionLabel(key)
end

local function containsSelected()
    for index, itemID in ipairs(results) do
        if itemID == selectedID then return index end
    end
end

local function refreshProfessionDetail()
    if not ui.professionUses then return end
    local state = ui.professionUses
    if ns.SetRecipePanelCompact then ns.SetRecipePanelCompact(not state.section.expanded) end
    local width = type(state.parent.GetWidth) == "function" and state.parent:GetWidth() or 0
    local pageSize = ns.ExplorerProfessionPageSize(width)
    if state.pageSize ~= pageSize or state.lastWidth ~= width then
        state.pageSize, state.lastWidth = pageSize, width
        state.page = math.min(state.page, math.max(1, math.ceil(#state.keys / pageSize)))
        local columnWidth = math.max(0, width - 36) / pageSize
        for i, cell in ipairs(state.cells) do
            cell:ClearAllPoints()
            cell:SetPoint("TOPLEFT", state.parent, "TOPLEFT",
                18 + (i - 1) * columnWidth, -124)
            cell:SetSize(columnWidth, 29)
        end
    end
    local first = (state.page - 1) * state.pageSize + 1
    for i, cell in ipairs(state.cells) do
        local key = state.keys[first + i - 1]
        if i <= state.pageSize and key and state.section.expanded then
            cell.icon:SetTexture(ns.GetExplorerProfessionIcon(key))
            cell.label:SetText(labelProfession(key))
            cell:Show()
        else
            cell:Hide()
        end
    end
    local pages = math.max(1, math.ceil(#state.keys / state.pageSize))
    state.previous:SetEnabled(state.section.expanded and state.page > 1)
    state.next:SetEnabled(state.section.expanded and state.page < pages)
    if state.section.expanded and pages > 1 then
        state.previous:Show()
        state.next:Show()
    else
        state.previous:Hide()
        state.next:Hide()
    end
end

local function createProfessionDetail(right)
    local width = type(right.GetWidth) == "function" and right:GetWidth() or 0
    local pageSize = ns.ExplorerProfessionPageSize(width)
    local state = {keys = {}, page = 1, pageSize = pageSize, parent = right, cells = {}}
    ui.professionUses = state
    state.section = ns.CreateExplorerSection(right, "USED_BY", -92, function()
        refreshProfessionDetail()
    end)
    -- Proportional columns: four professions in one row at normal width,
    -- two at compact scales. Only page when the real list exceeds capacity.
    local innerWidth = math.max(0, width - 36)
    local columnWidth = innerWidth / pageSize
    for i = 1, 4 do
        local cell = CreateFrame("Frame", nil, right)
        cell:SetPoint("TOPLEFT", right, "TOPLEFT",
            18 + (i - 1) * columnWidth, -124)
        cell:SetSize(columnWidth, 29)
        cell.icon = cell:CreateTexture(nil, "ARTWORK")
        cell.icon:SetSize(25, 25)
        cell.icon:SetPoint("LEFT", cell, "LEFT", 0, 0)
        cell.label = font(cell, "GameFontHighlightSmall")
        cell.label:SetPoint("LEFT", cell.icon, "RIGHT", 7, 0)
        cell.label:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
        cell.label:SetJustifyH("LEFT")
        cell.label:SetWordWrap(false)
        state.cells[i] = cell
    end
    for _, direction in ipairs({"previous", "next"}) do
        local button = CreateFrame("Button", nil, state.section, "UIPanelButtonTemplate")
        button:SetSize(21, 19)
        button:SetPoint("RIGHT", state.section, "RIGHT", direction == "previous" and -77 or -50, 0)
        button:SetText(direction == "previous" and "<" or ">")
        button:SetScript("OnClick", function()
            state.page = state.page + (direction == "previous" and -1 or 1)
            refreshProfessionDetail()
        end)
        state[direction] = button
    end
    -- Reflow against the final pane width, even if layout was unresolved at construction.
    refreshProfessionDetail()
end

local function showDetail()
    if not ui.detailTitle then return end
    if currentView == "recipes" then
        ns.SetRecipeDetail(selectedRecipe)
        return
    end
    local itemID = selectedID
    local valid = itemID and ns.IsVerifiedReagent(itemID)
    ui.detailIcon:Hide()
    if not valid then
        ui.detailTitle:SetText(ns.L("SELECT_MATERIAL"))
        ui.detailTitle:SetTextColor(1, 1, 1)
        ui.detailMeta:SetText("")
        ui.detailID:SetText("")
        ui.professionUses.keys = {}
        ui.professionUses.page = 1
        refreshProfessionDetail()
        ns.RefreshRecipePanel(nil)
        return
    end
    local name, icon = ns.GetMaterialDisplay(itemID)
    if icon then
        ui.detailIcon:SetTexture(icon)
        ui.detailIcon:Show()
    end
    ui.detailTitle:SetText(name or (ns.L("ITEM_ID") .. " " .. itemID))
    ui.detailID:SetText(ns.L("ITEM_ID") .. ": " .. itemID)
    local metadata = ns.GetItemMetadata(itemID)
    local details = {}
    if metadata then
        if metadata.itemType then details[#details + 1] = metadata.itemType end
        if metadata.level then
            details[#details + 1] = string.format(ns.L("ITEM_LEVEL"), metadata.level)
        end
    end
    ui.detailMeta:SetText(table.concat(details, "  |  "))
    local colors = type(ITEM_QUALITY_COLORS) == "table" and ITEM_QUALITY_COLORS or nil
    local qualityColor = metadata and colors and colors[metadata.quality]
    if qualityColor and qualityColor.r and qualityColor.g and qualityColor.b then
        ui.detailTitle:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
    else
        ui.detailTitle:SetTextColor(1, 1, 1)
    end
    -- The profession section owns its localized heading; no legacy detailHeading frame.
    ui.professionUses.section:Refresh()
    local keys = ns.FindProfessions(itemID, ns.materials, ns.professionOrder)
    local professionState = ui.professionUses
    if professionState.itemID ~= itemID then professionState.page = 1 end
    professionState.itemID = itemID
    professionState.keys = keys
    refreshProfessionDetail()
    ns.RefreshRecipePanel(itemID)
end

local function updateRows()
    if not ui.rows then return end
    local count = currentView == "materials" and #treeEntries or #results
    scrollOffset = math.min(scrollOffset, math.max(0, count - VISIBLE_ROWS))
    for index, row in ipairs(ui.rows) do
        local entry = currentView == "materials" and treeEntries[index + scrollOffset] or nil
        local itemID = entry and entry.itemID or (currentView == "recipes" and results[index + scrollOffset])
        if entry and not itemID then
            row.itemID = nil
            row.groupKey = entry.group
            local collapsed = (searchQuery ~= "" and treeState.searchOverrides[entry.group] == false)
                or (searchQuery == "" and treeState.expanded[entry.group] == false)
            ns.StyleExplorerGroupRow(row, labelProfession(entry.group), entry.count, not collapsed)
            row:Show()
        elseif itemID then
            ns.StyleExplorerItemRow(row, currentView == "materials")
            row.groupKey = nil
            local name, icon, subtitle
            if currentView == "recipes" then
                local recipe = ns.GetCatalogRecipe(itemID)
                local spellName, spellIcon = ns.GetRecipeSpellPresentation(recipe.spellID)
                local outputName, outputIcon
                if recipe.outputItemID then
                    outputName, outputIcon = ns.GetItemDisplay(recipe.outputItemID)
                end
                name = outputName or spellName or (ns.L("RECIPE_ID") .. " " .. recipe.spellID)
                icon = outputIcon or spellIcon
                subtitle = ns.ProfessionLabel(recipe.professionKey)
            else
                name, icon = ns.GetMaterialDisplay(itemID)
                local professions = {}
                for _, key in ipairs(ns.FindProfessions(itemID, ns.materials, ns.professionOrder)) do
                    professions[#professions + 1] = labelProfession(key)
                end
                subtitle = table.concat(professions, ", ")
            end
            row.itemID = itemID
            row.name:SetText(name or (ns.L("ITEM_ID") .. " " .. tostring(itemID)))
            row.professions:SetText(subtitle or "")
            if icon then row.icon:SetTexture(icon) row.icon:Show() else row.icon:Hide() end
            if (currentView == "recipes" and itemID == selectedRecipe)
                or (currentView == "materials" and itemID == selectedID) then
                row.highlight:Show()
            else
                row.highlight:Hide()
            end
            row:Show()
        else
            row.itemID = nil
            row.groupKey = nil
            row:Hide()
        end
    end
    if ui.scrollbar then
        ui.scrollbar:SetMinMaxValues(0, math.max(0, count - VISIBLE_ROWS))
        ui.scrollbar:SetValue(scrollOffset)
        if count > VISIBLE_ROWS then ui.scrollbar:Show() else ui.scrollbar:Hide() end
    end
    ui.count:SetText(string.format(ns.L("RESULT_COUNT"), #results))
    if unresolved > 0 then
        if currentView == "recipes" then
            ui.incomplete:SetText(ns.L("RECIPE_NAME_RESULTS_INCOMPLETE"))
        else
            local loaded, pending = ns.GetMaterialLoadProgress()
            if pending > 0 or loaded < 1 then
                ui.incomplete:SetText(string.format(ns.L("LOADING_ITEMS"), loaded))
            else
                ui.incomplete:SetText(ns.L("NAME_RESULTS_INCOMPLETE"))
            end
        end
        ui.incomplete:Show()
    else
        ui.incomplete:Hide()
    end
    if count == 0 then
        ui.empty:SetText(currentView == "recipes"
            and (unresolved > 0 and ns.L("LOADING_RECIPE_NAMES") or ns.L("NO_RECIPES_FOUND"))
            or (unresolved > 0 and ns.L("LOADING_ITEM_NAMES") or ns.L("NO_RESULTS")))
        ui.empty:Show()
    else
        ui.empty:Hide()
    end
end

local function refreshResults(resetOffset)
    catalogMetrics.fullRefreshes = catalogMetrics.fullRefreshes + 1
    local locale = ns.ResolveLocale(ns.GetLanguage(), ns.GetClientLocale())
    local cache = cachedSearch[currentView]
    if cache and cache.query == searchQuery and cache.profession == selectedProfession
        and cache.locale == locale and cache.generation == catalogGenerations[currentView] then
        results, unresolved = cache.results, cache.unresolved
    else
        local labels = {}
        for _, key in ipairs(ns.professionOrder or {}) do labels[key] = ns.ProfessionLabel(key) end
        local numberQuery = string.match(searchQuery, "^%d+$") ~= nil and searchQuery ~= ""
        if currentView == "recipes" then
            results, unresolved = ns.SearchCatalogRecipes(searchQuery, selectedProfession,
                ns.GetRecipeNames(), ns.GetKnownMaterialNames(), labels)
            catalogMetrics.recipesSearch = catalogMetrics.recipesSearch + 1
        else
            results, unresolved = ns.FilterMaterials(ns.materials, ns.professionOrder,
                searchQuery, selectedProfession, ns.GetKnownMaterialNames(),
                not numberQuery, labels, ns.recipeUses)
            catalogMetrics.materialsSearch = catalogMetrics.materialsSearch + 1
        end
        cachedSearch[currentView] = {
            results = results, unresolved = unresolved, query = searchQuery,
            profession = selectedProfession, locale = locale,
            generation = catalogGenerations[currentView]
        }
    end
    if currentView == "materials" then
        -- The tree is a cheap projection of the cached filtered list and live collapse state.
        local groups = ns.BuildProfessionGroups(results, ns.materials, ns.professionOrder)
        treeEntries = ns.FlattenProfessionGroups(groups, treeState, searchQuery ~= "")
        catalogMetrics.materialProjections = catalogMetrics.materialProjections + 1
    end
    local selected = currentView == "recipes" and selectedRecipe or selectedID
    local index
    local visible = currentView == "materials" and treeEntries or results
    for i, key in ipairs(visible) do
        if (currentView == "materials" and key.itemID == selected)
            or (currentView == "recipes" and key == selected) then index = i break end
    end
    local stillMatches = false
    for _, key in ipairs(results) do
        if key == selected then stillMatches = true break end
    end
    if not stillMatches and not forcedSelection then
        selected = results[1]
        if currentView == "materials" then
            for _, entry in ipairs(treeEntries) do
                if entry.itemID then selected = entry.itemID break end
            end
        end
        index = nil
    end
    if currentView == "recipes" then selectedRecipe = selected else selectedID = selected end
    if resetOffset then scrollOffset = 0 end
    if index and resetOffset and (index <= scrollOffset or index > scrollOffset + VISIBLE_ROWS) then
        scrollOffset = math.max(0, index - 1)
    end
    updateRows()
    showDetail()
end

local function showCatalogProgress()
    if not ui.preparation then return end
    local progress = currentView == "recipes" and
        (ns.GetRecipePreparation and ns.GetRecipePreparation()) or
        (currentView == "materials" and ns.GetMaterialPreparation and ns.GetMaterialPreparation())
    if not progress or (progress.status ~= "active" and progress.status ~= "incomplete") then
        ui.preparation:SetProgress("complete", 100, "")
        return
    end
    local percent = ns.CatalogPercent(progress)
    local caption
    if progress.status == "incomplete" then
        caption = ns.L("CATALOG_PREPARATION_PAUSED")
    else
        caption = string.format(ns.L(currentView == "materials"
            and "CATALOG_PREPARING_MATERIALS" or "CATALOG_PREPARING_CRAFTABLES"), percent)
    end
    ui.preparation:SetProgress(progress.status, percent, caption)
end

-- Batch/event callbacks never run a whole search immediately. At most one
-- visible redraw is scheduled per 0.4 s window; direct user actions stay immediate.
function ns.OnCatalogDataChanged(_source)
    catalogGenerations.materials = catalogGenerations.materials + 1
    catalogGenerations.recipes = catalogGenerations.recipes + 1
    if not panel or not panel:IsShown() then return end
    if not refreshGate then refreshGate = ns.NewCatalogRefreshGate() end
    if not ns.MarkCatalogRefreshDirty(refreshGate) then return end
    local function flush()
        if ns.ConsumeCatalogRefresh(refreshGate) and panel and panel:IsShown() then
            catalogMetrics.backgroundRefreshes = catalogMetrics.backgroundRefreshes + 1
            refreshResults(false)
        end
    end
    local timer = C_Timer and C_Timer.After
    if type(timer) == "function" then
        local ok = pcall(timer, 0.4, flush)
        if ok then return end
    end
    -- Missing timers cannot keep deferred changes pending indefinitely.
    flush()
end

function ns.OnCatalogProgressChanged(view)
    if view == currentView then showCatalogProgress() end
end

function ns.GetCatalogPerformanceSnapshot()
    return {
        materialsSearch = catalogMetrics.materialsSearch,
        recipesSearch = catalogMetrics.recipesSearch,
        materialProjections = catalogMetrics.materialProjections,
        fullRefreshes = catalogMetrics.fullRefreshes,
        backgroundRefreshes = catalogMetrics.backgroundRefreshes
    }
end

local function createProfessionMenu(left)
    local button, menu, choices = ns.CreateExplorerProfessionFilter(left, function(key)
        selectedProfession = key
        forcedSelection = false
        ui.professionButton:SetText(key == "" and ns.L("ALL_PROFESSIONS") or labelProfession(key))
        refreshResults(true)
    end, function() return selectedProfession end, PROFESSION_POPUP)
    ui.professionButton, ui.professionMenu, ui.professionChoices = button, menu, choices
end

local function updateRowsAfterGroupToggle()
    local groups = ns.BuildProfessionGroups(results, ns.materials, ns.professionOrder)
    treeEntries = ns.FlattenProfessionGroups(groups, treeState, searchQuery ~= "")
    updateRows()
end

local function createRows(left)
    local list = CreateFrame("Frame", nil, left)
    list:SetPoint("TOPLEFT", left, "TOPLEFT", 4, -LIST_TOP)
    list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -2, LIST_BOTTOM)
    if list.SetClipsChildren then list:SetClipsChildren(true) end
    ui.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = ns.CreateExplorerRow(list, ROW_HEIGHT, function(self, button)
            if ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) and self.itemID then
                if currentView == "recipes" then
                    ns.InsertRecipeChatLink(ns.GetCatalogRecipe(self.itemID))
                else
                    ns.InsertEntityChatLink("item", self.itemID)
                end
                return
            end
            if currentView == "materials" and self.groupKey and not self.itemID then
                ns.ToggleProfessionTreeGroup(treeState, self.groupKey, searchQuery ~= "")
                updateRowsAfterGroupToggle()
                return
            end
            forcedSelection = false
            if currentView == "recipes" then selectedRecipe = self.itemID
            else selectedID = self.itemID end
            updateRows()
            showDetail()
        end, true)
        row:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -(index - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", list, "TOPRIGHT", -19, -(index - 1) * ROW_HEIGHT)
        ui.rows[index] = row
    end

    local scrollbar = CreateFrame("Slider", nil, list, "UIPanelScrollBarTemplate")
    scrollbar:SetPoint("TOPRIGHT", list, "TOPRIGHT", -2, -18)
    scrollbar:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 18)
    scrollbar:SetWidth(16)
    scrollbar:SetMinMaxValues(0, 0)
    scrollbar:SetValueStep(1)
    scrollbar:SetScript("OnValueChanged", function(self, value)
        local offset = math.floor(value + 0.5)
        if offset ~= scrollOffset then
            scrollOffset = offset
            updateRows()
        end
    end)
    ui.scrollbar = scrollbar
    left:EnableMouseWheel(true)
    left:SetScript("OnMouseWheel", function(_, delta)
        local total = currentView == "materials" and #treeEntries or #results
        scrollOffset = math.max(0, math.min(total - VISIBLE_ROWS, scrollOffset - delta * 2))
        scrollOffset = math.max(0, scrollOffset)
        updateRows()
    end)
end

-- WoW's standard close script can expect managed UIPanel registration.
-- CraftAtlas is standalone: always hide its own frame explicitly.
function ns.BindExplorerClose(window)
    local close = window.ClosePanelButton or window.CloseButton
    if not close then
        close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
    end
    window.CloseButton = close
    close:SetScript("OnClick", function()
        window:Hide()
    end)
    close:Show()
    return close
end

local function registerFrameName(registry, name)
    if type(registry) ~= "table" then return end
    for _, registered in ipairs(registry) do
        if registered == name then return end
    end
    registry[#registry + 1] = name
end

local function bindExplorerEscape(window, search)
    local function dismiss()
        if not window:IsVisible() then return false end
        if ui.professionMenu:IsShown() then
            ui.professionMenu:Hide()
        else
            window:Hide()
        end
        return true
    end
    if type(UISpecialFrames) == "table" then
        -- The native special-window close path can hide this addon-owned frame safely.
        -- Re-arm it if only a fallback popup was dismissed.
        local escapeFrame = CreateFrame("Frame", ESCAPE_FRAME_NAME, window)
        escapeFrame:Hide()
        escapeFrame:SetScript("OnHide", function(self)
            if dismiss() and window:IsVisible() then self:Show() end
        end)
        window:HookScript("OnShow", function() escapeFrame:Show() end)
        window:HookScript("OnHide", function() escapeFrame:Hide() end)
        registerFrameName(UISpecialFrames, ESCAPE_FRAME_NAME)
    end
    search:SetScript("OnEscapePressed", dismiss)
end

-- Templates can specify their own strata, including for nested controls.
local function alignFrameStrata(frame, strata)
    if frame.GetFrameStrata and frame:GetFrameStrata() ~= strata then
        frame:SetFrameStrata(strata)
    end
    if not frame.GetChildren then return end
    for _, child in ipairs({frame:GetChildren()}) do
        alignFrameStrata(child, strata)
    end
end

local function createPanel()
    if panel then return panel end
    local ok, window = pcall(CreateFrame, "Frame", WINDOW_NAME, UIParent, "SettingsFrameTemplate")
    if not ok or not window then
        ok, window = pcall(CreateFrame, "Frame", WINDOW_NAME, UIParent, "BasicFrameTemplate")
        if not ok or not window then
            window = CreateFrame("Frame", WINDOW_NAME, UIParent)
            addPanelBackground(window)
        end
    end
    panel = window
    local scale = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 800
    local height = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 600
    local logicalWidth, logicalHeight, uiScale = ns.ExplorerWindowGeometry(scale, height)
    panel:SetSize(logicalWidth, logicalHeight)
    panel:SetScale(uiScale)
    local contentHeight = logicalHeight - CONTENT_TOP - CONTENT_BOTTOM - 6
    VISIBLE_ROWS = ns.ExplorerVisibleRowCount(contentHeight - LIST_TOP - LIST_BOTTOM, ROW_HEIGHT)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata(WINDOW_STRATA)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    panel:Hide()
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT")
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT")
    header:SetHeight(24)

    local title = (panel.NineSlice and panel.NineSlice.Text) or panel.TitleText or font(panel, "GameFontNormal")
    title:ClearAllPoints()
    title:SetPoint("CENTER", header, "CENTER", 0, 0)
    ui.title = title

    local search = ns.CreateExplorerSearchBox(panel, function(value)
        if switching or value == searchQuery then return end
        if value == "" and searchQuery ~= "" then ns.ClearProfessionTreeSearch(treeState) end
        if value ~= "" and searchQuery == "" then ns.ClearProfessionTreeSearch(treeState) end
        searchQuery = value
        forcedSelection = false
        refreshResults(true)
    end)
    search:SetSize(math.min(290, math.floor(logicalWidth * 0.36)), 24)
    search:ClearAllPoints()
    search:SetPoint("RIGHT", panel, "TOPRIGHT", -24, -CONTENT_TOP + TAB_HEIGHT / 2)
    ui.search = search
    local hint = font(panel, "GameFontDisableSmall")
    hint:SetPoint("LEFT", search, "LEFT", search.searchIcon and 19 or 7, 0)
    hint:SetPoint("RIGHT", search, "RIGHT", -22, 0)
    hint:SetJustifyH("LEFT")
    hint:SetWordWrap(false)
    hint:SetText(ns.L("SEARCH_PLACEHOLDER"))
    hint:SetTextColor(0.70, 0.67, 0.60)
    ui.searchHint = hint
    search:HookScript("OnTextChanged", function(self)
        if self:GetText() == "" then hint:Show() else hint:Hide() end
    end)
    search:HookScript("OnEditFocusGained", function() hint:Hide() end)
    search:HookScript("OnEditFocusLost", function()
        if search:GetText() == "" then hint:Show() end
    end)
    local clear = ns.CreateExplorerSearchClear(search)
    clear:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(ns.L("CLEAR_SEARCH"))
            GameTooltip:Show()
        end
    end)
    clear:SetScript("OnLeave", ns.HideExplorerTooltip)
    ui.clear = clear
    ui.clearIcon = clear.icon
    local materialsTab = ns.CreateExplorerTab(panel)
    materialsTab:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 24, -CONTENT_TOP)
    materialsTab:SetHeight(TAB_HEIGHT)
    materialsTab:SetScript("OnClick", function() switchView("materials") end)
    local recipesTab = ns.CreateExplorerTab(panel)
    recipesTab:SetPoint("LEFT", materialsTab, "RIGHT", 8, 0)
    recipesTab:SetHeight(TAB_HEIGHT)
    recipesTab:SetScript("OnClick", function() switchView("recipes") end)
    local back = ns.CreateExplorerClassicButton(panel)
    back:SetPoint("RIGHT", search, "LEFT", -12, 0)
    back:SetSize(76, 26)
    back:SetScript("OnClick", function()
        local entry = table.remove(history)
        if entry then
            switchView(entry.view, entry.selected, true, true)
        end
    end)
    ui.materialsTab, ui.recipesTab, ui.back = materialsTab, recipesTab, back
    ui.preparation = ns.CreateExplorerCatalogProgress(panel)

    local hasInset, content = pcall(CreateFrame, "Frame", nil, panel, "InsetFrameTemplate")
    if not hasInset or not content then
        content = CreateFrame("Frame", nil, panel)
    elseif content.Bg then
        content.Bg:Hide()
    end
    content:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -CONTENT_TOP)
    content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -12, CONTENT_BOTTOM)
    local innerSurface = content:CreateTexture(nil, "BACKGROUND")
    innerSurface:SetAllPoints()
    innerSurface:SetColorTexture(0.07, 0.045, 0.025, 0.3)
    local innerBorder = content:CreateTexture(nil, "BORDER")
    if innerBorder.SetAtlas then
        innerBorder:SetAllPoints()
        innerBorder:SetAtlas("Options_InnerFrame")
        if content.NineSlice then content.NineSlice:Hide() end
    end
    local left = CreateFrame("Frame", nil, content)
    left:SetPoint("TOPLEFT", content, "TOPLEFT", 3, -3)
    left:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 3, 3)
    left:SetWidth(math.floor((logicalWidth - 24) * 0.36))
    local sidebar = left:CreateTexture(nil, "BACKGROUND")
    sidebar:SetAllPoints()
    sidebar:SetColorTexture(0.08, 0.05, 0.03, 0.46)
    local divider = content:CreateTexture(nil, "BORDER")
    divider:SetPoint("TOPLEFT", left, "TOPRIGHT")
    divider:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT")
    divider:SetWidth(1)
    divider:SetColorTexture(0.52, 0.35, 0.17, 0.55)
    local right = CreateFrame("Frame", nil, content)
    right:SetPoint("TOPLEFT", left, "TOPRIGHT", 8, 0)
    right:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -3, 3)
    createProfessionMenu(left)

    local count = font(left, "GameFontHighlightSmall")
    count:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -44)
    ui.count = count
    local incomplete = font(left, "GameFontDisableSmall")
    incomplete:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 10, 5)
    incomplete:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 5)
    incomplete:SetJustifyH("LEFT")
    ui.incomplete = incomplete
    local empty = font(left, "GameFontHighlight")
    empty:SetPoint("TOPLEFT", left, "TOPLEFT", 12, -72)
    ui.empty = empty
    createRows(left)

    local detailIcon = right:CreateTexture(nil, "ARTWORK")
    detailIcon:SetSize(52, 52)
    detailIcon:SetPoint("TOPLEFT", right, "TOPLEFT", 16, -16)
    ui.detailIcon = detailIcon
    local materialLink = CreateFrame("Button", nil, right)
    materialLink:SetPoint("TOPLEFT", right, "TOPLEFT", 13, -13)
    materialLink:SetSize(59, 58)
    materialLink:SetScript("OnClick", function(_, button)
        if selectedID and ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) then
            ns.InsertEntityChatLink("item", selectedID)
        end
    end)
    ui.materialLink = materialLink
    local detailTitle = font(right, "GameFontHighlightLarge")
    detailTitle:SetPoint("TOPLEFT", right, "TOPLEFT", 75, -19)
    detailTitle:SetPoint("TOPRIGHT", right, "TOPRIGHT", -12, -19)
    detailTitle:SetJustifyH("LEFT")
    ui.detailTitle = detailTitle
    local materialTitleLink = CreateFrame("Button", nil, right)
    materialTitleLink:SetPoint("TOPLEFT", right, "TOPLEFT", 74, -16)
    materialTitleLink:SetPoint("TOPRIGHT", right, "TOPRIGHT", -11, -16)
    materialTitleLink:SetHeight(27)
    materialTitleLink:SetScript("OnClick", function(_, button)
        if selectedID and ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) then
            ns.InsertEntityChatLink("item", selectedID)
        end
    end)
    ui.materialTitleLink = materialTitleLink
    local detailID = font(right, "GameFontDisableSmall")
    detailID:SetPoint("TOPLEFT", right, "TOPLEFT", 75, -42)
    ui.detailID = detailID
    local detailMeta = font(right, "GameFontDisableSmall")
    detailMeta:SetPoint("TOPLEFT", right, "TOPLEFT", 17, -74)
    detailMeta:SetPoint("TOPRIGHT", right, "TOPRIGHT", -12, -74)
    detailMeta:SetJustifyH("LEFT")
    detailMeta:SetWordWrap(false)
    ui.detailMeta = detailMeta
    createProfessionDetail(right)
    ns.InitRecipePanel(right, contentHeight)
    ns.InitRecipeDetail(right)

    local version = ns.GetInstalledReleaseVersion(ns.name)
    if version then
        local caption = font(panel, "GameFontDisableSmall")
        caption:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -18, 12)
        caption:SetText(version)
    end

    ui.itemListener = CreateFrame("Frame", nil, panel)
    ui.itemListener:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    ui.itemListener:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    -- Some Classic clients emit spell-data events; absence is not an error.
    pcall(ui.itemListener.RegisterEvent, ui.itemListener, "SPELL_DATA_LOAD_RESULT")
    ui.itemListener:SetScript("OnEvent", function(_, event, itemID, success)
        if event == "SPELL_DATA_LOAD_RESULT" then
            if ns.UpdateRecipeName then ns.UpdateRecipeName(itemID) end
        elseif ns.UpdateMaterialInfo(itemID, success) then
            ns.OnCatalogDataChanged("materials")
        end
    end)
    panel:SetScript("OnHide", function()
        ui.professionMenu:Hide()
        ui.search:ClearFocus()
        ns.HideExplorerTooltip(panel)
    end)
    ns.BindExplorerClose(panel)
    bindExplorerEscape(panel, search)
    alignFrameStrata(panel, WINDOW_STRATA)
    return panel
end

local function showActiveDetail()
    local material = currentView == "materials"
    if ui.materialLink then
        if material then
            ui.materialLink:Show()
            ui.materialTitleLink:Show()
        else
            ui.materialLink:Hide()
            ui.materialTitleLink:Hide()
        end
    end
    for _, element in ipairs({ui.detailIcon, ui.detailTitle, ui.detailID, ui.detailMeta,
        ui.professionUses.section}) do
        if material then element:Show() else element:Hide() end
    end
    if not material then
        for _, cell in ipairs(ui.professionUses.cells) do cell:Hide() end
        ui.professionUses.previous:Hide()
        ui.professionUses.next:Hide()
    else
        refreshProfessionDetail()
    end
    if ns.SetRecipePanelVisible then ns.SetRecipePanelVisible(material) end
    ns.ShowRecipeDetailView(not material)
    ns.SetExplorerTabText(ui.materialsTab, ns.L("MATERIALS_HEADING"))
    ns.SetExplorerTabText(ui.recipesTab, ns.L("CRAFTABLES_HEADING"))
    ns.SetExplorerTabSelected(ui.materialsTab, material)
    ns.SetExplorerTabSelected(ui.recipesTab, not material)
    ui.back:SetText(ns.L("BACK"))
    ui.back:SetEnabled(#history > 0)
    if #history > 0 then ui.back:Show() else ui.back:Hide() end
    ui.searchHint:SetText(ns.L(material and "SEARCH_PLACEHOLDER" or "CRAFTABLES_SEARCH_PLACEHOLDER"))
    showCatalogProgress()
end

switchView = function(target, direct, fromBack)
    if not panel then return end
    if target ~= "recipes" then target = "materials" end
    viewState[currentView] = {
        query = searchQuery, profession = selectedProfession,
        selected = currentView == "recipes" and selectedRecipe or selectedID,
        offset = scrollOffset,
        recipePage = currentView == "materials" and ns.GetRecipePanelPage() or nil
    }
    currentView = target
    local state = viewState[target]
    searchQuery, selectedProfession, scrollOffset = state.query, state.profession, state.offset
    selectedRecipe = target == "recipes" and state.selected or selectedRecipe
    selectedID = target == "materials" and state.selected or selectedID
    forcedSelection = direct ~= nil
    switching = true
    ui.search:SetText(searchQuery)
    switching = false
    ui.professionButton:SetText(selectedProfession == "" and ns.L("ALL_PROFESSIONS")
        or labelProfession(selectedProfession))
    showActiveDetail()
    refreshResults(false)
    if direct then
        if target == "recipes" then selectedRecipe = direct else selectedID = direct end
        updateRows()
        showDetail()
    end
    if target == "recipes" then ns.PreloadRecipeNames() end
    showCatalogProgress()
    if fromBack and target == "materials" and ns.SetRecipePanelPage then
        local entry = viewState.materials
        if entry.recipePage then ns.SetRecipePanelPage(entry.recipePage) end
    end
end

function ns.NavigateToRecipe(use)
    if not use then return end
    history[#history + 1] = {
        view = currentView, selected = currentView == "materials" and selectedID or selectedRecipe
    }
    if #history > 8 then table.remove(history, 1) end
    switchView("recipes", ns.RecipeKey(use.professionKey, use.spellID))
end

function ns.OpenMaterialFromRecipe(itemID)
    if not ns.IsVerifiedReagent(itemID) then return end
    history[#history + 1] = {
        view = currentView, selected = currentView == "materials" and selectedID or selectedRecipe
    }
    if #history > 8 then table.remove(history, 1) end
    switchView("materials", itemID)
end

function ns.RefreshExplorer()
    if panel and panel:IsShown() then
        refreshResults(false)
    end
end

function ns.RefreshMaterialResults()
    if panel and panel:IsShown() then refreshResults(false) end
end

function ns.RefreshSettings()
    if not panel then return end
    ui.title:SetText(ns.L("TITLE"))
    showActiveDetail()
    ui.searchHint:SetText(ns.L(currentView == "materials"
        and "SEARCH_PLACEHOLDER" or "CRAFTABLES_SEARCH_PLACEHOLDER"))
    ui.professionUses.section:Refresh()
    showCatalogProgress()
    ui.professionButton:SetText(selectedProfession == "" and ns.L("ALL_PROFESSIONS")
        or labelProfession(selectedProfession))
    ui.professionChoices[""]:SetText(ns.L("ALL_PROFESSIONS"))
    for _, key in ipairs(ns.professionOrder or {}) do
        ui.professionChoices[key]:SetText(labelProfession(key))
    end
    refreshResults(false)
end

function ns.OpenSettings(itemID)
    createPanel()
    if currentView ~= "materials" then switchView("materials") end
    if ns.IsVerifiedReagent(itemID) then
        currentView = "materials"
        forcedSelection = true
        searchQuery = ""
        selectedProfession = ""
        ui.search:SetText("")
        selectedID = itemID
    end
    ns.PreloadMaterialInfo()
    if currentView == "recipes" then ns.PreloadRecipeNames() end
    ns.RefreshSettings()
    panel:Show()
    showCatalogProgress()
end

function ns.InitSettings()
    local slashCommands = SlashCmdList
    if type(slashCommands) ~= "table" then return end

    SLASH_CRAFTATLAS1 = "/craftatlas"
    slashCommands.CRAFTATLAS = function(input)
        local argument = string.lower(string.match(input or "", "^%s*(.-)%s*$"))
        if argument == "perf" then
            local m = ns.GetMaterialPreparationMetrics()
            local r = ns.GetRecipePreparationMetrics()
            local u = ns.GetCatalogPerformanceSnapshot()
            if type(print) == "function" then
                print("CraftAtlas: " .. string.format(ns.L("CATALOG_DIAGNOSTICS"),
                    m.attempts, m.units, m.batches,
                    r.attempts, r.units, r.batches,
                    u.materialsSearch, u.recipesSearch, u.fullRefreshes,
                    u.backgroundRefreshes, m.maxBatchMs, r.maxBatchMs))
            end
            return
        end
        local id = tonumber(string.match(argument, "^%d+$"))
        ns.OpenSettings(id)
    end
end
