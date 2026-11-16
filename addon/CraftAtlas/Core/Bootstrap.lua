local addonName, ns = ...

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, loadedName)
    if event ~= "ADDON_LOADED" or loadedName ~= addonName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")
    ns.InitPreferences()
    if ns.InitSettings then
        ns.InitSettings()
    end
    if ns.InitMinimapButton then
        local minimapOk, minimapReason = ns.InitMinimapButton()
        if not minimapOk and type(print) == "function" then
            print("CraftAtlas: " .. tostring(minimapReason))
        end
    end
    local ok, reason = ns.InitTooltip()
    if not ok and type(print) == "function" then
        print("CraftAtlas: " .. tostring(reason))
    end
    local optionsOk, optionsReason = ns.InitAddonOptions()
    if not optionsOk and optionsReason and type(print) == "function" then
        print("CraftAtlas: " .. tostring(optionsReason))
    end
end)
