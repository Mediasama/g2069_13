---@type PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")
---@class GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

function GrowthSystem:init()

end

--- 获取玩家等级
---@param player any
function GrowthSystem:getLevel(player)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        return growthComponent:getLevel()
    end
    return 1
end

--- 获取玩家经验
---@param player any
function GrowthSystem:getExp(player)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        return growthComponent:getExp()
    end
    return 0
end

--- 设置等级
---@param player any
---@param level any
function GrowthSystem:setLevel(player, level)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        growthComponent:setLevel(level)
    end
end

--- 设置经验
---@param player any
---@param exp any
function GrowthSystem:setExp(player, exp)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        growthComponent:setExp(exp)
    end
end

--- 设置等级数据
---@param player any
---@param level any
---@param exp any
function GrowthSystem:setLevelData(player, level, exp)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        growthComponent:setLevel(level)
        growthComponent:setExp(exp)
    end
end

--- 获取当前总经验
---@param player any
function GrowthSystem:getTotalExp(player)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        local level = growthComponent:getLevel()
        local exp = growthComponent:getExp()
        if level > 1 then
            for i = 1, level - 1 do
                local config = PlayerLevelConfig:getCfgByLevel(i)
                exp = exp + config.need_exp
            end
        end
        return exp
    end
    return 0
end

--- 升级
---@param player any
---@param addExp any
---@return boolean success
---@return number level
---@return number exp
---@return number addLevel
function GrowthSystem:addExp(player, addExp)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    
    if growthComponent then
        local maxLevel = PlayerLevelConfig:getMaxLevel()
        local level = growthComponent:getLevel()
        if level < maxLevel then
            local exp = growthComponent:getExp() + addExp
            --- 满足经验升级
            local needExp
            local addLevel = 0
            local totalExp = self:getTotalExp(player)

            for i = 1, maxLevel, 1 do
                needExp = PlayerLevelConfig:getNeedExp(level)
                if exp < needExp then
                    break
                end
                exp = exp - needExp
                addLevel = addLevel + 1
                level = level + 1

                --- 截取经验
                if level >= maxLevel then
                    exp = 0
                    break
                end
            end

            --- 设置经验
            growthComponent:setLevel(level)
            growthComponent:setExp(exp)

            Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, player, addLevel, self:getTotalExp(player) - totalExp)
            if addLevel ~= 0 then
                Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_LEVEL, player, addLevel)
            end

            if not World.isClient and addLevel > 0 then
                local entityCfg = player:cfg()
                if entityCfg.levelUpEffect and entityCfg.levelUpEffect ~= "" then
                    local oneBuffTime = entityCfg.levelUpEffectTime or 20
                    player:addBuff(entityCfg.levelUpEffect, oneBuffTime)
                    local delayTime = 0
                    for i = 2, addLevel do
                        delayTime = delayTime + 10
                        World.Timer(delayTime, function()
                            if player and player:isValid() then
                                player:addBuff(entityCfg.levelUpEffect, oneBuffTime)
                            end
                            return false
                        end)
                    end
                end
                player:checkUpdateTaskData(Define.TargetConditionKey.LEVEL)
            end

            return true, level, exp, addLevel
        end
    end
    return false, 1, 0, 0
end

--- 获取玩家属性点
---@param player any
function GrowthSystem:getAttributePoint(player)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        return growthComponent:getAttributePoint()
    end
    return 0
end

GrowthSystem:init()

return GrowthSystem