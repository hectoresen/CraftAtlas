-- Offline pure Lua checks: texlua tests/test_recipe_usage.lua
local ns = {
    professionOrder = {"ALCHEMY", "LEATHERWORKING", "TAILORING"},
    recipeUses = {
        [14044] = {{19093, 2, 1, 15138, 1}},
        [100] = {{250, 1, 2, 0, 2}, {250, 1, 2, 0, 2}, {240, 3, 5, 400, 1}},
        [200] = {{333, 1, 1, 0, 3}},
    },
}
assert(loadfile("addon/CraftAtlas/Domain/RecipeUsage.lua"))("CraftAtlas", ns)
assert(ns.IsVerifiedReagent(14044))
assert(not ns.IsVerifiedReagent(15138), "crafted output-only item must be excluded")
local cloak = ns.GetRecipeUses(14044)
assert(#cloak == 1 and cloak[1].spellID == 19093)
assert(cloak[1].professionKey == "LEATHERWORKING" and cloak[1].quantity == 1)
assert(cloak[1].outputItemID == 15138)
local grouped, count = ns.GetGroupedRecipeRows(100)
assert(count == 2, "duplicate source recipe must collapse")
assert(#grouped == 4 and grouped[1].kind == "heading")
assert(grouped[2].use.kind == "enchant" and not grouped[2].use.outputItemID)
assert(grouped[3].professionKey == "TAILORING")
assert(grouped[4].use.outputItemID == 400 and grouped[4].use.quantity == 5)
local unknown = ns.GetRecipeUses(999)
assert(#unknown == 0)
assert(ns.GetRecipeUses(200)[1].kind == "unknown")
print("RecipeUsage pure-Lua scenarios PASS")
