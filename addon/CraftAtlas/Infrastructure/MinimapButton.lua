local _, ns = ...

local button
local iconTexture = "Interface\\Icons\\Trade_BlackSmithing"
local borderTexture = "Interface\\Minimap\\MiniMap-TrackingBorder"
local unavailableCursor = "Interface\\Cursor\\UI-Cursor-NoMop"

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
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
    button:RegisterForClicks("LeftButtonUp")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconTexture)
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture(borderTexture)
    border:SetAllPoints()
    button.border = border

    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" and ns.OpenSettings then
            ns.OpenSettings()
        end
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
