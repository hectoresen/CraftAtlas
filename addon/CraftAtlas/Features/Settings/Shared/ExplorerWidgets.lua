local _, ns = ...

-- Shared native controls. A view supplies values and callbacks; no domain dependency.

function ns.HideExplorerTooltip(frame)
    if not frame or not GameTooltip or not GameTooltip.GetOwner then return end
    if GameTooltip.IsForbidden and GameTooltip:IsForbidden() then return end
    local owner = GameTooltip:GetOwner()
    while owner do
        if owner == frame then
            GameTooltip:Hide()
            return
        end
        if owner.IsForbidden and owner:IsForbidden() then return end
        owner = owner.GetParent and owner:GetParent()
    end
end

-- Prefer the explicit Magic Broom texture. The previous cache-based lookup could
-- return the question-mark icon before WoW had loaded the seasonal item.
function ns.GetExplorerClearIcon(fileLookup)
    local broom = "Interface\\Icons\\Achievement_Halloween_Witch_01"
    if type(fileLookup) == "function" then
        local ok, supported = pcall(fileLookup, broom)
        if ok and supported then return broom end
        return "Interface\\Icons\\Spell_Holy_DispelMagic"
    end
    -- WoW bundles the icon as a client texture; no item cache/API is needed.
    return broom
end

-- A minimum logical size is scaled uniformly for smaller physical viewports.
function ns.ExplorerWindowGeometry(viewportWidth, viewportHeight)
    local width = math.min(860, math.max(600, viewportWidth - 50))
    local height = math.min(610, math.max(440, viewportHeight - 60))
    local scale = math.min(1, (viewportWidth - 24) / width, (viewportHeight - 24) / height)
    return width, height, math.max(0.2, scale)
end

function ns.ExplorerVisibleRowCount(listHeight, rowHeight)
    return math.max(2, math.min(11, math.floor(listHeight / rowHeight)))
end

-- Keep profession metadata and the fabrication header in separate vertical bands.
-- Profession icons remain in one horizontal row; compact panes page in pairs.
-- Four fit on a normal native detail pane without occupying recipe-list height.
function ns.ExplorerProfessionPageSize(detailWidth)
    return type(detailWidth) == "number" and detailWidth >= 475 and 4 or 2
end

function ns.MaterialDetailSectionOffsets(availableHeight)
    if availableHeight < 270 then return -160, -188 end
    return -167, -197
end

function ns.AddExplorerHeadingSurface(parent, height)
    local surface = parent:CreateTexture(nil, "BACKGROUND")
    surface:SetPoint("TOPLEFT", parent, "TOPLEFT")
    surface:SetPoint("TOPRIGHT", parent, "TOPRIGHT")
    surface:SetHeight(height)
    if surface.SetAtlas then
        surface:SetAtlas("Options_CategoryHeader_1")
    else
        surface:SetColorTexture(0.12, 0.07, 0.03, 0.9)
    end
    return surface
end

function ns.CreateExplorerRow(parent, height, onClick, sidebar)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(height)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local hover = row.GetHighlightTexture and row:GetHighlightTexture()
    if hover then hover:SetAlpha(0.35) end
    local selected = row:CreateTexture(nil, "BACKGROUND")
    selected:SetAllPoints()
    if sidebar and selected.SetAtlas then
        selected:SetAtlas("Options_List_Active")
    else
        selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        if selected.SetBlendMode then selected:SetBlendMode("ADD") end
        if selected.SetAlpha then selected:SetAlpha(0.55) end
    end
    selected:Hide()
    row.highlight = selected
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(30, 30)
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 39, -4)
    row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -4)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.professions = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    if sidebar then
        row.professions:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 39, 4)
        row.professions:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -3, 4)
        row.professions:SetHeight(11)
    else
        row.professions:SetPoint("TOPLEFT", row, "TOPLEFT", 39, -22)
        row.professions:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -22)
    end
    row.professions:SetJustifyH("LEFT")
    row.professions:SetWordWrap(false)
    if sidebar then
        row.groupHeader = ns.AddExplorerHeadingSurface(row, height)
        row.groupHeader:Hide()
    end
    row.groupArrow = row:CreateTexture(nil, "OVERLAY")
    row.groupArrow:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    row.groupArrow:SetSize(17, 17)
    row.groupName = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.groupName:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.groupName:SetPoint("RIGHT", row, "RIGHT", -25, 0)
    row.groupName:SetJustifyH("LEFT")
    row.groupName:SetWordWrap(false)
    row.groupArrow:Hide()
    row.groupName:Hide()
    row:SetScript("OnClick", function(self, button) if onClick then onClick(self, button) end end)
    return row
