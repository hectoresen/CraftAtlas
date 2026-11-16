-- Lua 5.1 offline regression: native link provenance, Shift precedence and safe fallbacks.
local ns = {}
local function itemLink(id) return "|cff1eff00|Hitem:" .. id .. ":0:0:0|h[Test Item]|h|r" end
local function spellLink(id) return "|cff71d5ff|Hspell:" .. id .. "|h[Test Spell]|h|r" end
local inserted, opened, sent = {}, 0, 0
local shift = false
IsShiftKeyDown = function() return shift end
GetItemInfo = function(id) return "Test Item", itemLink(id) end
GetSpellLink = function(id) return spellLink(id) end
ChatEdit_GetActiveWindow = function() return nil end
ChatFrame_OpenChat = function() opened = opened + 1 end
ChatEdit_InsertLink = function(link) inserted[#inserted + 1] = link return true end
SendChatMessage = function() sent = sent + 1 end
assert(loadfile("addon/CraftAtlas/Infrastructure/ChatLinks.lua"))("CraftAtlas", ns)
local function expect(expr, message) assert(expr, message or "assertion failed") end

expect(not ns.IsEntityChatLinkClick("LeftButton"), "ordinary click")
shift = true
expect(ns.IsEntityChatLinkClick("LeftButton"), "shift left")
expect(not ns.IsEntityChatLinkClick("RightButton"), "right click is not link action")
expect(ns.InsertEntityChatLink("item", 159), "native item")
expect(inserted[1] == itemLink(159), "item provenance")
expect(ns.InsertRecipeChatLink({outputItemID = 118, spellID = 2332}), "output must be item")
expect(inserted[2] == itemLink(118), "must not link output spell")
expect(ns.InsertRecipeChatLink({spellID = 7411}), "non-item spell")
expect(inserted[3] == spellLink(7411), "spell provenance")
expect(opened == 3 and sent == 0, "must only open editor, never send")

-- The client must provide a COMPLETE native link; never make one from numeric ID.
GetItemInfo = function() return "Uncached", nil end
expect(not ns.InsertEntityChatLink("item", 123), "uncached item")
GetItemInfo = function() return "Malformed", "item:159" end
expect(not ns.InsertEntityChatLink("item", 159), "no fake hyperlinks")
GetSpellLink = nil
expect(not ns.InsertRecipeChatLink({spellID = 7411}), "unsupported spell links")
GetItemInfo = function(id) return "Test Item", itemLink(id) end
ChatEdit_InsertLink = nil
expect(not ns.InsertEntityChatLink("item", 159), "missing editor insertion")
ChatEdit_InsertLink = function() return false end
expect(not ns.InsertEntityChatLink("item", 159), "rejected insertion")
ChatEdit_InsertLink = function(link) inserted[#inserted + 1] = link end
ChatEdit_GetActiveWindow = function() return {} end
local previous = opened
expect(ns.InsertEntityChatLink("item", 159), "active editor")
expect(opened == previous, "no redundant chat opening")

-- Current row identity must be read at click time: static source contract guards.
local function source(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("*a")
    f:close()
    return text
end
local settings = source("addon/CraftAtlas/Features/Settings/Settings.lua")
local panel = source("addon/CraftAtlas/Features/Settings/RecipePanel.lua")
local view = source("addon/CraftAtlas/Features/Settings/RecipesView.lua")
expect(settings:find("ns.InsertRecipeChatLink(ns.GetCatalogRecipe(self.itemID))", 1, true), "recycled recipe row")
expect(settings:find('ns.InsertEntityChatLink("item", self.itemID)', 1, true), "recycled material row")
expect(panel:find("ns.InsertRecipeChatLink(self.use)", 1, true), "recycled material use")
expect(view:find('ns.InsertEntityChatLink("item", self.ingredient.itemID)', 1, true), "recycled ingredient")
expect(not view:find("UI-Quickslot2", 1, true) or view:find("No UI-Quickslot2 overlay", 1, true), "no slot overlay")
print("PASS: native CraftAtlas chat links and clickable source contracts")
