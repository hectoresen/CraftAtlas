local _, ns = ...
local panel
local elements = {}

local options = {"auto", "esES", "enUS"}
local labels = {auto = "AUTO", esES = "SPANISH", enUS = "ENGLISH"}

local function text(parent, font, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return label
end

local function createPanel()
    if panel then
        return panel
    end

    -- Native visual primitives. Template availability is checked at runtime
    -- because Forever is a modern client with its own frame implementations.
    local ok, window = pcall(CreateFrame, "Frame", "CraftAtlasSettingsFrame",
        UIParent, "BasicFrameTemplateWithInset")
    if not ok or not window then
        window = CreateFrame("Frame", "CraftAtlasSettingsFrame", UIParent)
        local background = window:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.09, 0.09, 0.09, 0.96)
    end

    panel = window
    panel:SetSize(440, 264)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    panel:Hide()

    if panel.TitleText then
        elements.title = panel.TitleText
    else
        elements.title = text(panel, "GameFontNormalLarge", 16, -12)
    end

    if not panel.CloseButton then
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
        close:SetScript("OnClick", function() panel:Hide() end)
    end

    local sidebar = CreateFrame("Frame", nil, panel)
    sidebar:SetPoint("TOPLEFT", 14, -43)
    sidebar:SetSize(110, 175)
    local divider = sidebar:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, 0)
    divider:SetSize(1, 175)
    divider:SetColorTexture(0.4, 0.35, 0.26, 0.55)
    elements.navigation = text(sidebar, "GameFontNormal", 9, -12)

    elements.heading = text(panel, "GameFontNormalLarge", 140, -53)
    elements.language = text(panel, "GameFontNormal", 140, -99)
    elements.help = text(panel, "GameFontHighlightSmall", 140, -168)
    elements.help:SetWidth(265)
    elements.help:SetJustifyH("LEFT")
    elements.help:SetWordWrap(true)

    local selector = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    selector:SetPoint("TOPLEFT", 140, -118)
    selector:SetSize(224, 28)
    elements.selector = selector

    local menu = CreateFrame("Frame", nil, panel)
    menu:SetPoint("TOPLEFT", selector, "BOTTOMLEFT", 0, -3)
    menu:SetSize(224, 87)
    menu:SetFrameLevel(selector:GetFrameLevel() + 2)
    local surface = menu:CreateTexture(nil, "BACKGROUND")
    surface:SetAllPoints()
    surface:SetColorTexture(0.12, 0.12, 0.12, 0.98)
    menu:Hide()
    elements.menu = menu

    selector:SetScript("OnClick", function()
        if menu:IsShown() then menu:Hide() else menu:Show() end
    end)

    elements.choices = {}
    for index, value in ipairs(options) do
        local choice = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
        choice:SetPoint("TOPLEFT", 2, -2 - (index - 1) * 28)
        choice:SetSize(220, 27)
        choice:SetScript("OnClick", function()
            ns.SetLanguage(value)
            menu:Hide()
        end)
        elements.choices[value] = choice
    end

    local version = text(panel, "GameFontDisableSmall", 18, -237)
    version:SetText("v" .. ns.version)
    panel:SetScript("OnHide", function() menu:Hide() end)
    return panel
end

function ns.RefreshSettings()
    if not panel then return end
    elements.title:SetText(ns.L("TITLE"))
    elements.navigation:SetText(ns.L("GENERAL"))
    elements.heading:SetText(ns.L("GENERAL"))
    elements.language:SetText(ns.L("LANGUAGE"))
    elements.help:SetText(ns.L("LANGUAGE_HELP"))

    local selected = ns.GetLanguage()
    elements.selector:SetText(ns.L(labels[selected]))
    for _, option in ipairs(options) do
        local prefix = option == selected and "> " or "   "
        elements.choices[option]:SetText(prefix .. ns.L(labels[option]))
    end
end

function ns.OpenSettings()
    local window = createPanel()
    ns.RefreshSettings()
    window:Show()
    window:Raise()
end

function ns.InitSettings()
    SLASH_CRAFTATLAS1 = "/craftatlas"
    SlashCmdList = SlashCmdList or {}
    SlashCmdList.CRAFTATLAS = ns.OpenSettings
end
