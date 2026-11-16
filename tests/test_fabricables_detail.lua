-- Native Fabricables detail regression, no live WoW client required.
local widgets = {}
local function widget(kind, parent)
    local self = {kind=kind, parent=parent, shown=true, width=400, height=400}
    function self:SetAllPoints() end
    function self:SetSize(w, h) self.width=w self.height=h end
    function self:SetHeight(h) self.height=h end
    function self:SetWidth(w) self.width=w end
    function self:GetHeight() return self.height end
    function self:SetPoint() end
    function self:ClearAllPoints() end
    function self:CreateTexture() return widget("Texture", self) end
    function self:CreateFontString() return widget("FontString", self) end
    function self:SetTexture(value) self.texture=value end
    function self:SetColorTexture() end
    function self:SetHighlightTexture() end
    function self:SetText(value) self.text=value end
    function self:SetTextColor() end
    function self:SetJustifyH() end
    function self:SetWordWrap() end
    function self:SetScript(name, callback) self[name]=callback end
    function self:SetEnabled(value) self.enabled=value end
    function self:LockHighlight() end
    function self:UnlockHighlight() end
    function self:Show() self.shown=true end
    function self:Hide() self.shown=false end
    widgets[#widgets+1]=self
    return self
end
CreateFrame = function(kind, _, parent) return widget(kind, parent) end
local ingredientSet = {
    {itemID=765, quantity=2},
    {itemID=2447, quantity=1},
    {itemID=3371, quantity=1},
}
local recipe = {spellID=2329, professionKey="ALCHEMY", outputItemID=118,
    kind="item", ingredients=ingredientSet}
local ns = {
    L = function(key)
        return ({RECIPE_INGREDIENT_COUNT="Ingredients (%d)", SELECT_RECIPE="Select recipe",
            RECIPE_ID="Recipe", ITEM_ID="Item", RECIPE_QUANTITY="x%d",
            RECIPE_PAGE_STATUS="Page %d / %d", PREVIOUS_PAGE="Previous",
            NEXT_PAGE="Next"})[key] or key
    end,
    GetCatalogRecipe = function(key)
        if key=="ALCHEMY:2329" then return recipe end
    end,
    GetRecipeSpellPresentation = function() return "Minor Potion", 123 end,
    GetItemDisplay = function(id) return "Item "..id, id+1000 end,
    ProfessionLabel = function() return "Alchemy" end,
    PaginateRecipeUses = function(ingredients,page,pageSize)
        local pages=math.ceil(#ingredients/pageSize)
        page=math.min(math.max(1,page),math.max(1,pages))
        local visible={}
        for i=(page-1)*pageSize+1,math.min(page*pageSize,#ingredients) do
            visible[#visible+1]=ingredients[i]
        end
        return visible,page,pages,#ingredients
    end,
    ShowOutputTooltip=function() return true end,
    HideRecipeTooltip=function() end,
}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Features/Settings/RecipesView.lua"))("CraftAtlas",ns)
local parent=widget("Frame")
ns.InitRecipeDetail(parent)
ns.ShowRecipeDetailView(true)
ns.SetRecipeDetail("ALCHEMY:2329")
local section
for _, candidate in ipairs(widgets) do
    if candidate.kind=="Button" and candidate.expanded ~= nil and candidate.label then
        section=candidate
        break
    end
end
assert(section and section.label.text=="Ingredients (3)",
    "ingredient heading is a data-backed native divider with the real count")
local visibleRows = {}
for _, candidate in ipairs(widgets) do
    if candidate.kind=="Button" and candidate.ingredient then
        visibleRows[#visibleRows+1] = candidate
    end
end
assert(#visibleRows==3, "all three source-backed ingredients are visible")
assert(visibleRows[1].ingredient.itemID==765 and
    visibleRows[1].professions.text=="x2",
    "ingredient identity and quantity are preserved")
ns.OpenMaterialFromRecipe=function(itemID) ns.navigated=itemID end
visibleRows[1].OnClick(visibleRows[1])
assert(ns.navigated==765, "clicking ingredient navigates to its material")
local itemList=visibleRows[1].parent
section.OnClick(section)
assert(section.expanded==false and not itemList.shown,
    "collapsing ingredients also hides their list")
section.OnClick(section)
assert(section.expanded==true and itemList.shown,
    "expanding restores ingredient list and selections")
ns.SetRecipeDetail(nil)
assert(section.label.text=="Ingredients (0)", "no selection shows zero ingredients")
ns.SetRecipeDetail("ALCHEMY:2329")
assert(section.label.text=="Ingredients (3)", "reselection restores the factual ingredient count")
print("Fabricables detail native section smoke PASS")
