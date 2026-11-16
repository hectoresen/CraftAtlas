-- Installed-version authority: local manifest only, no network and no dev claims.
local ns = {}
assert(loadfile("addon/CraftAtlas/Core/Init.lua"))("CraftAtlas", ns)
local calls = 0
local function metadata(version)
    return function(addon, field)
        calls = calls + 1
        assert(addon == "CraftAtlas" and field == "Version")
        return version
    end
end
assert(ns.GetInstalledReleaseVersion("CraftAtlas", metadata("0.1.0")) == "v0.1.0")
assert(ns.GetInstalledReleaseVersion("CraftAtlas", metadata("2.34.5")) == "v2.34.5")
for _, version in ipairs({"0.1.0-dev", "v0.1.0", "0.1", "latest", ""}) do
    assert(ns.GetInstalledReleaseVersion("CraftAtlas", metadata(version)) == nil)
end
assert(ns.GetInstalledReleaseVersion("CraftAtlas", function() error("api unavailable") end) == nil)
assert(ns.GetInstalledReleaseVersion("CraftAtlas", function() return nil end) == nil)
assert(ns.GetInstalledReleaseVersion("CraftAtlas", false, false) == nil)
assert(calls == 7, "read local metadata once per query")
print("Installed release version regression PASS")
