---@class AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

local settings = {}

function AbilityConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/ability.csv", 2)
    for _, vConfig in pairs(config) do

        local buffs = nil
        if vConfig.s_passiveBuff and vConfig.s_passiveBuff ~= "" then
            buffs = Lib.splitString(vConfig.s_passiveBuff, "#", true)
        end
        local unlockLevels = nil
        if vConfig.s_unlockSkills and vConfig.s_unlockSkills ~= "" then
            unlockLevels = Lib.splitString(vConfig.s_unlockSkills, "#", true)
        end

        local parts = nil
        if vConfig.s_part and vConfig.s_part ~= "" then
            parts = {}
            local suitParts = Lib.splitString(vConfig.s_part, ";")
            for _, str in pairs(suitParts) do
                local str2Parts = Lib.splitString(str, "#")
                parts[str2Parts[1]] = str2Parts[2]
            end
        end

        local conflictParts = nil
        if vConfig.s_conflictParts and vConfig.s_conflictParts ~= "" then
            conflictParts = Lib.splitString(vConfig.s_conflictParts, "#")
        end

        local conflictOriginals = nil
        if vConfig.s_conflictOriginal and vConfig.s_conflictOriginal ~= "" then
            conflictOriginals = Lib.splitString(vConfig.s_conflictOriginal, "#")
        end

        local skin_color = nil
        if vConfig.s_skin_color and vConfig.s_skin_color ~= "" then
            local rgb = Lib.splitString(vConfig.s_skin_color, "#", true)
            skin_color = { rgb[1], rgb[2], rgb[3], 1 }
        end

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            abilityId = tonumber(vConfig.n_abilityId) or 0,
            unlimited_name = vConfig.s_unlimited_name or "",
            unlimited_icon = vConfig.s_unlimited_icon or "",
            rare = tonumber(vConfig.n_rare) or 0,
            damageType = tonumber(vConfig.n_damage_type) or 0,
            abilityName = vConfig.s_abilityName or "",
            imageIcon = vConfig.s_imageIcon or "",
            maxLevel = tonumber(vConfig.n_maxLevel) or 0,
            buffs = buffs,
            attackSkill = tonumber(vConfig.n_attackSkill) or 0,
            unlockLevels = unlockLevels,
            sprintSkill = tonumber(vConfig.n_sprintSkill) or 0,
            flySkill = tonumber(vConfig.n_flySkill) or 0,
            addFlySkill = tonumber(vConfig.n_addFlySkill) or 0,

            fightCount = tonumber(vConfig.n_fightCount) or 0,
            parts = parts,
            conflictParts = conflictParts,
            conflictOriginals = conflictOriginals,
            runAction = vConfig.s_runAction or "",
            idleAction = vConfig.s_idleAction or "",
            fightAction = vConfig.s_fightAction or "",
            fightRunAction = vConfig.s_fightRunAction or "",
            missBuffId = tonumber(vConfig.n_missBuffId) or 0,
            skin_color = skin_color,
        }

        local skills = nil
        if vConfig.s_skills and vConfig.s_skills ~= "" then
            skills = Lib.splitString(vConfig.s_skills, "#", true)
            data.skillLocks = {}
            if not unlockLevels then
                unlockLevels = {}
            end
            for key, skillId in pairs(skills) do
                data.skillLocks[skillId] = unlockLevels[key] or 0
            end
            data.skills = skills
        end

        settings[data.abilityId] = data
    end
end

-- function AbilityConfig:getCfgById(id)
--     if not settings[id] then
--         Lib.logError("Error:Not found the data in ability.csv, ability id:", id)
--     end
--     return settings[id]
-- end

function AbilityConfig:getCfgByAbilityId(abilityId)
    if not settings[abilityId] then
        Lib.logError("Error:Not found the data in ability.csv, ability id:", abilityId)
    end
    return settings[abilityId]
end

function AbilityConfig:getMaxLevel(abilityId)
    local config = self:getCfgByAbilityId(abilityId)
    return config.maxLevel
end

--- 获取主动技能
---@param abilityId any
function AbilityConfig:getActiveSkillList(abilityId)
    local skillList = {}
    local config = self:getCfgByAbilityId(abilityId)
    local unlocks = config.unlockLevels
    local skills = config.skills
    if skills and unlocks then
        for i = 1, #skills, 1 do
            skillList[#skillList + 1] = { unlock_level = unlocks[i], skill_id = skills[i] }
        end
    end
    return skillList
end

function AbilityConfig:getAllCfgs()
    return settings
end

AbilityConfig:init()

return AbilityConfig

