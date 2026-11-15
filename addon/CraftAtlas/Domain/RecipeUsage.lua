local _, ns = ...

-- Only source-backed reagent entries are eligible. Craftability alone never qualifies.
function ns.IsVerifiedReagent(itemID)
    return type(itemID) == "number" and type(ns.recipeUses) == "table"
        and type(ns.recipeUses[itemID]) == "table" and #ns.recipeUses[itemID] > 0
end

function ns.GetRecipeUses(itemID)
    if not ns.IsVerifiedReagent(itemID) then return {} end
    local result, seen = {}, {}
    for _, record in ipairs(ns.recipeUses[itemID]) do
        local spell, professionIndex, quantity, output, kindIndex =
            record[1], record[2], record[3], record[4], record[5]
        local profession = ns.professionOrder[professionIndex]
        local identity = tostring(spell) .. ":" .. tostring(profession)
        if profession and not seen[identity] and quantity and quantity > 0 then
            seen[identity] = true
            result[#result + 1] = {
                spellID = spell,
                professionKey = profession,
                professionIndex = professionIndex,
                quantity = quantity,
                outputItemID = output and output > 0 and output or nil,
                kind = kindIndex == 1 and "item" or (kindIndex == 2 and "enchant" or "unknown"),
            }
        end
    end
    table.sort(result, function(a, b)
        if a.professionIndex ~= b.professionIndex then
            return a.professionIndex < b.professionIndex
        end
        return a.spellID < b.spellID
    end)
    return result
end

function ns.GetGroupedRecipeRows(itemID)
    local rows, previous = {}, nil
    local uses = ns.GetRecipeUses(itemID)
    for _, use in ipairs(uses) do
        if use.professionKey ~= previous then
            rows[#rows + 1] = {kind = "heading", professionKey = use.professionKey}
            previous = use.professionKey
        end
        rows[#rows + 1] = {kind = "recipe", use = use}
    end
    return rows, #uses
end
