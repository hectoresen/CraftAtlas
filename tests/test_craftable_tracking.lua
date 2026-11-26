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
combined = bag
observation = ns.ReadCraftInventoryCount(3,true)
eq(observation.bank,0,"confirmed empty bank must be numeric zero")
eq(observation.available,bag,"empty bank adds nothing to progress")
combined = 1
eq(ns.ReadCraftInventoryCount(3,true).available,2,"inconsistent combined count")
ns.SetCraftBankOpen(false)
eq(ns.ReadCraftInventoryCount(3,true).bank,nil,"no cached bank stock")
-- Regression from the in-game bank screenshot: combined item count returned
-- bag-only for Silverleaf even while bank slots visibly held multiple stacks.
-- Prefer a full scan of actual bank slots to C_Item.GetItemCount(true).
C_Container = {}
local bankStacks = {
    [-1] = {
        [1] = {itemID=765,stackCount=20},
        [2] = {itemID=765,stackCount=11},
        [3] = {itemID=2449,stackCount=6},
    },
    [5] = {[1] = {itemID=765,stackCount=4}},
}
C_Container.GetContainerNumSlots = function(container)
    if container == -1 then return 28 end
    if container == 5 then return 4 end
    return 0
end
C_Container.GetContainerItemInfo = function(container,slot)
    return bankStacks[container] and bankStacks[container][slot]
end
C_Container.GetContainerItemID = function(container,slot)
    local v=bankStacks[container] and bankStacks[container][slot]
    return v and v.itemID
end
local oldGetter = C_Item.GetItemCount
C_Item.GetItemCount = function(item, withBank)
    if item == 2449 then return 1 end
    if item == 765 then return 0 end -- known broken aggregated path
    return 0
end
ns.SetCraftBankOpen(true)
local silverleaf = ns.ReadCraftInventoryCount(765,true)
eq(silverleaf.bags,0,"silverleaf missing from bags")
eq(silverleaf.bank,35,"main-bank and bank-bag stacks must be scanned")
eq(silverleaf.available,35,"fresh scan overrides broken includeBank count")
eq(silverleaf.bankStatus,"confirmed","bank scan is current")
-- The slot API exists but fails: never silently accept the aggregate zero.
local originalSlotCount = C_Container.GetContainerNumSlots
C_Container.GetContainerNumSlots = function(container)
    if container == -1 then return nil end
    return originalSlotCount(container)
end
local incomplete = ns.ReadCraftInventoryCount(765,true)
eq(incomplete.bankStatus,"unknown","unreadable bank cannot be confirmed empty")
eq(incomplete.bank,nil,"unreadable bank is not a confirmed zero")
eq(incomplete.available,0,"only current bags survive incomplete scan")
C_Container.GetContainerNumSlots = originalSlotCount
local earthroot = ns.ReadCraftInventoryCount(2449,true)
eq(earthroot.available,7,"bag and bank combined without double counting")
local absent = ns.ReadCraftInventoryCount(3371,true)
eq(absent.bank,0,"an empty but accessible bank is confirmed zero")
ns.SetCraftBankOpen(false)
eq(ns.ReadCraftInventoryCount(765,true).available,0,
    "closed bank does not use previously observed bank stacks")
C_Item.GetItemCount = oldGetter
C_Container = nil

C_Item = nil
GetItemCount = nil
eq(ns.ReadCraftInventoryCount(3,false).bags,nil,"missing API unknown not zero")
eq(ns.ReadCraftInventoryCount(3,true).bankStatus,"unavailable","unsupported bank")
local player,realm="Alice","Test Realm"
UnitName=function() return player end
GetRealmName=function() return realm end
CraftAtlasDB = nil
ns.InitPreferences()
eq(ns.IsCraftTrackingEnabled(),false,"global tracking defaults off")
-- Upgrading from old per-recipe SavedVariables must never auto-enable global mode.
CraftAtlasDB.craftTracking["Test Realm:Alice"] = {["ALCHEMY:100"] = true}
eq(ns.IsCraftTrackingEnabled(),false,"old recipe opt-in never enables global toggle")
eq(ns.SetCraftTrackingEnabled(true),true,"enable global tracking")
eq(ns.IsCraftTrackingEnabled(),true,"all recipes share one character toggle")
eq(CraftAtlasDB.craftTracking["Test Realm:Alice"]["ALCHEMY:100"],true,
    "legacy recipe records remain untouched")
