-- Offline Lua regression tests. Run from repository root: texlua tests/test_addon.lua
local ns = { state = {} }
local function module(path)
    assert(loadfile("addon/CraftAtlas/" .. path))("CraftAtlas", ns)
end
local function equals(a, b, label)
    if a ~= b then error((label or "mismatch") .. ": " .. tostring(a) .. " ~= " .. tostring(b)) end
end
module("Core/Init.lua")
module("Domain/MaterialLookup.lua")
module("Localization/Locales.lua")
module("Infrastructure/Preferences.lua")
module("Infrastructure/TooltipAdapter.lua")
module("Features/Tooltip/Tooltip.lua")

local fixture = {
    [2589] = {"TAILORING", "FIRST_AID", "TAILORING"},
    [2840] = {"ENGINEERING", "BLACKSMITHING"},
}
local first = ns.FindProfessions(2589, fixture, ns.professionOrder)
equals(#first, 2, "duplicate relations")
equals(first[1], "FIRST_AID", "stable order")
equals(first[2], "TAILORING", "stable order")
equals(#ns.FindProfessions(999999, fixture, ns.professionOrder), 0, "unknown")
equals(#ns.FindProfessions("2589", fixture, ns.professionOrder), 0, "string id")
equals(#ns.FindProfessions(nil, fixture, ns.professionOrder), 0, "nil id")
equals(#ns.FindProfessions(-10, fixture, ns.professionOrder), 0, "negative id")
equals(#ns.FindProfessions(2589.1, fixture, ns.professionOrder), 0, "fractional id")
equals(ns.ResolveLocale("auto", "esES"), "esES", "auto Spanish")
equals(ns.ResolveLocale("auto", "frFR"), "enUS", "fallback")
equals(ns.ResolveLocale("enUS", "esES"), "enUS", "override")
equals(ns.Text("FIRST_AID", "esES", "enUS"), "Primeros auxilios", "label")
equals(ns.Text("FIRST_AID", "enUS", "esES"), "First Aid", "English")
equals(ns.NormalizeLanguage("malformed"), "auto", "invalid preference")

CraftAtlasDB = { language = "malformed" }
ns.InitPreferences()
equals(CraftAtlasDB.language, "auto", "recover preference")
ns.SetLanguage("esES")
equals(CraftAtlasDB.language, "esES", "persist preference")
GetLocale = function() return "enUS" end
equals(ns.L("TAILORING"), "Sastrería", "effective preference")

-- Mock the modern client callback. Actual client compatibility still needs in-game testing.
local callback
TooltipDataProcessor = {
    AddTooltipPostCall = function(itemType, listener)
        equals(itemType, 0, "item tooltip enum")
        callback = listener
    end,
}
Enum = { TooltipDataType = { Item = 0 } }
ns.materials = fixture
assert(ns.InitTooltip())
local tooltip = { lines = {} }
function tooltip:AddLine(line) self.lines[#self.lines + 1] = line end
function tooltip:NumLines() return #self.lines end
function tooltip:Show() self.shown = true end
callback(tooltip, { id = 2589, dataInstanceID = 100 })
equals(#tooltip.lines, 2, "profession line count")
equals(tooltip.lines[2], "Primeros auxilios, Sastrería", "translated order")
callback(tooltip, { id = 2589, dataInstanceID = 100 })
equals(#tooltip.lines, 2, "dedup repeated callback")
tooltip.lines = {}
callback(tooltip, { id = 2589, dataInstanceID = 100 })
equals(#tooltip.lines, 2, "tooltip refreshed")
tooltip.lines = {}
callback(tooltip, { id = 555, dataInstanceID = 102 })
equals(#tooltip.lines, 0, "no invented annotation")
print("OK: Lua domain, localization, settings and tooltip callback tests passed")