end

-- Client-bundled profession artwork, never fabricated catalog facts.
local professionIcons = {
    ALCHEMY = "Interface\\Icons\\Trade_Alchemy",
    BLACKSMITHING = "Interface\\Icons\\Trade_BlackSmithing",
    COOKING = "Interface\\Icons\\INV_Misc_Food_15",
    ENCHANTING = "Interface\\Icons\\Trade_Engraving",
    ENGINEERING = "Interface\\Icons\\Trade_Engineering",
    FIRST_AID = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
    FISHING = "Interface\\Icons\\Trade_Fishing",
    HERBALISM = "Interface\\Icons\\Trade_Herbalism",
    LEATHERWORKING = "Interface\\Icons\\Trade_LeatherWorking",
    MINING = "Interface\\Icons\\Trade_Mining",
    SKINNING = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
    TAILORING = "Interface\\Icons\\Trade_Tailoring",
}

function ns.GetExplorerProfessionIcon(key)
    return professionIcons[key] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Group rows have their own header treatment; they never masquerade as item rows.
function ns.StyleExplorerGroupRow(row, label, count, expanded)
    if row.groupHeader then row.groupHeader:Show() end
    row.icon:Hide()
    row.name:Hide()
    row.professions:Hide()
    row.highlight:Hide()
    row.groupArrow:SetTexture(expanded and "Interface\\Buttons\\UI-MinusButton-Up"
        or "Interface\\Buttons\\UI-PlusButton-Up")
    row.groupName:SetText(label .. " (" .. count .. ")")
    row.groupArrow:Show()
    row.groupName:Show()
end

function ns.StyleExplorerItemRow(row, compact)
    if row.groupHeader then row.groupHeader:Hide() end
    row.groupArrow:Hide()
    row.groupName:Hide()
    row.icon:ClearAllPoints()
    row.name:ClearAllPoints()
    if compact then
        -- Indentation communicates parent/child hierarchy independently of color.
        row.icon:SetPoint("LEFT", row, "LEFT", 15, 0)
        row.name:SetPoint("LEFT", row, "LEFT", 51, 0)
        row.name:SetPoint("RIGHT", row, "RIGHT", -3, 0)
        row.professions:Hide()
    else
        row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
        row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 39, -4)
        row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -4)
        row.professions:Show()
    end
    row.name:Show()
end

-- A recessed header and native disclosure distinguish each detail section.
function ns.CreateExplorerSection(parent, titleKey, top, onToggle)
    local section = CreateFrame("Button", nil, parent)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, top)
    section:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, top)
    section:SetHeight(27)
    ns.AddExplorerHeadingSurface(section, 27)
    section:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    section.label = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.label:SetPoint("LEFT", section, "LEFT", 9, 0)
    section.arrow = section:CreateTexture(nil, "OVERLAY")
    section.arrow:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    section.arrow:SetSize(17, 17)
    section.expanded = true
    function section:Refresh()
        self.label:SetText(self.titleText or ns.L(titleKey))
        self.arrow:SetTexture(self.expanded and "Interface\\Buttons\\UI-MinusButton-Up"
            or "Interface\\Buttons\\UI-PlusButton-Up")
    end
    function section:SetTitle(text)
        self.titleText = text
        self:Refresh()
    end
    section:SetScript("OnClick", function(self)
        self.expanded = not self.expanded
        self:Refresh()
        if onToggle then onToggle(self.expanded) end
    end)
    section:Refresh()
    return section
end

-- Classic's own button atlas restores the familiar red/gold affordance.
-- Leave custom styling to grouping dividers and detail sections.
function ns.CreateExplorerClassicButton(parent)
    return CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
end

