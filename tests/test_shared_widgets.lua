-- Minimal native UI fixture: texlua tests/test_shared_widgets.lua
local created = {}
local function ui()
    local o = {}
    for _, method in ipairs({"SetPoint","SetSize","SetHeight","SetWidth","SetText",
        "SetColorTexture","SetAllPoints","ClearAllPoints","SetTexture","SetHighlightTexture",
        "SetJustifyH","SetWordWrap","SetEnabled","SetFrameLevel","SetTextColor","Show","Hide"}) do
        o[method]=function(self,...) self[method.."Called"]=true end
    end
    o.CreateTexture=function() return ui() end
    o.CreateFontString=function() return ui() end
    o.SetScript=function(self,name,fn) self[name]=fn end
    o.GetFrameLevel=function() return 1 end
    o.IsShown=function(self) return self.visible end
    o.CreateFontString=function() return ui() end
    return o
end
CreateFrame=function(_,_,parent) local o=ui() o.parent=parent created[#created+1]=o return o end
local ns = {
    L = function(key) local map={PREVIOUS_PAGE="Previous",NEXT_PAGE="Next",RECIPE_PAGE_STATUS="Page %d / %d",USED_BY="Used by professions"} return map[key] end,
    professionOrder={"ALCHEMY"}
}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",ns)
local n=0
local row=ns.CreateExplorerRow(ui(),39,function() n=n+1 end)
row.OnClick(row)
assert(n==1 and row.icon and row.name and row.professions)
ns.StyleExplorerGroupRow(row, "Alchemy", 93, true)
assert(row.groupBackground and row.groupArrow and row.groupName and row.groupState)
assert(row.groupBackground.ShowCalled and row.itemBackground.HideCalled)
assert(row.name.HideCalled and row.icon.HideCalled)
ns.StyleExplorerItemRow(row, true)
assert(row.professions.HideCalled and row.name.ShowCalled)
assert(row.groupBackground.HideCalled and row.itemBackground.ShowCalled)
assert(row.name.ShowCalled and row.groupName.HideCalled)
assert(ns.GetExplorerProfessionIcon("ALCHEMY"):find("Trade_Alchemy", 1, true))
local toggles=0
local section=ns.CreateExplorerSection(ui(), "USED_BY", -92, function() toggles=toggles+1 end)
section.OnClick(section)
assert(section.expanded==false and toggles==1)
section.OnClick(section)
assert(section.expanded==true and toggles==2)
local pager=ns.CreateExplorerPager(ui(),function() n=n+1 end,function() n=n+2 end)
pager.previous.OnClick()
pager.next.OnClick()
assert(n==4)
ns.UpdateExplorerPager(pager,1,3)
assert(pager.previous.SetEnabledCalled and pager.next.SetEnabledCalled)
local broom = ns.GetExplorerClearIcon()
assert(broom:find("Achievement_Halloween_Witch_01", 1, true),
    "broom texture must not depend on seasonal item metadata cache")
local safe = ns.GetExplorerClearIcon(function() return nil end)
assert(safe:find("DispelMagic", 1, true),
    "unknown client support uses safe native action fallback")
assert(ns.GetExplorerClearIcon(function() return 1 end) == broom)
local current, other = {query="peacebloom"}, {query="blue"}
local search = {
    GetText = function() return current.query end,
    SetText = function(_, value) current.query=value end,
    SetFocus = function(self) self.focused=true end,
}
assert(ns.ClearExplorerSearch(search) == true)
assert(current.query == "" and other.query == "blue" and search.focused,
    "broom must clear only active view and preserve inactive view state")
assert(ns.ClearExplorerSearch(search) == false, "empty search is harmlessly inert")
print("Shared native UI widget smoke tests PASS")
