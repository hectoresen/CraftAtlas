local _, ns = ...

local function addLabel(parent, font, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return label
end

function ns.CreatePreferencesPanel()
    local panel = CreateFrame("Frame")
    panel:Hide()

    local general = addLabel(panel, "GameFontNormalLarge", 24, -22)
    local languageLabel = addLabel(panel, "GameFontHighlight", 28, -58)
    local languageSlot = CreateFrame("Frame", nil, panel)
    languageSlot:SetSize(148, 32)
    languageSlot:SetPoint("TOPLEFT", panel, "TOPLEFT", 112, -45)
    local language = ns.CreateExplorerLanguageSelector(languageSlot)
    local tooltip = addLabel(panel, "GameFontNormalLarge", 24, -130)

    local boxes = {}
    local function addCheckbox(key, labelKey, x, y, needsProfessions)
        local button = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        button:SetSize(24, 24)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("TOPLEFT", button, "TOPRIGHT", 6, -5)
        label:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -24, y - 5)
        label:SetJustifyH("LEFT")
        button:SetScript("OnClick", function(self)
            ns.SetDisplayPreference(key, self:GetChecked() and true or false)
            if key == "showMinimapButton" then ns.InitMinimapButton() end
            panel:Refresh()
        end)
        boxes[#boxes + 1] = {key = key, labelKey = labelKey, button = button,
            label = label, needsProfessions = needsProfessions}
    end

    addCheckbox("showMinimapButton", "CONFIG_SHOW_MINIMAP", 24, -86)
    addCheckbox("showTooltipProfessions", "CONFIG_SHOW_TOOLTIP_PROFESSIONS", 24, -158)
    addCheckbox("hideTooltipProfessionIcons", "CONFIG_HIDE_PROFESSION_ICONS", 42, -192, true)
    addCheckbox("tooltipProfessionsOnOneLine", "CONFIG_SINGLE_LINE", 42, -226, true)

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

    panel:SetScript("OnShow", panel.Refresh)
    panel:SetScript("OnHide", language.CloseMenu)
    return panel
end
