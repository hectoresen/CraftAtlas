local _, ns = ...

-- Only links returned by the client are allowed into chat.
local function validLink(link, kind)
    return type(link) == "string" and
        string.find(link, "|H" .. kind .. ":", 1, true) ~= nil and
        string.find(link, "|h", 1, true) ~= nil
end

local function itemLink(itemID)
    if type(itemID) ~= "number" then return nil end
    if C_Item and type(C_Item.GetItemInfo) == "function" then
        local ok, _, link = pcall(C_Item.GetItemInfo, itemID)
        if ok and validLink(link, "item") then return link end
    end
    if type(GetItemInfo) == "function" then
        local ok, _, link = pcall(GetItemInfo, itemID)
        if ok and validLink(link, "item") then return link end
    end
end

local function spellLink(spellID)
    if type(spellID) ~= "number" then return nil end
    if C_Spell and type(C_Spell.GetSpellLink) == "function" then
        local ok, link = pcall(C_Spell.GetSpellLink, spellID)
        if ok and validLink(link, "spell") then return link end
    end
    if type(GetSpellLink) == "function" then
        local ok, link = pcall(GetSpellLink, spellID)
        if ok and validLink(link, "spell") then return link end
    end
end

function ns.IsEntityChatLinkClick(button)
    return button == "LeftButton" and type(IsShiftKeyDown) == "function"
        and IsShiftKeyDown() == true
end

function ns.InsertEntityChatLink(kind, id)
    local link = kind == "item" and itemLink(id)
        or (kind == "spell" and spellLink(id)) or nil
    if not link or type(ChatEdit_InsertLink) ~= "function" then return false end
    -- Blizzard's native insertion works with an active editor; open the
    -- default chat editor when none is active. Never send a message.
    if ChatEdit_GetActiveWindow and not ChatEdit_GetActiveWindow()
        and type(ChatFrame_OpenChat) == "function" then
        pcall(ChatFrame_OpenChat, "")
    end
    local ok, inserted = pcall(ChatEdit_InsertLink, link)
    return ok and inserted ~= false
end

function ns.InsertRecipeChatLink(recipe)
    if type(recipe) ~= "table" then return false end
    if recipe.outputItemID then
        return ns.InsertEntityChatLink("item", recipe.outputItemID)
    end
    return ns.InsertEntityChatLink("spell", recipe.spellID)
end
