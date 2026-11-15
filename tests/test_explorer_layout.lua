-- Pure native layout regression: texlua tests/test_explorer_layout.lua
local ns = {}
assert(loadfile("addon/CraftAtlas/Features/Settings/Shared/ExplorerWidgets.lua"))("CraftAtlas", ns)

-- Tabbed CraftAtlas shell: full 510px window can show seven results.
assert(ns.ExplorerVisibleRowCount(510, 36) == 7)
assert(ns.ExplorerVisibleRowCount(475, 36) == 6)
assert(ns.ExplorerVisibleRowCount(430, 36) == 5)
assert(ns.ExplorerVisibleRowCount(340, 36) == 2)
assert(ns.ExplorerVisibleRowCount(800, 36) == 9)

-- Material profession text begins at -115 and occupies 18px.
-- Both normal and compact section headings must start below it.
for _, paneHeight in ipairs({343, 300, 260}) do
    local headingY, gridY = ns.MaterialDetailSectionOffsets(paneHeight)
    assert(headingY <= -133, "section header overlaps profession text")
    assert(gridY < headingY - 17, "cards overlap fabrication heading")
end
print("Explorer layout geometry PASS")
