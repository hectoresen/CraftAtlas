local _, ns = ...

local bankOpen = false

local function validCount(value)
    return type(value) == "number" and value >= 0
        and value == math.floor(value)
end

local function countItem(itemID, withBank)
    if type(itemID) ~= "number" or itemID <= 0 then return nil end
    local getter = C_Item and C_Item.GetItemCount
    if type(getter) ~= "function" then getter = GetItemCount end
    if type(getter) ~= "function" then return nil end
    local ok, result = pcall(getter, itemID, withBank == true)
    if not ok or not validCount(result) then return nil end
    return result
end

-- Forever's Classic character-bank containers: the main bank is -1 and
-- equipped bank bags are 5..11. Scan *actual slots* while the bank is open
-- instead of assuming C_Item.GetItemCount(includeBank=true) includes every
-- material; the screenshot showed Silverleaf absent from that aggregate.
local function scanOpenBank(itemID)
    local getSlots = C_Container and C_Container.GetContainerNumSlots
        or GetContainerNumSlots
    local getID = C_Container and C_Container.GetContainerItemID
        or GetContainerItemID
    local getInfo = C_Container and C_Container.GetContainerItemInfo
        or GetContainerItemInfo
    if type(getSlots) ~= "function" or type(getInfo) ~= "function" then
        return nil
    end
    local total = 0
    local indices = {-1, 5, 6, 7, 8, 9, 10, 11}
    local sawBank = false
    for _, container in ipairs(indices) do
        local ok, slots = pcall(getSlots, container)
        if not ok then return nil end
        if slots == nil and container ~= -1 then slots = 0 end
        if not validCount(slots) then return nil end
        if container == -1 and slots > 0 then sawBank = true end
        for slot = 1, slots do
            local itemInSlot
            if type(getID) == "function" then
                local okID, resultID = pcall(getID, container, slot)
                if not okID then return nil end
                itemInSlot = resultID
            end
            local okInfo, info, legacyCount, _, _, _, _, legacyLink, _, _, legacyID =
                pcall(getInfo, container, slot)
            if not okInfo then return nil end
            if type(info) == "table" then
                itemInSlot = itemInSlot or info.itemID
                if itemInSlot == itemID then
                    if not validCount(info.stackCount) then return nil end
                    total = total + info.stackCount
                end
            elseif info ~= nil then
                itemInSlot = itemInSlot or legacyID
                if not itemInSlot and type(legacyLink) == "string" then
                    itemInSlot = tonumber(string.match(legacyLink, "item:(%d+)"))
                end
                if itemInSlot == itemID then
                    if not validCount(legacyCount) then return nil end
                    total = total + legacyCount
                end
            end
        end
    end
    if not sawBank then return nil end
    return total
end

function ns.IsCraftBankSupported()
    local hasItemCount = (C_Item and type(C_Item.GetItemCount) == "function")
        or type(GetItemCount) == "function"
    local hasSlots = (C_Container and type(C_Container.GetContainerNumSlots) == "function")
        or type(GetContainerNumSlots) == "function"
    local hasInfo = (C_Container and type(C_Container.GetContainerItemInfo) == "function")
        or type(GetContainerItemInfo) == "function"
    return hasItemCount or (hasSlots and hasInfo)
end

function ns.IsCraftBankOpen()
    return bankOpen
end

function ns.ReadCraftInventoryCount(itemID, includeBank)
    local bags = countItem(itemID, false)
    local observed = {bags = bags, bank = nil, available = bags,
        bankStatus = includeBank and "unknown" or "excluded"}
    if not includeBank then return observed end
    if not ns.IsCraftBankSupported() then
        observed.bankStatus = "unavailable"
        return observed
    end
    if not bankOpen then return observed end

    -- Prefer the scanned bank-only quantity. It resolves items in bank bags
    -- even if the aggregate item-count API reports bags-only for that item.
    local scannedBank = scanOpenBank(itemID)
    if scannedBank ~= nil then
        observed.bank = scannedBank
        observed.available = bags and (bags + scannedBank) or nil
        observed.bankStatus = "confirmed"
        return observed
    end

    -- If enumeration is unavailable, cautiously retain the native combined
    -- count fallback, never replacing a known inventory count with a guess.
    local combined = countItem(itemID, true)
    if bags == nil or combined == nil or combined < bags then return observed end
    observed.bank = combined - bags
    observed.available = combined
    observed.bankStatus = "confirmed"
    return observed
end

function ns.SetCraftBankOpen(open)
    bankOpen = open == true
end
