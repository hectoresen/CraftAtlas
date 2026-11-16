local _, ns = ...
local names, icons, requested, failed = {}, {}, {}, {}
local started = false

local function itemAPI()
    return type(C_Item) == "table" and C_Item or nil
end

local function readItem(itemID)
    local api = itemAPI()
    local getInfo = api and api.GetItemInfo or GetItemInfo
    if type(getInfo) == "function" then
        local ok, name, _, _, _, _, _, _, _, _, texture = pcall(getInfo, itemID)
        if ok then
            if type(name) == "string" and name ~= "" then names[itemID] = name end
            if texture then icons[itemID] = texture end
        end
    end
    -- Instant information contains the original icon even before the name is cached.
    if not icons[itemID] then
        local getInstant = api and api.GetItemInfoInstant or GetItemInfoInstant
        if type(getInstant) == "function" then
            local ok, _, _, _, _, icon = pcall(getInstant, itemID)
            if ok and icon then icons[itemID] = icon end
        end
    end
    if not icons[itemID] then
        local getIcon = api and api.GetItemIconByID or GetItemIcon
        if type(getIcon) == "function" then
            local ok, texture = pcall(getIcon, itemID)
            if ok and texture then icons[itemID] = texture end
        end
    end
end

function ns.GetItemDisplay(itemID)
    if type(itemID) ~= "number" or itemID < 1 then return nil, nil end
    -- Known client name+icon are session-stable until a native data event refresh.
    if not names[itemID] or not icons[itemID] then readItem(itemID) end
    if not names[itemID] and not requested[itemID] and not failed[itemID] then
        local api = itemAPI()
        if api and type(api.RequestLoadItemDataByID) == "function" then
            -- Set the flag before the request: the result event may be synchronous.
            requested[itemID] = true
            local ok = pcall(api.RequestLoadItemDataByID, itemID)
            if not ok then requested[itemID] = nil end
        end
    end
    return names[itemID], icons[itemID]
end

-- Optional, client-derived metadata only; absent fields remain absent.
function ns.GetItemMetadata(itemID)
    if type(itemID) ~= "number" or itemID < 1 then return nil end
    local api = itemAPI()
    local getter = api and api.GetItemInfo or GetItemInfo
    if type(getter) ~= "function" then return nil end
    local ok, _, _, quality, level, _, itemType = pcall(getter, itemID)
    if not ok then return nil end
    local metadata = {}
    if type(level) == "number" and level > 0 then metadata.level = level end
    if type(quality) == "number" then metadata.quality = quality end
    if type(itemType) == "string" and itemType ~= "" then metadata.itemType = itemType end
    return next(metadata) and metadata or nil
end

function ns.GetMaterialDisplay(itemID)
    if not (ns.IsVerifiedReagent and ns.IsVerifiedReagent(itemID)) then return nil, nil end
    return ns.GetItemDisplay(itemID)
end

function ns.GetKnownMaterialNames()
    return names
end

function ns.GetMaterialLoadProgress()
    local loaded, pending, unavailable = 0, 0, 0
    for itemID in pairs(ns.recipeUses or {}) do
        if names[itemID] then loaded = loaded + 1
        elseif requested[itemID] then pending = pending + 1
        elseif failed[itemID] then unavailable = unavailable + 1 end
    end
    return loaded, pending, unavailable
end

function ns.UpdateMaterialInfo(itemID, success)
    if not requested[itemID] then return false end
    requested[itemID] = nil
    if success == false then
        failed[itemID] = true
        return false
    end
    local oldName, oldIcon = names[itemID], icons[itemID]
    readItem(itemID)
    return names[itemID] ~= oldName or icons[itemID] ~= oldIcon
end

local preparation
local materialStats = {units = 0, batches = 0, attempts = 0, maxBatchMs = 0}

local function profileNow()
    if type(debugprofilestop) == "function" then
        local ok, value = pcall(debugprofilestop)
        if ok and type(value) == "number" then return value, 1 end
    end
    if type(GetTime) == "function" then
        local ok, value = pcall(GetTime)
        if ok and type(value) == "number" then return value, 1000 end
    end
end

function ns.GetMaterialPreparation()
    return preparation
end

function ns.GetMaterialPreparationMetrics()
    return materialStats
end

function ns.PreloadMaterialInfo()
    if started then return end
    started = true
    local ids = {}
    for itemID in pairs(ns.materials or {}) do
        ids[#ids + 1] = itemID
    end
    table.sort(ids)
    preparation = ns.NewCatalogProgress(#ids)
    materialStats.units = #ids
    if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("materials") end
    local position = 1
    local function batch()
        local began, units = profileNow()
        local last = math.min(position + 19, #ids)
        local changed = false
        for i = position, last do
            local id = ids[i]
            local oldName, oldIcon = names[id], icons[id]
            ns.GetMaterialDisplay(id)
            if oldName ~= names[id] or oldIcon ~= icons[id] then changed = true end
        end
        local finished = began and profileNow() or nil
        local elapsed = began and finished and (finished - began) or nil
        ns.AdvanceCatalogProgress(preparation, math.max(0, last - position + 1), elapsed)
        materialStats.batches = preparation.batches
        materialStats.attempts = preparation.completed
        materialStats.maxBatchMs = preparation.maxBatchMs
        position = last + 1
        if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("materials") end
        if changed and ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("materials") end
        if preparation.status == "complete" then
            if ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("materials") end
            return
        end
        local timer = C_Timer and C_Timer.After
        if type(timer) ~= "function" or not pcall(timer, 0.1, batch) then
            ns.StopCatalogProgress(preparation)
            if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("materials") end
            if ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("materials") end
        end
    end
    if preparation.status == "active" then batch() end
end