function ns.CreateExplorerTab(parent)
    local ok, tab = pcall(CreateFrame, "Button", nil, parent, "MinimalTabTemplate")
    if ok and tab and tab.Text and tab.SetSelected then return tab end
    local fallback = ns.CreateExplorerClassicButton(parent)
    fallback:SetWidth(104)
    return fallback
end

function ns.SetExplorerTabText(button, label)
    if button.SetSelected and button.Text then
        button.Text:SetText(label)
        button:SetWidth(button.Text:GetStringWidth() + 40)
    else
        button:SetText(label)
    end
end

function ns.SetExplorerTabSelected(button, selected)
    if button.SetSelected and button.Text then
        button:SetSelected(selected)
    elseif selected then
        button:LockHighlight()
    else
        button:UnlockHighlight()
    end
end

-- The native arrow makes profession/language selectors look interactive.
function ns.AddExplorerDropdownArrow(button)
    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    arrow:SetSize(17, 17)
    arrow:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    button.dropdownArrow = arrow
    return arrow
end

function ns.CreateExplorerPager(parent, onPrevious, onNext)
    local previous = ns.CreateExplorerClassicButton(parent)
    previous:SetSize(76, 24)
    previous:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 14, 9)
    previous:SetScript("OnClick", function() if onPrevious then onPrevious() end end)
    local nextButton = ns.CreateExplorerClassicButton(parent)
    nextButton:SetSize(76, 24)
    nextButton:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -14, 9)
    nextButton:SetScript("OnClick", function() if onNext then onNext() end end)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER", parent, "BOTTOM", 0, 21)
    return {previous = previous, next = nextButton, label = label}
end

function ns.UpdateExplorerPager(pager, page, pages)
    pager.previous:SetText(ns.L("PREVIOUS_PAGE"))
    pager.next:SetText(ns.L("NEXT_PAGE"))
    pager.label:SetText(string.format(ns.L("RECIPE_PAGE_STATUS"), page, pages))
    pager.previous:SetEnabled(page > 1)
    pager.next:SetEnabled(page > 0 and page < pages)
end

-- The footer keeps catalog preparation clear of the tabs, Back, and search.
function ns.CreateExplorerCatalogProgress(panel)
    local holder = CreateFrame("Frame", nil, panel)
    holder:SetPoint("BOTTOM", panel, "BOTTOM", 0, 8)

    -- Cap the bar so the progress fill and label read as one component.
    local width = type(panel.GetWidth) == "function" and panel:GetWidth() or 600
    local trackWidth = math.max(130, math.min(252, width - 430))
    holder:SetSize(trackWidth, 24)
    local bar = CreateFrame("StatusBar", nil, holder)
    bar:SetSize(trackWidth, 6)
    bar:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0.73, 0.52, 0.18, 0.95)
    bar:SetMinMaxValues(0, 100)

    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0.055, 0.048, 0.039, 0.94)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("BOTTOM", bar, "TOP", 0, 3)
    label:SetJustifyH("CENTER")
    label:SetTextColor(1, 0.93, 0.75)
    if type(label.SetWordWrap) == "function" then label:SetWordWrap(false) end
    holder.label, holder.bar, holder.track = label, bar, track
    function holder:SetProgress(status, percent, caption)
        if status ~= "active" and status ~= "incomplete" then
            self:Hide()
            return
        end
        self.bar:SetValue(math.max(0, math.min(100, percent or 0)))
        self.label:SetText(caption or "")
        self:Show()
    end
    holder:Hide()
    return holder
end

-- Same search widget is reused by each active view, with state owned by its adapter.
function ns.ClearExplorerSearch(search)
    if not search or type(search.GetText) ~= "function"
        or type(search.SetText) ~= "function" or search:GetText() == "" then
        return false
    end
    search:SetText("")
    if type(search.SetFocus) == "function" then search:SetFocus() end
    return true
end