ns.InitPreferences()
eq(ns.IsCraftTrackingEnabled(),true,"global tracking survives UI reload")
player="Bob"
eq(ns.IsCraftTrackingEnabled(),false,"other character defaults disabled")
eq(ns.SetCraftTrackingEnabled(true),true,"second character can opt in")
player="Alice"
eq(ns.IsCraftTrackingEnabled(),true,"first character retains preference")
eq(ns.SetCraftTrackingEnabled(false),true,"global opt-out")
eq(ns.IsCraftTrackingEnabled(),false,"global opt-out sticks")
player="Bob"
eq(ns.IsCraftTrackingEnabled(),true,"disabling first character does not affect second")
player=nil
eq(ns.SetCraftTrackingEnabled(true),false,"identity required for global write")
eq(ns.IsCraftTrackingEnabled(),false,"identity required for global read")
player="Alice"
ns.SetCraftBankPreference(true)
eq(ns.GetCraftBankPreference(),true,"bank preference independent of global tracking")
eq(ns.IsCraftTrackingEnabled(),false,"bank toggle never enables tracking")
ns.SetCraftTrackingEnabled(true)
eq(ns.GetCraftBankPreference(),true,"global tracking never clears include bank")
ns.SetCraftBankPreference(false)
eq(ns.IsCraftTrackingEnabled(),true,"bank opt-out never disables tracking")
print("Craftable tracking domain/adapter/preferences PASS")

-- Native UI regression: Ingredients stays intact, tracking gets its own rows and
-- actual Blizzard StatusBars. No live-client claims are made by these mocks.
local frames = {}
local function widget(kind,parent)
    local w = {kind=kind,parent=parent,shown=true,width=460,height=440}
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
    function w:SetBackdrop(info) self.backdrop=info end
    function w:SetBackdropColor() end
    function w:SetBackdropBorderColor() end
    function w:SetStatusBarColor(r,g,b) self.barColor={r,g,b} end
    function w:SetMinMaxValues(a,b) self.min=a self.max=b end
    function w:SetValue(v) self.value=v end
    function w:SetText(v) self.text=v end
    function w:SetTextColor() end
    function w:SetJustifyH() end
    function w:SetWordWrap() end
    function w:SetScript(k,fn) self[k]=fn end
    function w:SetEnabled(v) self.enabled=v end
    function w:SetChecked(v) self.checked=v end
    function w:GetChecked()
        if self.kind == "CheckButton" then return self.checked and 1 or nil end
        return self.checked
    end
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
local otherRecipe={key="ALCHEMY:2330",spellID=2330,professionKey="ALCHEMY",
    outputItemID=858,kind="item",
    ingredients={{itemID=5,quantity=1}}}
