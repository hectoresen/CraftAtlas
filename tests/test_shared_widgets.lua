-- Minimal native UI fixture: texlua tests/test_shared_widgets.lua
local created = {}
local function ui()
    local o = {}
    for _, method in ipairs({"SetPoint","SetSize","SetHeight","SetWidth","SetText",
        "SetColorTexture","SetAllPoints","ClearAllPoints","SetTexture","SetHighlightTexture",
        "SetJustifyH","SetWordWrap","SetEnabled","SetFrameLevel","SetTextColor","LockHighlight","UnlockHighlight","Show","Hide"}) do
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
CreateFrame=function(_,_,parent,template) local o=ui() o.parent=parent o.template=template created[#created+1]=o return o end
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
local classic = ns.CreateExplorerClassicButton(ui())
assert(classic.template=="UIPanelButtonTemplate", "classic UI must keep Blizzard red button template")
ns.SetExplorerTabSelected(classic, true)
assert(classic.LockHighlightCalled, "active classic button retains native highlight")
ns.SetExplorerTabSelected(classic, false)
assert(classic.UnlockHighlightCalled, "inactive classic button resets native highlight")
local dropdown = ns.CreateExplorerClassicButton(ui())
ns.AddExplorerDropdownArrow(dropdown)
assert(dropdown.dropdownArrow and dropdown.dropdownArrow.SetTextureCalled,
    "native dropdown arrow is visible on the classic control")
-- Native Blizzard dropdown path, including localized label refresh and selection.
local options = {}
UIDropDownMenu_Initialize = function(frame, build) frame.buildMenu = build end
UIDropDownMenu_CreateInfo = function() return {} end
UIDropDownMenu_AddButton = function(info) options[#options+1] = info end
UIDropDownMenu_SetWidth = function(frame, width) frame.dropdownWidth=width end
UIDropDownMenu_SetText = function(frame, value) frame.displayText=value end
CloseDropDownMenus = function() end
local selectedKey
local native, menu, choices = ns.CreateExplorerNativeDropdown(ui(), {"", "ALCHEMY"},
    function(key) selectedKey=key end, 215)
assert(native and native.dropdownWidth==215 and choices["ALCHEMY"])
choices[""]:SetText("All professions")
choices["ALCHEMY"]:SetText("Alchemy")
native:SetText("All professions")
native.buildMenu(native, 1)
assert(#options==2 and options[1].text=="All professions" and options[2].text=="Alchemy")
options[2].func()
assert(selectedKey=="ALCHEMY" and native.displayText=="All professions")
menu:Hide()
UIDropDownMenu_Initialize=nil
UIDropDownMenu_CreateInfo=nil
UIDropDownMenu_AddButton=nil
UIDropDownMenu_SetWidth=nil
UIDropDownMenu_SetText=nil
CloseDropDownMenus=nil
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
local query = {value=""}
function query:GetText() return self.value end
function query:SetText(value)
    self.value = value
    if self.textChanged then self.textChanged(self) end
end
function query:HookScript(name, callback)
    assert(name == "OnTextChanged")
    self.textChanged = callback
end
function query:SetTextInsets(left,right)
    self.insets = {left,right}
end
function query:SetFocus() self.focused=true end
local inside = ns.CreateExplorerSearchClear(query)
assert(inside.HideCalled and query.insets[2] == 25,
    "empty search has no clear X and reserves space for the input text")
query:SetText("cloth")
assert(inside.ShowCalled, "X becomes visible when the user types")
inside.OnClick()
assert(query.value == "" and query.focused and inside.HideCalled,
    "X clears and refocuses the active input, then hides")
assert(inside.icon.SetTextureCalled,
    "clear icon uses Blizzard's own panel-close artwork")
print("Shared native UI widget smoke tests PASS")
