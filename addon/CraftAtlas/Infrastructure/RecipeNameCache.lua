local _, ns = ...
local spellNames, spellIcons = {}, {}
local started = false
local cursor = 1
local preparation
local metrics = {units = 0, attempts = 0, batches = 0, maxBatchMs = 0}

local function profileNow()
    if type(debugprofilestop) == "function" then
        local ok, value = pcall(debugprofilestop)
        if ok and type(value) == "number" then return value end
    end
    if type(GetTime) == "function" then
        local ok, value = pcall(GetTime)
        if ok and type(value) == "number" then return value * 1000 end
    end
end

local function readSpell(spellID)
    if spellNames[spellID] and spellIcons[spellID] then return false end
    local oldName, oldIcon = spellNames[spellID], spellIcons[spellID]
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        local ok, value = pcall(C_Spell.GetSpellInfo, spellID)
        if ok and type(value) == "table" then
            if value.name then spellNames[spellID] = value.name end
            if value.iconID then spellIcons[spellID] = value.iconID end
        end
    end
    if not spellNames[spellID] and type(GetSpellInfo) == "function" then
        local ok, name, _, icon = pcall(GetSpellInfo, spellID)
        if ok then spellNames[spellID], spellIcons[spellID] = name, icon end
    end
    return oldName ~= spellNames[spellID] or oldIcon ~= spellIcons[spellID]
end

function ns.GetRecipeNames()
    return spellNames
end

function ns.GetRecipeSpellPresentation(spellID)
    if readSpell(spellID) and ns.OnCatalogDataChanged then
        ns.OnCatalogDataChanged("recipes")
    end
    return spellNames[spellID], spellIcons[spellID]
end

-- Optional native event path for late spell metadata; no polling or retries.
function ns.UpdateRecipeName(spellID)
    if type(spellID) ~= "number" then return false end
    local changed = readSpell(spellID)
    if changed and ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("recipes") end
    return changed
end

function ns.GetRecipePreparation()
    return preparation
end

function ns.GetRecipePreparationMetrics()
    return metrics
end

function ns.PreloadRecipeNames()
    if started then return end
    started = true
    local records = ns.recipes or {}
    preparation = ns.NewCatalogProgress(#records)
    metrics.units = #records
    if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("recipes") end
    local function batch()
        local began = profileNow()
        local last = math.min(cursor + 24, #records)
        local changed = false
        for i = cursor, last do
            local row = records[i]
            if readSpell(row[1]) then changed = true end
            if row[3] and row[3] > 0 then
                local oldName = ns.GetKnownMaterialNames and ns.GetKnownMaterialNames()[row[3]]
                local name = ns.GetItemDisplay(row[3])
                if name and name ~= oldName then changed = true end
            end
        end
        local finished = began and profileNow() or nil
        ns.AdvanceCatalogProgress(preparation, math.max(0, last - cursor + 1),
            began and finished and (finished - began) or nil)
        metrics.batches = preparation.batches
        metrics.attempts = preparation.completed
        metrics.maxBatchMs = preparation.maxBatchMs
        cursor = last + 1
        if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("recipes") end
        if changed and ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("recipes") end
        if preparation.status == "complete" then
            if ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("recipes") end
            return
        end
        local timer = C_Timer and C_Timer.After
        if type(timer) ~= "function" or not pcall(timer, 0.08, batch) then
            ns.StopCatalogProgress(preparation)
            if ns.OnCatalogProgressChanged then ns.OnCatalogProgressChanged("recipes") end
            if ns.OnCatalogDataChanged then ns.OnCatalogDataChanged("recipes") end
        end
    end
    if preparation.status == "active" then batch() end
end
