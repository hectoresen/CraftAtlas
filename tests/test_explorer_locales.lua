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
for _, key in ipairs({"CONFIG_TOOLTIP", "CONFIG_SHOW_MINIMAP", "CONFIG_SHOW_TOOLTIP_PROFESSIONS",
    "CONFIG_HIDE_PROFESSION_ICONS", "CONFIG_SINGLE_LINE"}) do
    local en, es = ns.Text(key, "enUS"), ns.Text(key, "esES")
    assert(en ~= key and es ~= key and en ~= es, "localized option label required: " .. key)
    assert(ns.Text(key, "auto", "frFR") == en)
end
for _, key in ipairs({"CATALOG_PREPARING_MATERIALS", "CATALOG_PREPARING_CRAFTABLES",
    "CATALOG_PREPARATION_PAUSED", "CATALOG_DIAGNOSTICS"}) do
    local en = ns.Text(key, "enUS", "enUS")
    local es = ns.Text(key, "esES", "esES")
    assert(en ~= key and es ~= key and en ~= es, "localized progress label required: " .. key)
end
assert(string.format(ns.Text("CATALOG_PREPARING_MATERIALS","esES","enUS"),42)
    == "Preparando materiales... 42%")
for _, key in ipairs({"TRACK_CRAFTING", "TRACK_PROGRESS", "TRACK_INCLUDE_BANK",
    "TRACK_BANK_UNKNOWN", "TRACK_INGREDIENT_UNKNOWN", "TRACK_UNVERIFIED"}) do
    local en = ns.Text(key, "enUS", "enUS")
    local es = ns.Text(key, "esES", "esES")
    assert(en ~= key and es ~= key and en ~= es,
        "localized craft tracker text required: " .. key)
end
for _, key in ipairs({"CRAFT_REQUIRED_SKILL", "CRAFT_SKILL_UNKNOWN", "CRAFT_SKILL_MET",
    "CRAFT_SKILL_UNMET", "CRAFT_SKILL_UNVERIFIED", "CRAFT_RECIPE_LEARNED",
    "CRAFT_RECIPE_UNLEARNED", "CRAFT_RECIPE_UNKNOWN", "CRAFT_SOURCE_ITEM",
    "CRAFT_SOURCE_TRAINER", "CRAFT_SOURCE_ITEM_OR_TRAINER", "CRAFT_SOURCE_UNKNOWN"}) do
    local en, es = ns.Text(key, "enUS"), ns.Text(key, "esES")
    assert(en ~= key and es ~= key and en ~= es, "localized requirement text required: " .. key)
end
assert(ns.Text("CRAFT_REQUIRED_SKILL", "esES"):format(15, ns.Text("CRAFT_SKILL_MET", "esES"))
    == "Nivel 15 · Alcanzado")
print("Explorer locale regression PASS")
