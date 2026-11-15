local _, ns = ...
local names, icons = {}, {}
local requested = {}

function ns.GetMaterialDisplay(itemID)
    if not (ns.materials and ns.materials[itemID]) then return nil, nil end
    if not requested[itemID] and type(GetItemInfo) == "function" then
        requested[itemID] = true
        local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
        if type(name) == "string" and name ~= "" then names[itemID] = name end
        if texture then icons[itemID] = texture end
    end
    if not icons[itemID] and type(GetItemIcon) == "function" then
        icons[itemID] = GetItemIcon(itemID)
    end
    return names[itemID], icons[itemID]
end

function ns.GetKnownMaterialNames()
    return names
end

function ns.UpdateMaterialInfo(itemID, success)
    if not success or not (ns.materials and ns.materials[itemID]) then return false end
    requested[itemID] = nil
    local previous = names[itemID]
    ns.GetMaterialDisplay(itemID)
    return names[itemID] ~= previous
end

-- Item data is requested once, in bounded batches, never on every keystroke.
function ns.PreloadMaterialInfo()
    if ns.state.materialPreloadStarted then return end
    ns.state.materialPreloadStarted = true
    local ids = {}
    for itemID in pairs(ns.materials or {}) do ids[#ids + 1] = itemID end
    table.sort(ids)
    local cursor = 1
    local function batch()
        local last = math.min(cursor + 29, #ids)
        for index = cursor, last do ns.GetMaterialDisplay(ids[index]) end
        cursor = last + 1
        if cursor <= #ids and C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0.1, batch)
        end
    end
    if C_Timer and type(C_Timer.After) == "function" then
        batch()
    else
        -- Without a supported scheduler, avoid a synchronous catalog-wide request.
        ns.state.materialPreloadStarted = false
    end
end
