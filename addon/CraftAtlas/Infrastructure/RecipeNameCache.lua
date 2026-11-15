local _, ns = ...
local spellNames, spellIcons = {}, {}
local pending = {}
local cursor = 1

local function readSpell(spellID)
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
end

function ns.GetRecipeNames()
    return spellNames
end

function ns.GetRecipeSpellPresentation(spellID)
    readSpell(spellID)
    return spellNames[spellID], spellIcons[spellID]
end

function ns.PreloadRecipeNames()
    if pending.started then return end
    pending.started = true
    local function batch()
        local last = math.min(cursor + 24, #(ns.recipes or {}))
        for i = cursor, last do
            local row = ns.recipes[i]
            readSpell(row[1])
            if row[3] and row[3] > 0 then ns.GetItemDisplay(row[3]) end
        end
        cursor = last + 1
        if ns.RefreshExplorer then ns.RefreshExplorer() end
        if cursor <= #(ns.recipes or {}) then
            if C_Timer and type(C_Timer.After) == "function" then
                C_Timer.After(0.08, batch)
            else
                pending.started = false
            end
        end
    end
    batch()
end
