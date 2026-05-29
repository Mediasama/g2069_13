---@class PlayerDataHelper
local PlayerDataHelper = T(Lib, "PlayerDataHelper")
---@type BattleManagerServer
local BattleManagerServer = require "server.manager.battle_manager"
---@type PlayerDBMgr
local PlayerDBMgr = T(Lib, "PlayerDBMgr") 
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

--- 玩家登录
---@param player Entity
function PlayerDataHelper:onPlayerLogin(player)
    if self:clearData() then
        self:cleanPlayerData(player)
    end
    --- 注册时间
    local curTime = os.time()
    player:setRegisterTime(curTime)
    player:setLastLoginTime(curTime)
    player:addActiveDay(curTime)

    --- 等级数据
    local levelData = self:loadLevelData(player)
    --- 背包数据
    local inventoryData = self:loadInventoryData(player)
    --- 装备中数据
    local equippedData = self:loadEquippedData(player)
    --- 属性数据
    local attributeData = self:loadAttributeData(player)
    --- 能力数据
    local abilityData = self:loadAbilityData(player)
    --- 交易数据
    local purchaseData = self:loadPurchaseData(player)

    --- 数据处理
    local bornMap = player:getBornMap()
    local curMap = player:getCurMap()
    if curMap and curMap == "map_born" then
        player:setCurMap(bornMap or "")
    end

    --- 加载皮肤数据
    self:loadSkinData(player)

    ------------------------------------------------
    player:sendPacket({
        pid = "S2CSyncRoleData",
        levelData = levelData,
        attributeData = attributeData,
        inventoryData = inventoryData,
        equippedData = equippedData,
        abilityData = abilityData,
        purchaseData = purchaseData,
        bornMap = bornMap,
    })
    
    --- 触发被动能力
    BattleManagerServer:instance():initAbility(player)

    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA,player)
end

--- 玩家登出
---@param player Entity
function PlayerDataHelper:onPlayerLogout(player)
    local curTime = os.time()
    player:setLastLogoutTime(curTime)
    local lastLoginTime = player:getLastLoginTime()
    if lastLoginTime == 0 then
        lastLoginTime = player:getRegisterTime()
    end
    local addPlayTime = math.max(curTime - lastLoginTime, 0)
    if addPlayTime > 0 then
        player:addTotalPlayTime(addPlayTime)
    end
end

--- 清除数据
---@param player any
function PlayerDataHelper:cleanPlayerData(player)
    player:setBornMap("")
    player:setCurMap("")
    player:setLevelData({})
    player:setInventoryData({})
    player:setAbilityData({})
    player:setAttributeData({})
    player:setEquippedData({})
    player:cleanTaskData()
    player:setDialogRecord({})
    player:setFirstPurchaseData({})
    player:setCombinedGiftData({})
    player:setDailyCoin({})
    player:setDailyExp({})
    player:setDangerValue(0)
    player:setDayKilledOther({})
    player:setPurchaseData({})
    player:setCurrency(Define.ITEM_ALIAS.GOLD_COIN, 0)
    player:setDialogDrawTime({})
    player:setDialogDrawCounts({})
    player:setValue("regTime", 0)
    player:setLastLoginTime(0)
    player:setActiveDayData({})
    player:setLevelUpTime(0)
    player:setSwitchPointSetTime(0)
    player:setValue("tAbilityGainTime", {})
    player:setValue("tAbilityGainCount", {})
    player:setLastLogoutTime(0)

    player:setFirstHitMonster(0)
    player:setFirstHitEntity(0)
    player:setFirstBeHitEntity(0)
    player:setBookRewardState({})
end

--- 加载数据
---@param player any
function PlayerDataHelper:loadLevelData(player)
    --- 等级数据
    local levelData = player:getLevelData()
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        growthComponent:deserialize(levelData)
    end
    return levelData
end

--- 加载背包数据
---@param player any
function PlayerDataHelper:loadInventoryData(player)
    --- 背包数据
    local inventoryData = player:getInventoryData()
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        inventoryComponent:deserialize(inventoryData)
        local save = false
        --- 判断背包是否创建
        for _, type in pairs(Define.INVENTORY_TYPE) do
            if not inventoryComponent:getInventory(type) then
                save = true
                inventoryComponent:createInventory(type, Define.INVENTORY_INIT_CAPACITY[type])
            end
        end
        --- 获取背包物品
        if not InventorySystem:getItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, Define.ITEM_ALIAS.DEFAULT_ABILITY) then
            local success, items = InventorySystem:addItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, Define.ITEM_ALIAS.DEFAULT_ABILITY, 1)
            --- 设置永久能力
            ---@type Ability
            local ability = items[1].item
            ability:setUnlimited(1)
            ability:setInspected(1)
            ability:setUnlimitedInspected(1)
            save = true
        end

        local defaultAbilities = World.cfg.defaultAbilities
        if defaultAbilities then
            for _, item_alias in pairs(defaultAbilities) do
                if not InventorySystem:getItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, item_alias) then
                    InventorySystem:addItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, item_alias, 1)
                    save = true
                end
            end
        end

        --- 保存数据
        if save then
            self:saveInventoryData(player, true)
            inventoryData = player:getInventoryData()
        end
    end
    return inventoryData
