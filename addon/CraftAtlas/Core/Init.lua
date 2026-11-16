local addonName, ns = ...
ns.name = addonName
-- Display only the locally installed, official SemVer stamped by the packager.
function ns.GetInstalledReleaseVersion(addon, modern, legacy)
    local getter = modern or (type(C_AddOns) == "table" and C_AddOns.GetAddOnMetadata)
        or legacy or GetAddOnMetadata
    if type(getter) ~= "function" then return nil end
    local ok, version = pcall(getter, addon or ns.name, "Version")
    if ok and type(version) == "string" and version:match("^%d+%.%d+%.%d+$") then
        return "v" .. version
    end
    return nil
end
ns.localeFallback = "enUS"
ns.state = {}
