-- Pure Lua recipe catalog regression, texlua tests/test_recipe_catalog.lua
local ns = {
    professionOrder = {"ALCHEMY", "TAILORING"},
    recipes = {
        {101,1,900,1,{{765,2},{3371,1}}},
        {102,1,900,1,{{765,1}}},
        {103,2,0,2,{{2589,3}}},
    },
}
assert(loadfile("addon/CraftAtlas/Domain/RecipeCatalog.lua"))("CraftAtlas", ns)
local recipe = ns.GetCatalogRecipe("ALCHEMY:101")
assert(recipe.key=="ALCHEMY:101" and recipe.spellID==101)
assert(recipe.outputItemID==900 and #recipe.ingredients==2)
assert(recipe.ingredients[1].quantity==2 and recipe.ingredients[2].itemID==3371)
assert(ns.GetCatalogRecipe("ALCHEMY:102").outputItemID==900, "same output does not collapse recipes")
assert(ns.GetCatalogRecipe("ALCHEMY:103")==nil)
assert(ns.GetCatalogRecipe("TAILORING:103").kind=="enchant")
local names={[101]="Healing Potion",[102]="Mana Potion",[103]="Cloth Enchant"}
local outputs={[900]="Healing Item"}
local labels={ALCHEMY="Alquimia",TAILORING="Sastrería"}
local all, incomplete=ns.SearchCatalogRecipes("","",names,outputs,labels)
assert(#all==3 and incomplete==0)
local byName=ns.SearchCatalogRecipes("Healing Potion","",names,outputs,labels)
assert(#byName==1 and byName[1]=="ALCHEMY:101")
local byOutput=ns.SearchCatalogRecipes("Healing Item","",names,outputs,labels)
assert(#byOutput==2, "same product yields two recipes")
local byProfession=ns.SearchCatalogRecipes("Alquimia","",names,outputs,labels)
assert(#byProfession==2)
local filtered=ns.SearchCatalogRecipes("","TAILORING",names,outputs,labels)
assert(#filtered==1 and filtered[1]=="TAILORING:103")
local byID=ns.SearchCatalogRecipes("102","",{}, {}, labels)
assert(#byID==1 and byID[1]=="ALCHEMY:102")
local unknown,pending=ns.SearchCatalogRecipes("not-there","",{}, {}, labels)
assert(#unknown==0 and pending==3)
print("RecipeCatalog domain tests PASS")
