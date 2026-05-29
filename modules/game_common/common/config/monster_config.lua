---@class MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")

local settings = {}

function MonsterConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/monster.csv", 2)
    for _, vConfig in pairs(config) do

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            monsterId = tonumber(vConfig.n_monsterId) or 0,
            monsterType = tonumber(vConfig.n_monsterType) or 0,
            monsterLevel = tonumber(vConfig.n_monsterLevel) or 0,
            monster_alias = vConfig.s_monster_alias or "",
            itemName = vConfig.s_itemName or "",
            monsterName = vConfig.s_monsterName or "",
            cleanHurtTime = tonumber(vConfig.n_cleanHurtTime) or 60,
            rewardRexp = tonumber(vConfig.n_rewardRexp) or 0,
            rewardGold = tonumber(vConfig.n_rewardGold) or 0,
            rewardAexp = tonumber(vConfig.n_rewardAexp) or 0,
            dangerExp = tonumber(vConfig.n_dangerExp) or 0,
            passiveSkills = Lib.splitString(vConfig.s_passiveSkills or "", "#", true),
            skillTotalCD = tonumber(vConfig.n_skillTotalCD) or 0,
            dangerDistance = tonumber(vConfig.n_dangerDistance) or 0,
            chaseDistance = tonumber(vConfig.n_chaseDistance) or 0,
            hurtChaseTime = tonumber(vConfig.n_hurtChaseTime) or 0,
            moveSpeed = tonumber(vConfig.n_moveSpeed) or 0,
            maxHp = tonumber(vConfig.n_maxHp) or 0,
            hpRegen = tonumber(vConfig.n_hpRegen) or 0,
            attDamage = tonumber(vConfig.n_attDamage) or 0,
            defDamage = tonumber(vConfig.n_defDamage) or 0,
            defTough = tonumber(vConfig.n_defTough) or 0,
            attDominant = tonumber(vConfig.n_attDominant) or 0,
        }
        data.attackSkill = Lib.splitString(vConfig.s_attackSkill or "", "$", true)
        data.skillGroup = {}
        local skillList = Lib.splitString(vConfig.s_skillGroup or "", "#")
        for _, skillData in pairs(skillList) do
            local info = Lib.splitString(skillData or "", "$", true)
            table.insert(data.skillGroup, {skillId = info[1] or 0, skillWeight = info[2] or 0, freeRange = info[3] or 5})
        end
        settings[data.monsterId] = data
    end
end

function MonsterConfig:getCfgByMonsterId(monsterId)
    if not settings[monsterId] then
        Lib.logError("Error:Not found the data in monster.csv, monster id:", monsterId)
    end
    return settings[monsterId]
end

--- 获取怪物属性
function MonsterConfig:getMonsterAttributes(monsterId)
    local attributes = {}
    local config = self:getCfgByMonsterId(monsterId)
    for _, id in pairs(Define.ATTR) do
        if config[id] then
            attributes[id] = config[id]
        end
    end
    return attributes
end

function MonsterConfig:getAllCfgs()
    return settings
end

MonsterConfig:init()

return MonsterConfig

