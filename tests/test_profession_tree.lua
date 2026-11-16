-- Pure profession tree: grouping, duplicate identities and search state restoration.
local ns = {}
assert(loadfile("addon/CraftAtlas/Domain/ProfessionTree.lua"))("CraftAtlas", ns)

local materials = {
    [159] = {"COOKING", "ALCHEMY"},
    [2447] = {"ALCHEMY"},
    [14341] = {"TAILORING", "LEATHERWORKING"},
}
local ids = {159, 2447, 14341}
local order = {"ALCHEMY", "COOKING", "TAILORING", "LEATHERWORKING", "MINING"}
local groups = ns.BuildProfessionGroups(ids, materials, order)
assert(#groups == 4, "empty groups are hidden")
assert(groups[1].key == "ALCHEMY" and groups[1].count == 2)
assert(groups[2].key == "COOKING" and groups[2].count == 1)
assert(groups[3].key == "TAILORING" and groups[3].items[1] == 14341)
local flat = ns.FlattenProfessionGroups(groups, ns.NewProfessionTreeState(), false)
assert(#flat == 9, "four headers and five relationships, no fabricated rows")
assert(#ids == 3, "global unique result count must not repeat profession relationships")

local state = ns.NewProfessionTreeState()
assert(ns.ToggleProfessionTreeGroup(state, "ALCHEMY", false) == false)
flat = ns.FlattenProfessionGroups(groups, state, false)
assert(#flat == 7, "collapsed group hides only its two rows")
local searching = ns.FlattenProfessionGroups(groups, state, true)
assert(#searching == 9, "search expands matching groups even if closed before search")
assert(ns.ToggleProfessionTreeGroup(state, "ALCHEMY", true) == false)
assert(#ns.FlattenProfessionGroups(groups, state, true) == 7,
    "explicit collapse while searching takes precedence")
ns.ClearProfessionTreeSearch(state)
assert(#ns.FlattenProfessionGroups(groups, state, true) == 9,
    "new search starts auto-expanded")
assert(#ns.FlattenProfessionGroups(groups, state, false) == 7,
    "clearing search restores pre-search expansion state")
local filtered = ns.BuildProfessionGroups({14341}, materials, order)
assert(#filtered == 2 and filtered[1].count == 1 and filtered[2].count == 1,
    "group counts come from filtered numeric IDs")
print("Profession tree domain regression PASS")
