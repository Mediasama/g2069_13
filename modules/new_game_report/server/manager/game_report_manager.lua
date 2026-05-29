---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"

---@type ShopConfig
local ShopConfig = T(Config, "ShopConfig")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

---@class GameReportManagerServer : singleton
local GameReportManagerServer = class("GameReportManagerServer")
GameReportManagerServer:include(singleton)

function GameReportManagerServer:initialize()
    self.isInited = false
    self.events = {}
end

function GameReportManagerServer:init()
    if self.isInited then
        return
    end
    self.isInited = true

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, function(player, ability, addLevel)
        self:reportAbilityLevelUp(player, ability, addLevel)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_BUSINESS_SHOP_BUY, function(player, shopId, success)
        if not success then
            return
        end
        self:reportShopBuyItem(player, shopId)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_POINT, function(success, player, index, id, level)
        if not success then
            return
        end
        self:reportAddPoint(player, id)
    end)
    
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_RESET_POINT_SET, function(success, player, levelIndex)
        if not success then
            return
        end
		self:reportResetPointSet(player)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_INDEX, function(success, player, index, preIndex)
        if not success then
            return
        end
		self:reportSwitchPointSet(player, index, preIndex)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_UNLOCK, function(success, player, unlockIndex, preIndex)
		if not success then
            return
        end
		self:reportSwitchPointSet(player, unlockIndex, preIndex, true)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_SET_BORN_MAP, function(player, mapName)
		self:reportSelectBornMap(player, mapName)
	end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_DROP_ABILITY, function(success, player, ability)
        if not success then
            return
        end
		self:reportDropAbility(player, ability)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, function(player, item, addAmount)
        if addAmount == 0 then
            return
        end
        if addAmount > 0 and item:getItemType() == Define.ITEM_TYPE.ABILITY then
            player:addAbilityGainCount(item:getItemId(), addAmount)
            player:addAbilityGainTime(item:getId())
        end
        self:reportItemChange(player, item, addAmount)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, function(player, item, addAmount)
        if addAmount == 0 then
            return
        end
        if addAmount > 0 and item:getItemType() == Define.ITEM_TYPE.ABILITY then
            player:addAbilityGainCount(item:getItemId(), addAmount)
            player:addAbilityGainTime(item:getId())
        end
        self:reportItemChange(player, item, addAmount)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_COIN_CHANGE_COIN_NUM, function(player, coinName, changeNum)
        if changeNum == 0 then
            return
        end
        self:reportCoinChange(player, coinName, changeNum)
	end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
        if addExp <= 0 then
            return
        end
        self:reportRoleExpChange(player, addExp)
        if addLevel ~= 0 then
            self:reportRoleLevelUp(player)
        end
	end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_EXP, function(player, ability, addLevel, addExp)
        if addExp <= 0 then
            return
        end
        self:reportAbilityExpChange(player, addExp)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
        if not success then
            return
        end
        self:reportChangeAbility(player, oldAbility, ability)
	end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_GO_TO_MAP, function(player, mapName)
        if not player.isPlayer then
            return
        end
        self:reportGotoMap(player, mapName)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_ROOM_OPEN, function(room, player)
        self:reportMissionRoomOpen(room, player)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_ROOM_WAIT_PLAYER_END, function(room, player, waitTime)
        self:reportMissionRoomWaitPlayerEnd(room, player, waitTime)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_ROOM_COMPLETE, function(room, player, gameTime, completeCode)
        self:reportMissionRoomComplete(room, player, gameTime, completeCode)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_ROOM_PLAYER_DEAD, function(room, player)
        self:reportMissionRoomPlayerDead(room, player)
	end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_AWAKE, function(success, player, ability)
        if not success then
            return
        end
        self:reportAbilityAwake(player, ability)
	end)
end

--- 能力觉醒
---@param player Entity
---@param ability Ability
function GameReportManagerServer:reportAbilityAwake(player, ability)
    local data = {}
    data.awake_ability_id_alias = ability:getItemAlias()
    data.awake_level = ability:getAwake()
    Plugins.CallTargetPluginFunc("report", "report", "awake_report", data, player)
end

--- 副本开启
---@param room MissionRoom
---@param player Entity
function GameReportManagerServer:reportMissionRoomOpen(room, player)
    local openCount = 0
    local missionCountInfo = player:getMissionCountInfo()
    if missionCountInfo then
        for _, val in pairs(World.cfg.game_missionSetting.missionCounts) do
            local leftCount = missionCountInfo[val.missionGroup] or val.missionNum
            openCount = openCount + (val.missionNum - leftCount)
        end
    end

    local data = {}
    data.mission_room_id = room:getId()
    data.mission_alias = room:getMissionAlias()
    if room:getMissionPlayMode() == Define.MISSION_PLAY_MODE.SINGLE then
        data.mission_invited_player = -1
    else
        data.mission_invited_player = room:getMultiplePlayerCount() - 1
    end
    data.mission_open_count_today = openCount

    Plugins.CallTargetPluginFunc("report", "report", "awake_mission_open_report", data, player)
