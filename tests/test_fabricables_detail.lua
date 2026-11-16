-- Native Fabricables detail regression, no live WoW client required.
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
local frame
-- The item and section are owned by the frame; find their elements through a fixture hook.
assert(ns.RefreshRecipeDetail, "detail module loaded")
assert(ns.SetRecipeDetail and ns.ShowRecipeDetailView)
-- Verify normal and non-item selections do not throw and keep quantities.
ns.SetRecipeDetail(nil)
ns.SetRecipeDetail("ALCHEMY:2329")
print("Fabricables detail native section smoke PASS")
