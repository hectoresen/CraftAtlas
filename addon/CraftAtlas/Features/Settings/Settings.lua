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

local function createSearchAffordance(header)
    local search = CreateFrame("Button", nil, header)
    search:SetPoint("TOPLEFT", header, "TOPLEFT", 8, -7)
    search:SetSize(190, 28)
    search:EnableMouse(true)
    search:SetScript("OnEnter", function()
        if ns.SetSearchUnavailableCursor then
            ns.SetSearchUnavailableCursor()
        end
    end)
    search:SetScript("OnLeave", function()
        if ns.ClearSearchUnavailableCursor then
            ns.ClearSearchUnavailableCursor()
        end
    end)

    local background = search:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.06, 0.06, 0.06, 0.72)

    local label = search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    label:SetPoint("LEFT", search, "LEFT", 10, 0)
    label:SetJustifyH("LEFT")
    label:SetText(ns.L("SEARCH_PLACEHOLDER"))
    search.label = label
    return search
end

local function createPanel()
    if panel then
        return panel
    end

    local ok, window = pcall(CreateFrame, "Frame", "CraftAtlasSettingsFrame",
        UIParent, "BasicFrameTemplateWithInset")
    if not ok or not window then
        window = CreateFrame("Frame", "CraftAtlasSettingsFrame", UIParent)
        local background = window:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.09, 0.09, 0.09, 0.96)
    end

    panel = window
    panel:SetSize(560, 340)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    panel:Hide()

    if panel.TitleText then
        panel.TitleText:Hide()
    end

    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -38)
    header:SetSize(536, 52)
    header:SetFrameLevel(panel:GetFrameLevel() + 1)
    local headerBackground = header:CreateTexture(nil, "BACKGROUND")
    headerBackground:SetAllPoints()
    headerBackground:SetColorTexture(0.12, 0.10, 0.07, 0.98)
    local headerDivider = header:CreateTexture(nil, "ARTWORK")
    headerDivider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    headerDivider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    headerDivider:SetHeight(2)
    headerDivider:SetColorTexture(0.78, 0.58, 0.20, 0.90)
    elements.header = header

    elements.search = createSearchAffordance(header)

    elements.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    elements.title:SetPoint("CENTER", header, "CENTER", 0, 0)
    elements.title:SetTextColor(1.0, 0.82, 0.30)

    if not panel.CloseButton then
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    end

    local selector = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
    selector:SetPoint("TOPRIGHT", header, "TOPRIGHT", -8, -13)
    selector:SetSize(118, 26)
    elements.selector = selector

    local menu = CreateFrame("Frame", nil, panel)
    menu:SetPoint("TOPRIGHT", selector, "BOTTOMRIGHT", 0, -3)
    menu:SetSize(118, 87)
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
        choice:SetSize(114, 27)
        choice:SetScript("OnClick", function()
            ns.SetLanguage(value)
            menu:Hide()
        end)
        elements.choices[value] = choice
    end

    local sidebar = CreateFrame("Frame", nil, panel)
    sidebar:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -98)
    sidebar:SetSize(120, 180)
    local divider = sidebar:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, 0)
    divider:SetSize(1, 180)
    divider:SetColorTexture(0.4, 0.35, 0.26, 0.55)
    elements.navigation = text(sidebar, "GameFontNormal", 9, -12)

    elements.heading = text(panel, "GameFontNormalLarge", 160, -114)
    elements.heading:SetWidth(360)
    elements.heading:SetJustifyH("CENTER")
    elements.comingSoon = text(panel, "GameFontHighlight", 160, -190)
    elements.comingSoon:SetWidth(360)
    elements.comingSoon:SetJustifyH("CENTER")

    local version = text(panel, "GameFontDisableSmall", 18, -314)
    version:SetText("v" .. ns.version)
    panel:SetScript("OnHide", function() menu:Hide() end)
    return panel
end

function ns.RefreshSettings()
    if not panel then return end
    elements.title:SetText(ns.L("TITLE"))
    elements.search.label:SetText(ns.L("SEARCH_PLACEHOLDER"))
    elements.navigation:SetText(ns.L("GENERAL"))
    elements.heading:SetText(ns.L("GENERAL"))
    elements.comingSoon:SetText(ns.L("COMING_SOON"))

    local selected = ns.GetLanguage()
    local effectiveLanguage = ns.ResolveLocale(selected, ns.GetClientLocale())
    elements.selector:SetText(ns.L(labels[effectiveLanguage]))
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