end

--- 副本结束等待玩家
---@param room MissionRoom
---@param player Entity
---@param waitTime number
function GameReportManagerServer:reportMissionRoomWaitPlayerEnd(room, player, waitTime)
    local data = {}
    data.mission_room_id = room:getId()
    data.mission_alias = room:getMissionAlias()
    data.mission_enter_player = room:getEnterPlayerCount()
    if room:getMissionPlayMode() == Define.MISSION_PLAY_MODE.SINGLE then
        data.mission_invited_player = -1
        data.mission_is_player_full = 1
    else
        data.mission_invited_player = room:getMultiplePlayerCount() - 1
        if data.mission_enter_player == data.mission_invited_player + 1 then
            data.mission_is_player_full = 1
        else
            data.mission_is_player_full = 0
        end
    end
    if room:getOwnerUserId() == player.platformUserId then
        data.mission_is_opener = 1
    else
        data.mission_is_opener = 0
    end
    data.mission_wait_time = waitTime

    Plugins.CallTargetPluginFunc("report", "report", "awake_mission_start_report", data, player)
end

--- 副本完成
---@param room MissionRoom
---@param player Entity
---@param gameTime number
---@param completeCode number
function GameReportManagerServer:reportMissionRoomComplete(room, player, gameTime, completeCode)
    local stage = room:getCurrentStage()
    local data = {}
    data.mission_room_id = room:getId()
    data.mission_alias = room:getMissionAlias()
    data.mission_finish_player = room:getPlayerCount(true)
    data.mission_end_stage = stage and stage:getStageId() or 0
    if completeCode == Define.MISSION_COMPLETE_CODE.SUCCESS then
        data.mission_end_reason = "finish"
    elseif completeCode == Define.MISSION_COMPLETE_CODE.GAME_TIME_OUT then
        data.mission_end_reason = "timeout"
    elseif completeCode == Define.MISSION_COMPLETE_CODE.NO_PLAYER then
        data.mission_end_reason = "noone"
    elseif completeCode == Define.MISSION_COMPLETE_CODE.ALL_PLAYER_DEAD then
        data.mission_end_reason = "fail"
    else
        data.mission_end_reason = "stagefail"
    end
    data.mission_end_time = gameTime

    Plugins.CallTargetPluginFunc("report", "report", "awake_mission_end_report", data, player)

end

--- 玩家副本死亡
---@param room MissionRoom
---@param player Entity
function GameReportManagerServer:reportMissionRoomPlayerDead(room, player)
    local stage = room:getCurrentStage()
    local data = {}
    data.mission_room_id = room:getId()
    data.mission_alias = room:getMissionAlias()
    data.mission_enter_player = room:getEnterPlayerCount()
    if room:getMissionPlayMode() == Define.MISSION_PLAY_MODE.SINGLE then
        data.mission_invited_player = -1
    else
        data.mission_invited_player = room:getMultiplePlayerCount() - 1
    end
    if room:getOwnerUserId() == player.platformUserId then
        data.mission_is_opener = 1
    else
        data.mission_is_opener = 0
    end
    data.mission_undead_player = room:getPlayerCount(true)
    data.mission_die_stage = stage and stage:getStageId() or 0

    Plugins.CallTargetPluginFunc("report", "report", "awake_mission_die_report", data, player)
end


--- 切换地图
---@param player Entity
function GameReportManagerServer:reportGotoMap(player, mapName)
    local data = {}
    Plugins.CallTargetPluginFunc("report", "report", "g2069_enter_map", data, player)
end

--- 角色升级埋点
---@param player Entity
function GameReportManagerServer:reportRoleLevelUp(player)
    ---@type Ability
    local ability = AbilitySystem:getAbility(player)
    local data = {}
    data.ability_id = ability and ability:getItemAlias() or Define.ITEM_ALIAS.DEFAULT_ABILITY
    data.player_level = GrowthSystem:getLevel(player)
    --- 花费时间
    local curTime = os.time()
    local levelUpTime = player:getLevelUpTime()
    player:setLevelUpTime(curTime)
    if not levelUpTime or levelUpTime == 0 then
        levelUpTime = player:getRegisterTime() or curTime
    end
    data.level_up_spent = math.ceil((curTime - levelUpTime) / 60)
    Plugins.CallTargetPluginFunc("report", "report", "player_levelup", data, player)
