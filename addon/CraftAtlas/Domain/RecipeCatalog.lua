local _, ns = ...

-- Generated records: spellID, professionIndex, outputItemID, kindIndex, {itemID,count}[].
local byKey
local function index()
    if byKey then return end
    byKey = {}
    for _, record in ipairs(ns.recipes or {}) do
        local profession = ns.professionOrder[record[2]]
        if profession then
            local key = profession .. ":" .. record[1]
            byKey[key] = {
                key = key, spellID = record[1], professionKey = profession,
                outputItemID = record[3] > 0 and record[3] or nil,
                kind = record[4] == 1 and "item" or (record[4] == 2 and "enchant" or "unknown"),
                ingredients = {},
                requiredSkill = record[6] and record[6][1] > 0 and record[6][1] or nil,
                teachingItemID = record[6] and record[6][2] > 0 and record[6][2] or nil,
                camping = record[6] and record[6][3] == 1 or false,
                difficulty = record[6] and record[6][4] or nil,
                foreverVendorIDs = record[6] and record[6][5] or nil,
            }
            for _, ingredient in ipairs(record[5]) do
                byKey[key].ingredients[#byKey[key].ingredients + 1] = {
                    itemID = ingredient[1], quantity = ingredient[2]
                }
            end
        end
    end
end

function ns.GetCatalogRecipe(key)
    index()
    return byKey[key]
end

function ns.RecipeKey(profession, spellID)
    return tostring(profession) .. ":" .. tostring(spellID)
end

function ns.SearchCatalogRecipes(query, profession, names, outputNames, professionLabels)
    local found, unresolved = {}, 0
    local needle = string.lower(tostring(query or ""))
    local numeric = needle ~= "" and string.match(needle, "^%d+$") ~= nil
    for _, record in ipairs(ns.recipes or {}) do
        local spell, profIndex, output = record[1], record[2], record[3]
        local key = ns.professionOrder[profIndex]
        if key and (not profession or profession == "" or profession == key) then
            local name = names and names[spell]
            local outputName = outputNames and outputNames[output]
            local label = (professionLabels and professionLabels[key]) or key
            local matched = needle == "" or string.find(tostring(spell), needle, 1, true)
                or (name and string.find(string.lower(name), needle, 1, true))
                or (outputName and string.find(string.lower(outputName), needle, 1, true))
                or (not numeric and string.find(string.lower(label), needle, 1, true))
            if matched then
                if numeric or name or outputName then
                    found[#found + 1] = ns.RecipeKey(key, spell)
                else
                    unresolved = unresolved + 1
                end
            elseif not numeric and not name and not outputName then
                unresolved = unresolved + 1
            end
        end
    end
    return found, unresolved
end
