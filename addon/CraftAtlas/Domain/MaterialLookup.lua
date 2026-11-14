local _, ns = ...

-- Pure domain function: no WoW APIs, UI globals, locale or character state.
function ns.FindProfessions(itemID, materials, professionOrder)
    if type(itemID) ~= "number" or itemID < 1 or itemID % 1 ~= 0 then
        return {}
    end
    local relations = materials and materials[itemID]
    if type(relations) ~= "table" then
        return {}
    end

    local selected = {}
    for _, profession in ipairs(relations) do
        if type(profession) == "string" then
            selected[profession] = true
        end
    end

    local result = {}
    for _, profession in ipairs(professionOrder or {}) do
        if selected[profession] then
            result[#result + 1] = profession
        end
    end
    return result
end
