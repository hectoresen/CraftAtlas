local _, ns = ...

local button
local iconTexture = "Interface\\Icons\\Trade_BlackSmithing"
local borderTexture = "Interface\\Minimap\\MiniMap-TrackingBorder"
local unavailableCursor = "Interface\\Cursor\\UnablePoint"
local buttonSize = 31
local iconSize = 20
local borderSize = 53
local defaultAngle = 45
local atan2 = math.atan2 or math.atan

local function isFinite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function savedAngle()
    local angle = ns.GetMinimapAngle and tonumber(ns.GetMinimapAngle())
    return isFinite(angle) and angle or defaultAngle
end

local function positionButton(frame, minimap, angle)
    local width = minimap.GetWidth and minimap:GetWidth()
    if not isFinite(width) or width <= 0 then
        return
    end

    local radius = width / 2
    local radians = math.rad(angle)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", minimap, "CENTER",
        math.cos(radians) * radius, math.sin(radians) * radius)
end

local function pointerAngle(minimap, previousAngle)
    if type(GetCursorPosition) ~= "function" or not minimap.GetCenter then
        return previousAngle
    end

    local scale = minimap.GetEffectiveScale and minimap:GetEffectiveScale()
    local centerX, centerY = minimap:GetCenter()
    local x, y = GetCursorPosition()
    if not isFinite(scale) or scale <= 0 or not isFinite(centerX) or not isFinite(centerY)
        or not isFinite(x) or not isFinite(y) then
        return previousAngle
    end

    local dx, dy = x / scale - centerX, y / scale - centerY
    if dx == 0 and dy == 0 then
        return previousAngle
    end
    return math.deg(atan2(dy, dx))
end

local function setUnavailableCursor()
    if type(SetCursor) == "function" then
        pcall(SetCursor, unavailableCursor)
    end
end

local function clearCursor()
    if type(SetCursor) == "function" then
        pcall(SetCursor, nil)
    end
end

local function addGestureHint(gesture, action)
    local label = "|cffc79a26" .. ns.L(gesture) .. ":|r "
    GameTooltip:AddLine(label .. ns.L(action), 1, 1, 1)
end

local function createButton()
    if button or not Minimap then
        return button
    end

    local minimap = Minimap
    local angle = savedAngle()
    local dragged = false
    local function updateDrag(frame)
        angle = pointerAngle(minimap, angle)
        positionButton(frame, minimap, angle)
    end

    button = CreateFrame("Button", "CraftAtlasMinimapButton", minimap)
    button:SetSize(buttonSize, buttonSize)
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconTexture)
    icon:SetSize(iconSize, iconSize)
    -- Match the native minimap button composition so the profession icon
    -- sits inside the visual center of the tracking ring.
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture(borderTexture)
    border:SetSize(borderSize, borderSize)
    border:SetPoint("TOPLEFT", button, "TOPLEFT")
    button.border = border

    button:SetScript("OnMouseDown", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            -- A drag release may or may not dispatch OnClick. Reset on the next press.
            dragged = false
        end
    end)
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and not dragged and ns.OpenSettings then
            ns.OpenSettings()
        elseif mouseButton == "RightButton" and ns.OpenAddonOptions then
            ns.OpenAddonOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        dragged = true
        updateDrag(self)
        self:SetScript("OnUpdate", updateDrag)
    end)
    button:SetScript("OnDragStop", function(self)
        updateDrag(self)
        self:SetScript("OnUpdate", nil)
        if ns.SetMinimapAngle then
            ns.SetMinimapAngle(angle)
        end
    end)
    button:SetScript("OnEnter", function(self)
        if GameTooltip and GameTooltip.SetOwner and GameTooltip.SetText
            and GameTooltip.AddLine and GameTooltip.Show then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(ns.L("TITLE"))
            addGestureHint("MINIMAP_LEFT_CLICK", "MINIMAP_OPEN")
            addGestureHint("MINIMAP_DRAG", "MINIMAP_MOVE")
            addGestureHint("MINIMAP_RIGHT_CLICK", "MINIMAP_OPTIONS")
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip and GameTooltip.Hide then
            GameTooltip:Hide()
        end
    end)

    return button
end

function ns.InitMinimapButton()
    local minimapButton = createButton()
    if not minimapButton then
        return false, "Minimap frame unavailable"
    end
    if ns.GetDisplayPreference("showMinimapButton") then
        positionButton(minimapButton, Minimap, savedAngle())
        minimapButton:Show()
    else
        minimapButton:Hide()
    end
    return true
end

function ns.SetSearchUnavailableCursor()
    setUnavailableCursor()
end

function ns.ClearSearchUnavailableCursor()
    clearCursor()
end
