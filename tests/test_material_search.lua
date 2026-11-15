-- Offline pure-Lua regression checks. Run: texlua tests/test_material_search.lua
local ns = {}
assert(loadfile("addon/CraftAtlas/Domain/MaterialSearch.lua"))("CraftAtlas", ns)

local materials = {
    [765] = {"ALCHEMY"},
    [2447] = {"ALCHEMY", "COOKING"},
    [2589] = {"TAILORING", "FIRST_AID"},
    [2840] = {"ENGINEERING", "BLACKSMITHING"},
}
local names = { [765] = "Silverleaf", [2447] = "Peacebloom", [2840] = "Copper Bar" }
local function has(ids, id)
    for _, value in ipairs(ids) do if value == id then return true end end
    return false
end

local all, unresolved = ns.FilterMaterials(materials, {}, "", "", names)
assert(#all == 4 and unresolved == 0)
local byID = ns.FilterMaterials(materials, {}, "2447", "", names)
assert(#byID == 1 and byID[1] == 2447)
local byName = ns.FilterMaterials(materials, {}, "peace", "", names)
assert(#byName == 1 and byName[1] == 2447)
local combined = ns.FilterMaterials(materials, {}, "2447", "COOKING", names)
assert(#combined == 1 and combined[1] == 2447)
local excluded = ns.FilterMaterials(materials, {}, "2447", "ENGINEERING", names)
assert(#excluded == 0)
local unresolvedSearch, pending = ns.FilterMaterials(materials, {}, "linen", "", names)
assert(#unresolvedSearch == 0 and pending == 1)
local wrong = ns.FilterMaterials(materials, {}, "999999", "", names)
assert(#wrong == 0)
local smithing = ns.FilterMaterials(materials, {}, "", "BLACKSMITHING", names)
assert(#smithing == 1 and smithing[1] == 2840)
local multi = ns.FilterMaterials(materials, {}, "", "ALCHEMY", names)
assert(#multi == 2 and has(multi, 2447) and has(multi, 765))
print("MaterialSearch offline scenarios PASS")
