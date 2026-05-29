
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@class AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")


function AbilitySystem:init()
    
end

--- 添加能力经验
---@param player Entity
---@param addExp number 添加经验
---@return boolean success
---@return Ability 当前能力
---@return number addLevel
function AbilitySystem:addAbilityExp(player, addExp)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")

    if abilityComponent then
        ---@type Ability
        local ability = abilityComponent:getAbility()
        if ability then
            local abilityId = ability:getItemId()
            local maxLevel = AbilityConfig:getMaxLevel(abilityId)
            local level = ability:getLevel()

            if level < maxLevel then
                local exp = ability:getExp() + addExp
                local totalExp = ability:getTotalExp()
                --- 满足经验升级
                local upgradePrice
                local addLevel = 0
                for i = level, maxLevel, 1 do
                    upgradePrice = AbilityLevelConfig:getCfgByLevel(i).upgradePrice
                    if exp < upgradePrice then
                        break
                    end
                    exp = exp - upgradePrice
                    addLevel = addLevel + 1
                    level = level + 1
    
                    --- 截取经验
                    if level >= maxLevel then
                        exp = 0
                        break
                    end
                end
                --- 设置经验与等级
                self:setAbilityLevelData(player, level, exp)

                Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_EXP, player, ability, addLevel, ability:getTotalExp() - totalExp)

                if addLevel > 0 then
                    --- 派发事件
                    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, player, ability, addLevel)
                end

                if not World.isClient and addLevel > 0 then
                    local entityCfg = player:cfg()
                    if entityCfg.abilityEffect and entityCfg.abilityEffect ~= "" then
                        player:addBuff(entityCfg.abilityEffect, entityCfg.abilityEffectTime or 20)
                    end
                    player:checkUpdateTaskData(Define.TargetConditionKey.ABILITY)
                end

                return true, ability, addLevel
            end

            return false, ability, 0
        end
    end
    return false, nil, 0
end

--- 获取当前能力
---@param player Entity
---@return Ability 当前能力
function AbilitySystem:getAbility(player)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        return abilityComponent:getAbility()
    end
    return nil
end

--- 设置当前能力
---@param player any
---@param ability any
function AbilitySystem:setAbility(player, ability)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        abilityComponent:setAbility(ability)
    end
end

--- 设置当前能力等级数据
---@param player any
---@param level any
---@param exp any
function AbilitySystem:setAbilityLevelData(player, level, exp)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        abilityComponent:setAbilityLevel(level)
        abilityComponent:setAbilityExp(exp)
    end
end

--- 获取当前能力等级
---@param player any
function AbilitySystem:getAbilityLevel(player)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        ---@type Ability
        local ability = abilityComponent:getAbility()
        if ability then
            return ability:getLevel()
        end
    end
    return 1
end

--- 获取所有技能
---@param player any
---@return AbilitySkill 当前能力技能
function AbilitySystem:getAbilitySkill(player)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        return abilityComponent:getAbilitySkill()
    end
    return nil
end

--- 获取上一次装备能力
---@param player any
function AbilitySystem:getPreviousId(player)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        return abilityComponent:getPreviousId()
    end
    return nil
end

--- 获取对应能力id的所有能力
---@param player any
---@param abilityId any
---@return table Ability类型的数组
function AbilitySystem:getAbilityListByAbilityId(player, abilityId)
    return InventorySystem:getItemListByItemId(player, Define.INVENTORY_TYPE.ABILITY, abilityId)
end

--- 获取默认能力
---@param player any
---@return Ability 能力
function AbilitySystem:getDefaultAbility(player)
    ---@type Ability
    local ability = InventorySystem:getItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, Define.ITEM_ALIAS.DEFAULT_ABILITY)
    return ability
end

--- 获取被动buff
---@param abilityId any
---@param awake any
function AbilitySystem:getPassiveBuffList(abilityId, awake)
    if awake and awake > 0 then
        local config = AbilityAwakeConfig:getCfgByAbilityId(abilityId)
        abilityId = config.awake_ids[awake]
    end
    local buffList = {}
    local config = AbilityConfig:getCfgByAbilityId(abilityId)
    local buffs = config.buffs
    if buffs then
        for i = 1, #buffs, 1 do
            buffList[#buffList + 1] = buffs[i]
        end
    end
    return buffList
end

--- 设置能力觉醒
---@param player any
---@param id any
---@param awake any
---@return Ability
function AbilitySystem:setAbilityAwake(player, id, awake)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        ---@type Ability
        local ability = abilityComponent:getAbility()
        if ability and ability:getId() == id then
            abilityComponent:setAbilityAwake(awake)
            return ability
        end
    end
    ---@type Ability
    local ability = InventorySystem:getItemById(player, Define.INVENTORY_TYPE.ABILITY, id)
    if ability then
        ability:setAwake(awake)
        return ability
    end
end

--- 设置能力皮肤
---@param player any
---@param abilityId any
function AbilitySystem:setAbilitySkin(player, abilityId)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        abilityComponent:setAbilitySkin(abilityId)
    end
end

--- 获取能力皮肤
---@param player any
function AbilitySystem:getAbilitySkin(player)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        return abilityComponent:getAbilitySkin()
    end
    return nil
end

AbilitySystem:init()

return AbilitySystem