end

--- 加载装备中数据
---@param player any
function PlayerDataHelper:loadEquippedData(player)
    --- 装备中数据
    local equippedData = player:getEquippedData()
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("equipment")
    if equipmentComponent then
        equipmentComponent:deserialize(equippedData)
    end
    return equippedData
end

--- 加载属性方案数据
---@param player any
function PlayerDataHelper:loadAttributeData(player)
     --- 属性数据
     local attributeData = player:getAttributeData()
     --- 反序列化数据
     
     ---@type AttributeComponent
     local attributeComponent = player:getComponent("attribute")
     if attributeComponent then
         attributeComponent:deserialize(attributeData)
     end

     return attributeData
end

--- 加载能力数据
---@param player any
function PlayerDataHelper:loadAbilityData(player)
    --- 属性数据
    local abilityData = player:getAbilityData()
    --- 反序列化数据
    
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        abilityComponent:deserialize(abilityData)
        ---@type Ability
        local ability = abilityComponent:getAbility()
        if not ability then
            local save = false
            --- 获取默认能力
            ability = InventorySystem:getItemByItemAlias(player, Define.INVENTORY_TYPE.ABILITY, Define.ITEM_ALIAS.DEFAULT_ABILITY)
            if ability then
                save = true
                abilityComponent:setAbility(ability)
            end
            if save then
                self:saveAbilityData(player, true)
                abilityData = player:getAbilityData()
            end
        end
    end

    return abilityData
end

--- 加载数据
---@param player any
function PlayerDataHelper:loadPurchaseData(player)
    local purchaseData = player:getPurchaseData()
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        businessComponent:deserialize(purchaseData)
    end
    return purchaseData
end

--- 加载皮肤数据
---@param player any
function PlayerDataHelper:loadSkinData(player)
    ---@type SkinComponentServer
    local skinComponent = player:getComponent("skin")
    if skinComponent then
        skinComponent:changeGameSkin()
    end
end

--- 保存等级数据
---@param player any
function PlayerDataHelper:saveLevelData(player, saveImmediate)
    ---@type GrowthComponent
    local growthComponent = player:getComponent("growth")
    if growthComponent then
        local data = growthComponent:serialize()
        player:setLevelData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 保存属性数据
---@param player any
function PlayerDataHelper:saveAttributeData(player, saveImmediate)
    ---@type AttributeComponent
    local attributeComponent = player:getComponent("attribute")
    if attributeComponent then
        local data = attributeComponent:serialize()
        player:setAttributeData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 保存背包数据
---@param player any
function PlayerDataHelper:saveInventoryData(player, saveImmediate)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        local data = inventoryComponent:serialize()
        player:setInventoryData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 保存装备数据
---@param player any
function PlayerDataHelper:saveEquippedData(player, saveImmediate)
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("inventory")
    if equipmentComponent then
        local data = equipmentComponent:serialize()
        player:setEquippedData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 保存能力数据
---@param player any
---@param saveImmediate any
function PlayerDataHelper:saveAbilityData(player, saveImmediate)
    ---@type AbilityComponent
    local abilityComponent = player:getComponent("ability")
    if abilityComponent then
        local data = abilityComponent:serialize()
        player:setAbilityData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 购买数据
---@param player any
---@param saveImmediate any
function PlayerDataHelper:savePurchaseData(player, saveImmediate)
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        local data = businessComponent:serialize()
        player:setPurchaseData(data)
        if saveImmediate then
            PlayerDBMgr.SaveImmediate(player)
        end
    end
end

--- 立刻保存玩家数据
---@param player any
function PlayerDataHelper:saveDataImmediate(player)
    PlayerDBMgr.SaveImmediate(player)
end

--- 是否清除数据
function PlayerDataHelper:clearData()
    if World.cfg.localDebug and World.cfg.clearData then
        return true
    end
    return false
end

return PlayerDataHelper