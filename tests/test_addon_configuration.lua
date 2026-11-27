local frames, menuItems, locale, escapeHandlers, minimalTabs
local function newWidget(kind, name, parent, template)
    local widget = {kind = kind, name = name, parent = parent, template = template,
        text = "", shown = true, enabled = true, scripts = {}, hooks = {}, anchors = {}}
    frames[#frames + 1] = widget
    if name then _G[name] = widget end
    for _, method in ipairs({
        "EnableMouse", "EnableMouseWheel", "Raise", "RegisterEvent", "UnregisterEvent",
        "RegisterForDrag", "RegisterForClicks", "SetAllPoints", "SetAutoFocus", "SetBackdrop",
        "SetBackdropBorderColor", "SetBackdropColor", "SetColorTexture", "SetVertexColor",
        "SetHighlightTexture", "SetJustifyH", "SetMaxLetters", "SetMinMaxValues", "SetMovable",
        "SetStatusBarColor", "SetStatusBarTexture", "SetTexCoord", "SetTextColor",
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
        if not wasShown and value then self:Emit("OnShow") end
    end
    function widget:Hide() self:SetShown(false) end
    function widget:Show() self:SetShown(true) end
    function widget:IsShown() return self.shown end
    function widget:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
    function widget:CreateTexture() return newWidget("Texture", nil, self) end
    function widget:CreateFontString(_, _, fontTemplate)
        return newWidget("FontString", nil, self, fontTemplate)
    end
    function widget:SetSize(w, h) self.width, self.height = w, h end
    function widget:SetWidth(w) self.width = w end
    function widget:SetHeight(h) self.height = h end
    function widget:GetWidth() return self.width or 350 end
    function widget:GetHeight() return self.height or 300 end
    function widget:SetScale(value) self.scale = value end
    function widget:GetParent() return self.parent end
    function widget:SetParent(value) self.parent = value end
    function widget:GetChildren()
        local children = {}
        for _, candidate in ipairs(frames) do
            if candidate.parent == self and candidate.kind ~= "Texture" and candidate.kind ~= "FontString" then
                children[#children + 1] = candidate
            end
        end
        return unpack(children)
    end
    function widget:SetFrameStrata(value) self.strata = value end
    function widget:GetFrameStrata()
        return self.strata or (template == "UIPanelScrollBarTemplate" and "TOOLTIP")
            or (self.parent and self.parent:GetFrameStrata()) or "MEDIUM"
    end
    function widget:SetClipsChildren(value) self.clipsChildren = value end
    function widget:SetFrameLevel(value) self.level = value end
    function widget:GetFrameLevel() return self.level or (parent and parent:GetFrameLevel() + 1) or 1 end
    function widget:SetPoint(...) self.anchors[#self.anchors + 1] = {...} end
    function widget:ClearAllPoints() self.anchors = {} end
    function widget:SetText(value)
        self.text = value
        if kind == "EditBox" then self:Emit("OnTextChanged") end
    end
    function widget:SetTexture(value) self.texture = value end
    function widget:SetAtlas(value) self.atlas = value end
    function widget:GetText() return self.text end
    function widget:GetStringWidth() return #self.text * 7 end
    function widget:SetValue(value) self.value = value end
    function widget:SetEnabled(value) self.enabled = value end
    function widget:SetAlpha(value) self.alpha = value end
    function widget:SetChecked(value) self.checked = value end
    function widget:GetChecked() return self.checked end
    function widget:LockHighlight() self.selected = true end
    function widget:UnlockHighlight() self.selected = false end
    function widget:SetFocus() self.focus = true end
    function widget:ClearFocus() self.focus = false end
    if kind == "DropdownButton" then
        function widget:SetupMenu(build) self.buildModernMenu = build end
        function widget:IsMenuOpen() return self.menuOpen end
        function widget:CloseMenu() self.menuOpen = false end
    end
    if template == "MinimalTabTemplate" then
        widget.Text = widget:CreateFontString()
        function widget:SetSelected(value) self.selected = value end
    end
    if template == "SettingsFrameTemplate" then
        widget.NineSlice = newWidget("Frame", nil, widget)
        widget.NineSlice.Text = widget.NineSlice:CreateFontString()
        widget.ClosePanelButton = newWidget("Button", nil, widget)
    end
    return widget
end

CreateFrame = function(kind, name, parent, template)
    if template == "MinimalTabTemplate" and not minimalTabs then error("template unavailable") end
    return newWidget(kind, name, parent, template)
end
GetLocale = function() return locale end
GetItemInfo = function(id)
    if id == 2770 then return "Copper Ore", nil, 1, 10, nil, "Objeto comerciable" end
end
Enum = {TooltipDataType = {Item = 0}}
TooltipDataProcessor = {AddTooltipPostCall = function() end}

local function registerNativeEscape(priority, handler)
    escapeHandlers[#escapeHandlers + 1] = {priority = priority, handler = handler}
    table.sort(escapeHandlers, function(left, right) return left.priority < right.priority end)
end

local function start(native, optionsAPI, settingsEnvironment)
    if not settingsEnvironment then SlashCmdList = {} end
    SLASH_CRAFTATLAS1 = nil
    frames = {}
    escapeHandlers = {}
    local modern = native == "forever"
    minimalTabs = modern
    local nativeEscape = modern or native == "forever-fallback"
    UISpecialFrames, UIMenus = {}, {}
    CraftAtlasSettingsFrame, CraftAtlasExplorerEscapeFrame = nil, nil
    CraftAtlasProfessionPopup = nil
    UIParent = newWidget("Frame")
    UIParent:SetSize(430, 340)
    Minimap = newWidget("Frame", "Minimap", UIParent)
    Minimap:SetSize(140, 140)
    UIDropDownMenu_Initialize = native and not modern and function(frame, build) frame.buildMenu = build end or nil
    UIDropDownMenu_CreateInfo = function() return {} end
    UIDropDownMenu_AddButton = function(info) menuItems[#menuItems + 1] = info end
    UIDropDownMenu_SetWidth = function() end
    UIDropDownMenu_SetText = function(frame, value) frame.text = value end
    DropDownList1 = nil
    if native == true then
        DropDownList1 = newWidget("Frame", "DropDownList1", UIParent)
        DropDownList1:Hide()
        UIMenus[1] = "DropDownList1"
    end
    CloseDropDownMenus = function() if DropDownList1 then DropDownList1:Hide() end end
    MenuUtil = modern and {} or nil
    GameMenuEscPriority = nativeEscape and {Dialog = 1, Menu = 2, AddOn = 8} or nil
    RegisterGameMenuEscHandler = nativeEscape and function()
        error("CraftAtlas must not register a handler in the game's Escape dispatcher")
    end or nil
    if modern then
        registerNativeEscape(GameMenuEscPriority.Menu, function()
            for _, widget in ipairs(frames) do
                if widget.kind == "DropdownButton" and widget:IsMenuOpen() then
                    widget:CloseMenu()
                    return true
                end
            end
        end)
    end
    local registry = {canvases = 0, categories = {}}
    Settings = nil
    if optionsAPI then
        Settings = { RegisterCanvasLayoutCategory = function(panel, name)
            assert(CraftAtlasDB and type(CraftAtlasDB.showMinimapButton) == "boolean",
                "register only after preferences are ready")
            assert(not panel:IsShown() and panel:GetParent() == nil)
            registry.canvases = registry.canvases + 1
            return {panel = panel, name = name, GetID = function() return 17 end}
        end }
        if optionsAPI == "available" then
            Settings.RegisterAddOnCategory = function(category)
                assert(not registry.categories[category.name])
                registry.categories[category.name] = category
            end
            Settings.OpenToCategory = function(id)
                local category = assert(registry.categories.CraftAtlas)
                assert(id == category:GetID())
                registry.openedID = id
                local panel = category.panel
                if not panel:GetParent() then panel:SetParent(newWidget("Frame", "SettingsCanvas", UIParent)) end
                panel:Show()
            end
        end
    end
    local ns = {}
    for path in io.lines("addon/CraftAtlas/CraftAtlas.toc") do
        if path:match("%.lua$") then
            local loadModule = assert(loadfile("addon/CraftAtlas/" .. path))
            if settingsEnvironment and path == "Features/Settings/Settings.lua" then
                setfenv(loadModule, settingsEnvironment)
            end
            loadModule("CraftAtlas", ns)
        end
    end
    frames[#frames]:Emit("OnEvent", "ADDON_LOADED", "CraftAtlas")
    return ns, registry
end

local function find(predicate)
    for _, widget in ipairs(frames) do
        if predicate(widget) then return widget end
    end
end

local function visibleText(text, kind)
    return find(function(widget)
        local label = widget.Text and widget.Text.text or widget.text
        return label == text and (not kind or widget.kind == kind) and widget:IsVisible()
    end)
end

local function named(name)
    return assert(find(function(widget) return widget.name == name end), name)
end

local function click(text)
    assert(visibleText(text, "Button"), text):Click()
end

local function inside(widget, root)
    while widget do
        if widget == root then return true end
        widget = widget:GetParent()
    end
    return false
end

local function findSelector(current, root)
    return find(function(widget)
        return widget.text == current and widget:IsVisible()
            and (widget.buildModernMenu or widget.buildMenu or widget.dropdownArrow) and inside(widget, root)
    end)
end

local function openDropdown(current, root)
    local selector = assert(findSelector(current, root), current)
    if selector.buildModernMenu then
        local items = {}
        local function addItem(_, label, onSelect, key, checked)
            items[#items + 1] = {text = label, checked = checked, func = function()
                onSelect(key)
                selector:CloseMenu()
            end}
        end
        selector.buildModernMenu(selector, {CreateButton = addItem,
            CreateRadio = function(menu, label, isSelected, onSelect, key)
                addItem(menu, label, onSelect, key, isSelected(key))
            end})
        selector.menuOpen = true
        return {IsShown = function() return selector:IsMenuOpen() end,
            Hide = function() selector:CloseMenu() end}, items
    end
    if selector.buildMenu then
        menuItems = {}
        selector.buildMenu(selector, 1)
        DropDownList1.dropdown = selector
        DropDownList1:Show()
        return DropDownList1, menuItems
    end
    selector:Click()
    local popup = assert(find(function(widget)
        return widget.kind == "Frame" and widget:IsVisible()
            and widget.anchors[1] and widget.anchors[1][2] == selector
    end), current)
    local items = {}
    for _, widget in ipairs(frames) do
        if widget.kind == "Button" and widget.parent == popup and widget:IsVisible() then
            local check = find(function(marker)
                return marker.parent == widget and marker.texture == "Interface\\Buttons\\UI-CheckBox-Check"
            end)
            items[#items + 1] = {text = widget.text, checked = check and check:IsShown(),
                func = function() widget:Click() end}
        end
    end
    return popup, items
end

local function pressEscape(search)
    if search and search.focus then
        search:Emit("OnEscapePressed")
        return true
    end
    if RegisterGameMenuEscHandler then
        for _, entry in ipairs(escapeHandlers) do
            if entry.handler() then return true end
        end
    end
    for _, registry in ipairs({UIMenus, UISpecialFrames}) do
        local handled = false
        for _, name in ipairs(registry) do
            local widget = _G[name]
            if widget and widget:IsShown() then
                widget:Hide()
                handled = true
            end
        end
        if handled then return true end
    end
    return false
end

local function choose(current, option, root)
    local _, items = openDropdown(current, root)
    for _, info in ipairs(items) do
        if info.text == option then info.func(); return end
    end
    error("missing option: " .. option)
end

local function checkLanguage(current, root)
    local popup, items = openDropdown(current, root)
    assert(#items == 3, "all language choices are available")
    for _, info in ipairs(items) do
        assert(not not info.checked == (info.text == current), "selected marker: " .. info.text)
    end
    popup:Hide()
end

local function checkbox(label)
    local text = assert(visibleText(label, "FontString"), label)
    local button = text.anchors[1][2]
    assert(button.template == "UICheckButtonTemplate" and button:IsVisible())
    return button
end

local function startWithSlashRegistry(commands)
    SlashCmdList = commands
    locale, CraftAtlasDB = "enUS", nil
    local environment = {}
    environment._G = environment
    setmetatable(environment, {
        __index = _G,
        __newindex = function(_, key, value)
            assert(key ~= "SlashCmdList", "startup must not assign the native SlashCmdList global")
            _G[key] = value
        end,
    })
    return start("forever", "available", environment)
end

local existingCommand = function() end
local clientCommands = {EXISTING = existingCommand}
startWithSlashRegistry(clientCommands)
assert(SLASH_CRAFTATLAS1 == "/craftatlas" and clientCommands.EXISTING == existingCommand)
local slashCommand = assert(clientCommands.CRAFTATLAS, "CraftAtlas is registered in the native table")
slashCommand("")
local slashExplorer = named("CraftAtlasSettingsFrame")
assert(slashExplorer:IsVisible(), "the plain slash command opens the explorer")
slashExplorer:Hide()
slashCommand("159")
assert(slashExplorer:IsVisible() and visibleText("ID 159", "FontString"),
    "the numeric slash command selects the requested material")
slashExplorer:Hide()
local diagnostic, originalPrint = nil, print
print = function(message) diagnostic = message end
slashCommand("perf")
print = originalPrint
assert(diagnostic and diagnostic:match("^CraftAtlas: Prepared: materials ") and not slashExplorer:IsShown(),
    "the performance command reports diagnostics and leaves the explorer closed")

local function checkMinimapWithoutSlashRegistry(commands)
    startWithSlashRegistry(commands)
    assert(SlashCmdList == commands and SLASH_CRAFTATLAS1 == nil,
        "an unavailable registry leaves slash registration untouched")
    named("CraftAtlasMinimapButton"):Click()
    assert(named("CraftAtlasSettingsFrame"):IsVisible(), "startup still provides minimap access")
end

checkMinimapWithoutSlashRegistry(nil)
checkMinimapWithoutSlashRegistry(false)

local defaults = {showMinimapButton = true, showTooltipProfessions = true,
    hideTooltipProfessionIcons = false, tooltipProfessionsOnOneLine = false}
locale = "enUS"
CraftAtlasDB = nil
local ns, registry = start(true)
assert(not ns.InitAddonOptions() and registry.canvases == 0)
for key, expected in pairs(defaults) do assert(ns.GetDisplayPreference(key) == expected, key) end
local legacyTracking = {["Realm:Name"] = {recipe = true}}
local globalTracking, savedBank = {["Realm:Name"] = true}, {["Realm:Name"] = true}
CraftAtlasDB = {language = "enUS", minimapAngle = -90, craftTracking = legacyTracking,
    craftTrackingEnabled = globalTracking, craftBankIncluded = savedBank}
local legacy = ns.InitPreferences()
assert(legacy.language == "enUS" and legacy.minimapAngle == -90)
assert(legacy.craftTracking == legacyTracking and legacy.craftTrackingEnabled == globalTracking
    and legacy.craftBankIncluded == savedBank)
for key, expected in pairs(defaults) do assert(legacy[key] == expected, key) end
legacy.showTooltipProfessions = false
legacy.showMinimapButton = "false"
legacy.hideTooltipProfessionIcons = true
legacy.tooltipProfessionsOnOneLine = 1
ns.InitPreferences()
assert(legacy.showMinimapButton and not legacy.showTooltipProfessions
    and legacy.hideTooltipProfessionIcons and legacy.tooltipProfessionsOnOneLine == false)
assert(ns.GetDisplayPreference("showTooltipProfessions") == false)

ns, registry = start(true, "incomplete")
assert(not ns.InitAddonOptions() and registry.canvases == 0, "partial Settings API skips the canvas")
assert(not ns.OpenAddonOptions(), "missing native open API leaves the current UI intact")
SlashCmdList.CRAFTATLAS("")
assert(named("CraftAtlasSettingsFrame"):IsVisible(), "explorer works without native registration")

local function openOptions(registry)
    local category = assert(registry.categories.CraftAtlas, "registered CraftAtlas AddOns category")
    local panel = category.panel
    if not panel:GetParent() then panel:SetParent(newWidget("Frame", "SettingsCanvas", UIParent)) end
    panel:Show()
    return panel
end

local function explorerExists()
    return find(function(widget) return widget.name == "CraftAtlasSettingsFrame" end)
end

for _, nativeDropdown in ipairs({true, false, "forever", "forever-fallback"}) do
    locale = "frFR"
    CraftAtlasDB = {minimapAngle = -90}
    ns, registry = start(nativeDropdown, "available")
    assert(ns.InitAddonOptions() and registry.canvases == 1 and not explorerExists())
    local minimap = named("CraftAtlasMinimapButton")
    minimap:Emit("OnClick", "RightButton")
    local options = registry.categories.CraftAtlas.panel
    assert(registry.openedID == 17 and options:IsVisible())
    assert(not explorerExists() and visibleText("General") and visibleText("Tooltip"))
    checkLanguage("Automatic", options)
    assert(checkbox("Show minimap button"):GetChecked())
    checkbox("Show minimap button"):Click()
    assert(not minimap:IsVisible())
    local icons = checkbox("Hide profession icons")
    local single = checkbox("Show professions on one line")
    local professions = checkbox("Show consuming professions")
    assert(-single.anchors[1][5] + single.height < options:GetHeight(),
        "last checkbox fits within a compact native canvas")
    icons:Click()
    single:Click()
    professions:Click()
    assert(not icons.enabled and not single.enabled and icons:GetChecked() and single:GetChecked())
    icons:Click()
    professions:Click()
    assert(icons.enabled and single.enabled and icons:GetChecked() and single:GetChecked())
    professions:Click()
    choose("Automatic", "Español", options)
    assert(visibleText("Información emergente") and visibleText("Mostrar botón del minimapa"))
    options:Hide()

    SlashCmdList.CRAFTATLAS("")
    local window = named("CraftAtlasSettingsFrame")
    local search = assert(find(function(widget) return widget.kind == "EditBox" end))
    assert(not findSelector("Español", window) and not visibleText("Configuración", "Button"))
    search:SetText("2770")
    choose("Todas las profesiones", "Minería", window)
    assert(visibleText("Copper Ore", "FontString"))
    local materialID = assert(visibleText("ID 2770", "FontString"))
    local materialType = assert(visibleText("Objeto comerciable", "FontString"))
    local materialLevel = assert(visibleText("Nivel de objeto 10", "FontString"))
    local materialTitle = assert(find(function(widget)
        return widget.parent == materialID.parent and widget.kind == "FontString"
            and widget:IsVisible() and widget.text == "Copper Ore"
    end), "material title")
    assert(materialType.parent == materialID.parent and materialLevel.parent == materialID.parent)
    assert(materialTitle.anchors[1][5] > materialType.anchors[1][5]
        and materialType.anchors[1][5] > materialLevel.anchors[1][5]
        and materialLevel.anchors[1][5] > materialID.anchors[1][5],
        "Materials displays title, type, level and ID in separate rows")
    local use = ns.GetRecipeUses(2770)[1]
    ns.NavigateToRecipe(use)
    search:SetText(tostring(use.spellID))
    choose("Todas las profesiones", ns.ProfessionLabel(use.professionKey), window)
    assert(visibleText("Fabricables", "Button").selected and not visibleText("Configuración", "Button"))
    local recipeLabel = assert(find(function(widget)
        return widget.kind == "FontString" and widget:IsVisible()
            and widget.text == "ID " .. use.spellID
    end), "selected recipe")
    local craftableProfession = assert(find(function(widget)
        return widget.parent == recipeLabel.parent and widget.kind == "FontString"
            and widget.text == ns.ProfessionLabel(use.professionKey)
    end))
    assert(craftableProfession.template == materialType.template
        and craftableProfession.anchors[1][4] == materialType.anchors[1][4]
        and craftableProfession.anchors[1][5] == materialType.anchors[1][5],
        "both detail subtitles use the same font and position")
    assert(recipeLabel.template == materialID.template
        and recipeLabel.anchors[1][4] == materialID.anchors[1][4]
        and recipeLabel.anchors[1][5] == materialID.anchors[1][5],
        "both IDs use the same font and position")
    assert(not materialType:IsVisible() and not materialLevel:IsVisible(),
        "material metadata is hidden on the Craftables tab")
    local output = recipeLabel.text
    openOptions(registry)
    options:Hide()
    assert(search.text == tostring(use.spellID) and recipeLabel:IsVisible() and recipeLabel.text == output)
    assert(findSelector(ns.ProfessionLabel(use.professionKey), window))
    click("Volver")
    assert(search.text == "2770" and visibleText("Materiales", "Button").selected)
    assert(findSelector("Minería", window) and not visibleText("Volver", "Button"))

    openOptions(registry)
    choose("Español", "Automático", options)
    assert(findSelector("Automatic", options) and visibleText("Tooltip"), "Auto falls back to English")
    checkLanguage("Automatic", options)
    choose("Automatic", "Español", options)
    assert(visibleText("Materiales", "Button").selected and search.text == "2770",
        "an open explorer refreshes its labels and maintains search state")
    assert(not findSelector("Español", window), "language remains in native options")
    options:Hide()
    SlashCmdList.CRAFTATLAS("159")
    assert(materialID.text == "ID 159" and materialType.text == "" and materialLevel.text == "",
        "a material without client metadata clears both rows and keeps its ID")

    ns, registry = start(nativeDropdown, "available")
    local restored = named("CraftAtlasMinimapButton")
    assert(not restored:IsVisible(), "minimap visibility survives reload")
    options = openOptions(registry)
    assert(not explorerExists() and findSelector("Español", options))
    checkLanguage("Español", options)
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
    options:Hide()
    restored:Click()
    assert(named("CraftAtlasSettingsFrame"):IsVisible() and visibleText("Materiales", "Button").selected)
end

for _, mode in ipairs({true, false, "forever", "forever-fallback"}) do
    locale, CraftAtlasDB = "enUS", nil
    start(mode, "available")
    SlashCmdList.CRAFTATLAS("")
    local window = named("CraftAtlasSettingsFrame")
    local search = assert(find(function(widget) return widget.kind == "EditBox" end))
    click("Craftables")
    local tab = assert(visibleText("Craftables", "Button"))
    assert(tab.selected and tab:GetHeight() == 37)
    local materials = assert(visibleText("Materials", "Button"))
    assert(search.anchors[1][5] == materials.anchors[1][5] + materials:GetHeight() / 2,
        "search and tabs share the same toolbar center")
    assert(find(function(widget) return widget.atlas == "Options_InnerFrame" and inside(widget, window) end))
    assert(find(function(widget)
        return widget.atlas == "Options_CategoryHeader_1" and widget:IsVisible() and inside(widget, window)
    end), "detail sections use the native recessed header")
    if mode == "forever" then
        assert(tab.template == "MinimalTabTemplate" and tab:GetWidth() == tab.Text:GetStringWidth() + 40)
    end
    assert(window.template == "SettingsFrameTemplate" and window.CloseButton == window.ClosePanelButton)
    assert(window.NineSlice.Text.text == "CraftAtlas", "native title is reused")
    assert(search.searchIcon.atlas == "common-search-magnifyingglass")
    local scrollbar = assert(find(function(widget) return widget.template == "UIPanelScrollBarTemplate" end))
    local list = scrollbar:GetParent()
    assert(list.clipsChildren and inside(list, window))
    local buffs = newWidget("Frame", nil, UIParent)
    buffs:SetFrameStrata("LOW")
    local options = newWidget("Frame", nil, UIParent)
    options:SetFrameStrata("HIGH")
    local tooltip = newWidget("Frame", nil, UIParent)
    tooltip:SetFrameStrata("TOOLTIP")
    local strata = {LOW = 1, MEDIUM = 2, HIGH = 3, DIALOG = 4, TOOLTIP = 5}
    for _, widget in ipairs(frames) do
        if inside(widget, window) and widget:IsVisible() then
            assert(widget:GetFrameStrata() == "DIALOG", "every control shares the window layer")
        end
    end
    local windowStrata = strata[window:GetFrameStrata()]
    assert(windowStrata > strata[buffs:GetFrameStrata()] and windowStrata > strata[options:GetFrameStrata()],
        "the whole explorer covers buffs and ordinary panels")
    assert(windowStrata < strata[tooltip:GetFrameStrata()], "native tooltips remain above the explorer")
    for _, row in ipairs({list:GetChildren()}) do
        assert(row:GetFrameStrata() == window:GetFrameStrata())
        assert(row == scrollbar or row.anchors[1][2] == list, "recycled rows are anchored to the clipped list")
        if row.professions then
            local bounds = row.professions.anchors
            assert(bounds[1][1] == "BOTTOMLEFT" and bounds[2][1] == "BOTTOMRIGHT")
            assert(bounds[1][5] > 0 and bounds[1][5] + row.professions:GetHeight() < row:GetHeight())
        end
    end

    if RegisterGameMenuEscHandler then
        local shown = true
        registerNativeEscape(GameMenuEscPriority.Dialog, function()
            if not shown then return false end
            shown = false
            return true
        end)
        assert(pressEscape() and not shown and window:IsShown(), "native dialogs retain Escape priority")
    end
    local registrationCount = #UISpecialFrames + #escapeHandlers
    assert(#UISpecialFrames == 1 and UISpecialFrames[1] == "CraftAtlasExplorerEscapeFrame")
    local professionPopup = openDropdown("All professions", window)
    assert(pressEscape() and window:IsShown() and not professionPopup:IsShown())
    search:SetText("19093")
    search:SetFocus()
    local filterPopup = openDropdown("All professions", window)
    assert(pressEscape(search) and window:IsShown() and not filterPopup:IsShown())
    assert(pressEscape(search) and not window:IsShown() and not search.focus)
    assert(not pressEscape(), "a hidden explorer never consumes Escape")
    SlashCmdList.CRAFTATLAS("")
    assert(window:IsShown() and visibleText("Materials", "Button").selected)
    assert(pressEscape() and not window:IsShown(), "unfocused Escape works through the special-frame registry")
    assert(not pressEscape(), "the game can handle the next Escape without CraftAtlas")
    SlashCmdList.CRAFTATLAS("")
    assert(not findSelector("Automatic", window))
    click("Craftables")
    assert(search:GetText() == "19093", "Escape preserves the query across reopen")
    local popup = openDropdown("All professions", window)
    window.CloseButton:Click()
    assert(not window:IsShown() and not popup:IsShown(), "X still closes with a popup open")
    assert(#UISpecialFrames + #escapeHandlers == registrationCount, "only one explorer Escape registration")
end

print("Native AddOns panel registration, shared language, explorer state and preferences PASS")
