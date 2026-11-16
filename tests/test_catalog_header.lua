-- Native header progress mock: must be bounded and never mutate existing controls.
local children={}
local function ui(kind,parent)
    local self={kind=kind,parent=parent,shown=true}
    function self:SetSize(w,h) self.width,self.height=w,h end
    function self:SetHeight(h) self.height=h end
    function self:SetAllPoints() end
    function self:SetColorTexture(...) self.fill={...} end
    function self:SetTextColor(...) self.textColor={...} end
    function self:CreateTexture() return ui("Texture",self) end
    function self:SetPoint(...) self.anchor={...} end
    function self:SetStatusBarTexture(texture) self.texture=texture end
    function self:SetStatusBarColor(r,g,b) self.color={r,g,b} end
    function self:SetMinMaxValues(min,max) self.minimum,self.maximum=min,max end
    function self:SetValue(value) self.value=value end
    function self:SetText(value) self.text=value end
    function self:SetJustifyH() end
    function self:Show() self.shown=true end
    function self:Hide() self.shown=false end
    function self:CreateFontString() return ui("FontString",self) end
    children[#children+1]=self
    return self
end
CreateFrame=function(kind,_,parent) return ui(kind,parent) end
local ns={}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas",ns)
local header=ui("Header")
local widget=ns.CreateExplorerCatalogProgress(header)
assert(#children==5,"one holder, track, status bar and label without extra frames")
assert(not widget.shown and widget.width==224 and widget.height==14)
assert(widget.anchor[1]=="BOTTOM" and widget.anchor[2]==header
    and widget.anchor[5]==5, "track clears the gold header divider")
assert(widget.track.fill[4]==0.94 and widget.label.textColor[1] > 0.9,
    "high-contrast inline text should remain readable as the bar fills")
widget:SetProgress("active",42,"Preparing materials... 42%")
assert(widget.shown and widget.bar.value==42)
assert(widget.label.text=="Preparing materials... 42%")
widget:SetProgress("incomplete",24,"Preparation paused")
assert(widget.shown and widget.bar.value==24)
widget:SetProgress("active",999,"Preparing craftables")
assert(widget.bar.value==100,"progress must be clamped")
widget:SetProgress("complete",100,"Finished")
assert(not widget.shown and #children==5,"completed state hides and never reallocates")
print("Native progress header mock PASS")
