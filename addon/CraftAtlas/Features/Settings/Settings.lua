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
local forcedSelection = false
local viewState = {
    materials = {query = "", profession = "", selected = nil, offset = 0},
    recipes = {query = "", profession = "", selected = nil, offset = 0},
}
local history = {}
local switchView
local ROW_HEIGHT = 38
local VISIBLE_ROWS = 6
local languageOptions = {"auto", "esES", "enUS"}
local languageLabels = {auto = "AUTO", esES = "SPANISH", enUS = "ENGLISH"}

local function font(parent, fontName)
    return parent:CreateFontString(nil, "OVERLAY", fontName)
end

local function paint(parent, r, g, b, alpha)
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(r, g, b, alpha)
    return texture
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
    local first = (state.page - 1) * state.pageSize + 1
    for i, cell in ipairs(state.cells) do
        local key = state.keys[first + i - 1]
        if key and state.section.expanded then
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
    local state = {keys = {}, page = 1, pageSize = pageSize, cells = {}}
    ui.professionUses = state
    state.section = ns.CreateExplorerSection(right, "USED_BY", -92, function()
        refreshProfessionDetail()
    end)
    -- Proportional columns: four professions in one row at normal width,
    -- two at compact scales. Only page when the real list exceeds capacity.
    local innerWidth = math.max(0, width - 36)
    local columnWidth = innerWidth / pageSize
    for i = 1, pageSize do
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
        ui.detailTitle:SetTextColor(1, 0.82, 0.30)
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
        ui.detailTitle:SetTextColor(1, 0.82, 0.30)
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
    local labels = {}
    for _, key in ipairs(ns.professionOrder or {}) do labels[key] = ns.ProfessionLabel(key) end
    local numberQuery = string.match(searchQuery, "^%d+$") ~= nil and searchQuery ~= ""
    if currentView == "recipes" then
        results, unresolved = ns.SearchCatalogRecipes(searchQuery, selectedProfession,
            ns.GetRecipeNames(), ns.GetKnownMaterialNames(), labels)
    else
        results, unresolved = ns.FilterMaterials(ns.materials, ns.professionOrder,
            searchQuery, selectedProfession, ns.GetKnownMaterialNames(),
            not numberQuery, labels, ns.recipeUses)
    end
    if currentView == "materials" then
        local groups = ns.BuildProfessionGroups(results, ns.materials, ns.professionOrder)
        treeEntries = ns.FlattenProfessionGroups(groups, treeState, searchQuery ~= "")
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

local function createLanguageMenu(header)
    local native, nativeMenu, nativeChoices = ns.CreateExplorerNativeDropdown(
        header, languageOptions, function(value) ns.SetLanguage(value) end, 108)
    if native then
        native:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 5, 2)
        ui.language = native
        ui.languageMenu = nativeMenu
        ui.languageChoices = nativeChoices
        return
    end
    local button = ns.CreateExplorerClassicButton(header)
    button:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -10, 3)
    button:SetSize(120, 28)
    ns.AddExplorerDropdownArrow(button)
    ui.language = button

    local menu = CreateFrame("Frame", nil, panel)
    menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -3)
    menu:SetSize(124, 96)
    menu:SetFrameLevel(header:GetFrameLevel() + 10)
    paint(menu, 0.09, 0.08, 0.06, 0.98)
    menu:Hide()
    ui.languageMenu = menu
    ui.languageChoices = {}
    button:SetScript("OnClick", function()
        if menu:IsShown() then menu:Hide() else menu:Show() end
    end)
    for index, value in ipairs(languageOptions) do
        local choice = ns.CreateExplorerClassicButton(menu)
        choice:SetPoint("TOPLEFT", menu, "TOPLEFT", 3, -3 - (index - 1) * 30)
        choice:SetSize(118, 28)
        choice:SetScript("OnClick", function()
            menu:Hide()
            ns.SetLanguage(value)
        end)
        ui.languageChoices[value] = choice
    end
end

local function createProfessionMenu(left)
    local button, menu, choices = ns.CreateExplorerProfessionFilter(panel, left, function(key)
        selectedProfession = key
        forcedSelection = false
        ui.professionButton:SetText(key == "" and ns.L("ALL_PROFESSIONS") or labelProfession(key))
        refreshResults(true)
    end)
    ui.professionButton, ui.professionMenu, ui.professionChoices = button, menu, choices
end

local function updateRowsAfterGroupToggle()
    local groups = ns.BuildProfessionGroups(results, ns.materials, ns.professionOrder)
    treeEntries = ns.FlattenProfessionGroups(groups, treeState, searchQuery ~= "")
    updateRows()