-- The client already ships the same close glyph used by its native panels.
-- Embed it into the edit box and show it only when there is text to clear.
function ns.CreateExplorerSearchClear(search, onClick)
    local button = CreateFrame("Button", nil, search)
    button:SetSize(18, 18)
    button:SetPoint("RIGHT", search, "RIGHT", -5, 0)
    local texture = button:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Buttons\\UI-Panel-CloseButton-Up")
    button.icon = texture
    if type(button.SetHighlightTexture) == "function" then
        button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-CloseButton-Highlight")
    end
    if type(search.SetTextInsets) == "function" then
        search:SetTextInsets(search.searchIcon and 19 or 6, 25, 0, 0)
    end
    button:SetScript("OnClick", function()
        if onClick then onClick() else ns.ClearExplorerSearch(search) end
    end)
    local function refresh()
        if search:GetText() == "" then button:Hide() else button:Show() end
    end
    search:HookScript("OnTextChanged", refresh)
    refresh()
    return button
end

function ns.CreateExplorerSearchBox(header, onChange)
    local search = CreateFrame("EditBox", nil, header, "InputBoxTemplate")
    search:SetPoint("LEFT", header, "LEFT", 13, 0)
    search:SetSize(185, 28)
    search:SetAutoFocus(false)
    search:SetMaxLetters(120)
    local icon = search:CreateTexture(nil, "OVERLAY")
    if icon.SetAtlas then
        icon:SetAtlas("common-search-magnifyingglass")
        icon:SetPoint("LEFT", search, "LEFT", 5, 0)
        icon:SetSize(10, 10)
        search.searchIcon = icon
    end
    search:SetScript("OnTextChanged", function(self)
        if onChange then onChange(self:GetText()) end
    end)
    return search
end

local function createModernDropdown(parent, keys, onSelect, width, getSelection, labels)
    if type(MenuUtil) ~= "table" then return end
    local ok, dropdown = pcall(CreateFrame, "DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    if not ok or not dropdown or not dropdown.SetupMenu or not dropdown.IsMenuOpen
        or not dropdown.CloseMenu then return end
    dropdown:SetWidth(width)
    local function isSelected(key) return getSelection() == key end
    dropdown:SetupMenu(function(_, root)
        for _, key in ipairs(keys) do
            local label = labels[key]
            if label then
                if getSelection then
                    root:CreateRadio(label, isSelected, onSelect, key)
                else
                    root:CreateButton(label, onSelect, key)
                end
            end
        end
    end)
    local popup = {
        IsShown = function() return dropdown:IsMenuOpen() end,
        Hide = function() if dropdown:IsMenuOpen() then dropdown:CloseMenu() end end,
    }
    return dropdown, popup
end

function ns.CreateExplorerNativeDropdown(parent, keys, onSelect, width, getSelection)
    local labels, choices = {}, {}
    for _, key in ipairs(keys) do
        local entry = {}
        function entry:SetText(value) labels[key] = value end
        choices[key] = entry
    end
    local modern, modernPopup = createModernDropdown(parent, keys, onSelect, width, getSelection, labels)
    if modern then return modern, modernPopup, choices end

    -- New Forever clients dismiss legacy lists without consuming Escape. If the
    -- modern template is unavailable there, use an owned fallback popup instead.
    if type(GameMenuEscPriority) == "table"
        or type(UIDropDownMenu_Initialize) ~= "function"
        or type(UIDropDownMenu_CreateInfo) ~= "function"
        or type(UIDropDownMenu_AddButton) ~= "function"
        or type(UIDropDownMenu_SetWidth) ~= "function"
        or type(UIDropDownMenu_SetText) ~= "function" then
        return nil
    end
    local ok, dropdown = pcall(CreateFrame, "Frame", nil, parent, "UIDropDownMenuTemplate")
    if not ok or not dropdown then return nil end
    dropdown.SetText = function(self, value)
        UIDropDownMenu_SetText(self, value or "")
    end
    local function isOpen()
        local list = DropDownList1
        if list and type(list.IsShown) == "function" then
            return list:IsShown() and (list.dropdown or UIDROPDOWNMENU_OPEN_MENU) == dropdown
        end
        return UIDROPDOWNMENU_OPEN_MENU == dropdown
    end
    local function closeMenu()
        if not isOpen() then return end
        if type(CloseDropDownMenus) == "function" then
            CloseDropDownMenus()
        elseif DropDownList1 then
            DropDownList1:Hide()
        end
    end
    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        if level and level ~= 1 then return end
        local selected = getSelection and getSelection()
        for _, key in ipairs(keys) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = labels[key] or key
            info.value = key
            info.notCheckable = getSelection == nil
            info.checked = selected == key
            info.func = function()
                closeMenu()
                if onSelect then onSelect(key) end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    return dropdown, {IsShown = isOpen, Hide = closeMenu}, choices
end

local languageOptions = {"auto", "esES", "enUS"}
local languageLabels = {auto = "AUTO", esES = "SPANISH", enUS = "ENGLISH"}

function ns.CreateAddonLanguageSelector(parent)
    local button, menu, choices = ns.CreateExplorerNativeDropdown(parent, languageOptions,
        ns.SetLanguage, 120, ns.GetLanguage)
    local markers
    if button then
        if button.SetupMenu then
            button:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 5)
        else
            button:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 5, 2)
        end
    else
        button = ns.CreateExplorerClassicButton(parent)
        button:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 3)
        button:SetSize(120, 28)
        ns.AddExplorerDropdownArrow(button)

        menu = CreateFrame("Frame", nil, parent)
        menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -3)
        menu:SetSize(124, 96)
        menu:SetFrameLevel(parent:GetFrameLevel() + 10)
        local background = menu:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.09, 0.08, 0.06, 0.98)
        menu:Hide()
        choices = {}
        markers = {}
        button:SetScript("OnClick", function()
            if menu:IsShown() then menu:Hide() else menu:Show() end
        end)
        for index, value in ipairs(languageOptions) do
            local choice = ns.CreateExplorerClassicButton(menu)
            choice:SetPoint("TOPLEFT", menu, "TOPLEFT", 3, -3 - (index - 1) * 30)
            choice:SetSize(118, 28)
            local check = choice:CreateTexture(nil, "OVERLAY")
            check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            check:SetSize(15, 15)
            check:SetPoint("LEFT", choice, "LEFT", 5, 0)
            markers[value] = check
            choice:SetScript("OnClick", function()
                menu:Hide()
                ns.SetLanguage(value)
            end)
            choices[value] = choice
        end
    end

    return {
        CloseMenu = function() menu:Hide() end,
        Refresh = function()
            local current = ns.GetLanguage()
            button:SetText(ns.L(languageLabels[current]))
            for _, value in ipairs(languageOptions) do
                choices[value]:SetText(ns.L(languageLabels[value]))
                if markers then
                    if current == value then markers[value]:Show() else markers[value]:Hide() end
                end
            end
        end,
    }
