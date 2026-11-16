local _, ns = ...

-- Shared native controls. A view supplies values and callbacks; no domain dependency.

function ns.GetExplorerClearIcon(fileLookup)
    -- Historical native broom artwork may vary between Classic/Forever clients.
    local candidates = {
        "Interface\\Icons\\Achievement_Halloween_Witch_01",
        "Interface\\Icons\\INV_Misc_Broom_01",
    }
    local probe = fileLookup or GetFileIDFromPath
    if type(probe) == "function" then
        for _, path in ipairs(candidates) do
            local ok, fileID = pcall(probe, path)
            if ok and type(fileID) == "number" and fileID > 0 then return path end
        end
    end
    -- Available native cleansing/action icon, never missing art or a textual X.
    return "Interface\\Icons\\Spell_Holy_DispelMagic"
end

-- A minimum logical size is scaled uniformly for smaller physical viewports.
function ns.ExplorerWindowGeometry(viewportWidth, viewportHeight)
    local width = math.min(740, math.max(600, viewportWidth - 50))
    local height = math.min(510, math.max(440, viewportHeight - 60))
    local scale = math.min(1, (viewportWidth - 24) / width, (viewportHeight - 24) / height)
    return width, height, math.max(0.2, scale)
end

-- The shell reserves 137 px above the list, 30 px below it, 76 px
-- for the filter and heading, and 16 px for the bottom status.
function ns.ExplorerVisibleRowCount(windowHeight, rowHeight)
    local rows = math.floor((windowHeight - 167 - 76 - 16) / rowHeight)
    return math.max(2, math.min(9, rows))
end

-- Keep profession metadata and the fabrication header in separate vertical bands.
function ns.MaterialDetailSectionOffsets(availableHeight)
    if availableHeight < 270 then return -138, -160 end
    return -151, -174
end

function ns.CreateExplorerRow(parent, height, onClick)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(height)
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.09, 0.08, 0.07, 0.55)
    row.itemBackground = bg
    local groupBackground = row:CreateTexture(nil, "BACKGROUND")
    groupBackground:SetAllPoints()
    groupBackground:SetColorTexture(0.16, 0.13, 0.09, 0.98)
    groupBackground:Hide()
    row.groupBackground = groupBackground
    local edge = row:CreateTexture(nil, "BORDER")
    edge:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT")
    edge:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT")
    edge:SetHeight(1)
    edge:SetColorTexture(0.48, 0.38, 0.24, 0.85)
    local hover = row:CreateTexture(nil, "BACKGROUND")
    hover:SetAllPoints()
    hover:SetColorTexture(0.42, 0.32, 0.14, 0.58)
    row:SetHighlightTexture(hover)
    local selected = row:CreateTexture(nil, "BACKGROUND")
    selected:SetAllPoints()
    selected:SetColorTexture(0.48, 0.34, 0.10, 0.55)
    selected:Hide()
    row.highlight = selected
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(30, 30)
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 39, -4)
    row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -4)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.professions = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.professions:SetPoint("TOPLEFT", row, "TOPLEFT", 39, -22)
    row.professions:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -22)
    row.professions:SetJustifyH("LEFT")
    row.professions:SetWordWrap(false)
    row.groupArrow = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.groupArrow:SetPoint("LEFT", row, "LEFT", 5, 0)
    row.groupArrow:SetTextColor(0.95, 0.70, 0.16)
    row.groupName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.groupName:SetPoint("LEFT", row, "LEFT", 24, 0)
    row.groupName:SetPoint("RIGHT", row, "RIGHT", -24, 0)
    row.groupName:SetJustifyH("LEFT")
    row.groupName:SetWordWrap(false)
    row.groupName:SetTextColor(1, 0.82, 0.30)
    row.groupState = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.groupState:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    for _, element in ipairs({row.groupArrow, row.groupName, row.groupState}) do
        element:Hide()
    end
    row:SetScript("OnClick", function(self) if onClick then onClick(self) end end)
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
    LEATHERWORKING = "Interface\\Icons\\Trade_LeatherWorking",
    MINING = "Interface\\Icons\\Trade_Mining",
    TAILORING = "Interface\\Icons\\Trade_Tailoring",
}

function ns.GetExplorerProfessionIcon(key)
    return professionIcons[key] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Group rows have their own header treatment; they never masquerade as item rows.
function ns.StyleExplorerGroupRow(row, label, count, expanded)
    row.groupBackground:Show()
    row.itemBackground:Hide()
    row.icon:Hide()
    row.name:Hide()
    row.professions:Hide()
    row.highlight:Hide()
    row.groupArrow:SetText(expanded and "▼" or "▶")
    row.groupName:SetText(label .. " (" .. count .. ")")
    row.groupState:SetText(expanded and "−" or "+")
    row.groupArrow:Show()
    row.groupName:Show()
    row.groupState:Show()
end

function ns.StyleExplorerItemRow(row)
    row.groupBackground:Hide()
    row.itemBackground:Show()
    row.groupArrow:Hide()
    row.groupName:Hide()
    row.groupState:Hide()
    row.name:Show()
    row.professions:Show()
end

-- Section headers share one dark bar, gold separator and collapse affordance.
function ns.CreateExplorerSection(parent, titleKey, top, onToggle)
    local section = CreateFrame("Button", nil, parent)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, top)
    section:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, top)
    section:SetHeight(27)
    local bg = section:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.13, 0.11, 0.09, 0.96)
    local edge = section:CreateTexture(nil, "BORDER")
    edge:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT")
    edge:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT")
    edge:SetHeight(1)
    edge:SetColorTexture(0.64, 0.48, 0.22, 0.8)
    section.label = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.label:SetPoint("LEFT", section, "LEFT", 9, 0)
    section.arrow = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    section.arrow:SetPoint("RIGHT", section, "RIGHT", -7, 0)
    section.expanded = true
    function section:Refresh()
        self.label:SetText(ns.L(titleKey))
        self.arrow:SetText(self.expanded and "−" or "+")
    end
    section:SetScript("OnClick", function(self)
        self.expanded = not self.expanded
        self:Refresh()
        if onToggle then onToggle(self.expanded) end
    end)
    section:Refresh()
    return section
end

function ns.CreateExplorerPager(parent, onPrevious, onNext)
    local previous = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    previous:SetSize(76, 24)
    previous:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 14, 9)
    previous:SetScript("OnClick", function() if onPrevious then onPrevious() end end)
    local nextButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
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

function ns.CreateExplorerSearchBox(header, onChange)
    local search = CreateFrame("EditBox", nil, header, "InputBoxTemplate")
    search:SetPoint("LEFT", header, "LEFT", 13, 0)
    search:SetSize(185, 28)
    search:SetAutoFocus(false)
    search:SetMaxLetters(120)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    search:SetScript("OnTextChanged", function(self)
        if onChange then onChange(self:GetText()) end
    end)
    return search
end

function ns.CreateExplorerProfessionFilter(parent, anchor, onSelect)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", anchor, "TOPLEFT", 8, -9)
    button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -8, -9)
    button:SetHeight(28)
    local menu = CreateFrame("Frame", nil, parent)
    menu:SetSize(225, (#(ns.professionOrder or {}) + 1) * 25 + 8)
    menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -3)
    menu:SetFrameLevel(anchor:GetFrameLevel() + 10)
    local background = menu:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.08, 0.08, 0.07, 0.99)
    menu:Hide()
    local choices = {[""] = nil}
    for index = 0, #(ns.professionOrder or {}) do
        local key = index == 0 and "" or ns.professionOrder[index]
        local choice = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
        choice:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4 - index * 25)
        choice:SetSize(217, 24)
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
