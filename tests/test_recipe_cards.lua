-- Native UI frame mock: texlua tests/test_recipe_cards.lua
local buttons, hiddenTooltips = {}, 0

local function widget(kind, parent)
    local self = {kind=kind,parent=parent,width=380,height=200,shown=true}
    function self:SetSize(w,h) self.width=w self.height=h end
    function self:SetWidth(w) self.width=w end
    function self:SetHeight(h) self.height=h end
    function self:GetWidth() return self.width end
    function self:GetHeight() return self.height end
    function self:SetPoint() end
    function self:ClearAllPoints() end
    function self:CreateTexture() return widget("texture",self) end
    function self:CreateFontString() return widget("font",self) end
    function self:SetColorTexture() end
    function self:SetTexture(texture) self.texture=texture end
    function self:SetHighlightTexture() end
    function self:SetJustifyH() end
    function self:SetWordWrap() end
    function self:SetText(text) self.text=text end
    function self:SetTextColor() end
    function self:SetEnabled(enabled) self.enabled=enabled end
    function self:SetScript(name,fn) self[name]=fn end
    function self:Show() self.shown=true end
    function self:Hide() self.shown=false end
    if kind=="Button" then buttons[#buttons+1]=self end
    return self
end
CreateFrame = function(kind, name, parent) return widget(kind,parent) end
local ns
ns = {
    L = function(key) 
        local vals = {CRAFTABLE_USES_HEADING="Used to craft", CRAFTABLE_USE_COUNT="%d uses",
            RECIPE_QUANTITY="x%d", RECIPE_PAGE_STATUS="Page %d / %d",
            PREVIOUS_PAGE="Previous", NEXT_PAGE="Next",
            NO_VERIFIED_RECIPES="No recipes", ITEM_ID="Item"}
        return vals[key] or key
    end,
    professionOrder = {"ALCHEMY"},
    recipeUses = {},
    ProfessionLabel = function() return "Alchemy" end,
    HideRecipeTooltip = function() hiddenTooltips=hiddenTooltips+1 end,
    ShowOutputTooltip = function(_,id) ns.lastHover=id return true end,
    ShowRecipeTooltip = function(_,use) ns.lastRecipe=use.spellID return true end,
    GetRecipePresentation = function(use)
        return {outputIcon = 100+use.spellID, outputName = "Output "..use.spellID,
                spellIcon = 500, spellName = "Recipe "..use.spellID}
    end,
}
for i=1,14 do
    ns.recipeUses[159] = ns.recipeUses[159] or {}
    ns.recipeUses[159][i] = {1000+i,1,i,2000+i,1}
end
ns.recipeUses[765] = {{800,1,2,0,2}}
assert(loadfile("addon/CraftAtlas/Domain/RecipeUsage.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",ns)
assert(loadfile("addon/CraftAtlas/Features/Settings/RecipePanel.lua"))("CraftAtlas",ns)
ns.InitRecipePanel(widget("Frame"),378)
assert(#buttons==8,"one collapsible section, five recyclable rows and two pager controls")
local section=buttons[1]
local rows={buttons[2],buttons[3],buttons[4],buttons[5],buttons[6]}
local previous,nextButton=buttons[7],buttons[8]
ns.RefreshRecipePanel(159)
section.OnClick(section)
assert(not rows[1].parent.shown, "collapsing use section hides the row container")
section.OnClick(section)
assert(rows[1].parent.shown, "expanding use section restores the row container")
for i=1,4 do
    assert(rows[i].shown,"first page shows bounded vertical rows")
    assert(rows[i].icon.texture==1100+i,"one output icon per row")
end
assert(not rows[5].shown,"overflow row must remain hidden")
assert(previous.enabled==false and nextButton.enabled==true)
rows[1].OnEnter(rows[1])
assert(ns.lastHover==2001,"native output tooltip should win")
rows[1].OnLeave(rows[1])
assert(hiddenTooltips>0)
nextButton.OnClick()
assert(rows[1].name.text=="Output 1005")
nextButton.OnClick()
assert(rows[1].name.text=="Output 1009" and rows[2].shown)
assert(nextButton.enabled==true and previous.enabled==true)
nextButton.OnClick()
assert(rows[1].name.text=="Output 1013" and rows[2].shown and not rows[3].shown)
assert(nextButton.enabled==false and previous.enabled==true)
local prior=hiddenTooltips
ns.RefreshRecipePanel(159)
assert(rows[1].name.text=="Output 1013","same selection should preserve page")
ns.RefreshRecipePanel(765)
assert(rows[1].shown and not rows[2].shown,"new selection resets to first page")
assert(rows[1].name.text=="Recipe 800","non-item recipe uses spell title")
rows[1].OnEnter(rows[1])
assert(ns.lastRecipe==800,"non-item hover should use native recipe tooltip")
ns.HideRecipePanelTooltip()
assert(hiddenTooltips>prior)
print("Recipe vertical rows UI mock PASS")
