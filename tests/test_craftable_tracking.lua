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

-- Native UI integration: empty bars stay visible and labels switch with locale.
local frames = {}
local function widget(kind, parent)
    local self = {kind = kind, parent = parent, width = 400, height = 343, shown = true}
    function self:SetAllPoints() end
    function self:SetPoint() end
    function self:ClearAllPoints() end
    function self:SetSize(w,h) self.width=w self.height=h end
    function self:SetHeight(h) self.height=h end
    function self:GetHeight() return self.height end
    function self:CreateTexture() return widget("Texture", self) end
    function self:CreateFontString() return widget("FontString", self) end
    function self:SetTexture(value) self.texture=value end
    function self:SetHighlightTexture() end
    function self:SetColorTexture() self.color=true end
    function self:SetStatusBarTexture() end
    function self:SetStatusBarColor() end
    function self:SetMinMaxValues() end
    function self:SetValue(value) self.value=value end
    function self:SetText(value) self.text=value end
    function self:SetTextColor() end
    function self:SetJustifyH() end
    function self:SetWordWrap() end
    function self:SetScript(key, fn) self[key]=fn end
    function self:SetEnabled() end
    function self:SetChecked(value) self.checked=value end
    function self:GetChecked() return self.checked end
    function self:Show() self.shown=true end
    function self:Hide() self.shown=false end
    frames[#frames+1] = self
    return self
end
CreateFrame = function(kind, _, parent) return widget(kind, parent) end
local uiLocale = "esES"
local uiRecipe = {
    key = "ALCHEMY:2329", spellID = 2329, professionKey = "ALCHEMY",
    outputItemID = 118, kind = "item",
    ingredients = {{itemID=3,quantity=2},{itemID=4,quantity=3}},
}
local uiNs = {
    L = function(key)
        local strings = {
            esES = {TRACK_CRAFTING="Seguir fabricación", TRACK_PROGRESS="Progreso de materiales",
                TRACK_INCLUDE_BANK="Incluir banco", TRACK_BANK_UNAVAILABLE="Banco no disponible",
                RECIPE_INGREDIENT_COUNT="Materiales necesarios (%d)",
                TRACK_INGREDIENT_STATUS="%d/%d · Faltan %d", RECIPE_PAGE_STATUS="Página %d / %d"},
            enUS = {TRACK_CRAFTING="Track crafting", TRACK_PROGRESS="Material progress",
                TRACK_INCLUDE_BANK="Include bank", TRACK_BANK_UNAVAILABLE="Bank unavailable",
                RECIPE_INGREDIENT_COUNT="Ingredients (%d)",
                TRACK_INGREDIENT_STATUS="%d/%d · Missing %d", RECIPE_PAGE_STATUS="Page %d / %d"}
        }
        return strings[uiLocale][key] or key
    end,
    ProfessionLabel=function() return "Alchemy" end,
    GetRecipeSpellPresentation=function() return "Minor Elixir", nil end,
    GetItemDisplay=function(id) return "Item "..id, id end,
    GetCatalogRecipe=function(key) if key==uiRecipe.key then return uiRecipe end end,
    IsCraftableTracked=function(key) return key==uiRecipe.key end,
    GetCraftBankPreference=function() return false end,
    IsCraftBankSupported=function() return true end,
    ReadCraftInventoryCount=function() return {bags=0,available=0,bankStatus="excluded"} end,
    ComputeCraftableCoverage=ns.ComputeCraftableCoverage,
    HideRecipeTooltip=function() end,
    PaginateRecipeUses=function(ingredients,page,size)
        local rows={}
        for i=(page-1)*size+1,math.min(page*size,#ingredients) do
            rows[#rows+1]=ingredients[i]
        end
        return rows,page,math.max(1,math.ceil(#ingredients/size))
    end,
}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",uiNs)
assert(loadfile("addon/CraftAtlas/Features/Settings/RecipesView.lua"))("CraftAtlas",uiNs)
uiNs.InitRecipeDetail(widget("Frame"))
uiNs.SetRecipeDetail(uiRecipe.key)
local trackCheck, bankText, footerBar, progressCount, divider = nil,nil,nil,0,0
for _, frame in ipairs(frames) do
    if frame.kind=="CheckButton" and frame.SetChecked then
        if not trackCheck then trackCheck=frame end
    end
    if frame.kind=="FontString" and frame.text=="Incluir banco" then bankText=frame end
    if frame.kind=="StatusBar" and frame.shown and frame.value==0 then
        progressCount=progressCount+1
        local hasBackground=false
        for _, child in ipairs(frames) do
            if child.kind=="Texture" and child.parent==frame and child.color then
                hasBackground=true
                break
            end
        end
        assert(hasBackground,"zero-percent bar has visible full-width background")
        footerBar=frame
    end
    if frame.kind=="Texture" and frame.color then divider=divider+1 end
end
assert(progressCount>=3, "both per-ingredient and aggregate bars are visible at 0%")
assert(divider>=3, "native-style section divider and bar outlines")
assert(trackCheck and trackCheck.checked and bankText, "tracking controls visible")
local function labelFound(value)
    for _, frame in ipairs(frames) do
        if frame.kind=="FontString" and frame.text==value then return true end
    end
    return false
end
assert(labelFound("Seguir fabricación"),"Spanish tracker label")
uiLocale="enUS"
uiNs.RefreshRecipeDetail()
assert(labelFound("Track crafting"),"checkbox text updates on locale change")
assert(labelFound("Include bank"),"bank label updates on locale change")
assert(labelFound("Ingredients (2)"),"ingredient section updates on locale change")
assert(labelFound("Material progress: 0%"),"progress title updates on locale change")
print("Craftable tracking localized native UI regression PASS")

