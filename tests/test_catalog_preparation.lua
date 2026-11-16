-- Deterministic fake timer; no WoW client or network required.
local ns = {
    materials = {}, recipes = {}, recipeUses = {},
    IsVerifiedReagent = function() return true end,
}
for i=1,45 do ns.materials[i]={"ALCHEMY"} end
for i=1,51 do
    ns.recipes[i] = {1000+i, 1, i, 1, {{i, 1}}}
end
local queued = {}
C_Timer = {After = function(delay, fn)
    queued[#queued+1] = {delay=delay,fn=fn}
end}
C_Item = {
    GetItemInfo = function(id)
        return "Material " .. id, nil,nil,nil,nil,nil,nil,nil,nil, 2000+id
    end,
}
C_Spell = {GetSpellInfo = function(id)
    if id == 1051 then return {name="", iconID=id+10} end
    return {name="Spell " .. id, iconID=id+10}
end}
local progressNotices, dirtyNotices = {materials=0, recipes=0},{materials=0,recipes=0}
ns.OnCatalogProgressChanged = function(view)
    progressNotices[view] = progressNotices[view] + 1
end
ns.OnCatalogDataChanged = function(view)
    dirtyNotices[view] = dirtyNotices[view] + 1
end
assert(loadfile("addon/CraftAtlas/Domain/CatalogProgress.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/ItemInfo.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/RecipeNameCache.lua"))("CraftAtlas",ns)
ns.PreloadMaterialInfo()
assert(ns.GetMaterialPreparation().completed==20)
assert(#queued==1 and queued[1].delay==0.1)
ns.PreloadMaterialInfo()
assert(#queued==1,"reopening must not launch a duplicate material worker")
while #queued>0 do
    local nextTask=table.remove(queued,1)
    nextTask.fn()
end
assert(ns.GetMaterialPreparation().completed==45)
assert(ns.GetMaterialPreparation().status=="complete")
assert(ns.GetMaterialPreparationMetrics().batches==3)
assert(dirtyNotices.materials<=4, "work notifies by batch, not by item")
assert(progressNotices.materials==4, "initial + three batches")
ns.PreloadRecipeNames()
assert(ns.GetRecipePreparation().completed==25)
assert(#queued==1 and queued[1].delay==0.08)
ns.PreloadRecipeNames()
assert(#queued==1,"duplicate recipe worker")
while #queued>0 do table.remove(queued,1).fn() end
assert(ns.GetRecipePreparation().completed==51 and ns.CatalogPercent(ns.GetRecipePreparation())==100)
assert(ns.GetRecipePreparationMetrics().batches==3)
assert(dirtyNotices.recipes<=4,"work notifies by batch, not by record")
assert(ns.GetRecipeNames()[1001]=="Spell 1001")
assert(ns.GetRecipeNames()[1051]==nil, "empty client names are unresolved, not cached")
-- Late resolution via optional native event invalidates names without rerunning preparation.
C_Spell.GetSpellInfo=function(id)
    if id==1001 then return {name="Updated spell",iconID=1011} end
    if id==1051 then return {name="Resolved late",iconID=1061} end
    return {name="Spell "..id,iconID=id+10}
end
assert(ns.UpdateRecipeName(1051)==true, "late native names must invalidate search cache")
assert(ns.GetRecipeNames()[1051]=="Resolved late")
assert(ns.UpdateRecipeName(1001)==false,
    "resolved names already cached must remain stable within the session")
print("Material and recipe fake-timer preparation PASS")