end

--- 切换能力
---@param player any
---@param preAbility Ability
---@param ability Ability
function GameReportManagerServer:reportChangeAbility(player, oldAbility, ability)
    local data = {}
    data.previous_ability_alias = oldAbility:getItemAlias()
    data.switch_ability_alias = ability:getItemAlias()
    Plugins.CallTargetPluginFunc("report", "report", "g2069_ability_change", data, player)
end

--- 能力经验
---@param player any
---@param coinName any
---@param changeNum any
function GameReportManagerServer:reportAbilityExpChange(player, addExp)
    local source = InventorySystem.MODIFY_SOURCE
    --- 没有标记的源头不处理
    if not source then
        Lib.logWarning("Error:Not found the modify source when item change.")
        return
    end
    local data = {}
    data.item_id_alias = Define.ITEM_ALIAS.ABILITY_EXP
    data.item_type_s = Define.ITEM_TYPE.ABILITY_EXP
    data.item_sub_type_s = ItemConfig:getCfgByItemAlias(Define.ITEM_ALIAS.ABILITY_EXP).sub_type_alias
    data.change_type_s = "obtain"
    data.change_method = source
    data.change_number = addExp
    data.obtain_ability_level = 0
    data.ability_total_count = 0

    Plugins.CallTargetPluginFunc("report", "report", "g2069_item_change", data, player)
end

--- 角色经验
---@param player any
---@param coinName any
---@param changeNum any
function GameReportManagerServer:reportRoleExpChange(player, addExp)
    local source = InventorySystem.MODIFY_SOURCE
    --- 没有标记的源头不处理
    if not source then
        Lib.logWarning("Error:Not found the modify source when item change.")
        return
    end
    local data = {}
    data.item_id_alias = Define.ITEM_ALIAS.ROLE_EXP
    data.item_type_s = Define.ITEM_TYPE.ROLE_EXP
    data.item_sub_type_s = ItemConfig:getCfgByItemAlias(Define.ITEM_ALIAS.ROLE_EXP).sub_type_alias
    data.change_type_s = "obtain"
    data.change_method = source
    data.change_number = addExp
    data.obtain_ability_level = 0
    data.ability_total_count = 0

    Plugins.CallTargetPluginFunc("report", "report", "g2069_item_change", data, player)
end

--- 货币更改
---@param player any
---@param coinName any
---@param changeNum any
function GameReportManagerServer:reportCoinChange(player, coinName, changeNum)
    local source = InventorySystem.MODIFY_SOURCE
    --- 没有标记的源头不处理
    if not source then
        Lib.logWarning("Error:Not found the modify source when item change.")
        return
    end
    local data = {}
    data.item_id_alias = coinName
    data.item_type_s = Define.ITEM_TYPE.CURRENCY
    data.change_type_s = changeNum > 0 and "obtain" or "consume"
    data.item_sub_type_s = ItemConfig:getCfgByItemAlias(coinName).sub_type_alias
    data.change_method = source
    data.change_number = math.abs(changeNum)
    data.obtain_ability_level = 0
    data.ability_total_count = 0

    Plugins.CallTargetPluginFunc("report", "report", "g2069_item_change", data, player)
end

--- 物品改变
---@param player Entity
---@param item Item
---@param changeNum any
function GameReportManagerServer:reportItemChange(player, item, changeNum)
    local source = InventorySystem.MODIFY_SOURCE
    --- 没有标记的源头不处理
    if not source then
        Lib.logWarning("Error:Not found the modify source when item change.")
        return
    end
    local alias = item:getItemAlias()
    local type = item:getItemType()
    local subType = item:getItemSubType()

    local data = {}
    data.item_id_alias = alias
    data.item_type_s = type
    data.change_type_s = changeNum > 0 and "obtain" or "consume"
    data.item_sub_type_s = subType
    data.change_method = source
    data.change_number = math.abs(changeNum)
    if type == Define.ITEM_TYPE.ABILITY then
        -- 获取能力等级与获取数量
        data.obtain_ability_level = item:getLevel()
        data.ability_total_count = player:getAbilityGainCount(item:getItemId())
    else
        data.obtain_ability_level = 0
        data.ability_total_count = 0
    end

    Plugins.CallTargetPluginFunc("report", "report", "g2069_item_change", data, player)
end

