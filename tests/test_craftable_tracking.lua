-- Offline Lua 5.1 regression for current-character opt-in tracking.
local ns = {state = {}}
assert(loadfile("addon/CraftAtlas/Domain/CraftableTracking.lua"))("CraftAtlas", ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/InventoryCounts.lua"))("CraftAtlas", ns)
assert(loadfile("addon/CraftAtlas/Infrastructure/Preferences.lua"))("CraftAtlas", ns)
local function eq(a,b,label) assert(a==b, (label or "mismatch") .. ": "..tostring(a).." ~= "..tostring(b)) end
local ingredients = {{itemID=3,quantity=2}, {itemID=4,quantity=3}}
local result = ns.ComputeCraftableCoverage(ingredients, {
    [3]={available=1}, [4]={available=2}
})
eq(result.percent,60,"weighted progress")
eq(result.missing,2,"missing units")
eq(result.verified,true,"known observations")
result = ns.ComputeCraftableCoverage({{itemID=3,quantity=2},{itemID=3,quantity=3}},
    {[3]={available=3}})
eq(result.required,5,"duplicate requirement")
eq(result.covered,3,"do not double count")
eq(#result.rows,1,"deduplicate rows")
result = ns.ComputeCraftableCoverage(ingredients,{[3]={available=2}})
eq(result.verified,false,"unknown count")
eq(result.percent,40,"lower bound not complete")
eq(ns.ComputeCraftableCoverage({},{}).verified,false,"missing recipe data")
eq(ns.ComputeCraftableCoverage({},{}).percent,nil,"no divide by zero")
local bag, combined = 2, 5
C_Item = {GetItemCount=function(_,bank) if bank then return combined end return bag end}
local observation = ns.ReadCraftInventoryCount(3,true)
eq(observation.available,2,"closed bank excluded")
eq(observation.bankStatus,"unknown","closed bank status")
ns.SetCraftBankOpen(true)
observation = ns.ReadCraftInventoryCount(3,true)
eq(observation.bank,3,"bank delta")
eq(observation.available,5,"combined stock")
eq(observation.bankStatus,"confirmed","open bank observation")
combined = 1
eq(ns.ReadCraftInventoryCount(3,true).available,2,"inconsistent combined count")
ns.SetCraftBankOpen(false)
eq(ns.ReadCraftInventoryCount(3,true).bank,nil,"no cached bank stock")
C_Item = nil
GetItemCount = nil
eq(ns.ReadCraftInventoryCount(3,false).bags,nil,"missing API unknown not zero")
eq(ns.ReadCraftInventoryCount(3,true).bankStatus,"unavailable","unsupported bank")
local player,realm="Alice","Test Realm"
UnitName=function() return player end
GetRealmName=function() return realm end
CraftAtlasDB = nil
ns.InitPreferences()
eq(ns.IsCraftableTracked("ALCHEMY:100"),false,"default disabled")
ns.SetCraftableTracked("ALCHEMY:100",true)
eq(ns.IsCraftableTracked("ALCHEMY:100"),true,"persist tracked recipe")
ns.InitPreferences()
eq(ns.IsCraftableTracked("ALCHEMY:100"),true,"reload persistence")
player="Bob"
eq(ns.IsCraftableTracked("ALCHEMY:100"),false,"character isolation")
ns.SetCraftableTracked("ALCHEMY:100",true)
player="Alice"
eq(ns.IsCraftableTracked("ALCHEMY:101"),false,"per recipe")
eq(ns.IsCraftableTracked("ALCHEMY:100"),true,"original char state")
ns.SetCraftableTracked("ALCHEMY:100",false)
eq(ns.IsCraftableTracked("ALCHEMY:100"),false,"disable")
player=nil
ns.SetCraftableTracked("ALCHEMY:100",true)
eq(ns.IsCraftableTracked("ALCHEMY:100"),false,"no ambiguous identity")
print("Craftable tracking domain/adapter/preferences PASS")
