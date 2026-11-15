-- Pure Lua pagination: texlua tests/test_recipe_pagination.lua
local ns = {professionOrder = {"ALCHEMY"}, recipeUses = {}}
assert(loadfile("addon/CraftAtlas/Domain/RecipeUsage.lua"))("CraftAtlas", ns)

local samples = {}
for i = 1, 14 do samples[i] = {spellID = 9000 + i} end
local function check(total, requested, expectedPage, expectedPages, expectedCount, firstIndex)
    local subset = {}
    for i = 1, total do subset[i] = samples[i] end
    local result, page, pages, count = ns.PaginateRecipeUses(subset, requested, 6)
    assert(page == expectedPage and pages == expectedPages and count == total,
        "invalid page metadata for total " .. total .. ", requested " .. requested)
    assert(#result == expectedCount, "wrong number of recipes")
    if firstIndex then assert(result[1] == samples[firstIndex]) end
    return result
end
check(0, 1, 0, 0, 0)
check(1, 1, 1, 1, 1, 1)
check(6, 1, 1, 1, 6, 1)
check(7, 2, 2, 2, 1, 7)
local first = check(14, 1, 1, 3, 6, 1)
local second = check(14, 2, 2, 3, 6, 7)
local third = check(14, 3, 3, 3, 2, 13)
check(14, 4, 3, 3, 2, 13)
check(14, 0, 1, 3, 6, 1)
check(14, -1, 1, 3, 6, 1)
local seen = {}
for _, page in ipairs({first, second, third}) do
    for _, use in ipairs(page) do
        assert(not seen[use.spellID], "duplicate between pages")
        seen[use.spellID] = true
    end
end
assert(#samples == 14)
for _, use in ipairs(samples) do assert(seen[use.spellID]) end
print("Recipe pagination domain tests PASS")
