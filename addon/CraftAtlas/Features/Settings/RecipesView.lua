local _, ns = ...
local view = {page = 1, pageSize = 5, selected = nil, rows = {}, ingredients = {}}
local ITEMS_PER_PAGE = 5
-- One text baseline and a separate bar; three rows fit without collisions.
local TRACKER_ROW_HEIGHT = 25
local TRACKER_TOP_HEIGHT = 34
local TRACKER_BOTTOM_HEIGHT = 19

local function trackedPageSize(availableHeight)
    -- Pair each paged ingredient with one independently rendered tracker row.
    local remaining = availableHeight - 143 - 40 - 6
        - TRACKER_TOP_HEIGHT - TRACKER_BOTTOM_HEIGHT
    return math.max(1, math.min(ITEMS_PER_PAGE,
        math.floor(remaining / (39 + TRACKER_ROW_HEIGHT))))
end

local function setCheck(button, checked)
    if button and type(button.SetChecked) == "function" then
        button:SetChecked(checked)
    end
end

local function showControl(control, visible)
    if not control then return end
    if visible then control:Show() else control:Hide() end
end

local function refreshTrackingCounts(recipe)
    view.trackingCounts = {}
    if not recipe or not ns.IsCraftableTracked or not ns.IsCraftableTracked(recipe.key) then
        return nil
    end
    local includeBank = ns.GetCraftBankPreference and ns.GetCraftBankPreference()
    for _, ingredient in ipairs(recipe.ingredients or {}) do
        if not view.trackingCounts[ingredient.itemID] then
            view.trackingCounts[ingredient.itemID] =
                ns.ReadCraftInventoryCount and
                ns.ReadCraftInventoryCount(ingredient.itemID, includeBank)
                or {bags = nil, available = nil, bankStatus = "unavailable"}
        end
    end
    if ns.ComputeCraftableCoverage then
        return ns.ComputeCraftableCoverage(recipe.ingredients, view.trackingCounts)
    end
end

local function createNativeBar(parent)
    -- A true Blizzard StatusBar using native fill and tooltip-frame assets.
    -- The backdrop belongs to the status bar, not an overlay hiding its fill.
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    if type(bar.SetBackdrop) == "function" then
        bar:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 9,
            insets = {left = 2, right = 2, top = 2, bottom = 2},
        })
        if type(bar.SetBackdropColor) == "function" then
            bar:SetBackdropColor(0.24, 0.23, 0.19, 0.98)
        end
        if type(bar.SetBackdropBorderColor) == "function" then
            bar:SetBackdropBorderColor(0.55, 0.49, 0.34, 1)
        end
    end
    if type(bar.SetStatusBarTexture) == "function" then
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        bar:SetStatusBarColor(0.18, 0.68, 0.22)
        bar:SetMinMaxValues(0, 1)
    end
    return bar
end

local function updateTrackingMaterial(row, ingredient, observation, bankIncluded)
    if not ingredient then
        row:Hide()
        return
    end
    local needed = ingredient.quantity
    local count = observation and observation.available
    local name = ns.GetItemDisplay(ingredient.itemID)
    row.name:SetText(name or (ns.L("ITEM_ID") .. " " .. tostring(ingredient.itemID)))
    local bankKnown = bankIncluded and observation and observation.bankStatus == "confirmed"
    if type(count) == "number" then
        row.amount:SetText(string.format(ns.L("TRACK_ROW_SUMMARY"),
            count, needed, math.max(0, needed - count)))
        row.missing:SetText("")
    else
        row.amount:SetText(string.format(ns.L("TRACK_AVAILABLE_UNKNOWN"), needed))
        row.missing:SetText("")
    end
    if type(row.bar.SetMinMaxValues) == "function" then
        row.bar:SetMinMaxValues(0, math.max(1, needed))
    end
    if type(row.bar.SetValue) == "function" then
        row.bar:SetValue(type(count) == "number" and math.min(needed, count) or 0)
    end
    row:Show()
