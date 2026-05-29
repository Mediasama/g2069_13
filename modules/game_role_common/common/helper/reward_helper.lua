---@type TaskConfig
local TaskConfig = T(Config, "TaskConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type WalletSystem
local WalletSystem = T(Lib, "WalletSystem")
---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")
---@type PlayerDataHelper
local PlayerDataHelper = T(Lib, "PlayerDataHelper")
---@type NpcDialogueReplyConfig
local NpcDialogueReplyConfig = T(Config, "NpcDialogueReplyConfig")
---@type RewardBoxPoolConfig
local RewardBoxPoolConfig = T(Config, "RewardBoxPoolConfig")
---@type RewardBoxConfig
local RewardBoxConfig = T(Config, "RewardBoxConfig")
---@type ShopConfig
local ShopConfig = T(Config, "ShopConfig")
---@type LimitedTimeActivityConfig
local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")
---@type LimitedTimeGiftItemConfig
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
---@class RewardHelper
local RewardHelper = T(Lib, "RewardHelper")

--- 击杀奖励
---@param player Entity
---@param monsterId number
---@param ratio number 奖励系数
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainKillRewards(player, monsterId, ratio)
    --- 击杀经验
    local config = MonsterConfig:getCfgByMonsterId(monsterId)
    local rewardRexp = config.rewardRexp
    local rewardGold = config.rewardGold
    local rewardAexp = config.rewardAexp
    --- 奖励
    local rewards = {}
    --- 添加货币
    local receiveGold = math.ceil(rewardGold * ratio)
    if receiveGold > 0 then
        rewards[#rewards + 1] = { item_alias = Define.ITEM_ALIAS.GOLD_COIN, item_num = receiveGold }
    end
    --- 角色经验
    local receiveRexp = math.ceil(rewardRexp * ratio)
    if receiveRexp > 0 then
        rewards[#rewards + 1] = { item_alias = Define.ITEM_ALIAS.ROLE_EXP, item_num = receiveRexp }
    end
    --- 能力经验
    local receiveAexp = math.ceil(rewardAexp * ratio)
    if receiveAexp > 0 then
        rewards[#rewards + 1] = { item_alias = Define.ITEM_ALIAS.ABILITY_EXP, item_num = receiveAexp }
    end
    self:rewardItems(player, Define.REWARD_TYPE.KILL, rewards, true, { monsterId = monsterId, ratio = ratio }, monsterId)
    return true, rewards
end

--- 领取任务奖励
---@param player Entity
---@param taskId number
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainTaskRewards(player, taskId)
    local config = TaskConfig:getCfgById(taskId)
    local rewards = config.rewards
    if not rewards or not next(rewards) then
        return false
    end
    self:rewardItems(player, Define.REWARD_TYPE.TASK, rewards, true, { taskId = taskId }, taskId)
    return true, rewards
end

--- 领取图鉴奖励
---@param player Entity
---@param taskId number
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainBookRewards(player, rewards, bookRewardId)
    if not rewards or not next(rewards) then
        return false
    end
    self:rewardItems(player, Define.REWARD_TYPE.BOOK, rewards, true, { bookRewardId = bookRewardId })
    return true, rewards
end

--- NPC对话奖励
---@param player Entity
---@param replyId number
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainNPCDialogRewards(player, replyId)
    local replyConfig = NpcDialogueReplyConfig:getCfgById(replyId)
    local rewards = replyConfig.rewards
    if not rewards or not next(rewards) then
        return false
    end
    self:rewardItems(player, Define.REWARD_TYPE.NPC, rewards, true, { replyId = replyId }, replyId)
    return true, rewards
end

--- NPC抽奖奖励
---@param player Entity
---@param rewards {item_alias, item_num}的数组
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainNPCLuckyDrawRewards(player, rewards)
    self:rewardItems(player, Define.REWARD_TYPE.NPC_LUCKY_DRAW, rewards, false, nil)
    return true, rewards
end

--- 获取宝箱奖励
---@param player Entity 
---@param itemAlias string 宝箱别称
---@return boolean 是否成功
---@return table 元素结构为{item_alias, item_num}的数组
function RewardHelper:gainTreasureBox(player, itemAlias)
    local config = ItemConfig:getCfgByItemAlias(itemAlias)
    local params = config.params
    local boxId = params and params["box_id"]
    if not boxId or boxId == 0 then
        Lib.logError("Error:Not found the box id in item.csv, item alias:", itemAlias)
        return false
    end
    local rewards = self:getRewardBoxItems(boxId)
    --- 收益处理
    local income_decay = params["income_decay"]
    if income_decay and income_decay > 0 then
        local itemId = config.item_id
        local count = player:getTreasureBoxData(itemId)
        player:addTreasureBoxData(itemId)
        local rate = math.max(10 - count, 0.1) / 10
        for _, data in pairs(rewards) do
            if data.item_alias == Define.ITEM_ALIAS.GOLD_COIN then
                local num = data.item_num
                data.item_num = math.ceil(num * rate)
            end
        end
    end

    --- 获取奖励
    self:rewardItems(player, Define.REWARD_TYPE.TREASURE_BOX, rewards, true, { itemId = config.item_id, rewards = rewards }, boxId)
    return true, rewards
end

--- 商业化
---@param player any
---@param items any
function RewardHelper:addLimitedActivityRewards(player, gift)
    if not gift then
        return
    end
    -- { 
        --     ["giftName"] = "general_gift_name300001",
        --     ["giftContent"] = {
        --       [1] = 200001,
        --       [2] = 200002,
        --       [3] = 200003,
        --       [4] = 200004
        --     },
        --     ["id"] = 3001,
        --     ["activityId"] = 300001,
        --     ["finalPrice"] = 80,
        --     ["initPrice"] = 100,
        --     ["price"] = 80,
        --     ["percent"] = "-50%",
        --     ["giftKey"] = "300001-3001"
        --   }

    local activityId = gift.activityId
    local giftId = gift.id
    local giftContent = gift.giftContent
    if giftContent and #giftContent > 0 then
        local rewards = {}
        for _, id in pairs(giftContent) do
            local giftConfig = LimitedTimeGiftItemConfig:getCfgById(id)
            local itemId = giftConfig.itemId
            local itemNum = giftConfig.itemCount
            local itemAlias = ItemConfig:getCfgByItemId(itemId).item_alias
            rewards[#rewards + 1] = { item_alias = itemAlias, item_num = itemNum }
        end

        local config = LimitedTimeActivityConfig:getCfgById(activityId)
        local activityType = config.type
        local rewardType = Define.REWARD_TYPE.LIMITED_TIME
        if activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL then
            rewardType = Define.REWARD_TYPE.GOLDEN_WHEEL
        elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
            rewardType = Define.REWARD_TYPE.COMBINATION_GIFT
        end
        self:rewardItems(player, rewardType, rewards, false, nil, activityId, giftId)
    end
end

--- 获取购买奖励
---@param player any
---@param shopId any
function RewardHelper:gainShopBuyRewards(player, shopId)
    local config = ShopConfig:getCfgByShopId(shopId)
    local item = config.item
    local isUse = config.is_use == 1
    local item_alias = item.item_alias
    local rewards = nil

    --- 判断是否立刻使用
    if isUse then
        local params = ItemConfig:getCfgByItemAlias(item_alias).params
        local boxId = params and params["box_id"]
        if boxId and boxId ~= 0 then
            rewards = self:getRewardBoxItems(boxId)
        else
            rewards = {}
            rewards[#rewards + 1] = item
        end
    else
        rewards = {}
        rewards[#rewards + 1] = item
    end
    --- 获取奖励
    self:rewardItems(player, Define.REWARD_TYPE.SHOP_BUY, rewards, false, nil, shopId)

    return true, rewards
end

--- 使用物品
---@param player Entity
---@param item Item
function RewardHelper:useItem(player, item)
    local itemType = item:getItemType()
    if itemType == Define.ITEM_TYPE.GIFT_PACK then
        local params = ItemConfig:getCfgByItemAlias(item:getItemAlias()).params
        local boxId = params["box_id"]
        local rewards = self:getRewardBoxItems(boxId)
        self:rewardItems(player, Define.REWARD_TYPE.USE_ITEM, rewards, false, nil, item:getItemAlias())
        return true, rewards
    end
end

--- 获取掉落物品
---@param player any
---@param itemId any
function RewardHelper:gainDropItem(player, itemId)
    local config = ItemConfig:getCfgByItemId(itemId)
    local rewards = {}
    rewards[#rewards + 1] = { item_alias = config.item_alias, item_num = 1 }
    --- 获取奖励
    self:rewardItems(player, Define.REWARD_TYPE.DROP_ITEM, rewards, true, { itemId = itemId })
    return true, rewards
end

--- 领取奖励
---@param player any
---@param itemAlias any
function RewardHelper:gainSubscribeVipAbility(player, itemAlias)
    local rewards = {}
    rewards[#rewards + 1] = { item_alias = itemAlias, item_num = 1 }
    --- 获取奖励
    self:rewardItems(player, Define.REWARD_TYPE.SUBSCRIBE_VIP, rewards)
    return true, rewards
end

--- 获取副本奖励
---@param player Entity
---@param missionId number
function RewardHelper:gainMissionRewards(player, missionId)
    local config = MissionInfoConfig:getCfgByMissionId(missionId)
    local rewards = Lib.copy(config.rewards)
    --- 获取奖励
    self:rewardItems(player, Define.REWARD_TYPE.MISSION_REWARD, rewards, true, { missionId = missionId }, missionId)
    return true, rewards
end

--- 获取宝箱奖励
---@param boxId any
---@return table 元素结构为{ item_alias, item_num }的数组
function RewardHelper:getRewardBoxItems(boxId)
    local config = RewardBoxConfig:getCfgByBoxId(boxId)
    local poolId = config.pool_id
    local rewardNum = config.reward_num
    local rewardNumMax = config.reward_num_max
    local rewardType = config.reward_type
    if rewardNumMax then
        rewardNum = math.random(rewardNum, rewardNumMax)
    end

    --- 奖池
    local pools = RewardBoxPoolConfig:getCfgByPoolId(poolId)
    --- 奖励
    local rewards = {}

    if rewardNum == 0 then
        --- 获取所有奖励
        for i = 1, #pools, 1 do
            local item = pools[i].item
            local amount = item.item_num
            if item.item_num_max then
                amount = math.random(amount, item.item_num_max)
            end
            rewards[#rewards + 1] = { item_alias = item.item_alias, item_num = amount }
        end
    else
        local totalWeight = 0
        local weights = {}
        for i = 1, #pools, 1 do
            local data = {}
            weights[#weights + 1] = data
            totalWeight = totalWeight + pools[i].weight
            data.weight = totalWeight
            data.index = i
        end

        --- 不重复
        for i = 1, rewardNum, 1 do
            local rand = math.random(1, totalWeight)
            for j = 1, #weights, 1 do
                if rand <= weights[j].weight then
                    local index = weights[j].index
                    local item = pools[index].item
                    local amount = item.item_num
                    if item.item_num_max then
                        amount = math.random(amount, item.item_num_max)
                    end
                    rewards[#rewards + 1] = { item_alias = item.item_alias, item_num = amount }
                    if rewardType == 1 then
                        --- 移除
                        table.remove(weights, j)
                    end
                    break
                end
            end
            if #weights <= 0 then
                break
            end
        end
    end

    return rewards
end

--- 获取奖励数量额外加成
---@param player Entity
---@param itemAlias string
---@param rewardType string Define.REWARD_TYPE
function RewardHelper:checkRewardRate(player, itemAlias, rewardType)
    if rewardType == Define.REWARD_TYPE.KILL
        or rewardType == Define.REWARD_TYPE.NPC
        or rewardType == Define.REWARD_TYPE.TREASURE_BOX
        or rewardType == Define.REWARD_TYPE.TASK
    then
        if itemAlias == Define.ITEM_ALIAS.GOLD_COIN then
            local rate = AttributeSystem:getAttributeValue(player, Define.ATTR.COIN_RATE)
            return rate
        elseif itemAlias == Define.ITEM_ALIAS.ROLE_EXP then
            local rate = AttributeSystem:getAttributeValue(player, Define.ATTR.EXP_RATE)
            return rate
        elseif itemAlias == Define.ITEM_ALIAS.ABILITY_EXP then
            local rate = AttributeSystem:getAttributeValue(player, Define.ATTR.AP_RATE)
            return rate
        end
    end
    return nil
end

--- 检测数量上限
---@param player Entity
---@param itemAlias any
---@param rewardType any
function RewardHelper:checkRewardLimit(player, itemAlias, itemNum, rewardType)
    if rewardType == Define.REWARD_TYPE.KILL
        or rewardType == Define.REWARD_TYPE.NPC
        or rewardType == Define.REWARD_TYPE.TREASURE_BOX
        or rewardType == Define.REWARD_TYPE.TASK
    then
        if itemAlias == Define.ITEM_ALIAS.GOLD_COIN then
            local limit = AttributeSystem:getAttributeValue(player, Define.ATTR.DAILY_COIN)
            if limit and limit > 0 then
                --- 获取每日剩余数量
                local dailyNum = player:getDailyCoin()
                if dailyNum >= limit then
                    return 0
                else
                    --- 取小的数字
                    itemNum = math.min(itemNum, limit - dailyNum)
                    return itemNum
                end
            end
        elseif itemAlias == Define.ITEM_ALIAS.ROLE_EXP then
            local limit = AttributeSystem:getAttributeValue(player, Define.ATTR.DAILY_EXP)
            if limit and limit > 0 then
                --- 获取每日剩余数量
                local dailyNum = player:getDailyExp()
                if dailyNum >= limit then
                    return 0
                else
                    --- 取小的数字
                    itemNum = math.min(itemNum, limit - dailyNum)
                    return itemNum
                end
            end
        end
    end
    return nil
end

--- 通用奖励
---@param player Entity 获奖者
---@param rewardType number 奖励类型，定义在Define.REWARD_TYPE
---@param rewards table 奖励物品，元素格式为{ item_alias, item_num }的数组
---@param needSyncPrompt boolean 客户端是否弹出提示
---@param params table 自定义参数，会将对应数据同步至客户端
---@param ... any 自定义参数
function RewardHelper:rewardItems(player, rewardType, rewards , needSyncPrompt, syncParams, ...)

    if Define.ITEM_REWARD_SOURCE[rewardType] then
        InventorySystem.MODIFY_SOURCE = Define.ITEM_REWARD_SOURCE[rewardType]
    end

    local packet = {
        pid = "S2CSyncRewards",
        type = rewardType,
        items = nil,
        prompt = needSyncPrompt and 1 or nil,
    }

    if syncParams then
        for k, v in pairs(syncParams) do
            if packet[k] then
                Lib.logWarning("Warning:Exist same key in S2CSyncRewards packet, key:", k)
            end
            packet[k] = v
        end
    end

    local items = nil
    local exp = nil
    local aexp = nil
    --- 限制物品，只做显示处理
    local limit = nil
    --- 修改数量，只做显示处理
    local item_nums = nil
    --- 激活能力
    local unlimited = nil
    ---@type Ability
    local ability = AbilitySystem:getAbility(player)

    for _, data in pairs(rewards) do
        local item_alias = data.item_alias 
        local item_num = data.item_num
        --- 额外加成
        local rate = self:checkRewardRate(player, item_alias, rewardType)
        if rate and rate > 1 then
            item_num = math.ceil(item_num * rate)
            item_nums = item_nums or {}
            item_nums[item_alias] = item_num
        end
        --- 是否限制数量
        local limit_num = self:checkRewardLimit(player, item_alias, item_num, rewardType)
        if limit_num then
            item_num = limit_num
            item_nums = item_nums or {}
            item_nums[item_alias] = item_num

            if item_num <= 0 then
                limit = limit or {}
                limit[item_alias] = 1
            else
                if item_alias == Define.ITEM_ALIAS.ROLE_EXP then
                    player:addDailyExp(item_num)
                elseif item_alias == Define.ITEM_ALIAS.GOLD_COIN then
                    player:addDailyCoin(item_num)
                end
            end
        end

        if item_num > 0 then
            local args = table.pack(self:addItemByItemAlias(player, item_alias, item_num, rewardType, ...))
            local success = args[1]
            if success then
                --- 依据判断
                local config = ItemConfig:getCfgByItemAlias(item_alias)
                local type_alias = config.type_alias
                if type_alias == Define.ITEM_TYPE.CURRENCY then
                    
                elseif type_alias == Define.ITEM_TYPE.ROLE_EXP then
                    exp = (exp or 0) + item_num
                elseif type_alias == Define.ITEM_TYPE.ABILITY_EXP then
                    aexp = (aexp or 0) + item_num
                else
                    local itemList = args[2]
                    for _, itemData in pairs(itemList) do
                        ---@type Item, number, number
                        local item, slotIndex, amount = itemData.item, itemData.index, itemData.amount
                        items = items or {}
                        items[#items + 1] = { item = item:serialize(), slotIndex = slotIndex, amount = amount }
                        if type_alias == Define.ITEM_TYPE.ABILITY_BOOK then
                            --- 激活能力
                            unlimited = unlimited or {}
                            unlimited[#unlimited + 1] = item:getId()
                        end
                    end
                end
            end
        end
    end

    packet.unlimited = unlimited
    packet.items = items
    packet.limit = limit
    packet.item_nums = item_nums
    --- 保存数据
    if exp and exp > 0 then
        PlayerDataHelper:saveLevelData(player, true)
        packet.level = GrowthSystem:getLevel(player)
        packet.exp = GrowthSystem:getExp(player)
    end

    --- 是否存库
    local saveInventory = false
    if aexp and aexp > 0 then
        saveInventory = true
        packet.aexp = ability:getExp()
        packet.alevel = ability:getLevel()
        packet.aid = ability:getId()
    end

    if saveInventory or items or unlimited then
        PlayerDataHelper:saveInventoryData(player, true)
    end

    InventorySystem.MODIFY_SOURCE = nil

    player:sendPacket(packet)
end

--- 添加物品奖励
---@param player Entity
---@param itemAlias any
---@param itemNum any
---@param rewardType any
---@param ... any 自定义参数，主要配合添加货币的reason，参考对应rewardType处理
---@return ... any 依据不同类型返回数据不一样，请自行判断
function RewardHelper:addItemByItemAlias(player, itemAlias, itemNum, ...)
    local config = ItemConfig:getCfgByItemAlias(itemAlias)
    local type_alias = config.type_alias
    if type_alias == Define.ITEM_TYPE.CURRENCY then
        local args = { ... }
        local rewardType = args[1]
        local reason = nil
        local related = nil
        if rewardType == Define.REWARD_TYPE.TASK then
            local taskId = args[2]
            reason = "task_reward_" .. taskId
        elseif rewardType == Define.REWARD_TYPE.KILL then
            local monsterId = args[2]
            reason = "kill_monster_" .. monsterId
        elseif rewardType == Define.REWARD_TYPE.NPC then
            local replyId = args[2]
            reason = "npc_replyId_" .. replyId
        elseif rewardType == Define.REWARD_TYPE.TREASURE_BOX then
            local boxId = args[2]
            reason = "open_chest_" .. boxId
        elseif rewardType == Define.REWARD_TYPE.SHOP_BUY then
            local shopId = args[2]
            reason = "shop_buy_" .. shopId
        elseif rewardType == Define.REWARD_TYPE.LIMITED_TIME then
            local activityId, giftId = args[2], args[3]
            reason = "limited_time_activity_" .. tostring(activityId) .. "_gift_" .. tostring(giftId)
        elseif rewardType == Define.REWARD_TYPE.DROP_ITEM then
            reason = "drop_item"
        elseif rewardType == Define.REWARD_TYPE.USE_ITEM then
            local alias = args[2]
            reason = "use_item_" .. alias
        elseif rewardType == Define.REWARD_TYPE.MISSION_REWARD then
            local missionId = args[2]
            reason = "mission_complete_" .. tostring(missionId)
        else
            reason = "common_reward"
            Lib.logWarning("Warning:Not found the define reward type.")
        end
        WalletSystem:addCoin(player, itemAlias, itemNum, reason, related)

        return true
    elseif type_alias == Define.ITEM_TYPE.ROLE_EXP then
        return GrowthSystem:addExp(player, itemNum)
    elseif type_alias == Define.ITEM_TYPE.ABILITY_EXP then
        return AbilitySystem:addAbilityExp(player, itemNum)
    elseif type_alias == Define.ITEM_TYPE.ABILITY_BOOK then
        --- 直接走打开逻辑
        --- 激活永久能力
        local abilityId = config.params["ability_id"]
        local items = nil
        local success = nil
        ---@type Ability, number, Slot
        local ability, slotIndex, slot = InventorySystem:getItemByItemId(player, Define.INVENTORY_TYPE.ABILITY, abilityId)
        if not ability then
            success, items = InventorySystem:addItemByItemId(player, Define.INVENTORY_TYPE.ABILITY, abilityId, 0)
            if success then
                ability = items[1].item
                ability:setUnlimited(1)
            end
        else
            if not ability:isUnlimited() then
                success = true
                ability:setUnlimited(1)
                items = {}
                items[#items + 1] = { item = ability, index = slotIndex, amount = slot:getAmount() }
            end
        end
        --- 激活能力并不会改变数量
        if success then
            Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_UNLIMITED, player, ability)
            return true, items
        end
    else
        local inventoryType = Define.ITEM_INVENTORY_TYPE[type_alias]
        if not inventoryType then
            Lib.logError("Error:Not found the define inventory type, item alias:", itemAlias, " item type:", type_alias)
        end
        return InventorySystem:addItemByItemAlias(player, inventoryType, itemAlias, itemNum)
    end
    return false
end

return RewardHelper