local _, ns = ...

local button
local iconTexture = "Interface\\Icons\\Trade_BlackSmithing"
local borderTexture = "Interface\\Minimap\\MiniMap-TrackingBorder"
local unavailableCursor = "Interface\\Cursor\\UI-Cursor-NoMop"
local buttonSize = 31
local iconSize = 20
local borderSize = 53

local function getAngleRadians(angle)
    return math.rad(tonumber(angle) or 45)
end

local function positionButton()
    if not button or not Minimap then
        return
    end

    -- Put the button's center on the minimap edge. The native border extends
    -- evenly on both sides of that edge instead of floating outside it.
    local radius = Minimap:GetWidth() / 2
    local radians = getAngleRadians(ns.GetMinimapAngle and ns.GetMinimapAngle() or 45)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(radians) * radius, math.sin(radians) * radius)
end

local function saveDraggedPosition()
    if not button or not Minimap or not GetCursorPosition then
        return
    end

    local scale = UIParent and UIParent.GetEffectiveScale
        and UIParent:GetEffectiveScale() or 1
    local cursorX, cursorY = GetCursorPosition()
    local minimapX, minimapY = Minimap:GetCenter()
    local dx = (cursorX / scale) - minimapX
    local dy = (cursorY / scale) - minimapY
    local angle
    if math.atan2 then
        angle = math.deg(math.atan2(dy, dx))
    else
        angle = math.deg(math.atan(dy, dx))
    end
    if ns.SetMinimapAngle then
        ns.SetMinimapAngle(angle)
    end
    positionButton()
end

local function setUnavailableCursor()
    if type(SetCursor) == "function" then
        SetCursor(unavailableCursor)
    end
end

local function clearCursor()
    if type(SetCursor) == "function" then
        SetCursor(nil)
    end
end

local function createButton()
    if button or not Minimap then
        return button
    end

    button = CreateFrame("Button", "CraftAtlasMinimapButton", Minimap)
    button:SetSize(buttonSize, buttonSize)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    positionButton()
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconTexture)
    icon:SetSize(iconSize, iconSize)
    -- These offsets match the native minimap button composition: the
    -- profession icon sits inside the visual center of the tracking ring.
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture(borderTexture)
    border:SetSize(borderSize, borderSize)
    border:SetPoint("TOPLEFT", button, "TOPLEFT")
    button.border = border

    button:SetScript("OnClick", function(self, mouseButton)
        if self.wasDragged then
            self.wasDragged = nil
            return
        end
        if mouseButton == "LeftButton" and ns.OpenSettings then
            ns.OpenSettings()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self.wasDragged = true
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        saveDraggedPosition()
    end)
    button:SetScript("OnEnter", function(self)
        if GameTooltip and GameTooltip.SetOwner then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(ns.L("MINIMAP_TOOLTIP"))
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
    minimapButton:Show()
    return true
end

function ns.SetSearchUnavailableCursor()
    setUnavailableCursor()
end

function ns.ClearSearchUnavailableCursor()
    clearCursor()
end