end

function ns.CreateExplorerProfessionFilter(parent, onSelect, getSelection, popupName)
    local keys = {""}
    for _, key in ipairs(ns.professionOrder or {}) do keys[#keys + 1] = key end
    local width = math.min(225, parent:GetWidth() - 20)
    local native, nativeMenu, nativeChoices =
        ns.CreateExplorerNativeDropdown(parent, keys, onSelect, width, getSelection)
    if native then
        if native.SetupMenu then
            native:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -12)
        else
            UIDropDownMenu_SetWidth(native, width - 30)
            native:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, -4)
        end
        return native, nativeMenu, nativeChoices
    end
    local button = ns.CreateExplorerClassicButton(parent)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -9)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -9)
    button:SetHeight(28)
    ns.AddExplorerDropdownArrow(button)
    local menu = CreateFrame("Frame", popupName, parent)
    menu:SetSize(width, (#(ns.professionOrder or {}) + 1) * 25 + 8)
    menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -3)
    menu:SetFrameLevel(parent:GetFrameLevel() + 10)
    local background = menu:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.08, 0.08, 0.07, 0.99)
    menu:Hide()
    local choices = {[""] = nil}
    for index = 0, #(ns.professionOrder or {}) do
        local key = index == 0 and "" or ns.professionOrder[index]
        local choice = ns.CreateExplorerClassicButton(menu)
        choice:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4 - index * 25)
        choice:SetSize(width - 8, 24)
        choice:SetScript("OnClick", function()
            menu:Hide()
            if onSelect then onSelect(key) end
        end)
        choices[key] = choice
    end
    button:SetScript("OnClick", function()
        if menu:IsShown() then menu:Hide() else menu:Show() end
    end)
    return button, menu, choices
end
