local _, ns = ...

-- Shared native controls. A view supplies values and callbacks; no domain dependency.
function ns.CreateExplorerRow(parent, height, onClick)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(height)
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.12, 0.10, 0.07, 0.82)
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
    row:SetScript("OnClick", function(self) if onClick then onClick(self) end end)
    return row
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