end

local function createRows(left)
    ui.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = ns.CreateExplorerRow(left, ROW_HEIGHT, function(self)
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
        end)
        row:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -76 - (index - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", left, "TOPRIGHT", -21, -76 - (index - 1) * ROW_HEIGHT)
        ui.rows[index] = row
    end

    local scrollbar = CreateFrame("Slider", nil, left, "UIPanelScrollBarTemplate")
    scrollbar:SetPoint("TOPRIGHT", left, "TOPRIGHT", -3, -76)
    scrollbar:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -3, 18)
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
    local close = window.CloseButton
    if not close then
        close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
        window.CloseButton = close
    end
    close:SetScript("OnClick", function()
        window:Hide()
    end)
    if close.SetFrameLevel and window.GetFrameLevel then
        close:SetFrameLevel(window:GetFrameLevel() + 30)
    end
    if close.Raise then close:Raise() end
    close:Show()
    return close
end

local function createPanel()
    if panel then return panel end
    local ok, window = pcall(CreateFrame, "Frame", "CraftAtlasSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not window then
        window = CreateFrame("Frame", "CraftAtlasSettingsFrame", UIParent)
        paint(window, 0.09, 0.09, 0.09, 0.96)
    end
    panel = window
    local scale = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 800
    local height = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 600
    local logicalWidth, logicalHeight, uiScale = ns.ExplorerWindowGeometry(scale, height)
    panel:SetSize(logicalWidth, logicalHeight)
    panel:SetScale(uiScale)
    -- The left pane begins 137 px from the top and ends 30 px above the bottom.
    -- Leave 76 px for its filter/header and 16 px for status; use the rest for rows.
    VISIBLE_ROWS = ns.ExplorerVisibleRowCount(panel:GetHeight(), ROW_HEIGHT)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    panel:Hide()
    if panel.TitleText then panel.TitleText:Hide() end
    -- Do not place a raw icon over the BasicFrameTemplate frame border.
    -- A framed crest requires a separate verified client-compatible widget.
    -- Bind the close handler after creating overlays, so it wins the click area.

    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -38)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -12, -38)
    header:SetHeight(54)
    header:SetFrameLevel(panel:GetFrameLevel() + 1)
    paint(header, 0.12, 0.10, 0.07, 0.95)
    local divider = header:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT")
    divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT")
    divider:SetHeight(2)
    divider:SetColorTexture(0.78, 0.58, 0.20, 0.90)

    local title = font(header, GameFontNormalHuge and "GameFontNormalHuge" or "GameFontNormalLarge")
    title:SetPoint("CENTER", header, "CENTER", 0, 0)
    title:SetTextColor(1, 0.82, 0.30)
    ui.title = title

    local search = ns.CreateExplorerSearchBox(header, function(value)
        if switching or value == searchQuery then return end
        if value == "" and searchQuery ~= "" then ns.ClearProfessionTreeSearch(treeState) end
        if value ~= "" and searchQuery == "" then ns.ClearProfessionTreeSearch(treeState) end
        searchQuery = value
        forcedSelection = false
        refreshResults(true)
    end)
    search:SetSize(math.max(130, math.min(210, (panel:GetWidth() - 340) / 2)), 28)
    search:ClearAllPoints()
    search:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 13, 3)
    ui.search = search
    local hint = font(header, "GameFontDisableSmall")
    hint:SetPoint("LEFT", search, "LEFT", 7, 0)
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
    clear:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    ui.clear = clear
    ui.clearIcon = clear.icon
    createLanguageMenu(header)

    local materialsTab = ns.CreateExplorerClassicButton(panel)
    materialsTab:SetPoint("TOPLEFT", panel, "TOPLEFT", 18, -101)
    materialsTab:SetSize(130, 27)
    materialsTab:SetScript("OnClick", function() switchView("materials") end)
    local recipesTab = ns.CreateExplorerClassicButton(panel)
    recipesTab:SetPoint("LEFT", materialsTab, "RIGHT", 8, 0)
    recipesTab:SetSize(130, 27)
    recipesTab:SetScript("OnClick", function() switchView("recipes") end)
    local back = ns.CreateExplorerClassicButton(panel)
    back:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -22, -101)
    back:SetSize(76, 26)
    back:SetScript("OnClick", function()
        local entry = table.remove(history)
        if entry then
            switchView(entry.view, entry.selected, true, true)
        end
    end)
    ui.materialsTab, ui.recipesTab, ui.back = materialsTab, recipesTab, back

    local left = CreateFrame("Frame", nil, panel)
    left:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -137)
    left:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 14, 30)
    left:SetWidth(math.floor((panel:GetWidth() - 40) * 0.38))
    paint(left, 0.06, 0.05, 0.04, 0.85)
    ui.left = left
    local right = CreateFrame("Frame", nil, panel)
    right:SetPoint("TOPLEFT", left, "TOPRIGHT", 9, 0)
    right:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -14, 30)
    paint(right, 0.075, 0.064, 0.055, 0.88)
    createProfessionMenu(left)

    local resultsHeading = font(left, "GameFontNormal")
    resultsHeading:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -51)
    ui.resultsHeading = resultsHeading
    local count = font(left, "GameFontDisableSmall")
    count:SetPoint("TOPRIGHT", left, "TOPRIGHT", -11, -53)
    ui.count = count
    local incomplete = font(left, "GameFontDisableSmall")
    incomplete:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 10, 5)
    incomplete:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 5)
    incomplete:SetJustifyH("LEFT")
    ui.incomplete = incomplete
    local empty = font(left, "GameFontHighlight")
    empty:SetPoint("TOPLEFT", left, "TOPLEFT", 12, -102)
    ui.empty = empty
    createRows(left)

    local detailIcon = right:CreateTexture(nil, "ARTWORK")
    detailIcon:SetSize(52, 52)
    detailIcon:SetPoint("TOPLEFT", right, "TOPLEFT", 16, -16)
    ui.detailIcon = detailIcon
    local detailTitle = font(right, "GameFontNormalLarge")
    detailTitle:SetPoint("TOPLEFT", right, "TOPLEFT", 75, -19)
    detailTitle:SetPoint("TOPRIGHT", right, "TOPRIGHT", -12, -19)
    detailTitle:SetJustifyH("LEFT")
    ui.detailTitle = detailTitle
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
    ns.InitRecipePanel(right, panel:GetHeight() - 167)
    ns.InitRecipeDetail(right)
    ui.right = right

    local version = ns.GetInstalledReleaseVersion(ns.name)
    if version then
        local caption = font(panel, "GameFontDisableSmall")
        caption:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 18, 14)
        caption:SetText(version)
    end

    ui.itemListener = CreateFrame("Frame", nil, panel)
    ui.itemListener:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    ui.itemListener:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    ui.itemListener:SetScript("OnEvent", function(_, _, itemID, success)
        if ns.UpdateMaterialInfo(itemID, success) then
            refreshResults(false)
        end
    end)
    panel:SetScript("OnHide", function()
        ui.languageMenu:Hide()
        ui.professionMenu:Hide()
        ui.search:ClearFocus()
        if ns.HideRecipePanelTooltip then ns.HideRecipePanelTooltip() end
    end)
    ns.BindExplorerClose(panel)
    return panel
