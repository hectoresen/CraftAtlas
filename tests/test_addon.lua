-- Lua 5.1 foundation fixture. The former file contained Markdown, not Lua.
-- Keep documentation in docs/TESTING.md and verify a live pure-domain contract.
local ns = {}
assert(loadfile("addon/CraftAtlas/Core/Init.lua"))("CraftAtlas", ns)
assert(ns.name == "CraftAtlas" and ns.localeFallback == "enUS")
assert(type(ns.state) == "table")
assert(loadfile("addon/CraftAtlas/Domain/MaterialLookup.lua"))("CraftAtlas", ns)
local registry = { [2589] = {"TAILORING", "FIRST_AID", "TAILORING"} }
local order = {"ALCHEMY", "FIRST_AID", "TAILORING"}
local result = ns.FindProfessions(2589, registry, order)
assert(#result == 2 and result[1] == "FIRST_AID" and result[2] == "TAILORING")
assert(#ns.FindProfessions(999, registry, order) == 0)
for _, invalid in ipairs({false, 0, -1, 1.5, "2589"}) do
    assert(#ns.FindProfessions(invalid, registry, order) == 0)
end
print("Addon Lua 5.1 foundation fixture PASS")
