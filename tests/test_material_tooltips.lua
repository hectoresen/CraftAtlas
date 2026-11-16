local locale = "enUS"
GetLocale = function() return locale end
NORMAL_FONT_COLOR = { r = 0.96, g = 0.81, b = 0.1 }
Enum = { TooltipDataType = { Item = 0 } }

local function boot()
    local ns = {}
    local callback
    local registrations = 0
    TooltipDataProcessor = { AddTooltipPostCall = function(tooltipType, handler)
        assert(tooltipType == Enum.TooltipDataType.Item)
        registrations = registrations + 1
        callback = handler
    end }
    for _, module in ipairs({
        "Core/Init.lua", "Data/Professions.lua", "Data/Materials.lua", "Domain/MaterialLookup.lua",
        "Localization/Locales.lua", "Infrastructure/Preferences.lua", "Localization/ProfessionLabels.lua",
        "Infrastructure/TooltipAdapter.lua", "Features/Tooltip/Tooltip.lua",
    }) do
        assert(loadfile("addon/CraftAtlas/" .. module))("CraftAtlas", ns)
    end
    ns.InitPreferences()
    assert(ns.InitTooltip())
    assert(ns.InitTooltip())
    assert(registrations == 1)
    return ns, callback
end

local function newTooltip(supportsClear)
    local tooltip = { lines = {}, scripts = {} }
    function tooltip:AddLine(text, r, g, b)
        self.lines[#self.lines + 1] = { text, r, g, b }
    end
    function tooltip:NumLines() return #self.lines end
    function tooltip:HasScript(script) return supportsClear and script == "OnTooltipCleared" end
    function tooltip:HookScript(script, handler)
        assert(self.scripts[script] == nil, "duplicated tooltip script hook")
        self.scripts[script] = handler
    end
    function tooltip:GetPrimaryTooltipData() return self.primary end
    function tooltip:rebuild()
        self.lines = {}
        if self.scripts.OnTooltipCleared then self.scripts.OnTooltipCleared(self) end
        self:AddLine("Native item name")
    end
    tooltip:rebuild()
    return tooltip
end

local function assertLine(tooltip, index, text, r, g, b)
    local line = tooltip.lines[index]
    assert(line and line[1] == text, "unexpected tooltip line " .. index .. ": " .. tostring(line and line[1]))
    assert(line[2] == r and line[3] == g and line[4] == b, "unexpected tooltip color at " .. index)
end

local function assertProfession(tooltip, index, text, icon)
    local prefix = icon and ("|T%d:14:14:0:0|t "):format(icon) or ""
    assertLine(tooltip, index, prefix .. text, 1, 1, 1)
end

local ns, onItem = boot()
local tooltip = newTooltip(true)
local copper, linen, silverleaf = { id = 2770 }, { id = 2589 }, { id = 765 }
tooltip.primary = copper
onItem(tooltip, linen)
assert(#tooltip.lines == 1)
onItem(tooltip, copper)
assert(#tooltip.lines == 4)
assertLine(tooltip, 1, "Native item name")
assertLine(tooltip, 2, " ")
assertLine(tooltip, 3, "Used in:", 0.96, 0.81, 0.1)
assertProfession(tooltip, 4, "Mining", 136248)
tooltip:AddLine("Additional native content")
onItem(tooltip, copper)
assert(#tooltip.lines == 5)
tooltip:rebuild()
onItem(tooltip, copper)
assert(#tooltip.lines == 4)

tooltip:rebuild()
tooltip.primary = linen
onItem(tooltip, linen)
assert(#tooltip.lines == 7)
assertProfession(tooltip, 4, "Blacksmithing", 136241)
assertProfession(tooltip, 5, "Engineering", 136243)
assertProfession(tooltip, 6, "First Aid", 135966)
assertProfession(tooltip, 7, "Tailoring", 136249)

ns.SetLanguage("esES")
onItem(tooltip, linen)
assert(#tooltip.lines == 7)
tooltip:rebuild()
onItem(tooltip, linen)
assertLine(tooltip, 3, "Utilizado en:", 0.96, 0.81, 0.1)
assertProfession(tooltip, 4, "Costura", 136249)
assertProfession(tooltip, 5, "Herrería", 136241)
assertProfession(tooltip, 6, "Ingeniería", 136243)
assertProfession(tooltip, 7, "Primeros auxilios", 135966)
assert(ns.ProfessionLabel("TAILORING") == "Sastrería")
assert(ns.L("USED_BY") == "Utilizado en profesiones")

ns.SetLanguage("auto")
locale = "frFR"
tooltip:rebuild()
tooltip.primary = silverleaf
onItem(tooltip, silverleaf)
assert(#tooltip.lines == 4)
assertLine(tooltip, 3, "Used in:", 0.96, 0.81, 0.1)
assertProfession(tooltip, 4, "Alchemy", 136240)

tooltip:rebuild()
tooltip.primary = nil
for _, data in ipairs({ { id = 25 }, { id = "2770" }, { id = 0 }, {}, true }) do
    onItem(tooltip, data)
end
onItem(tooltip, nil)
onItem(true, copper)
onItem({}, copper)
tooltip.IsForbidden = function() return true end
onItem(tooltip, copper)
assert(#tooltip.lines == 1)

NORMAL_FONT_COLOR = nil
C_Texture = { GetFilenameFromFileDataID = function(id)
    if id ~= 136248 then return "Interface/Icons/profession" end
end }
local _, onFallbackItem = boot()
local fallback = newTooltip(false)
onFallbackItem(fallback, linen)
fallback:AddLine("Additional native content")
onFallbackItem(fallback, linen)
assert(#fallback.lines == 8)
fallback:rebuild()
onFallbackItem(fallback, copper)
assert(#fallback.lines == 4)
assertLine(fallback, 3, "Used in:", 1, 0.82, 0)
assertProfession(fallback, 4, "Mining")
fallback.scripts.OnHide(fallback)
fallback:rebuild()
onFallbackItem(fallback, copper)
assert(#fallback.lines == 4)

print("Material tooltip presentation and lifecycle PASS")
