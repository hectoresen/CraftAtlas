-- Run from repository root: texlua tests/test_addon.lua
local ns={state={}}
local function module(path) assert(loadfile("addon/CraftAtlas/" .. path))("CraftAtlas",ns) end
local function equal(a,b,label)
    if a~=b then error((label or "mismatch")..": "..tostring(a).." ~= "..tostring(b)) end
end
module("Core/Init.lua")
module("Data/Professions.lua")
module("Domain/MaterialLookup.lua")
module("Data/Materials.lua")
module("Localization/Locales.lua")
module("Infrastructure/Preferences.lua")
module("Localization/ProfessionLabels.lua")
module("Infrastructure/TooltipAdapter.lua")
module("Features/Tooltip/Tooltip.lua")

local fixture={[2589]={"TAILORING","FIRST_AID","TAILORING"}}
local keys=ns.FindProfessions(2589,fixture,ns.professionOrder)
equal(#keys,2,"distinct professions")
equal(keys[1],"FIRST_AID","stable order")
equal(keys[2],"TAILORING","stable order")
equal(#ns.FindProfessions(999999,fixture,ns.professionOrder),0,"unknown")
equal(#ns.FindProfessions("2589",fixture,ns.professionOrder),0,"numeric identity")
equal(ns.ResolveLocale("auto","frFR"),"enUS","fallback")
CraftAtlasDB={language="invalid"}
ns.InitPreferences()
equal(ns.GetLanguage(),"auto","preference recovery")
GetLocale=function() return "enUS" end
ns.SetLanguage("esES")
equal(ns.ProfessionLabel("FIRST_AID"),"Primeros auxilios","Spanish")
equal(ns.ResolveTooltipItemID({id=2589}),2589,"item ID")
equal(ns.ResolveTooltipItemID({id="2589"}),nil,"bad ID")
local callback
TooltipDataProcessor={AddTooltipPostCall=function(kind,fn)
    equal(kind,0,"zero-valued enum")
    callback=fn
end}
Enum={TooltipDataType={Item=0}}
ns.materials=fixture
assert(ns.InitTooltip())
local tooltip={lines={}}
function tooltip:AddLine(s) self.lines[#self.lines+1]=s end
function tooltip:NumLines() return #self.lines end
function tooltip:Show() end
function tooltip:HookScript(_,fn) self.hide=fn end
callback(tooltip,{id=2589,dataInstanceID=1})
equal(#tooltip.lines,2,"two lines")
equal(tooltip.lines[2],"Primeros auxilios, Sastrería","Spanish names")
callback(tooltip,{id=2589,dataInstanceID=1})
equal(#tooltip.lines,2,"no duplication")
tooltip.lines={}
callback(tooltip,{id=2589,dataInstanceID=1})
equal(#tooltip.lines,2,"refresh")
tooltip.lines={}
ns.SetLanguage("enUS")
callback(tooltip,{id=2589,dataInstanceID=1})
equal(tooltip.lines[2],"First Aid, Tailoring","locale switch")
tooltip.lines={}
callback(tooltip,{id=555555,dataInstanceID=2})
equal(#tooltip.lines,0,"unknown no annotation")
print("OK: offline Lua regression tests")
