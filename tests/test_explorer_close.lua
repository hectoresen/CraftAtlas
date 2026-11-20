-- Native close handler mock: texlua tests/test_explorer_close.lua
local ns = {}
assert(loadfile("addon/CraftAtlas/Features/Settings/Settings.lua"))("CraftAtlas", ns)

local function button()
    return {
        SetScript = function(self, name, action) self[name] = action end,
        Show = function(self) self.visible = true end,
        SetPoint = function(self) self.anchored = true end,
    }
end
local function window(existing)
    return {
        CloseButton = existing and button() or nil,
        Hide = function(self) self.hidden = true end,
    }
end
local win = window(true)
local original = win.CloseButton
local close = ns.BindExplorerClose(win)
assert(close == original, "native close button should be reused")
assert(close.visible, "the X remains visible in the native title bar")
close.OnClick()
assert(win.hidden, "the X must hide the standalone frame")

local optionsSkin = window(false)
optionsSkin.ClosePanelButton = button()
assert(ns.BindExplorerClose(optionsSkin) == optionsSkin.ClosePanelButton)
optionsSkin.ClosePanelButton.OnClick()
assert(optionsSkin.hidden, "the native Settings skin close button hides only CraftAtlas")

local fallback = window(false)
CreateFrame = function(kind, name, parent, template)
    assert(kind == "Button" and parent == fallback and template == "UIPanelCloseButton")
    return button()
end
local created = ns.BindExplorerClose(fallback)
assert(created == fallback.CloseButton and created.anchored)
created.OnClick()
assert(fallback.hidden, "fallback X must hide the frame")
assert(ns.BindExplorerClose(fallback) == created, "reopening must not duplicate close buttons")
print("Explorer native close tests PASS")
