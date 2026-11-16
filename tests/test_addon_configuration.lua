local frames, menuItems, locale
local function newWidget(kind, name, parent, template)
    local widget = {kind = kind, name = name, parent = parent, template = template,
        text = "", shown = true, enabled = true, scripts = {}, hooks = {}, anchors = {}}
    frames[#frames + 1] = widget
    for _, method in ipairs({
        "EnableMouse", "EnableMouseWheel", "Raise", "RegisterEvent", "UnregisterEvent",
        "RegisterForDrag", "RegisterForClicks", "SetAllPoints", "SetAutoFocus", "SetBackdrop",
        "SetBackdropBorderColor", "SetBackdropColor", "SetColorTexture", "SetFrameStrata",
        "SetHighlightTexture", "SetJustifyH", "SetMaxLetters", "SetMinMaxValues", "SetMovable",
        "SetStatusBarColor", "SetStatusBarTexture", "SetTexCoord", "SetTextColor", "SetTexture",
        "SetValueStep", "SetWordWrap", "SetTextInsets",
    }) do
        widget[method] = function() end
    end
    function widget:SetScript(event, fn) self.scripts[event] = fn end
    function widget:HookScript(event, fn) self.hooks[event] = fn end
    function widget:Emit(event, ...)
        if self.scripts[event] then self.scripts[event](self, ...) end
        if self.hooks[event] then self.hooks[event](self, ...) end
    end
    function widget:Click()
        if not self.enabled or not self:IsVisible() then return end
        if self.kind == "CheckButton" then self.checked = not self.checked end
        self:Emit("OnClick", "LeftButton")
    end
    function widget:SetShown(value)
        local wasShown = self.shown
        self.shown = value
        if wasShown and not value then self:Emit("OnHide") end
    end
    function widget:Hide() self:SetShown(false) end
    function widget:Show() self:SetShown(true) end
    function widget:IsShown() return self.shown end
    function widget:IsVisible() return self.shown and (not parent or parent:IsVisible()) end
    function widget:CreateTexture() return newWidget("Texture", nil, self) end
    function widget:CreateFontString() return newWidget("FontString", nil, self) end
    function widget:SetSize(w, h) self.width, self.height = w, h end
    function widget:SetWidth(w) self.width = w end
    function widget:SetHeight(h) self.height = h end
    function widget:GetWidth() return self.width or 350 end
    function widget:GetHeight() return self.height or 300 end
    function widget:SetScale(value) self.scale = value end
    function widget:GetParent() return parent end
    function widget:SetFrameLevel(value) self.level = value end
    function widget:GetFrameLevel() return self.level or (parent and parent:GetFrameLevel() + 1) or 1 end
    function widget:SetPoint(...) self.anchors[#self.anchors + 1] = {...} end
    function widget:ClearAllPoints() self.anchors = {} end
    function widget:SetText(value)
        self.text = value
        if kind == "EditBox" then self:Emit("OnTextChanged") end
    end
    function widget:GetText() return self.text end
    function widget:SetValue(value) self.value = value end
    function widget:SetEnabled(value) self.enabled = value end
    function widget:SetAlpha(value) self.alpha = value end
    function widget:SetChecked(value) self.checked = value end
    function widget:GetChecked() return self.checked end
    function widget:LockHighlight() self.selected = true end
    function widget:UnlockHighlight() self.selected = false end
    function widget:SetFocus() self.focus = true end
    function widget:ClearFocus() self.focus = false end
    return widget
end

CreateFrame = newWidget
GetLocale = function() return locale end
GetItemInfo = function(id)
    if id == 2770 then return "Copper Ore" end
end
Enum = {TooltipDataType = {Item = 0}}
TooltipDataProcessor = {AddTooltipPostCall = function() end}

local function start(native)
    frames = {}
    UIParent = newWidget("Frame")
    UIParent:SetSize(430, 340)
    Minimap = newWidget("Frame", "Minimap", UIParent)
    Minimap:SetSize(140, 140)
    UIDropDownMenu_Initialize = native and function(frame, build) frame.buildMenu = build end or nil
    UIDropDownMenu_CreateInfo = function() return {} end
    UIDropDownMenu_AddButton = function(info) menuItems[#menuItems + 1] = info end
    UIDropDownMenu_SetWidth = function() end
    UIDropDownMenu_SetText = function(frame, value) frame.text = value end
    CloseDropDownMenus = function() end
    local ns = {}
    for path in io.lines("addon/CraftAtlas/CraftAtlas.toc") do
        if path:match("%.lua$") then assert(loadfile("addon/CraftAtlas/" .. path))("CraftAtlas", ns) end
    end
    frames[#frames]:Emit("OnEvent", "ADDON_LOADED", "CraftAtlas")
    return ns
end

local function find(predicate)
    for _, widget in ipairs(frames) do
        if predicate(widget) then return widget end
    end
end

local function visibleText(text, kind)
    return find(function(widget)
        return widget.text == text and (not kind or widget.kind == kind) and widget:IsVisible()
    end)
end

local function named(name)
    return assert(find(function(widget) return widget.name == name end), name)
end

local function click(text)
    assert(visibleText(text, "Button"), text):Click()
end

local function findSelector(current)
    return find(function(widget)
        return widget.text == current and widget:IsVisible()
            and (widget.buildMenu or widget.dropdownArrow)
    end)
end

local function choose(current, option)
    local selector = assert(findSelector(current), current)
    if selector.buildMenu then
        menuItems = {}
        selector.buildMenu(selector, 1)
        for _, info in ipairs(menuItems) do
            if info.text:match("^%s*(.-)%s*$") == option then info.func(); return end
        end
        error("missing native option: " .. option)
    end
    selector:Click()
    local choice = assert(find(function(widget)
        return widget.kind == "Button" and widget:IsVisible() and widget.parent
            and widget.parent.anchors[1] and widget.parent.anchors[1][2] == selector
            and widget.text:match("^%s*(.-)%s*$") == option
    end), option)
    choice:Click()
end

local function checkbox(label)
    local text = assert(visibleText(label, "FontString"), label)
    local button = text.anchors[1][2]
    assert(button.template == "UICheckButtonTemplate" and button:IsVisible())
    return button
end

locale = "enUS"
CraftAtlasDB = nil
local ns = start(true)
local defaults = {showMinimapButton = true, showTooltipProfessions = true,
    hideTooltipProfessionIcons = false, tooltipProfessionsOnOneLine = false}
for key, expected in pairs(defaults) do assert(ns.GetDisplayPreference(key) == expected, key) end
local tracking = {["Realm:Name"] = {recipe = true}}
CraftAtlasDB = {language = "enUS", minimapAngle = -90, craftTracking = tracking}
local legacy = ns.InitPreferences()
assert(legacy.language == "enUS" and legacy.minimapAngle == -90 and legacy.craftTracking == tracking)
for key, expected in pairs(defaults) do assert(legacy[key] == expected, key) end
legacy.showTooltipProfessions = false
legacy.showMinimapButton = "false"
legacy.hideTooltipProfessionIcons = true
legacy.tooltipProfessionsOnOneLine = 1
ns.InitPreferences()
assert(legacy.showMinimapButton and not legacy.showTooltipProfessions
    and legacy.hideTooltipProfessionIcons and legacy.tooltipProfessionsOnOneLine == false)
assert(ns.GetDisplayPreference("showTooltipProfessions") == false)

for _, native in ipairs({true, false}) do
    locale = "frFR"
    CraftAtlasDB = {minimapAngle = -90}
    ns = start(native)
    SlashCmdList.CRAFTATLAS("")
    local window = named("CraftAtlasSettingsFrame")
    local minimapButton = named("CraftAtlasMinimapButton")
    local search = assert(find(function(widget) return widget.kind == "EditBox" end))
    assert(window.scale < 1 and window.width * window.scale < UIParent.width)
    local config = assert(visibleText("Configuration", "Button"))
    local tab = assert(visibleText("Materials", "Button"))
    local status = assert(find(function(widget) return widget.kind == "StatusBar" end))
    assert(-config.anchors[1][5] + config.height < -tab.anchors[1][5]
        and config.width + config.anchors[1][4] < window.width - 30,
        "Configuration must fit above the toolbar and clear the window close button")

    search:SetText("2770")
    search:SetFocus()
    choose("All professions", "Mining")
    assert(visibleText("Copper Ore", "FontString") and status:IsVisible())
    click("Configuration")
    assert(window:IsVisible() and visibleText("General") and visibleText("Tooltip"))
    assert(not search.focus and not search:IsVisible() and not status:IsVisible())
    local minimap = checkbox("Show minimap button")
    assert(minimap:GetChecked())
    minimap:Click()
    assert(not minimapButton:IsVisible())
    local icons = checkbox("Hide profession icons")
    local single = checkbox("Show professions on one line")
    icons:Click()
    single:Click()
    local professions = checkbox("Show consuming professions")
    professions:Click()
    assert(not icons.enabled and not single.enabled and icons:GetChecked() and single:GetChecked())
    icons:Click()
    professions:Click()
    assert(icons.enabled and single.enabled and icons:GetChecked() and single:GetChecked())
    professions:Click()
    choose("Automatic", "Español")
    assert(visibleText("Información emergente") and visibleText("Mostrar botón del minimapa"))
    click("Volver")
    assert(search:IsVisible() and search.text == "2770" and status:IsVisible())
    assert(visibleText("Copper Ore", "FontString") and findSelector("Español") and findSelector("Minería"))
    assert(not visibleText("Volver", "Button"), "Configuration must not add history")
    choose("Español", "Automático")
    assert(visibleText("Materials", "Button"))
    click("Configuration")
    assert(visibleText("Automatic") and visibleText("Tooltip"), "Auto falls back to English")
    click("Back")

    local use = ns.GetRecipeUses(2770)[1]
    ns.NavigateToRecipe(use)
    local recipe = ns.GetCatalogRecipe(ns.RecipeKey(use.professionKey, use.spellID))
    search:SetText(tostring(use.spellID))
    choose("All professions", ns.ProfessionLabel(use.professionKey))
    assert(visibleText("Craftables", "Button").selected and recipe)
    local recipeLabel = assert(find(function(widget)
        return widget.kind == "FontString" and widget:IsVisible()
            and widget.text:find("Recipe " .. use.spellID, 1, true)
    end), "selected recipe")
    local output = recipeLabel.text
    click("Configuration")
    click("Back")
    assert(search.text == tostring(use.spellID) and recipeLabel:IsVisible() and recipeLabel.text == output)
    assert(findSelector(ns.ProfessionLabel(use.professionKey)))
    click("Back")
    assert(search.text == "2770" and visibleText("Materials", "Button").selected)

    ns.SetLanguage("esES")
    ns = start(native)
    local restored = named("CraftAtlasMinimapButton")
    assert(not restored:IsVisible(), "minimap visibility survives reload")
    SlashCmdList.CRAFTATLAS("")
    click("Configuración")
    assert(visibleText("Español"))
    assert(not checkbox("Mostrar las profesiones que usan el material"):GetChecked())
    local savedIcons = checkbox("Ocultar iconos de profesión")
    local savedSingle = checkbox("Mostrar profesiones en una sola línea")
    assert(savedIcons:GetChecked() and not savedIcons.enabled and savedSingle:GetChecked() and not savedSingle.enabled)
    checkbox("Mostrar botón del minimapa"):Click()
    assert(restored:IsVisible() and ns.GetMinimapAngle() == -90)
    assert(math.abs(restored.anchors[1][4]) < 0.00001 and restored.anchors[1][5] == -70)
    checkbox("Mostrar botón del minimapa"):Click()
    checkbox("Mostrar botón del minimapa"):Click()
    assert(ns.InitMinimapButton())
    local count = 0
    for _, widget in ipairs(frames) do
        if widget.name == "CraftAtlasMinimapButton" then count = count + 1 end
    end
    assert(count == 1, "repeated visibility changes must reuse the minimap button")
    window = named("CraftAtlasSettingsFrame")
    window.CloseButton:Click()
    restored:Click()
    assert(window:IsVisible() and visibleText("Materiales", "Button").selected)
end

print("Addon configuration, shared selectors, explorer state and minimap persistence PASS")
