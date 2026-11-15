local _, ns = ...

function ns.NormalizeLanguage(value)
    if value == "auto" or value == "enUS" or value == "esES" then
        return value
    end
    return "auto"
end

function ns.InitPreferences()
    if type(CraftAtlasDB) ~= "table" then
        CraftAtlasDB = {}
    end
    CraftAtlasDB.version = 1
    CraftAtlasDB.language = ns.NormalizeLanguage(CraftAtlasDB.language)
    ns.state.preferences = CraftAtlasDB
    return CraftAtlasDB
end

function ns.GetLanguage()
    local preferences = ns.state.preferences
    return preferences and ns.NormalizeLanguage(preferences.language) or "auto"
end

function ns.SetLanguage(value)
    if not ns.state.preferences then
        ns.InitPreferences()
    end
    ns.state.preferences.language = ns.NormalizeLanguage(value)
    if ns.RefreshSettings then
        ns.RefreshSettings()
    end
end

function ns.GetClientLocale()
    return type(GetLocale) == "function" and GetLocale() or "enUS"
end

function ns.L(key)
    return ns.Text(key, ns.GetLanguage(), ns.GetClientLocale())
end
