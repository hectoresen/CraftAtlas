local scripts, frame, anchor, framesCreated
local centerX, centerY, scale = 300, 200, 1
local cursorX, cursorY
local cursorReads = 0
local clientLocale = "enUS"

UIParent = { GetEffectiveScale = function() return 1 end }
Minimap = {
    GetWidth = function() return 140 end,
    GetCenter = function() return centerX, centerY end,
    GetEffectiveScale = function() return scale end,
}
GetCursorPosition = function()
    cursorReads = cursorReads + 1
    return cursorX, cursorY
end
GetLocale = function() return clientLocale end

local function noOp() end
CreateFrame = function(kind, name, parent)
    assert(kind == "Button" and name == "CraftAtlasMinimapButton" and parent == Minimap)
    framesCreated = (framesCreated or 0) + 1
    scripts = {}
    frame = {
        SetSize = noOp,
        SetFrameStrata = noOp,
        ClearAllPoints = noOp,
        Show = noOp,
        RegisterForClicks = function(_, left, right)
            assert(left == "LeftButtonUp" and right == "RightButtonUp")
        end,
        RegisterForDrag = function(_, button) assert(button == "LeftButton") end,
        SetScript = function(_, event, handler) scripts[event] = handler end,
        SetPoint = function(_, point, relative, relativePoint, x, y)
            assert(point == "CENTER" and relative == Minimap and relativePoint == "CENTER")
            anchor = { x, y }
        end,
        CreateTexture = function()
            return { SetTexture = noOp, SetSize = noOp, SetPoint = noOp, SetTexCoord = noOp }
        end,
    }
    return frame
end

local function loadAddon()
    local ns = { state = {}, opens = 0, optionsOpens = 0 }
    ns.OpenSettings = function() ns.opens = ns.opens + 1 end
    ns.OpenAddonOptions = function() ns.optionsOpens = ns.optionsOpens + 1 end
    for _, path in ipairs({ "Localization/Locales.lua", "Infrastructure/Preferences.lua",
        "Infrastructure/MinimapButton.lua" }) do
        assert(loadfile("addon/CraftAtlas/" .. path))("CraftAtlas", ns)
    end
    ns.InitPreferences()
    assert(ns.InitMinimapButton())
    return ns
end

local function emit(event, button)
    scripts[event](frame, button)
end

local function pointCursor(dx, dy)
    cursorX, cursorY = (centerX + dx) * scale, (centerY + dy) * scale
end

local function expectAnchor(x, y)
    assert(math.abs(anchor[1] - x) < 0.00001 and math.abs(anchor[2] - y) < 0.00001,
        ("expected (%.3f, %.3f), got (%.3f, %.3f)"):format(x, y, anchor[1], anchor[2]))
end

local function leftClick()
    emit("OnMouseDown", "LeftButton")
    emit("OnClick", "LeftButton")
end

CraftAtlasDB = nil
local ns = loadAddon()
expectAnchor(70 / math.sqrt(2), 70 / math.sqrt(2))
assert(ns.InitMinimapButton() and framesCreated == 1, "initialization must reuse the button")
assert(scripts.OnUpdate == nil and cursorReads == 0, "idle button must not sample the pointer")
leftClick()
assert(ns.opens == 1 and ns.optionsOpens == 0)
emit("OnClick", "RightButton")
assert(ns.opens == 1 and ns.optionsOpens == 1)

for _, dragScale in ipairs({ 1, 0.5 }) do
    scale = dragScale
    local opens, optionsOpens, savedAngle = ns.opens, ns.optionsOpens, ns.GetMinimapAngle()
    emit("OnMouseDown", "LeftButton")
    pointCursor(100, 0)
    emit("OnDragStart")
    expectAnchor(70, 0)
    pointCursor(0, 18)
    emit("OnUpdate")
    expectAnchor(0, 70)
    pointCursor(-165, 0)
    emit("OnUpdate")
    expectAnchor(-70, 0)
    pointCursor(0, 0)
    emit("OnUpdate")
    expectAnchor(-70, 0)
    cursorX = nil
    emit("OnUpdate")
    expectAnchor(-70, 0)
    assert(ns.GetMinimapAngle() == savedAngle, "updates must not write the release angle early")

    local releaseX, releaseY, releaseAngle = 0, -70, -90
    if scale == 0.5 then
        releaseX, releaseY, releaseAngle = 70, 0, 0
        emit("OnClick", "LeftButton")
    end
    pointCursor(releaseX * 4, releaseY * 4)
    emit("OnDragStop")
    expectAnchor(releaseX, releaseY)
    assert(scripts.OnUpdate == nil and ns.GetMinimapAngle() == releaseAngle)
    if scale == 0.5 then
        emit("OnClick", "LeftButton")
    end
    assert(ns.opens == opens and ns.optionsOpens == optionsOpens,
        "drag release must not open either screen")
    pointCursor(-300, 0)
    expectAnchor(releaseX, releaseY)
    leftClick()
    assert(ns.opens == opens + 1, "the next ordinary click must open the explorer")

    ns = loadAddon()
    expectAnchor(releaseX, releaseY)
    assert(scripts.OnUpdate == nil, "reload must restore the saved angle without polling")
end

-- Centered at drag start, then unavailable minimap geometry at release.
pointCursor(0, 0)
emit("OnMouseDown", "LeftButton")
emit("OnDragStart")
expectAnchor(70, 0)
centerX = nil
emit("OnDragStop")
expectAnchor(70, 0)
assert(ns.GetMinimapAngle() == 0 and scripts.OnUpdate == nil)
CraftAtlasDB.minimapAngle = math.huge
ns = loadAddon()
expectAnchor(70 / math.sqrt(2), 70 / math.sqrt(2))

local lines, visible
GameTooltip = {
    SetOwner = function(_, owner, point)
        assert(owner == frame and point == "ANCHOR_LEFT")
        lines = {}
    end,
    SetText = function(_, text) lines[1] = text end,
    AddLine = function(_, text) lines[#lines + 1] = text end,
    Show = function() visible = true end,
    Hide = function() visible = false end,
}

local function expectTooltip(open, move, options)
    emit("OnEnter")
    assert(visible and #lines == 4 and lines[1] == "CraftAtlas")
    assert(lines[2] == open and lines[3] == move and lines[4] == options)
    emit("OnLeave")
    assert(not visible)
end

ns.SetLanguage("esES")
expectTooltip("|cffc79a26Clic izquierdo:|r Abrir CraftAtlas", "|cffc79a26Arrastrar:|r Mover icono",
    "|cffc79a26Clic derecho:|r Abrir opciones del addon")
ns.SetLanguage("enUS")
expectTooltip("|cffc79a26Left-click:|r Open CraftAtlas", "|cffc79a26Drag:|r Move icon",
    "|cffc79a26Right-click:|r Open addon options")
ns.SetLanguage("auto")
clientLocale = "esES"
expectTooltip("|cffc79a26Clic izquierdo:|r Abrir CraftAtlas", "|cffc79a26Arrastrar:|r Mover icono",
    "|cffc79a26Clic derecho:|r Abrir opciones del addon")
clientLocale = "frFR"
expectTooltip("|cffc79a26Left-click:|r Open CraftAtlas", "|cffc79a26Drag:|r Move icon",
    "|cffc79a26Right-click:|r Open addon options")
GameTooltip = { SetOwner = function() error("incomplete tooltip should not be used") end }
emit("OnEnter")
emit("OnLeave")

print("Minimap button regression PASS")
