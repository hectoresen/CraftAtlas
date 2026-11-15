local _, ns = ...

local function spellData(spellID)
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        local ok, data = pcall(C_Spell.GetSpellInfo, spellID)
        if ok and type(data) == "table" then
            return data.name, data.iconID or data.originalIconID
        end
    end
    if type(GetSpellInfo) == "function" then
        local ok, name, _, icon = pcall(GetSpellInfo, spellID)
        if ok then return name, icon end
    end
end

function ns.GetRecipePresentation(use)
    local spellName, spellIcon = spellData(use.spellID)
    local outputName, outputIcon
    if use.outputItemID then
        outputName, outputIcon = ns.GetItemDisplay(use.outputItemID)
    end
    return {
        spellName = spellName,
        spellIcon = spellIcon,
        outputName = outputName,
        outputIcon = outputIcon,
    }
end

local function tooltipOwner(button)
    if not GameTooltip or type(GameTooltip.SetOwner) ~= "function" then return false end
    local ok = pcall(GameTooltip.SetOwner, GameTooltip, button, "ANCHOR_RIGHT")
    return ok
end

function ns.ShowOutputTooltip(button, itemID)
    if not itemID or not tooltipOwner(button) then return false end
    local ok = false
    if type(GameTooltip.SetItemByID) == "function" then
        ok = pcall(GameTooltip.SetItemByID, GameTooltip, itemID)
    end
    if not ok and type(GameTooltip.SetHyperlink) == "function" then
        ok = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. itemID)
    end
    if ok and type(GameTooltip.Show) == "function" then GameTooltip:Show() end
    if not ok and type(GameTooltip.Hide) == "function" then GameTooltip:Hide() end
    return ok
end

function ns.ShowRecipeTooltip(button, use)
    if not use or not tooltipOwner(button) then return false end
    local ok = false
    if type(GameTooltip.SetSpellByID) == "function" then
        ok = pcall(GameTooltip.SetSpellByID, GameTooltip, use.spellID)
    end
    if not ok and type(GameTooltip.SetHyperlink) == "function" then
        ok = pcall(GameTooltip.SetHyperlink, GameTooltip, "spell:" .. use.spellID)
    end
    if not ok and type(GameTooltip.SetText) == "function" then
        local info = ns.GetRecipePresentation(use)
        GameTooltip:SetText(info.spellName or (ns.L("RECIPE_ID") .. " " .. use.spellID))
        if type(GameTooltip.AddLine) == "function" then
            GameTooltip:AddLine(ns.ProfessionLabel(use.professionKey), 0.85, 0.78, 0.62)
            GameTooltip:AddLine(ns.L("RECIPE_TOOLTIP_LIMITED"), 0.65, 0.65, 0.65, true)
        end
        ok = true
    end
    if ok and type(GameTooltip.Show) == "function" then GameTooltip:Show() end
    return ok
end

function ns.HideRecipeTooltip()
    if GameTooltip and type(GameTooltip.Hide) == "function" then GameTooltip:Hide() end
end