end

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
    if view.trackerFooter then
        showControl(view.trackerFooter, expanded and view.trackingActive)
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
    local tracking = recipe and ns.IsCraftableTracked
        and ns.IsCraftableTracked(recipe.key) == true or false
    view.trackingActive = tracking
    if view.trackCheckbox then
        showControl(view.trackCheckbox, recipe ~= nil)
        showControl(view.trackLabel, recipe ~= nil)
        setCheck(view.trackCheckbox, tracking)
        view.trackLabel:SetText(ns.L("TRACK_CRAFTING"))
    end
    view.pageSize = tracking and trackedPageSize(view.availableHeight) or view.normalPageSize
    local coverage = tracking and refreshTrackingCounts(recipe) or nil
    if view.trackerFooter then
        if tracking then
            local percent = coverage and coverage.percent
            local valid = coverage and coverage.verified
            view.trackerLabel:SetText(ns.L("TRACK_PROGRESS"))
            if #view.ingredients == 0 then
                view.trackerPercent:SetText(ns.L("TRACK_NO_INGREDIENTS"))
            else
                view.trackerPercent:SetText(
                    (percent and (tostring(percent) .. "%") or ns.L("TRACK_UNKNOWN")) ..
                    (valid and "" or (" · " .. ns.L("TRACK_UNVERIFIED"))))
            end
            if type(view.trackerBar.SetMinMaxValues) == "function" then
                view.trackerBar:SetMinMaxValues(0, 100)
            end
            if type(view.trackerBar.SetValue) == "function" then
                view.trackerBar:SetValue(percent or 0)
            end
            local supported = ns.IsCraftBankSupported and ns.IsCraftBankSupported()
            setCheck(view.bankCheckbox, ns.GetCraftBankPreference
                and ns.GetCraftBankPreference() or false)
            if type(view.bankCheckbox.SetEnabled) == "function" then
                view.bankCheckbox:SetEnabled(supported == true)
            end
            view.bankLabel:SetText(supported and ns.L("TRACK_INCLUDE_BANK")
                or ns.L("TRACK_BANK_UNAVAILABLE"))
            local bankIncluded = ns.GetCraftBankPreference and ns.GetCraftBankPreference()
            if bankIncluded then
                local confirmed = true
                for _, observation in pairs(view.trackingCounts) do
                    if observation.bankStatus ~= "confirmed" then confirmed = false break end
                end
                view.bankStatus:SetText(confirmed and ns.L("TRACK_BANK_CURRENT")
                    or ns.L("TRACK_BANK_OPEN_HINT"))
            else
                view.bankStatus:SetText("")
            end
        else
            view.trackerFooter:Hide()
        end
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
    if view.trackerFooter then
        local footerTop = -(#visible * 39 + 6)
        view.trackerFooter:ClearAllPoints()
        view.trackerFooter:SetPoint("TOPLEFT", view.itemList, "TOPLEFT", 0, footerTop)
        view.trackerFooter:SetPoint("TOPRIGHT", view.itemList, "TOPRIGHT", 0, footerTop)
        view.trackerFooter:SetHeight(TRACKER_TOP_HEIGHT
            + #visible * TRACKER_ROW_HEIGHT + TRACKER_BOTTOM_HEIGHT)
        local includeBank = ns.GetCraftBankPreference and ns.GetCraftBankPreference()
        for i, trackerRow in ipairs(view.trackerRows) do
            updateTrackingMaterial(trackerRow, tracking and visible[i] or nil,
                tracking and visible[i] and view.trackingCounts[visible[i].itemID],
                includeBank)
        end
        view.totalLabel:SetText(ns.L("TRACK_TOTAL"))
        view.totalLabel:ClearAllPoints()
        view.totalLabel:SetPoint("TOPLEFT", view.trackerFooter, "TOPLEFT", 8,
            -(TRACKER_TOP_HEIGHT + #visible * TRACKER_ROW_HEIGHT))
        view.trackerBar:ClearAllPoints()
        view.trackerBar:SetPoint("TOPLEFT", view.totalLabel, "BOTTOMLEFT", 0, -4)
        view.trackerBar:SetPoint("TOPRIGHT", view.trackerFooter, "TOPRIGHT", -8,
            -(TRACKER_TOP_HEIGHT + #visible * TRACKER_ROW_HEIGHT + 16))
    end
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
    view.availableHeight = availableHeight
    view.normalPageSize = math.max(1, math.min(ITEMS_PER_PAGE,
        math.floor((availableHeight - 138 - 40) / 39)))
    view.pageSize = view.normalPageSize

    view.icon = frame:CreateTexture(nil, "ARTWORK")
    view.icon:SetSize(52, 52)
    view.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
    -- No UI-Quickslot2 overlay: its inner slot draws a duplicate inset square.

    view.title = font(frame, "GameFontNormalLarge")
    view.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -18)
    view.title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, -18)
    view.title:SetJustifyH("LEFT")
    view.title:SetWordWrap(false)
    local titleLink = CreateFrame("Button", nil, frame)
    titleLink:SetPoint("TOPLEFT", frame, "TOPLEFT", 74, -15)
    titleLink:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -15)
    titleLink:SetHeight(27)
    titleLink:SetScript("OnClick", function(_, button)
        if not (ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button)) then return end
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if recipe then ns.InsertRecipeChatLink(recipe) end
    end)
    view.profession = font(frame, "GameFontHighlightSmall")
    view.profession:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -40)
    view.output = font(frame, "GameFontDisableSmall")
    view.output:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -76)
    view.output:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -76)
    view.output:SetJustifyH("LEFT")
    view.output:SetWordWrap(false)

    -- Optional tracker lives in the unused band between profession and metadata.
    local trackCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    trackCheckbox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -176, -55)
    trackCheckbox:SetSize(20, 20)
    local trackLabel = font(frame, "GameFontHighlightSmall")
    trackLabel:SetPoint("LEFT", trackCheckbox, "RIGHT", 2, 0)
    trackLabel:SetText(ns.L("TRACK_CRAFTING"))
    trackCheckbox:SetScript("OnClick", function(self)
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if recipe and ns.SetCraftableTracked then
            ns.SetCraftableTracked(recipe.key, self:GetChecked() == true)
            view.page = 1
            render()
        end
    end)
    view.trackCheckbox = trackCheckbox
    view.trackLabel = trackLabel

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
            if self.ingredient and ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) then
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

    local trackerFooter = CreateFrame("Frame", nil, frame)
    trackerFooter:SetPoint("TOPLEFT", itemList, "TOPLEFT", 0, -47)
    trackerFooter:SetPoint("TOPRIGHT", itemList, "TOPRIGHT", 0, -47)
    trackerFooter:SetHeight(TRACKER_TOP_HEIGHT + TRACKER_BOTTOM_HEIGHT)
    view.trackerFooter = trackerFooter

    local separator = trackerFooter:CreateTexture(nil, "ARTWORK")
    separator:SetPoint("TOPLEFT", trackerFooter, "TOPLEFT", 0, 0)
    separator:SetPoint("TOPRIGHT", trackerFooter, "TOPRIGHT", 0, 0)
    separator:SetHeight(2)
    separator:SetColorTexture(0.72, 0.54, 0.24, 0.95)

    local trackerLabel = font(trackerFooter, "GameFontNormal")
    trackerLabel:SetPoint("TOPLEFT", trackerFooter, "TOPLEFT", 8, -3)
    trackerLabel:SetTextColor(1, 0.82, 0.30)
    view.trackerLabel = trackerLabel

    local trackerPercent = font(trackerFooter, "GameFontHighlightSmall")
    trackerPercent:SetPoint("TOPRIGHT", trackerFooter, "TOPRIGHT", -8, -4)
    trackerPercent:SetJustifyH("RIGHT")
    view.trackerPercent = trackerPercent

    local bankCheckbox = CreateFrame("CheckButton", nil, trackerFooter, "UICheckButtonTemplate")
    bankCheckbox:SetPoint("TOPLEFT", trackerFooter, "TOPLEFT", 4, -16)
    bankCheckbox:SetSize(17, 17)
    local bankLabel = font(trackerFooter, "GameFontDisableSmall")
    bankLabel:SetPoint("LEFT", bankCheckbox, "RIGHT", 2, 0)
    view.bankCheckbox, view.bankLabel = bankCheckbox, bankLabel
    bankCheckbox:SetScript("OnClick", function(self)
        if ns.SetCraftBankPreference then
            ns.SetCraftBankPreference(self:GetChecked() == true)
        end
        render()
    end)
    local bankStatus = font(trackerFooter, "GameFontDisableSmall")
    bankStatus:SetPoint("TOPRIGHT", trackerFooter, "TOPRIGHT", -8, -20)
    bankStatus:SetJustifyH("RIGHT")
    view.bankStatus = bankStatus

    view.trackerRows = {}
    for i = 1, ITEMS_PER_PAGE do
        local row = CreateFrame("Frame", nil, trackerFooter)
        row:SetPoint("TOPLEFT", trackerFooter, "TOPLEFT", 8,
            -(TRACKER_TOP_HEIGHT + (i - 1) * TRACKER_ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", trackerFooter, "TOPRIGHT", -8,
            -(TRACKER_TOP_HEIGHT + (i - 1) * TRACKER_ROW_HEIGHT))
        row:SetHeight(TRACKER_ROW_HEIGHT)
        row.name = font(row, "GameFontHighlightSmall")
        row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)
        row.amount = font(row, "GameFontDisableSmall")
        row.amount:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
        row.amount:SetJustifyH("RIGHT")
        row.name:SetPoint("TOPRIGHT", row.amount, "TOPLEFT", -8, 0)
        row.missing = font(row, "GameFontDisableSmall")
        row.missing:SetText("")
        row.bar = createNativeBar(row)
        row.bar:SetHeight(10)
        row.bar:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -13)
        row.bar:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -13)
        row:Hide()
        view.trackerRows[i] = row
    end

    local totalLabel = font(trackerFooter, "GameFontNormalSmall")
    view.totalLabel = totalLabel
    local trackerBar = createNativeBar(trackerFooter)
    trackerBar:SetHeight(9)
    view.trackerBar = trackerBar
    trackerFooter:Hide()

    local listener = CreateFrame("Frame", nil, frame)
    local function onInventoryChanged(_, event)
        if event == "BANKFRAME_OPENED" and ns.SetCraftBankOpen then
            ns.SetCraftBankOpen(true)
        elseif event == "BANKFRAME_CLOSED" and ns.SetCraftBankOpen then
            ns.SetCraftBankOpen(false)
        end
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if not recipe or not (view.frame and view.frame:IsShown())
            or not ns.IsCraftableTracked or not ns.IsCraftableTracked(recipe.key)
            or view.refreshQueued then return end
        local function update()
            view.refreshQueued = false
            if view.frame and view.frame:IsShown() then render() end
        end
        local timer = C_Timer and C_Timer.After
        if type(timer) == "function" then
            view.refreshQueued = true
            local ok = pcall(timer, 0.1, update)
            if ok then return end
            view.refreshQueued = false
        end
        update()
    end
    listener:SetScript("OnEvent", onInventoryChanged)
    for _, event in ipairs({"BAG_UPDATE_DELAYED", "BANKFRAME_OPENED", "BANKFRAME_CLOSED",
        "PLAYERBANKSLOTS_CHANGED", "PLAYERBANKBAGSLOTS_CHANGED"}) do
        if type(listener.RegisterEvent) == "function" then
            pcall(listener.RegisterEvent, listener, event)
        end
    end
    view.inventoryListener = listener

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
        if not ns.IsEntityChatLinkClick and ns.IsEntityChatLinkClick(button) then return end
        local recipe = view.selected and ns.GetCatalogRecipe(view.selected)
        if recipe then ns.InsertRecipeChatLink(recipe) end
    end)
    outputHover:SetScript("OnLeave", clearTooltip)
    frame:SetScript("OnHide", clearTooltip)
    frame:Hide()
end
