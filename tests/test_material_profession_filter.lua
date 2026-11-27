-- Exercise the explorer's real search, dropdown, result rows and Back handlers.
local frames = {}
local widget = {}
widget.__index = widget
for _, method in ipairs({"ClearFocus", "EnableMouse", "EnableMouseWheel", "RegisterEvent",
    "RegisterForDrag", "SetAllPoints", "SetAlpha", "SetAutoFocus", "SetColorTexture", "SetEnabled",
    "SetFrameLevel", "SetHeight", "SetJustifyH", "SetMaxLetters", "SetMovable", "SetScale",
    "SetStatusBarColor", "SetStatusBarTexture", "SetTextColor", "SetValueStep", "SetWordWrap",
    "LockHighlight", "UnlockHighlight"}) do
    widget[method] = function() end
end

local function newWidget(kind, name, parent)
    local frame = setmetatable({kind = kind, frameName = name, parent = parent,
        shown = true, scripts = {}, hooks = {}, points = {}, text = ""}, widget)
    frames[#frames + 1] = frame
    return frame
end

function widget:SetScript(event, handler) self.scripts[event] = handler end
function widget:HookScript(event, handler) self.hooks[event] = handler end
function widget:Emit(event, ...)
    if self.scripts[event] then self.scripts[event](self, ...) end
    if self.hooks[event] then self.hooks[event](self, ...) end
end
function widget:Show() self.shown = true end
function widget:Hide() self.shown = false end
function widget:IsShown() return self.shown end
function widget:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
function widget:Click()
    assert(self:IsVisible(), "test must click a visible control")
    self:Emit("OnClick", "LeftButton")
end
function widget:SetPoint(...) self.points[#self.points + 1] = {...} end
function widget:ClearAllPoints() self.points = {} end
function widget:GetParent() return self.parent end
function widget:SetSize(width, height) self.width, self.height = width, height end
function widget:SetWidth(width) self.width = width end
function widget:GetWidth() return self.width or 460 end
function widget:GetHeight() return self.height or 600 end
function widget:GetFrameLevel() return 1 end
function widget:SetFrameStrata(strata) self.strata = strata end
function widget:GetFrameStrata() return self.strata end
function widget:CreateTexture() return newWidget("Texture", nil, self) end
function widget:CreateFontString() return newWidget("FontString", nil, self) end
function widget:SetTexture(texture) self.texture = texture end
function widget:SetHighlightTexture(texture) self.hoverTexture = texture end
function widget:SetText(text)
    self.text = text
    if self.kind == "EditBox" then self:Emit("OnTextChanged") end
end
function widget:GetText() return self.text end
function widget:SetMinMaxValues(_, max) self.maximum = max end
function widget:SetValue(value)
    if self.value == value then return end
    self.value = value
    self:Emit("OnValueChanged", value)
end

CreateFrame = newWidget
UIParent = newWidget("Frame")
UIParent:SetSize(800, 600)
SlashCmdList = {}
local names, link, shiftDown = {}, nil, false
GetItemInfo = function(id) return names[id], "|Hitem:" .. id .. "|h[Test item]|h" end
IsShiftKeyDown = function() return shiftDown end
ChatEdit_InsertLink = function(value) link = value end

local ns = {state = {}, materials = {}, recipeUses = {}, professionOrder = {"ALCHEMY", "COOKING"},
    recipes = {{700, 1, 400, 1, {{113, 1}}}}}
local alchemyItems = {}
for itemID = 101, 113 do
    alchemyItems[#alchemyItems + 1] = itemID
    ns.materials[itemID] = {"ALCHEMY"}
    ns.recipeUses[itemID] = {{700, 1, 1, 400, 1}}
    names[itemID] = string.format("Reagent %02d", itemID - 100)
end
ns.materials[101] = {"ALCHEMY", "COOKING"}
ns.recipeUses[101][2] = {701, 2, 1, 401, 1}
names[101] = "Reagent 01 Shared"
ns.materials[149], ns.recipeUses[149] = {"ALCHEMY"}, {{700, 1, 1, 400, 1}}
ns.materials[201], ns.recipeUses[201], names[201] = {"COOKING"}, {{701, 2, 1, 401, 1}}, "Kitchen salt"

function ns.GetKnownMaterialNames() return names end
function ns.GetMaterialDisplay(itemID) return names[itemID], "Test item icon" end
function ns.GetItemDisplay() return "Test output", "Test output icon" end
function ns.GetMaterialLoadProgress() return 1, 0 end
function ns.GetRecipeNames() return {[700] = "Test recipe"} end
function ns.GetRecipeSpellPresentation() return "Test recipe" end
function ns.GetRecipePresentation() return {outputName = "Test output"} end
local recipeDetail
function ns.SetRecipeDetail(key) recipeDetail = key end
for _, entry in ipairs({"GetItemMetadata", "GetInstalledReleaseVersion", "InitRecipeDetail",
    "PreloadMaterialInfo", "PreloadRecipeNames", "ShowRecipeDetailView"}) do
    ns[entry] = function() end
end

for _, path in ipairs({"Domain/MaterialLookup.lua", "Domain/MaterialSearch.lua",
    "Domain/ProfessionTree.lua", "Domain/CatalogProgress.lua", "Domain/RecipeUsage.lua",
    "Domain/RecipeCatalog.lua", "Localization/Locales.lua", "Infrastructure/Preferences.lua",
    "Localization/ProfessionLabels.lua", "Infrastructure/ChatLinks.lua",
    "Features/Settings/Shared/ExplorerWidgets.lua", "Features/Settings/RecipePanel.lua",
    "Features/Settings/Settings.lua"}) do
    assert(loadfile("addon/CraftAtlas/" .. path))("CraftAtlas", ns)
end

local function find(predicate)
    for _, frame in ipairs(frames) do
        if predicate(frame) then return frame end
    end
end

local function textVisible(text)
    return find(function(frame) return frame.text == text and frame:IsVisible() end) ~= nil
end

ns.InitSettings()
SlashCmdList.CRAFTATLAS("")
local search = assert(find(function(frame) return frame.kind == "EditBox" end))
local popup = assert(find(function(frame) return frame.frameName == "CraftAtlasProfessionPopup" end))
local selector = assert(find(function(frame) return frame.dropdownArrow end))
local scrollbar = assert(find(function(frame) return frame.kind == "Slider" end))
local pool = {}
for _, frame in ipairs(frames) do
    if frame.groupHeader then pool[#pool + 1] = frame end
end

local function choose(label)
    selector:Click()
    assert(find(function(frame) return frame.parent == popup and frame.text == label end), label):Click()
    assert(selector.text == label)
end

local function assertCount(amount)
    assert(textVisible(string.format(ns.L("RESULT_COUNT"), amount)), "unexpected unique result count")
end

local function assertFlat(itemIDs)
    assertCount(#itemIDs)
    assert(scrollbar.maximum == math.max(0, #itemIDs - #pool), "scroll bounds must use the flat list")
    for index, row in ipairs(pool) do
        local expected = itemIDs[index + scrollbar.value]
        if expected then
            assert(row:IsVisible() and row.itemID == expected)
            assert(not row.groupKey and not row.groupHeader:IsShown()
                and not row.groupName:IsShown() and not row.groupArrow:IsShown())
            assert(row.name:IsShown() and not row.professions:IsShown() and row.icon.points[1][4] == 2)
        else
            assert(not row:IsVisible() and not row.itemID and not row.groupKey)
        end
    end
end

assert(pool[1].groupKey == "ALCHEMY" and pool[2].icon.points[1][4] == 15)
pool[1]:Click()
assert(pool[2].groupKey == "COOKING", "collapsing Alchemy should hide all its item rows")
choose("Alchemy")
assertFlat(alchemyItems)
assert(pool[1].name.text == names[101] and pool[1].icon.texture == "Test item icon")

search:SetText("Reagent")
local sidebar = scrollbar.parent.parent
sidebar:Emit("OnMouseWheel", -100)
local offset = 13 - #pool
assert(offset > 0 and scrollbar.value == offset)
assertFlat(alchemyItems)
local last = pool[#pool]
assert(last.itemID == 113 and last.hoverTexture)
local detailID = string.format(ns.L("EXPLORER_DETAIL_ID"), last.itemID)
last:Click()
assert(last.highlight:IsShown() and textVisible(detailID), "select the item shown on the recycled row")
shiftDown = true
pool[1]:Click()
shiftDown = false
assert(link:find("|Hitem:" .. pool[1].itemID .. "|h", 1, true) and last.highlight:IsShown())
assert(find(function(frame) return frame.use and frame:IsVisible() end)):Click()
assert(recipeDetail == "ALCHEMY:700")
assert(find(function(frame) return frame.kind == "Button" and frame.text == ns.L("BACK") end)):Click()
assert(search.text == "Reagent" and selector.text == "Alchemy" and scrollbar.value == offset)
assertFlat(alchemyItems)
assert(last.highlight:IsShown() and textVisible(detailID), "restore the selected material after Back")

search:SetText("Reagent 02")
assertFlat({102})
choose("Cooking")
assert(search.text == "Reagent 02")
assertFlat({})
assert(textVisible(ns.L("NO_RESULTS")) and textVisible(ns.L("SELECT_MATERIAL")))
search:SetText("")
assertFlat({201, 101})

choose("Alchemy")
search:SetText("149")
assertFlat({149})
assert(pool[1].name.text == ns.L("ITEM_ID") .. " 149")
search:SetText("Stabilizer")
assertFlat({})
assert(textVisible(ns.L("LOADING_ITEM_NAMES")) and textVisible(ns.L("NAME_RESULTS_INCOMPLETE")))
names[149] = "Stabilizer"
ns.OnCatalogDataChanged("materials")
assertFlat({149})
assert(not textVisible(ns.L("NAME_RESULTS_INCOMPLETE")))

search:SetText("Reagent 02")
choose("All professions")
assert(search.text == "Reagent 02" and pool[1].groupKey == "ALCHEMY" and pool[2].itemID == 102,
    "a one-profession search result must remain grouped when the dropdown is unfiltered")
search:SetText("Shared")
assertCount(1)
assert(pool[1].groupKey == "ALCHEMY" and pool[2].itemID == 101
    and pool[3].groupKey == "COOKING" and pool[4].itemID == 101)
pool[1]:Click()
choose("Alchemy")
assertFlat({101})
choose("All professions")
assert(search.text == "Shared" and pool[1].groupKey == "ALCHEMY" and pool[2].groupKey == "COOKING",
    "the search-time collapse survives a round trip through the flat list")
assert(find(function(frame) return frame.kind == "Button" and frame.parent == search end)):Click()
assert(search.text == "" and pool[1].groupKey == "ALCHEMY" and pool[2].groupKey == "COOKING",
    "clearing search restores the user's original collapse state")

ns.SetLanguage("esES")
choose("Alquimia")
alchemyItems[#alchemyItems + 1] = 149
assertFlat(alchemyItems)
choose("Todas las profesiones")
assert(pool[1].groupKey == "ALCHEMY" and pool[2].groupKey == "COOKING")

print("Material profession filter explorer regression PASS")
