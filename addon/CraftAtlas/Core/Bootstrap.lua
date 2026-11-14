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
    local ok, reason = ns.InitTooltip()
    if not ok and type(print) == "function" then
        print("CraftAtlas: " .. tostring(reason))
    end
end)
