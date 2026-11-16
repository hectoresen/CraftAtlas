local _, ns = ...

local function addLabel(parent, font, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return label
end

function ns.CreatePreferencesPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -137)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -14, 30)
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.075, 0.064, 0.055, 0.88)

    local general = addLabel(panel, "GameFontNormalLarge", 18, -16)
    local languageLabel = addLabel(panel, "GameFontHighlight", 22, -52)
    local languageSlot = CreateFrame("Frame", nil, panel)
    languageSlot:SetSize(148, 32)
    languageSlot:SetPoint("TOPLEFT", panel, "TOPLEFT", 104, -39)
    local language = ns.CreateExplorerLanguageSelector(languageSlot)
    local tooltip = addLabel(panel, "GameFontNormalLarge", 18, -122)

    local boxes = {}
    local function addCheckbox(key, labelKey, x, y, needsProfessions)
        local button = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        button:SetSize(24, 24)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", button, "RIGHT", 6, 0)
        button:SetScript("OnClick", function(self)
            ns.SetDisplayPreference(key, self:GetChecked() and true or false)
            if key == "showMinimapButton" then ns.InitMinimapButton() end
            panel:Refresh()
        end)
        boxes[#boxes + 1] = {key = key, labelKey = labelKey, button = button,
            label = label, needsProfessions = needsProfessions}
    end

    addCheckbox("showMinimapButton", "CONFIG_SHOW_MINIMAP", 18, -79)
    addCheckbox("showTooltipProfessions", "CONFIG_SHOW_TOOLTIP_PROFESSIONS", 18, -148)
    addCheckbox("hideTooltipProfessionIcons", "CONFIG_HIDE_PROFESSION_ICONS", 36, -179, true)
    addCheckbox("tooltipProfessionsOnOneLine", "CONFIG_SINGLE_LINE", 36, -210, true)

    function panel:Refresh()
        general:SetText(ns.L("GENERAL"))
        languageLabel:SetText(ns.L("LANGUAGE"))
        tooltip:SetText(ns.L("CONFIG_TOOLTIP"))
        language.Refresh()
        local showProfessions = ns.GetDisplayPreference("showTooltipProfessions")
        for _, box in ipairs(boxes) do
            local enabled = showProfessions or not box.needsProfessions
            box.button:SetEnabled(enabled)
            box.button:SetChecked(ns.GetDisplayPreference(box.key))
            box.label:SetText(ns.L(box.labelKey))
            box.label:SetAlpha(enabled and 1 or 0.5)
        end
    end

    panel:SetScript("OnHide", language.CloseMenu)
    panel:Hide()
    return panel
end
