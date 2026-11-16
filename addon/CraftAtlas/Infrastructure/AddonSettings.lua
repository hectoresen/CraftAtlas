local _, ns = ...
local panel, category, registered

function ns.InitAddonOptions()
    if registered then return true end
    local settings = Settings
    if type(settings) ~= "table"
        or type(settings.RegisterCanvasLayoutCategory) ~= "function"
        or type(settings.RegisterAddOnCategory) ~= "function" then
        return false
    end

    if not category then
        panel = panel or ns.CreatePreferencesPanel()
        local ok, result = pcall(settings.RegisterCanvasLayoutCategory, panel, ns.L("TITLE"))
        if not ok then return false, result end
        if not result then return false, "Native options category unavailable" end
        category = result
    end

    local ok, reason = pcall(settings.RegisterAddOnCategory, category)
    if not ok then return false, reason end
    registered = true
    return true
end

function ns.RefreshAddonOptions()
    if panel and panel:IsVisible() then panel:Refresh() end
end
