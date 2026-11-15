local _, ns = ...

-- Pure catalog filtering. Item identity always remains a numeric itemID.
local function normalize(value)
    return string.lower(tostring(value or ""))
end

local function contains(haystack, needle)
    return string.find(normalize(haystack), needle, 1, true) ~= nil
end

function ns.FilterMaterials(materials, professionOrder, query, profession, names, namedOnly, professionLabels)
    local ids = {}
    local unresolved = 0
    local needle = normalize(query)
    local numberQuery = needle ~= "" and string.match(needle, "^%d+$") ~= nil
    for itemID, professions in pairs(materials or {}) do
        if type(itemID) == "number" and type(professions) == "table" then
            local accepted = not profession or profession == ""
            if not accepted then
                for _, key in ipairs(professions) do
                    if key == profession then accepted = true break end
                end
            end
            if accepted then
                local name = names and names[itemID]
                local professionMatch = false
                if needle ~= "" and not numberQuery then
                    for _, key in ipairs(professions) do
                        if contains((professionLabels and professionLabels[key]) or key, needle) then
                            professionMatch = true
                            break
                        end
                    end
                end
                if (not namedOnly or name) and (needle == "" or contains(itemID, needle)
                    or (name and not numberQuery and contains(name, needle)) or professionMatch) then
                    ids[#ids + 1] = itemID
                elseif not numberQuery and not name then
                    unresolved = unresolved + 1
                end
            end
        end
    end
    table.sort(ids, function(a, b)
        local aName = names and names[a]
        local bName = names and names[b]
        if aName and bName and aName ~= bName then
            return normalize(aName) < normalize(bName)
        end
        if aName and not bName then return true end
        if bName and not aName then return false end
        return a < b
    end)
    return ids, unresolved
end

function ns.ItemMatchesProfession(itemID, profession)
    if not profession or profession == "" then return true end
    for _, key in ipairs(ns.FindProfessions(itemID, ns.materials, ns.professionOrder)) do
        if key == profession then return true end
    end
    return false
end
