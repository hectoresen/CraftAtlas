local _, ns = ...

local function formatProfessions(keys)
    local result = {}
    for _, key in ipairs(keys) do
        result[#result + 1] = ns.L(key)
    end
    return table.concat(result, ", ")
end

-- The modern item callback covers a range of tooltip origins. Release
-- testing must prove actual game behavior; no assumptions about all frames.
local function onItemTooltip(tooltip, data)
    local itemID = ns.ResolveTooltipItemID(data)
    if not itemID or not tooltip or type(tooltip.AddLine) ~= "function" then
        return
    end

    local professions = ns.FindProfessions(itemID, ns.materials, ns.professionOrder)
    if #professions == 0 then
        return
    end

    local marker = tostring(data.dataInstanceID or itemID)
    if tooltip.CraftAtlasLastData == marker then
        return
    end
    tooltip.CraftAtlasLastData = marker
    tooltip:AddLine(ns.L("USED_BY"), 0.9, 0.75, 0.47)
    tooltip:AddLine(formatProfessions(professions), 0.95, 0.90, 0.82, true)
    if type(tooltip.Show) == "function" then
        tooltip:Show()
    end
end

function ns.InitTooltip()
    return ns.RegisterTooltipHook(onItemTooltip)
end
