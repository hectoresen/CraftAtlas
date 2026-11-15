local _, ns = ...

local function formatProfessions(keys)
    local result = {}
    for _, key in ipairs(keys) do
        result[#result + 1] = ns.ProfessionLabel(key)
    end
    return table.concat(result, ", ")
end

local function onItemTooltip(tooltip, data)
    local itemID = ns.ResolveTooltipItemID(data)
    if not itemID or not tooltip or type(tooltip.AddLine) ~= "function" then return end
    local keys = ns.FindProfessions(itemID, ns.materials, ns.professionOrder)
    if #keys == 0 then return end
    local language = ns.ResolveLocale(ns.GetLanguage(), ns.GetClientLocale())
    local marker = tostring(itemID) .. ":" .. tostring(data.dataInstanceID or "") .. ":" .. language
    local count = type(tooltip.NumLines) == "function" and tooltip:NumLines() or nil
    if tooltip.CraftAtlasLastData == marker
        and (not count or tooltip.CraftAtlasLineCount == count) then return end
    tooltip:AddLine(ns.L("USED_BY"), 0.9, 0.75, 0.47)
    tooltip:AddLine(formatProfessions(keys), 0.95, 0.90, 0.82, true)
    tooltip.CraftAtlasLastData = marker
    tooltip.CraftAtlasLineCount = count and count + 2 or nil
    if not tooltip.CraftAtlasHideHooked and type(tooltip.HookScript) == "function" then
        tooltip:HookScript("OnHide", function(self)
            self.CraftAtlasLastData = nil
            self.CraftAtlasLineCount = nil
        end)
        tooltip.CraftAtlasHideHooked = true
    end
    if type(tooltip.Show) == "function" then tooltip:Show() end
end

function ns.InitTooltip()
    return ns.RegisterTooltipHook(onItemTooltip)
end
