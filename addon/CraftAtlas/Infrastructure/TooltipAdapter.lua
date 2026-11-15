local _, ns = ...

function ns.ResolveTooltipItemID(data)
    local ok, id = pcall(function() return data and data.id end)
    if not ok or type(id) ~= "number" or id < 1 or id % 1 ~= 0 then return nil end
    return id
end

-- One modern item-tooltip hook for all origins exposed by the Forever client.
-- Unsupported/protected frame APIs are never patched.
function ns.RegisterTooltipHook(callback)
    if not (TooltipDataProcessor and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
        and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item ~= nil) then
        return false, "TooltipDataProcessor item hook unavailable"
    end
    local ok, err = pcall(TooltipDataProcessor.AddTooltipPostCall,
        Enum.TooltipDataType.Item, callback)
    if not ok then return false, tostring(err) end
    return true
end
