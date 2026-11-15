-- Offline UI adapter mock: texlua tests/test_recipe_info.lua
local ns = {
    L = function(k) return k end,
    ProfessionLabel = function(k) return k end,
    GetItemDisplay = function(id) if id == 15138 then return "Onyxia Scale Cloak", 555 end end,
}
local calls = {}
GameTooltip = {
    SetOwner = function(self, owner, anchor) calls.owner=owner end,
    SetHyperlink = function(self, link) calls.link=link end,
    SetSpellByID = function(self, id) calls.spell=id end,
    Show = function(self) calls.shown=true end,
    Hide = function(self) calls.hidden=true end,
    SetText = function(self, v) calls.text=v end,
    AddLine = function(self, v) end,
}
C_Spell = {GetSpellInfo = function(id) return {name="Onyxia Cloak",iconID=987} end}
assert(loadfile("addon/CraftAtlas/Infrastructure/RecipeInfo.lua"))("CraftAtlas", ns)
local use = {spellID=19093,professionKey="LEATHERWORKING",outputItemID=15138}
local info = ns.GetRecipePresentation(use)
assert(info.spellName=="Onyxia Cloak" and info.outputName=="Onyxia Scale Cloak")
assert(ns.ShowRecipeTooltip({},use) and calls.spell==19093)
assert(ns.ShowOutputTooltip({},15138) and calls.link=="item:15138")
ns.HideRecipeTooltip()
assert(calls.hidden)
assert(not ns.ShowOutputTooltip({},nil))
print("RecipeInfo native tooltip mock PASS")
