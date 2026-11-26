local _, ns = ...

local displayDefaults = {
    showMinimapButton = true,
    showTooltipProfessions = true,
    hideTooltipProfessionIcons = false,
    tooltipProfessionsOnOneLine = false,
}

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
    for key, default in pairs(displayDefaults) do
        if type(CraftAtlasDB[key]) ~= "boolean" then CraftAtlasDB[key] = default end
    end
    if type(CraftAtlasDB.craftTracking) ~= "table" then CraftAtlasDB.craftTracking = {} end
    ns.state.preferences = CraftAtlasDB
    return CraftAtlasDB
end

function ns.GetDisplayPreference(key)
    local preferences = ns.state.preferences
    if preferences and type(preferences[key]) == "boolean" then return preferences[key] end
    return displayDefaults[key]
end

function ns.SetDisplayPreference(key, value)
    if displayDefaults[key] == nil or type(value) ~= "boolean" then return end
    local preferences = ns.state.preferences or ns.InitPreferences()
    preferences[key] = value
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
    if ns.RefreshAddonOptions then
        ns.RefreshAddonOptions()
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
    local name, realm
    if type(UnitName) == "function" then name = UnitName("player") end
    if type(GetRealmName) == "function" then realm = GetRealmName() end
    -- Some Forever client states have the character ready before GetRealmName.
    -- UnitFullName is a compatible fallback and must not change existing keys.
    if (type(name) ~= "string" or name == "" or
        type(realm) ~= "string" or realm == "") and type(UnitFullName) == "function" then
        local fullName, fullRealm = UnitFullName("player")
        if type(name) ~= "string" or name == "" then name = fullName end
        if type(realm) ~= "string" or realm == "" then realm = fullRealm end
    end
    if type(name) ~= "string" or name == "" or type(realm) ~= "string" or realm == "" then
        return nil
    end
    return realm .. ":" .. name
end

-- Global opt-in scoped to the current character, never to a recipe key.
-- Old per-recipe craftTracking entries remain untouched but do not opt in.
function ns.IsCraftTrackingEnabled()
    local id, db = characterKey(), ns.state.preferences
    return id ~= nil and db ~= nil
        and type(db.craftTrackingEnabled) == "table"
        and db.craftTrackingEnabled[id] == true or false
end

function ns.SetCraftTrackingEnabled(enabled)
    local id = characterKey()
    if not id then return false end
    local db = ns.state.preferences or ns.InitPreferences()
    if type(db.craftTrackingEnabled) ~= "table" then
        db.craftTrackingEnabled = {}
    end
    db.craftTrackingEnabled[id] = enabled == true or nil
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
