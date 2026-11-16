-- Minimal native UI fixture: texlua tests/test_shared_widgets.lua
local created = {}
local function ui()
    local o = {}
    for _, method in ipairs({"SetPoint","SetSize","SetHeight","SetWidth","SetText",
        "SetColorTexture","SetAllPoints","SetTexture","SetHighlightTexture",
        "SetJustifyH","SetWordWrap","SetEnabled","SetFrameLevel","Show","Hide"}) do
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
    L = function(key) local map={PREVIOUS_PAGE="Previous",NEXT_PAGE="Next",RECIPE_PAGE_STATUS="Page %d / %d"} return map[key] end,
    professionOrder={"ALCHEMY"}
}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",ns)
local n=0
local row=ns.CreateExplorerRow(ui(),39,function() n=n+1 end)
row.OnClick(row)
assert(n==1 and row.icon and row.name and row.professions)
local pager=ns.CreateExplorerPager(ui(),function() n=n+1 end,function() n=n+2 end)
pager.previous.OnClick()
pager.next.OnClick()
assert(n==4)
ns.UpdateExplorerPager(pager,1,3)
assert(pager.previous.SetEnabledCalled and pager.next.SetEnabledCalled)
local broom = ns.GetExplorerClearIcon(function(path)
    assert(path:find("Witch", 1, true), "first probe uses established historical broom art")
    return 12345
end)
assert(broom:find("Witch", 1, true), "native broom chosen if available")
local safe = ns.GetExplorerClearIcon(function() return nil end)
assert(safe:find("DispelMagic", 1, true), "safe native fallback for missing icon")
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
