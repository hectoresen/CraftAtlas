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
    CraftAtlasDB.minimapAngle = tonumber(CraftAtlasDB.minimapAngle) or 45
    if type(CraftAtlasDB.craftTracking) ~= "table" then CraftAtlasDB.craftTracking = {} end
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

function ns.GetMinimapAngle()
    local preferences = ns.state.preferences
    return preferences and tonumber(preferences.minimapAngle) or 45
end

function ns.SetMinimapAngle(value)
    if not ns.state.preferences then
        ns.InitPreferences()
    end
    ns.state.preferences.minimapAngle = tonumber(value) or 45
end

function ns.GetClientLocale()
    return type(GetLocale) == "function" and GetLocale() or "enUS"
end

function ns.L(key)
    return ns.Text(key, ns.GetLanguage(), ns.GetClientLocale())
end

-- The account-wide SavedVariables file contains isolated character maps.
-- Do not persist tracking until both identity components are resolved.
local function characterKey()
    if type(UnitName) ~= "function" or type(GetRealmName) ~= "function" then return nil end
    local name, realm = UnitName("player"), GetRealmName()
    if type(name) ~= "string" or name == "" or type(realm) ~= "string" or realm == "" then
        return nil
    end
    return realm .. ":" .. name
end

function ns.IsCraftableTracked(recipeKey)
    local id = characterKey()
    local db = ns.state.preferences
    return id ~= nil and type(recipeKey) == "string" and db
        and type(db.craftTracking) == "table"
        and type(db.craftTracking[id]) == "table"
        and db.craftTracking[id][recipeKey] == true or false
end

function ns.SetCraftableTracked(recipeKey, enabled)
    local id = characterKey()
    if not id or type(recipeKey) ~= "string" or recipeKey == "" then return false end
    local db = ns.state.preferences or ns.InitPreferences()
    if type(db.craftTracking[id]) ~= "table" then db.craftTracking[id] = {} end
    if enabled then db.craftTracking[id][recipeKey] = true
    else db.craftTracking[id][recipeKey] = nil end
    return true
end

function ns.GetCraftBankPreference()
    local id, db = characterKey(), ns.state.preferences
    return id ~= nil and db and type(db.craftBankIncluded) == "table"
        and db.craftBankIncluded[id] == true or false
end

function ns.SetCraftBankPreference(included)
    local id = characterKey()
    if not id then return false end
    local db = ns.state.preferences or ns.InitPreferences()
    if type(db.craftBankIncluded) ~= "table" then db.craftBankIncluded = {} end
    db.craftBankIncluded[id] = included == true or nil
    return true
end
