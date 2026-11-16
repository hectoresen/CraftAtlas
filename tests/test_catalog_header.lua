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
    function self:SetPoint(...) self.anchors=self.anchors or {} self.anchors[#self.anchors+1]={...} end
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
local panel=ui("Panel")
local tabs=ui("RecipesTab",panel)
local back=ui("Back",panel)
local widget=ns.CreateExplorerCatalogProgress(panel,tabs,back)
assert(#children==7,"three existing controls plus reusable holder, track, bar and label")
assert(not widget.shown and widget.height==20)
assert(widget.anchors[1][1]=="LEFT" and widget.anchors[1][2]==tabs
    and widget.anchors[1][3]=="RIGHT" and widget.anchors[1][4]==12,
    "progress begins after native Fabricables tab")
assert(widget.anchors[2][1]=="RIGHT" and widget.anchors[2][2]==back
    and widget.anchors[2][3]=="LEFT" and widget.anchors[2][4]==-12,
    "progress ends before native Back button")
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
assert(not widget.shown and #children==7,"completed state hides and never reallocates")
print("Native progress header mock PASS")
