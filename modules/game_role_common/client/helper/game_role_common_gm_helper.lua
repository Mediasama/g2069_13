---@class GameRoleCommonGMHelperClient
local GameRoleCommonGMHelperClient = T(Lib, "GameRoleCommonGMHelperClient")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")

--- 添加物品
---@param player Entity
---@param itemAlias any
---@param itemNum any
function GameRoleCommonGMHelperClient:addItem(player, itemAlias, itemNum)
    if not World.cfg.openGM then
        return
    end
    player:sendPacket({
        pid = "C2SGMGameRoleCommon",
        command = Define.GAME_ROLE_COMMON_GM_COMMAND.ADD_ITEM,
        item_alias = itemAlias,
        item_num = itemNum,
    })
end

--- 设置等级
---@param player any
---@param level any
function GameRoleCommonGMHelperClient:setLevel(player, level)
    if not World.cfg.openGM then
        return
    end
    player:sendPacket({
        pid = "C2SGMGameRoleCommon",
        command = Define.GAME_ROLE_COMMON_GM_COMMAND.SET_LEVEL,
        level = level
    })
end

--- 设置能力等级
---@param player any
---@param level any
function GameRoleCommonGMHelperClient:setAbilityLevel(player, level)
    if not World.cfg.openGM then
        return
    end
    player:sendPacket({
        pid = "C2SGMGameRoleCommon",
        command = Define.GAME_ROLE_COMMON_GM_COMMAND.SET_ABILITY_LEVEL,
        level = level
    })
end

--- 设置能力觉醒
---@param player any
---@param awake any
function GameRoleCommonGMHelperClient:setAbilityAwake(player, awake)
    if not World.cfg.openGM then
        return
    end
    ---@type Ability
    local ability = AbilitySystem:getAbility(player)
    if not ability or not AbilityAwakeConfig:canAwake(ability:getItemId()) then
        return
    end

    local maxAwake = AbilityAwakeConfig:getMaxAwake(ability:getItemId())
    if awake > maxAwake or awake == ability:getAwake() then
        return
    end
    player:sendPacket({
        pid = "C2SGMGameRoleCommon",
        command = Define.GAME_ROLE_COMMON_GM_COMMAND.SET_ABILITY_AWAKE,
        awake = awake,
    },
    function(stateCode)
        if stateCode and stateCode == 0 then
            AbilitySystem:setAbilityAwake(player, ability:getId(), awake)
            AbilitySystem:setAbilitySkin(player, ability:getAwakeAbilityId())
            Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_AWAKE, true, player, ability)
        end
    end)
end