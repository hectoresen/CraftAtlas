local _, ns = ...

-- Forever 1.60.x reports a modern Mainline tooltip API. Verify in the
-- actual supported client before claiming production compatibility.
function ns.ResolveTooltipItemID(data)
    if type(data) ~= "table" or type(data.id) ~= "number" then
        return nil
    end
    if data.id <= 0 or data.id % 1 ~= 0 then
        return nil
    end
    return data.id
end

function ns.RegisterTooltipHook(callback)
    if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
        and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item) then
        return false, "TooltipDataProcessor API unavailable"
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, callback)
    return true
end
