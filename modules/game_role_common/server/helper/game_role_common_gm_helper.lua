---@class GameRoleCommonGMHelperServer
local GameRoleCommonGMHelperServer = T(Lib, "GameRoleCommonGMHelperServer")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type PlayerDataHelper
local PlayerDataHelper = T(Lib, "PlayerDataHelper")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")
---@type PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")

---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")



--- gm处理
---@param player Entity
---@param packet any
function GameRoleCommonGMHelperServer:onCommandHandle(player, packet)
    if not World.openGM then
        return
    end

    local stateCode = 0

    local command = packet.command
    if command == Define.GAME_ROLE_COMMON_GM_COMMAND.ADD_ITEM then
        local config
        local item_id = packet.item_id
        local item_num = packet.item_num
        local item_alias = packet.item_alias
        if item_id then
            config = ItemConfig:getCfgByItemId(item_id)
            if config then
                item_alias = config.item_alias
            end
        else
            config = ItemConfig:getCfgByItemAlias(item_alias)
        end
        if not config then
            return
        end
        local inventoryType = Define.ITEM_INVENTORY_TYPE[ItemConfig:getCfgByItemAlias(item_alias).type_alias]
        local success, items = InventorySystem:addItemByItemAlias(player, inventoryType, item_alias, item_num)
        if success and items and #items > 0 then

            PlayerDataHelper:saveInventoryData(player, true)

            ---@type Item
            local item = items[1].item
            local index = items[1].index
            local amount = items[1].amount

            player:sendPacket({
                pid = "S2CUpdateInventorySingle",
                inv_type = inventoryType,
                item = item:serialize(),
                slot_idx = index,
                amount = amount,
            })
        end
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.ADD_EXP then
        local exp = packet.exp
        local success, level, exp = GrowthSystem:addExp(player, exp)
        if success then
            PlayerDataHelper:saveLevelData(player, true)

            player:sendPacket({
                pid = "S2CUpdateLevelData",
                exp = exp,
                level = level,
            })
        end
        
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.ADD_ABILITY_EXP then
        ---@type Entity
        local exp = packet.exp
        local success, ability = AbilitySystem:addAbilityExp(player, exp)
        if success then
            PlayerDataHelper:saveInventoryData(player, true)

            player:sendPacket({
                pid = "S2CUpdateAbilityLevelData",
                id = ability:getId(),
                level = ability:getLevel(),
                exp = ability:getExp(),
            })
        end
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SET_INVINCIBLE then
        local enable = packet.enable
        player:setInvincible(enable)
        if enable then
            Lib.logWarning("Warning:Player invincible is enabled, player:", player.objID)
        end    
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.RESET_LEVEL then
        GrowthSystem:setLevelData(player, 1, 0)
        PlayerDataHelper:saveLevelData(player, true)
   
        player:sendPacket({
            pid = "S2CUpdateLevelData",
            level = 1,
            exp = 0
        })
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SHOW_DAMAGE_CALC then
        local enable = packet.enable
        BattleSystem.showCalc = enable
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SET_LEVEL then
        local level = packet.level
        local curLevel = GrowthSystem:getLevel(player)
        if curLevel >= level or level > PlayerLevelConfig:getMaxLevel() then
            return
        end
        local totalExp = 0
        for i = curLevel, level - 1, 1 do
            local needExp = PlayerLevelConfig:getNeedExp(i)
            totalExp = totalExp + needExp
        end
        GrowthSystem:addExp(player, totalExp)
        --- 同步经验数据
        PlayerDataHelper:saveLevelData(player, true)

        player:sendPacket({
            pid = "S2CUpdateLevelData",
            exp = GrowthSystem:getExp(player),
            level = GrowthSystem:getLevel(player),
        })
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SET_ABILITY_LEVEL then
        local level = packet.level
        ---@type Ability
        local ability = AbilitySystem:getAbility(player)
        local curLevel = ability:getLevel()
        if curLevel >= level then
            return
        end
        local maxLevel = AbilityConfig:getMaxLevel(ability:getItemId())
        maxLevel = math.min(maxLevel, level)
        local addExp = 0
        for i = curLevel, maxLevel - 1, 1 do
            local needExp = AbilityLevelConfig:getCfgByLevel(i).upgradePrice
            addExp = addExp + needExp
        end

        addExp = addExp - ability:getExp()

        if addExp > 0 then
            if AbilitySystem:addAbilityExp(player, addExp) then
                --- 同步经验数据
                PlayerDataHelper:saveInventoryData(player, true)

                player:sendPacket({
                    pid = "S2CUpdateAbilityLevelData",
                    id = ability:getId(),
                    level = ability:getLevel(),
                    exp = ability:getExp(),
                })
            end
        end
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.CLEAR_DATA then
        PlayerDataHelper:cleanPlayerData(player)
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.ADD_BUFF then
        local buffId = packet.buffId
        local buff = SkillBuffConfig:getCfgByBuffId(buffId)
        if not buff then
            return
        end
        player:addBuff(buff.buffName, buff.duration, player)
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.GO_TO_MAP then
        local mapName = packet.map
        local config = PlayerBornConfig:getCfgByMapName(mapName)
        if not config then
            return
        end
        ---@type MapManagerServer
        local MapManagerServer = require "server.manager.game_map_manager"
        MapManagerServer:instance():gotoMap(player, mapName)
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SET_DANGER_VALUE then
        player:setDangerValue(packet.exp, true)
        player:setIsResetDanger(false)
    elseif command == Define.GAME_ROLE_COMMON_GM_COMMAND.SET_ABILITY_AWAKE then
        local awake = packet.awake or 0
        ---@type Ability
        local ability = AbilitySystem:getAbility(player)
        if not ability or not AbilityAwakeConfig:canAwake(ability:getItemId()) then
            return
        end
        local maxAwake = AbilityAwakeConfig:getMaxAwake(ability:getItemId())
        if awake > maxAwake or awake == ability:getAwake() then
            return
        end
        --- 设置觉醒等级
        AbilitySystem:setAbilityAwake(player, ability:getId(), awake)
        --- 保存数据
        PlayerDataHelper:saveInventoryData(player)
        PlayerDataHelper:saveAbilityData(player, true)
    end

    return stateCode
end