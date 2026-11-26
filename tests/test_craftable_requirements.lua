-- Client API contract for the read-only Craftables requirements adapter.
local ns = {}
assert(loadfile("addon/CraftAtlas/Infrastructure/ProfessionRequirements.lua"))("CraftAtlas", ns)

local recipe = {professionKey = "ALCHEMY", spellID = 2329}
local function expect(rank, learned, trainer, transitioning)
    local actualRank, actualLearned, actualTrainer = ns.GetCraftablePlayerRequirements(recipe, transitioning)
    assert(actualRank == rank, "Unexpected profession rank: " .. tostring(actualRank))
    assert(actualLearned == learned, "Unexpected learned state: " .. tostring(actualLearned))
    assert(actualTrainer == (trainer == true), "Unexpected trainer source")
end
expect(nil, nil)

local profile = {professionID = 171, skillLevel = 14}
local active = {professionID = 171}
local info = {recipeID = 2329, learned = false}
local external = false
local professionLearned = true
C_TradeSkillUI = {
    GetProfessionInfoByRecipeID = function(spellID)
        assert(spellID == recipe.spellID)
        return profile
    end,
    GetBaseProfessionInfo = function() return active end,
    IsRecipeProfessionLearned = function() return professionLearned end,
    IsTradeSkillLinked = function() return external end,
    GetRecipeInfo = function(spellID)
        assert(spellID == recipe.spellID)
        return info
    end,
}
expect(14, false)
profile.skillLevel, info.learned = 15, true
expect(15, true)
profile.skillLevel = 16
expect(16, true)

-- An unrelated or absent active profession window cannot confirm a negative.
active, info.learned = {professionID = 333}, false
expect(16, nil)
active = nil
expect(16, nil)
info.learned = true
expect(16, true)
info.recipeID = 2330
expect(16, nil)
info.recipeID = 2329
profile = {professionID = 333, skillLevel = 300}
expect(nil, nil)
profile = {professionID = 2485, parentProfessionID = 171, skillLevel = 52}
expect(52, true)
profile = {professionID = 171, skillLevel = 0}
info.learned = false
expect(nil, nil)
professionLearned = false
expect(0, false)

-- Profession slots belong to the current player irrespective of the active trade UI.
GetProfessions = function() return nil, 21, nil, 42 end
GetProfessionInfo = function(index)
    if index == 21 then return "Alquimia", 0, 66, 150, 0, 0, 171 end
    return "Pesca", 0, 85, 150, 0, 0, 356
end
expect(66, nil)
expect(66, nil, false, true)
external = true
expect(66, nil)
C_SpellBook = {IsSpellKnown = function(spellID) return spellID == 2329 end}
expect(66, true)
C_SpellBook.IsSpellKnown = function() return false end
expect(66, nil)
C_TradeSkillUI.IsTradeSkillLinked = function() error("unavailable context") end
expect(66, nil)

-- An exact spell offer is evidence for a trainer source. A matching item ID
-- or a closed trainer window is insufficient.
local trainerOpen = true
local serviceType = 0
ClassTrainerFrame = {IsShown = function() return trainerOpen end}
Enum = {TooltipDataType = {Spell = 1}}
GetNumTrainerServices = function() return 2 end
C_TooltipInfo = {GetTrainerService = function(index)
    return {type = serviceType, id = index == 1 and 2330 or 2329}
end}
expect(66, nil)
serviceType = Enum.TooltipDataType.Spell
expect(66, nil, true)
trainerOpen = false
expect(66, nil)
print("Craftable profession requirements client adapter PASS")
