-- No deferred API: process only bounded initial work and report incomplete.
local ns = {materials={},recipes={},recipeUses={},IsVerifiedReagent=function() return true end}
for i=1,50 do ns.materials[i]={"ALCHEMY"} end
for i=1,80 do ns.recipes[i]={900+i,1,0,2,{{i,1}}} end
C_Timer=nil
C_Item={GetItemInfo=function() return nil end}
C_Spell={GetSpellInfo=function() return nil end}
ns.OnCatalogProgressChanged=function() end
ns.OnCatalogDataChanged=function() end
assert(loadfile("addon/CraftAtlas/Domain/CatalogProgress.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/ItemInfo.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/RecipeNameCache.lua"))("CraftAtlas",ns)
ns.PreloadMaterialInfo()
assert(ns.GetMaterialPreparation().status=="incomplete")
assert(ns.GetMaterialPreparation().completed==20)
assert(ns.CatalogPercent(ns.GetMaterialPreparation())==40)
ns.PreloadRecipeNames()
assert(ns.GetRecipePreparation().status=="incomplete")
assert(ns.GetRecipePreparation().completed==25)
assert(ns.CatalogPercent(ns.GetRecipePreparation())==31)
print("Missing timer safe incomplete state PASS")
