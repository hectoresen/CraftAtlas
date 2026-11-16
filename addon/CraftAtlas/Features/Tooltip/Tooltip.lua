local _, ns = ...

-- Forever SkillLine art from the pinned Profession Reagents design reference.
local professionIcons = {
    ALCHEMY = 136240,
    BLACKSMITHING = 136241,
    COOKING = 133971,
    ENCHANTING = 136244,
    ENGINEERING = 136243,
    FIRST_AID = 135966,
    FISHING = 136245,
    LEATHERWORKING = 136247,
    MINING = 136248,
    TAILORING = 136249,
}

local iconPrefixes = {}
local annotations = setmetatable({}, { __mode = "k" })
local registered = false

local function clearAnnotation(tooltip)
    annotations[tooltip].rendered = false
end

local function trackAnnotation(tooltip)
    local annotation = {}
    annotations[tooltip] = annotation
    if type(tooltip.HookScript) == "function" then
        if type(tooltip.HasScript) == "function" and tooltip:HasScript("OnTooltipCleared") then
            annotation.tracksClears = pcall(tooltip.HookScript, tooltip, "OnTooltipCleared", clearAnnotation)
        end
        if not annotation.tracksClears then
            pcall(tooltip.HookScript, tooltip, "OnHide", clearAnnotation)
        end
    end
    return annotation
end

local function formatProfessions(keys)
    local rows = {}
    for index, key in ipairs(keys) do
        local name = key == "TAILORING" and ns.L("MATERIAL_TOOLTIP_TAILORING") or ns.ProfessionLabel(key)
        rows[index] = { key = key, name = name, order = name:lower() }
    end
    -- The enUS/esES labels have distinct alphabetic prefixes before accented letters.
    table.sort(rows, function(left, right)
        if left.order == right.order then return left.key < right.key end
        return left.order < right.order
    end)
    return rows
end

local function isReadableTable(value)
    return (type(issecretvalue) ~= "function" or not issecretvalue(value))
        and type(value) == "table"
        and (type(canaccesstable) ~= "function" or canaccesstable(value))
end

local function onItemTooltip(tooltip, data)
    if not isReadableTable(tooltip) or type(tooltip.AddLine) ~= "function" then return end
    if type(tooltip.IsForbidden) == "function" and tooltip:IsForbidden() then return end
    if not isReadableTable(data) then return end
    if type(tooltip.GetPrimaryTooltipData) == "function" then
        local ok, primary = pcall(tooltip.GetPrimaryTooltipData, tooltip)
        if not ok or (type(issecretvalue) == "function" and issecretvalue(primary))
            or (primary ~= nil and primary ~= data) then return end
    end
    local ok, itemID = pcall(ns.ResolveTooltipItemID, data)
    if not ok or not itemID then return end
    local keys = ns.FindProfessions(itemID, ns.materials, ns.professionOrder)
    if #keys == 0 then return end

    local annotation = annotations[tooltip] or trackAnnotation(tooltip)
    local count = not annotation.tracksClears and type(tooltip.NumLines) == "function" and tooltip:NumLines()
    if annotation.rendered
        and (not count or not annotation.lineCount or count >= annotation.lineCount) then return end

    local rows = formatProfessions(keys)
    local gold = NORMAL_FONT_COLOR
    tooltip:AddLine(" ")
    tooltip:AddLine(ns.L("MATERIAL_TOOLTIP_HEADING"), gold and gold.r or 1, gold and gold.g or 0.82,
        gold and gold.b or 0)
    for _, row in ipairs(rows) do
        tooltip:AddLine((iconPrefixes[row.key] or "") .. row.name, 1, 1, 1)
    end
    annotation.rendered = true
    annotation.lineCount = count and count + 2 + #rows or nil
end

function ns.InitTooltip()
    if registered then return true end
    local filename = C_Texture and C_Texture.GetFilenameFromFileDataID
    for key, fileID in pairs(professionIcons) do
        local available = true
        if type(filename) == "function" then
            local ok, path = pcall(filename, fileID)
            available = ok and type(path) == "string" and path ~= ""
        end
        iconPrefixes[key] = available and ("|T%d:14:14:0:0|t "):format(fileID) or nil
    end
    local ok, reason = ns.RegisterTooltipHook(onItemTooltip)
    registered = ok
    return ok, reason
end
