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

-- Native UI regression: Ingredients stays intact, tracking gets its own rows and
-- actual Blizzard StatusBars. No live-client claims are made by these mocks.
local frames = {}
local function widget(kind,parent)
    local w = {kind=kind,parent=parent,shown=true,width=460,height=500}
    function w:SetAllPoints() end
    function w:SetPoint(which, relative, relativePoint, x, y)
        self.points=self.points or {}
        self.points[which]={relative=relative,x=x,y=y}
    end
    function w:ClearAllPoints() self.points={} end
    function w:SetSize(a,b) self.width=a self.height=b end
    function w:SetHeight(v) self.height=v end
    function w:GetHeight() return self.height end
    function w:CreateTexture() return widget("Texture",self) end
    function w:CreateFontString() return widget("FontString",self) end
    function w:SetTexture(t) self.texture=t end
    function w:SetVertexColor() end
    function w:SetColorTexture() end
    function w:SetHighlightTexture() end
    function w:SetStatusBarTexture(t) self.barTexture=t end
    function w:SetStatusBarColor() end
    function w:SetMinMaxValues(a,b) self.min=a self.max=b end
    function w:SetValue(v) self.value=v end
    function w:SetText(v) self.text=v end
    function w:SetTextColor() end
    function w:SetJustifyH() end
    function w:SetWordWrap() end
    function w:SetScript(k,fn) self[k]=fn end
    function w:SetEnabled(v) self.enabled=v end
    function w:SetChecked(v) self.checked=v end
    function w:GetChecked() return self.checked end
    function w:Show() self.shown=true end
    function w:Hide() self.shown=false end
    frames[#frames+1]=w
    return w
end
CreateFrame=function(kind,_,parent) return widget(kind,parent) end
local locale, includeBank="esES",false
local stock = {[3]={bags=0,available=0,bankStatus="excluded"},
    [4]={bags=0,available=0,bankStatus="excluded"}}
local recipe={key="ALCHEMY:2329",spellID=2329,professionKey="ALCHEMY",
    outputItemID=118,kind="item",
    ingredients={{itemID=3,quantity=2},{itemID=4,quantity=3}}}
local strings = {
    esES={RECIPE_INGREDIENT_COUNT="Materiales necesarios (%d)",
        RECIPE_QUANTITY="x%d",RECIPE_PAGE_STATUS="Página %d / %d",
        TRACK_CRAFTING="Seguir fabricación",
        TRACK_PROGRESS="Progreso de materiales",TRACK_TOTAL="Progreso total",
        TRACK_INCLUDE_BANK="Incluir banco",TRACK_AVAILABLE_BAGS="%d/%d",
        TRACK_AVAILABLE_BANK="%d/%d",TRACK_AVAILABLE_UNKNOWN="?/%d",
        TRACK_MISSING="Faltan: %d",TRACK_BANK_CURRENT="Banco actualizado",
        TRACK_BANK_OPEN_HINT="Abre el banco para actualizar"},
    enUS={RECIPE_INGREDIENT_COUNT="Ingredients (%d)",
        RECIPE_QUANTITY="x%d",RECIPE_PAGE_STATUS="Page %d / %d",
        TRACK_CRAFTING="Track crafting",
        TRACK_PROGRESS="Material progress",TRACK_TOTAL="Total progress",
        TRACK_INCLUDE_BANK="Include bank",TRACK_AVAILABLE_BAGS="%d/%d",
        TRACK_AVAILABLE_BANK="%d/%d",TRACK_AVAILABLE_UNKNOWN="?/%d",
        TRACK_MISSING="Missing: %d",TRACK_BANK_CURRENT="Bank current",
        TRACK_BANK_OPEN_HINT="Open bank to update"}
}
local uiNs={
    L=function(key) return strings[locale][key] or key end,
    ProfessionLabel=function() return "Alchemy" end,
    GetRecipeSpellPresentation=function() return "Minor Elixir",nil end,
    GetItemDisplay=function(id) return "Item "..id,id end,
    GetCatalogRecipe=function(key) if key==recipe.key then return recipe end end,
    IsCraftableTracked=function(key) return key==recipe.key end,
    GetCraftBankPreference=function() return includeBank end,
    SetCraftBankPreference=function(v) includeBank=v end,
    IsCraftBankSupported=function() return true end,
    ReadCraftInventoryCount=function(id) return stock[id] end,
    ComputeCraftableCoverage=ns.ComputeCraftableCoverage,
    HideRecipeTooltip=function() end,
    PaginateRecipeUses=function(items,page,size)
        local pages=math.max(1,math.ceil(#items/size))
        page=math.max(1,math.min(page,pages))
        local rows={}
        for i=(page-1)*size+1,math.min(#items,page*size) do
            rows[#rows+1]=items[i]
        end
        return rows,page,pages
    end,
}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",uiNs)
assert(loadfile("addon/CraftAtlas/Features/Settings/RecipesView.lua"))("CraftAtlas",uiNs)
uiNs.InitRecipeDetail(widget("Frame"))
uiNs.SetRecipeDetail(recipe.key)
local function findLabel(txt)
    for _,w in ipairs(frames) do
        if w.kind=="FontString" and w.text==txt then return w end
    end
end
local function ingredientRows()
    local result={}
    for _,w in ipairs(frames) do
        if w.kind=="Button" and w.ingredient and w.shown then
            result[#result+1]=w
        end
    end
    return result
end
local ingredient=ingredientRows()
eq(#ingredient,2,"both ingredients are on first page")
eq(ingredient[1].professions.text,"x2","Ingredients remains exactly x2")
eq(ingredient[2].professions.text,"x3","Ingredients remains exactly x3")
for _,w in ipairs(ingredient) do
    eq(w.progress,nil,"no progress bar added to original Ingredients row")
end
assert(findLabel("Progreso de materiales") and findLabel("Progreso total"),
    "distinct tracking section in Spanish")
assert(findLabel("0/2") and findLabel("0/3"),
    "zero-stock tracker shows required quantities")
local statusbars={}
for _,w in ipairs(frames) do
    if w.kind=="StatusBar" and w.shown then
        eq(w.barTexture,"Interface\\TargetingFrame\\UI-StatusBar","Blizzard bar texture")
        statusbars[#statusbars+1]=w
    end
end
eq(#statusbars,3,"two independent material bars and one aggregate")
for _,w in ipairs(statusbars) do eq(w.value,0,"empty bar really at zero") end
stock[3]={bags=4,available=4,bankStatus="excluded"}
stock[4]={bags=1,available=1,bankStatus="excluded"}
uiNs.RefreshRecipeDetail()
assert(findLabel("4/2") and findLabel("1/3"),"show uncapped bags in dedicated tracker")
assert(findLabel("60%"),"weighted overall percent is 3/5")
assert(findLabel("Faltan: 0") and findLabel("Faltan: 2"),"missing counts")
eq(ingredient[1].professions.text,"x2","Ingredients stays unchanged on stock refresh")
includeBank=true
stock[3]={bags=4,bank=0,available=4,bankStatus="confirmed"}
stock[4]={bags=1,bank=2,available=3,bankStatus="confirmed"}
uiNs.RefreshRecipeDetail()
assert(findLabel("100%"),"bank increment completes the overall total")
assert(findLabel("3/3"),"bank added to item availability")
includeBank=false
uiNs.RefreshRecipeDetail()
assert(findLabel("100%"),"stub bank count still included in raw observation: fixture sanity check")
-- Real adapter returns bags-only observations when Include bank is off.
stock[4]={bags=1,available=1,bankStatus="excluded"}
uiNs.RefreshRecipeDetail()
assert(findLabel("60%"),"disabling bank reverts to bags-only")
locale="enUS"
uiNs.RefreshRecipeDetail()
assert(findLabel("Material progress") and findLabel("Total progress"),
    "locale refresh retranslates separate tracker")
assert(findLabel("Track crafting") and findLabel("Missing: 2"),
    "tracker label and missing quantity localized")
assert(findLabel("Ingredients (2)"),"original ingredient section localizes")
print("Craftable tracking native separate material rows PASS")