local trackingEnabled=true
local strings = {
    esES={RECIPE_INGREDIENT_COUNT="Materiales necesarios (%d)",
        RECIPE_QUANTITY="x%d",RECIPE_PAGE_STATUS="Página %d / %d",
        TRACK_CRAFTING="Seguir fabricación",
        TRACK_PROGRESS="Progreso de materiales",TRACK_TOTAL="Progreso total",
        TRACK_INCLUDE_BANK="Incluir banco",TRACK_ROW_SUMMARY="%d/%d · Faltan %d",TRACK_AVAILABLE_BAGS="%d/%d",
        TRACK_AVAILABLE_BANK="%d/%d",TRACK_AVAILABLE_UNKNOWN="?/%d",
        TRACK_MISSING="Faltan: %d",TRACK_BANK_CURRENT="Banco actualizado",
        TRACK_BANK_OPEN_HINT="Abre el banco para actualizar"},
    enUS={RECIPE_INGREDIENT_COUNT="Ingredients (%d)",
        RECIPE_QUANTITY="x%d",RECIPE_PAGE_STATUS="Page %d / %d",
        TRACK_CRAFTING="Track crafting",
        TRACK_PROGRESS="Material progress",TRACK_TOTAL="Total progress",
        TRACK_INCLUDE_BANK="Include bank",TRACK_ROW_SUMMARY="%d/%d · Missing %d",TRACK_AVAILABLE_BAGS="%d/%d",
        TRACK_AVAILABLE_BANK="%d/%d",TRACK_AVAILABLE_UNKNOWN="?/%d",
        TRACK_MISSING="Missing: %d",TRACK_BANK_CURRENT="Bank current",
        TRACK_BANK_OPEN_HINT="Open bank to update"}
}
local uiNs={
    L=function(key) return strings[locale][key] or key end,
    ProfessionLabel=function() return "Alchemy" end,
    GetRecipeSpellPresentation=function() return "Minor Elixir",nil end,
    GetItemDisplay=function(id) return "Item "..id,id end,
    GetCatalogRecipe=function(key)
        if key==recipe.key then return recipe end
        if key==otherRecipe.key then return otherRecipe end
    end,
    IsCraftTrackingEnabled=function() return trackingEnabled end,
    SetCraftTrackingEnabled=function(value) trackingEnabled=value end,
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
assert(findLabel("0/2 · Faltan 2") and findLabel("0/3 · Faltan 3"),
    "zero-stock tracker shows required quantities")
local statusbars={}
for _,w in ipairs(frames) do
    if w.kind=="StatusBar" and w.shown and (not w.parent or w.parent.shown) then
        eq(w.barTexture,"Interface\\TargetingFrame\\UI-StatusBar","Blizzard bar texture")
        eq(w.backdrop.edgeFile,"Interface\\Tooltips\\UI-Tooltip-Border","Blizzard frame")
        statusbars[#statusbars+1]=w
    end
end
eq(#statusbars,3,"two independent material bars and one aggregate")
for _,w in ipairs(statusbars) do
    eq(w.value,0,"empty bar really at zero")
end
local function progressColors()
    local rows={}
    for _,w in ipairs(frames) do
        if w.kind=="StatusBar" and w.shown and (not w.parent or w.parent.shown) then
            rows[#rows+1]=w
        end
    end
    return rows
end
local function isOrange(w)
    return w.barColor and w.barColor[1] > w.barColor[2]
        and w.barColor[2] > w.barColor[3]
end
local function isGreen(w)
    return w.barColor and w.barColor[2] > w.barColor[1]
        and w.barColor[2] > w.barColor[3]
end
stock[3]={bags=4,available=4,bankStatus="excluded"}
stock[4]={bags=1,available=1,bankStatus="excluded"}
uiNs.RefreshRecipeDetail()
assert(findLabel("4/2 · Faltan 0") and findLabel("1/3 · Faltan 2"),"show uncapped bags in dedicated tracker")
assert(findLabel("60%"),"weighted overall percent is 3/5")
local halfBars=progressColors()
eq(#halfBars,3,"three native bars shown for partial progress")
assert(isOrange(halfBars[3]),"total partial progress uses amber fill")
local greenCount, amberCount=0,0
for _,w in ipairs(halfBars) do
    if isGreen(w) then greenCount=greenCount+1 end
    if isOrange(w) then amberCount=amberCount+1 end
end
eq(greenCount,1,"exactly one material is fully covered")
eq(amberCount,2,"partial ingredient and aggregate progress use amber")
assert(findLabel("4/2 · Faltan 0") and findLabel("1/3 · Faltan 2"),"missing counts")
eq(ingredient[1].professions.text,"x2","Ingredients stays unchanged on stock refresh")
includeBank=true
stock[3]={bags=4,bank=0,available=4,bankStatus="confirmed"}
stock[4]={bags=1,bank=2,available=3,bankStatus="confirmed"}
uiNs.RefreshRecipeDetail()
assert(findLabel("100%"),"bank increment completes the overall total")
for _,w in ipairs(progressColors()) do
    assert(isGreen(w),"every fully covered native progress bar must be green")
end
assert(findLabel("3/3 · Faltan 0"),"bank added to item availability")
includeBank=false
uiNs.RefreshRecipeDetail()
-- Adapter observations change from combined stock to bags-only on opt-out.
stock[4]={bags=1,available=1,bankStatus="excluded"}
uiNs.RefreshRecipeDetail()
assert(findLabel("60%"),"disabling bank reverts to bags-only")
locale="enUS"
uiNs.RefreshRecipeDetail()
assert(findLabel("Material progress") and findLabel("Total progress"),
    "locale refresh retranslates separate tracker")
assert(findLabel("Track crafting") and findLabel("1/3 · Missing 2"),
    "tracker label and missing quantity localized")
assert(findLabel("Ingredients (2)"),"original ingredient section localizes")
-- Compact pane: three ingredient and tracking rows must fit on one page.
recipe.ingredients[#recipe.ingredients + 1] = {itemID=5,quantity=1}
stock[5]={bags=0,available=0,bankStatus="excluded"}
uiNs.RefreshRecipeDetail()
local rowsWithThird = ingredientRows()
eq(#rowsWithThird,3,"all three original ingredient rows remain visible at 440px")
eq(rowsWithThird[3].professions.text,"x1","third ingredient remains unmodified")
local progressBars=0
for _,w in ipairs(frames) do
    if w.kind=="StatusBar" and w.shown and (not w.parent or w.parent.shown) then
        progressBars=progressBars+1
    end
end
eq(progressBars,4,"three material progress bars plus total on one page")
assert(findLabel("0/1 · Missing 1"),"third material progress belongs in separate section")
-- Prevent the previous visual regression: compact row math alone is
-- insufficient when second-line text and bars intersect the next row.
local trackerRows = {}
local bankButton
for _,w in ipairs(frames) do
    if w.kind=="Frame" and w.shown and w.height==25 and w.name and w.bar then
        trackerRows[#trackerRows+1]=w
    elseif w.kind=="CheckButton" and w.parent and w.parent.points
        and w.points and w.points.TOPLEFT and w.points.TOPLEFT.y == -16 then
        bankButton=w
    end
end
eq(#trackerRows,3,"three separately spaced tracker rows are visible")
for _,w in ipairs(trackerRows) do
    local point = w.bar.points.TOPLEFT
    assert(point and point.y <= -12,"material bar must be below summary baseline")
    assert(-point.y + w.bar.height <= w.height,
        "material bar must end inside its own row, before the next material")
    assert(w.amount.points.TOPRIGHT and w.name.points.TOPRIGHT,
        "name and available/missing summary share one baseline")
    eq(w.missing.text,"","missing quantity must not create a third text line")
end
assert(bankButton and bankButton.points.TOPLEFT.y + -bankButton.height >= -34,
    "bank checkbox must not extend into the first tracker row")
-- The real WoW 5.1 CheckButton may return numeric 1, not boolean true.
includeBank=false
bankButton:SetChecked(true)
bankButton.OnClick(bankButton)
eq(includeBank,true,"native numeric bank checkbox opt-in must persist")
bankButton:SetChecked(false)
bankButton.OnClick(bankButton)
eq(includeBank,false,"native bank checkbox opt-out must persist")
-- Toggle once, navigate to another recipe, and keep it enabled. Only the
-- selected recipe's ingredients contribute to Material progress.
local trackingCheckbox
for _,w in ipairs(frames) do
    if w.kind=="CheckButton" and w.points and w.points.TOPRIGHT
        and w.points.TOPRIGHT.x == -176 then trackingCheckbox=w end
end
assert(trackingCheckbox and trackingCheckbox.checked,
    "global checkbox is checked when tracking is enabled")
uiNs.SetRecipeDetail(otherRecipe.key)
eq(trackingCheckbox.checked,true,"switching to another recipe preserves toggle")
assert(findLabel("0/1 · Missing 1"),"second recipe has its own ingredient quantities")
local secondRows=ingredientRows()
eq(#secondRows,1,"second recipe shows only its own Ingredients")
eq(secondRows[1].ingredient.itemID,5,"second recipe itemID not stale")
eq(secondRows[1].professions.text,"x1","second recipe requirement kept")
trackingCheckbox:SetChecked(false)
trackingCheckbox.OnClick(trackingCheckbox)
eq(trackingEnabled,false,"turning off recipe B disables global tracking")
uiNs.SetRecipeDetail(recipe.key)
eq(trackingCheckbox.checked,false,"recipe A stays unchecked after global opt-out")
assert(not (function()
    for _,w in ipairs(frames) do
        if w.kind=="Frame" and w.points and w.points.TOPLEFT
            and w.points.TOPLEFT.y == -47 and w.shown then return true end
    end
    return false
end)(),"material progress hidden when global preference is disabled")
trackingCheckbox:SetChecked(true)
trackingCheckbox.OnClick(trackingCheckbox)
eq(trackingEnabled,true,"re-enable global tracking on recipe A")
eq(trackingCheckbox.checked,true,"numeric GetChecked=1 must persist opt-in")
uiNs.SetRecipeDetail(otherRecipe.key)
eq(trackingCheckbox.checked,true,"global opt-in survives second navigation")
assert(findLabel("0/1 · Missing 1"),"other recipe tracker reappears without rechecking")
print("Craftable tracking native separate material rows PASS")
