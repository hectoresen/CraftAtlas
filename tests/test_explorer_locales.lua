-- Native explorer additions must remain localized in enUS and esES.
local ns = {}
assert(loadfile("addon/CraftAtlas/Localization/Locales.lua"))("CraftAtlas", ns)
for _, key in ipairs({"CLEAR_SEARCH", "PROFESSION_GROUP_COUNT", "ITEM_LEVEL"}) do
    local english = ns.Text(key, "enUS", "esES")
    local spanish = ns.Text(key, "esES", "enUS")
    assert(type(english) == "string" and english ~= key and english ~= "")
    assert(type(spanish) == "string" and spanish ~= key and spanish ~= "")
    assert(english ~= spanish, "distinct locale copy required: " .. key)
end
assert(ns.Text("CLEAR_SEARCH", "unknown", "enUS") == "Clear search")
assert(ns.Text("PROFESSION_GROUP_COUNT", "esES", "enUS"):format(3) == "3 materiales")
print("Explorer locale regression PASS")
