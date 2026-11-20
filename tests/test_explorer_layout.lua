-- Pure native layout regression: texlua tests/test_explorer_layout.lua
local ns = {}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas", ns)

assert(ns.ExplorerVisibleRowCount(305, 34) == 8)
assert(ns.ExplorerVisibleRowCount(237, 34) == 6)
assert(ns.ExplorerVisibleRowCount(170, 34) == 5)
assert(ns.ExplorerVisibleRowCount(34, 34) == 2)
assert(ns.ExplorerVisibleRowCount(800, 34) == 11)

-- Profession section starts at -92, its icon row ends at -153.
-- The recipe section must begin below it and its rows below the gold divider.
for _, paneHeight in ipairs({343, 300, 260}) do
    local headingY, gridY = ns.MaterialDetailSectionOffsets(paneHeight)
    assert(headingY <= -160, "recipe heading overlaps profession icon row")
    assert(gridY <= headingY - 27, "recipe rows overlap 27px section bar")
end
for _, size in ipairs({{800,600}, {430,340}, {1024,768}, {600,500}}) do
    local viewportWidth, viewportHeight = size[1], size[2]
    local width, height, scale = ns.ExplorerWindowGeometry(viewportWidth, viewportHeight)
    assert(width >= 600 and height >= 440 and scale > 0)
    assert(width * scale <= viewportWidth - 23)
    assert(height * scale <= viewportHeight - 23)
    local searchWidth = math.min(290, math.floor(width * 0.36))
    assert(searchWidth + 24 <= width, "right-aligned search fits inside the upper toolbar")
end
-- A normal detail pane fits four icon/name pairs horizontally; compact keeps two.
assert(ns.ExplorerProfessionPageSize(600)==4)
assert(ns.ExplorerProfessionPageSize(475)==4)
assert(ns.ExplorerProfessionPageSize(474)==2)
assert(ns.ExplorerProfessionPageSize(320)==2)
assert(math.ceil(3 / ns.ExplorerProfessionPageSize(600))==1,
    "three professions must not show horizontal pagination")
assert(math.ceil(5 / ns.ExplorerProfessionPageSize(600))==2,
    "five professions must remain accessible")
assert(math.ceil(3 / ns.ExplorerProfessionPageSize(320))==2,
    "compact panes preserve navigation rather than truncate professions")
print("Explorer layout geometry PASS")
