local _, ns = ...

-- Forever SkillLine IDs, independent of the client language.
local skillLines = {
    ALCHEMY = 171, BLACKSMITHING = 164, COOKING = 185, ENCHANTING = 333,
    ENGINEERING = 202, FIRST_AID = 129, FISHING = 356, HERBALISM = 182,
    LEATHERWORKING = 165, MINING = 186, SKINNING = 393, TAILORING = 197,
}

local function read(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, a, b, c, d, e, f, g = pcall(fn, ...)
    if ok then return a, b, c, d, e, f, g end
end

local function matchesSkillLine(info, skillLine)
    return type(info) == "table" and
        (info.professionID == skillLine or info.parentProfessionID == skillLine)
end

local function validRank(rank)
    return type(rank) == "number" and rank > 0 and rank < math.huge
        and rank == math.floor(rank)
end

local function playerSkill(skillLine)
    -- This API reads the player's profession slots even while viewing another character's list.
    for _, index in pairs({read(GetProfessions)}) do
        if type(index) == "number" then
            local _, _, rank, _, _, _, id = read(GetProfessionInfo, index)
            if id == skillLine and validRank(rank) then return rank end
        end
    end
end

local function hasExternalContext(api)
    for _, name in ipairs({"IsNPCCrafting", "IsTradeSkillLinked", "IsTradeSkillGuild",
        "IsTradeSkillGuildMember", "IsDataSourceChanging"}) do
        local check = api[name]
        if type(check) == "function" then
            local ok, flag = pcall(check)
            if not ok or (flag ~= nil and flag ~= false and flag ~= 0) then return true end
        end
    end
    return false
end

local function trainerTeaches(spellID)
    -- Accept a trainer only when its currently displayed spell offer proves the source.
    local spellType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Spell
    if spellType == nil or not C_TooltipInfo or not ClassTrainerFrame
        or not read(ClassTrainerFrame.IsShown, ClassTrainerFrame) then return false end

    local count = read(GetNumTrainerServices)
    if not validRank(count) then return false end
    for index = 1, count do
        local service = read(C_TooltipInfo.GetTrainerService, index)
        if type(service) == "table" and service.type == spellType and service.id == spellID then
            return true
        end
    end
    return false
end

function ns.GetCraftablePlayerRequirements(recipe, changingProfession)
    local skillLine = skillLines[recipe.professionKey]
    local spellID = recipe.spellID
    local api = C_TradeSkillUI
    local rank, learned

    if skillLine and api and not changingProfession and not hasExternalContext(api) then
        local profession = read(api.GetProfessionInfoByRecipeID, spellID)
        if matchesSkillLine(profession, skillLine) then
            if validRank(profession.skillLevel) then rank = profession.skillLevel end

            local info = read(api.GetRecipeInfo, spellID)
            if type(info) == "table" and info.recipeID == spellID then
                if info.learned == true then
                    learned = true
                elseif info.learned == false then
                    -- The client can supply catalog recipe data without a current player list.
                    if matchesSkillLine(read(api.GetBaseProfessionInfo), skillLine) then
                        learned = false
                    end
                    if profession.skillLevel == 0 and read(api.IsRecipeProfessionLearned, spellID) == false then
                        rank = playerSkill(skillLine)
                        if not rank then rank, learned = 0, false end
                    end
                end
            end
        end
    end

    if not rank and skillLine then rank = playerSkill(skillLine) end
    -- Missing spellbook entries do not establish that a profession recipe is unlearned.
    if learned == nil and C_SpellBook and read(C_SpellBook.IsSpellKnown, spellID) == true then
        learned = true
    end
    return rank, learned, trainerTeaches(spellID)
end