--- 丢弃能力
---@param player Entity
---@param ability Ability
function GameReportManagerServer:reportDropAbility(player, ability)
    if not ability then
        return
    end

    local alias = ability:getItemAlias()
    local itemId = ability:getItemId()
    local level = ability:getLevel()
    local id = ability:getId()

    local gainCount = player:getAbilityGainCount(itemId)

    local data = {}
    data.drop_ability_id_alias = alias
    data.drop_ability_level = level
    local gainTime = player:getAbilityGainTime(id)
    if not gainTime or gainTime == 0 then
        gainTime = ability:getTime()
    end
    data.holding_time = os.time() - gainTime
    data.ability_total_count = gainCount
    data.quantity_after_discard = InventorySystem:getItemAmountByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, alias)

    Plugins.CallTargetPluginFunc("report", "report", "g2069_ability_discard", data, player)
end

--- 选择初始地图
---@param player any
---@param mapName any
function GameReportManagerServer:reportSelectBornMap(player, mapName)
    local data = {}
    data.map_name = mapName
    Plugins.CallTargetPluginFunc("report", "report", "g2069_birthplace_selection", data, player)
end

--- 解析属性
---@param attributeData AttributeData
---@param index number
---@param attrType number
local parseAttributes = function(attributeData, index, attrType)
    local str = nil
    local attributes = AttributeInfoConfig:getAttributesByType(attrType)
    if attributes then
        for _, config in pairs(attributes) do
            local attrId = config.attr_id
            local level = attributeData:getLevelByIndex(attrId, index) or 1
            if not str then
                str = attrId .. "=" .. tostring(level - 1)
            else
                str = str .. "," .. (attrId .. "=" .. tostring(level - 1))
            end
        end
    end
    return str or ""
end

--- 切换属性方案
---@param player Entity
---@param index any
---@param preIndex any
---@param unlock any
function GameReportManagerServer:reportSwitchPointSet(player, index, preIndex, unlock)
    ---@type AttributeData
    local attributeData = AttributeSystem:getAttributeData(player)
    if not attributeData then
        return
    end
    local data = {}
    if unlock then
        data.operation_type = "activate"
    else
        data.operation_type = "switch"
    end
    data.existing_solution_count = attributeData.uidx
    data.previous_solution = preIndex
    data.previous_solution_attributes = parseAttributes(attributeData, preIndex, 2)
    local lastSwitchPointSetTime = player:getSwitchPointSetTime()
    if lastSwitchPointSetTime == 0 then
        lastSwitchPointSetTime = player:getRegisterTime()
    end
    local curTime = os.time()
    player:setSwitchPointSetTime(curTime)
    data.duration_time = curTime - lastSwitchPointSetTime
    data.after_solution = index
    data.after_solution_attributes = parseAttributes(attributeData, index, 2)

    Plugins.CallTargetPluginFunc("report", "report", "g2069_points_solution_operation", data, player)
end

--- 加点
---@param player any
---@param id any
function GameReportManagerServer:reportAddPoint(player, id)
    local data = {}
    data.points_operation_type = "allocate"
    data.upgrade_attribute = id
    Plugins.CallTargetPluginFunc("report", "report", "g2069_role_attributes_points_operation", data, player)
end

--- 重置属性方案
---@param player any
function GameReportManagerServer:reportResetPointSet(player)
    local data = {}
    data.points_operation_type = "refund"
    data.upgrade_attribute = ""
    Plugins.CallTargetPluginFunc("report", "report", "g2069_role_attributes_points_operation", data, player)
end

--- 能力升级
---@param player any
---@param ability Ability
---@param addLevel any
function GameReportManagerServer:reportAbilityLevelUp(player, ability, addLevel)
    local data = {}
    data.ability_id_alias = ability:getItemAlias()
    data.level_after_upgrad = ability:getLevel()
    data.time_spent = os.time() - ability:getTime()
    Plugins.CallTargetPluginFunc("report", "report", "g2069_ability_level_up", data, player)
end

--- 商店购买
---@param player any
---@param shopId any
function GameReportManagerServer:reportShopBuyItem(player, shopId)
    local config = ShopConfig:getCfgByShopId(shopId)
    local cost = config.cost
    local data = {}
    data.shop_id_alias = config.shop_alias
    data.shop_method = "shop"
    data.purchase_currency = cost.item_alias
    data.amount_spent = cost.item_num
    
    Plugins.CallTargetPluginFunc("report", "report", "g2069_commodity_change", data, player)
end

--- 幸运转盘
---@param player any
---@param activityId any
function GameReportManagerServer:reportPlayLimitedTimeGoldWheel(player, activityId)
    Plugins.CallTargetPluginFunc("report", "report", "g2069_wheel", {}, player)
end

return GameReportManagerServer