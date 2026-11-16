-- Isolated mock for Forever C_Item name/icon cache and asynchronous item loading.
local ns = { materials = {[2589]={"TAILORING"},[4306]={"TAILORING"}}, state = {} }
local cache = {[4306]={name="Silk Cloth",icon=132905}}
local requests = {}
C_Item = {
    GetItemInfo = function(id)
        local item = cache[id]
        if not item then return nil end
        return item.name, nil,item.quality,item.level,nil,item.itemType,nil,nil,nil,item.icon
    end,
    GetItemInfoInstant = function(id)
        return id,nil,nil,nil,(id==2589 and 132889 or 132905)
    end,
    RequestLoadItemDataByID = function(id)
        requests[#requests+1]=id
    end,
}
assert(loadfile("addon/CraftAtlas/Infrastructure/ItemInfo.lua"))("CraftAtlas", ns)
local firstName,firstIcon=ns.GetMaterialDisplay(2589)
assert(firstName == nil and firstIcon == 132889, "uncached item must still have native instant icon")
assert(#requests==1 and requests[1]==2589, "uncached item data must be requested")
ns.GetMaterialDisplay(2589)
assert(#requests==1, "duplicate calls must not re-request pending item")
cache[2589]={name="Linen Cloth",icon=132889,quality=1,level=5,itemType="Trade Goods"}
assert(ns.UpdateMaterialInfo(2589,true)==true)
local loadedName,loadedIcon=ns.GetMaterialDisplay(2589)
assert(loadedName=="Linen Cloth" and loadedIcon==132889)
assert(ns.GetKnownMaterialNames()[2589]=="Linen Cloth")
local meta=ns.GetItemMetadata(2589)
assert(meta.level==5 and meta.itemType=="Trade Goods" and meta.quality==1,
    "item metadata must only come from the live client adapter")
assert(ns.GetItemMetadata(999999)==nil, "uncached item must not acquire fake metadata")
local cachedName,cachedIcon=ns.GetMaterialDisplay(4306)
assert(cachedName=="Silk Cloth" and cachedIcon==132905)
local missingName,missingIcon=ns.GetMaterialDisplay(999999)
assert(missingName==nil and missingIcon==nil)
print("Forever C_Item adapter offline mock PASS")
