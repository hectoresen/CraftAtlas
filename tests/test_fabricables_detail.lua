-- Native Fabricables detail regression, no live WoW client required.
local widgets = {}
local function widget(kind, parent)
    local self = {kind=kind, parent=parent, shown=true, width=400, height=400}
    function self:SetAllPoints() end
    function self:SetSize(w, h) self.width=w self.height=h end
    function self:SetHeight(h) self.height=h end
    function self:SetWidth(w) self.width=w end
    function self:GetHeight() return self.height end
    function self:SetPoint(point, relative, relativePoint, x, y)
        self.points = self.points or {}
        self.points[point] = {relative = relative, point = relativePoint, x = x, y = y}
    end
    function self:RegisterEvent(event)
        self.events = self.events or {}
        self.events[event] = true
    end
    function self:IsVisible()
        return self.shown and (not self.parent or self.parent:IsVisible())
    end
    function self:ClearAllPoints() end
    function self:CreateTexture() return widget("Texture", self) end
    function self:CreateFontString() return widget("FontString", self) end
    function self:SetTexture(value) self.texture=value end
    function self:SetColorTexture() end
    function self:SetHighlightTexture() end
    function self:SetText(value) self.text=value end
    function self:SetTextColor(r, g, b) self.color = {r, g, b} end
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
    kind="item", ingredients=ingredientSet, requiredSkill=15, teachingItemID=2450}
local unknownRecipe = {spellID=2330, professionKey="ALCHEMY", kind="unknown", ingredients={}}
local rank, learned, trainer = 15, false, false
local locale = "enUS"
local ns = {
    GetCraftablePlayerRequirements = function(selected, changing)
        if selected == recipe and not changing then return rank, learned, trainer end
    end,
    GetCatalogRecipe = function(key)
        if key=="ALCHEMY:2329" then return recipe end
        if key=="ALCHEMY:2330" then return unknownRecipe end
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
assert(loadfile("addon/CraftAtlas/Localization/Locales.lua"))("CraftAtlas", ns)
ns.L = function(key) return ns.Text(key, locale) end
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
local function label(text)
    for _, candidate in ipairs(widgets) do
        if candidate.kind == "FontString" and candidate.text == text then return candidate end
    end
    error("Missing detail label: " .. text)
end
local function isGray(field)
    return field.color[1] == field.color[2] and field.color[2] == field.color[3]
end
local function isRed(field)
    return field.color[1] > field.color[2] * 2
end
local skill = label("Skill 15 · Met")
local status = label("Recipe unlearned")
local source = label("Recipe item")
assert(isGray(skill) and isRed(status) and isRed(source), "requirements are independent at exact rank")

local check = label("Track crafting").points.LEFT.relative
local column = check.parent
assert(check.kind == "CheckButton" and status.parent == column and source.parent == column)
assert(column.points.TOPRIGHT.x < 0 and check.points.TOPLEFT.y < source.points.TOPLEFT.y,
    "tracking checkbox sits below both recipe lines in the right column")
assert(skill.points.TOPLEFT.x == label("Alchemy").points.TOPLEFT.x
    and skill.points.TOPLEFT.y < label("Alchemy").points.TOPLEFT.y,
    "skill is aligned beneath the profession")

local events
for _, candidate in ipairs(widgets) do
    if candidate.events and candidate.events.NEW_RECIPE_LEARNED then events = candidate end
end
assert(events and events.events.SKILL_LINES_CHANGED)
rank, learned, trainer = 14, true, true
events.OnEvent(events, "NEW_RECIPE_LEARNED")
assert(skill == label("Skill 15 · Too low") and isRed(skill))
assert(status == label("Recipe learned") and isGray(status) and source.text == "Recipe item or trainer")
rank = 16
events.OnEvent(events, "SKILL_LINES_CHANGED")
assert(skill == label("Skill 15 · Met") and isGray(skill))

events.OnEvent(events, "TRADE_SKILL_DATA_SOURCE_CHANGING")
assert(skill.text == "Skill 15 · Unverified" and not isGray(skill) and not isRed(skill))
assert(status.text == "Recipe not verified" and source.text == "Recipe item")
events.OnEvent(events, "TRADE_SKILL_DATA_SOURCE_CHANGED")
assert(skill.text == "Skill 15 · Met" and status.text == "Recipe learned")

ns.SetRecipeDetail("ALCHEMY:2330")
assert(skill.text == "Skill unknown" and status.text == "Recipe not verified" and source.text == "Source unknown")
ns.SetRecipeDetail(nil)
assert(not skill.shown and not status.shown and not source.shown, "clearing selection hides all new fields")
locale = "esES"
ns.SetRecipeDetail("ALCHEMY:2329")
assert(skill.text == "Nivel 15 · Alcanzado" and status.text == "Receta aprendida")
assert(source.text == "Objeto o instructor" and label("Seguir fabricación").shown)
print("Fabricables detail native section and requirements PASS")
