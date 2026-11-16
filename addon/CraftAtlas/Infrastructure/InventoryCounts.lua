local _, ns = ...

local bankOpen = false

local function countItem(itemID, withBank)
    if type(itemID) ~= "number" or itemID <= 0 then return nil end
    local getter = C_Item and C_Item.GetItemCount
    if type(getter) ~= "function" then getter = GetItemCount end
    if type(getter) ~= "function" then return nil end
    local ok, result = pcall(getter, itemID, withBank == true)
    if not ok or type(result) ~= "number" or result < 0
        or result ~= math.floor(result) then
        return nil
    end
    return result
end

function ns.IsCraftBankSupported()
    return (C_Item and type(C_Item.GetItemCount) == "function")
        or type(GetItemCount) == "function"
end

function ns.IsCraftBankOpen()
    return bankOpen
end

function ns.ReadCraftInventoryCount(itemID, includeBank)
    local bags = countItem(itemID, false)
    local observed = {bags = bags, bank = nil, available = bags,
        bankStatus = includeBank and "unknown" or "excluded"}
    -- A closed bank can expose a cached amount. Never treat that as fresh.
    if not includeBank then return observed end
    if not ns.IsCraftBankSupported() then
        observed.bankStatus = "unavailable"
        return observed
    end
    if not bankOpen then return observed end
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