end

local function showActiveDetail()
    local material = currentView == "materials"
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
    ui.materialsTab:SetText(ns.L("MATERIALS_HEADING"))
    ui.recipesTab:SetText(ns.L("CRAFTABLES_HEADING"))
    ns.SetExplorerTabSelected(ui.materialsTab, material)
    ns.SetExplorerTabSelected(ui.recipesTab, not material)
    ui.back:SetText(ns.L("BACK"))
    ui.back:SetEnabled(#history > 0)
    if #history > 0 then ui.back:Show() else ui.back:Hide() end
    ui.searchHint:SetText(ns.L(material and "SEARCH_PLACEHOLDER" or "CRAFTABLES_SEARCH_PLACEHOLDER"))
    ui.resultsHeading:SetText(ns.L(material and "MATERIALS_HEADING" or "CRAFTABLES_HEADING"))
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
    ui.resultsHeading:SetText(ns.L(currentView == "materials"
        and "MATERIALS_HEADING" or "CRAFTABLES_HEADING"))
    ui.professionUses.section:Refresh()
    ui.professionButton:SetText(selectedProfession == "" and ns.L("ALL_PROFESSIONS")
        or labelProfession(selectedProfession))
    ui.language:SetText(ns.L(languageLabels[ns.ResolveLocale(ns.GetLanguage(), ns.GetClientLocale())]))
    local current = ns.GetLanguage()
    for _, value in ipairs(languageOptions) do
        ui.languageChoices[value]:SetText((current == value and "> " or "   ") .. ns.L(languageLabels[value]))
    end
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
    panel:Raise()
end

function ns.InitSettings()
    SLASH_CRAFTATLAS1 = "/craftatlas"
    SlashCmdList = SlashCmdList or {}
    SlashCmdList.CRAFTATLAS = function(input)
        local id = tonumber(string.match(input or "", "^%s*(%d+)%s*$"))
        ns.OpenSettings(id)
    end
end
