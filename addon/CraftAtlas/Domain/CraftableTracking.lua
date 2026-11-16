local _, ns = ...

-- Pure coverage calculation. Unknown observations are never represented as zero.
function ns.ComputeCraftableCoverage(ingredients, counts)
    local result = {rows = {}, required = 0, covered = 0, missing = 0,
        percent = nil, verified = true}
    if type(ingredients) ~= "table" or #ingredients == 0 then
        result.verified = false
        return result
    end
    local byID = {}
    for _, ingredient in ipairs(ingredients) do
        local id, quantity = ingredient.itemID, ingredient.quantity
        if type(id) ~= "number" or id <= 0 or type(quantity) ~= "number"
            or quantity <= 0 or quantity ~= math.floor(quantity) then
            result.verified = false
        else
            if not byID[id] then
                byID[id] = {itemID = id, required = 0}
                result.rows[#result.rows + 1] = byID[id]
            end
            byID[id].required = byID[id].required + quantity
        end
    end
    for _, row in ipairs(result.rows) do
        local observation = counts and counts[row.itemID]
        local available = observation and observation.available
        result.required = result.required + row.required
        if type(available) == "number" and available >= 0
            and available == math.floor(available) then
            row.available = available
            row.covered = math.min(available, row.required)
            row.missing = row.required - row.covered
            result.covered = result.covered + row.covered
            result.missing = result.missing + row.missing
        else
            row.verified = false
            result.verified = false
        end
    end
    if result.required == 0 then result.verified = false end
    if result.required > 0 then
        result.percent = math.floor(100 * result.covered / result.required + 0.5)
    end
    return result
end
