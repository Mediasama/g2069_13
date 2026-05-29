---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type uuid
local uuid = require "common.uuid"

---@class InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

function InventorySystem:init()
    self.MODIFY_SOURCE = nil
end

--- 通过物品配置表id获取Item
---@param player Entity 玩家
---@param inventoryType number 背包类型
---@param itemId any 物品配置表id
---@return Item 物品
---@return number 索引
---@return Slot 槽
function InventorySystem:getItemByItemId(player, inventoryType, itemId)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local slot, slotIndex = inventory:retrieveSlotByItemId(itemId)
            if slot then
                return slot:getItem(), slotIndex, slot
            end
        end
    end
    return nil, -1, nil
end

--- 通过物品配置表物品别称获取Item
---@param player any
---@param inventoryType any
---@param itemAlias any
---@return Item 物品
---@return number 索引
---@return Slot 槽
function InventorySystem:getItemByItemAlias(player, inventoryType, itemAlias)
    local config = ItemConfig:getCfgByItemAlias(itemAlias)
    return self:getItemByItemId(player, inventoryType, config.item_id)
end

--- 通过物品唯一id获取Item
---@param player Entity 玩家
---@param inventoryType number 背包类型
---@param id any 物品唯一id
---@return Item 物品
---@return number 索引
---@return Slot 槽
function InventorySystem:getItemById(player, inventoryType, id)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local slot, slotIndex = inventory:retrieveSlotById(id)
            if slot then
                return slot:getItem(), slotIndex, slot
            end
        end
    end
    return nil, -1, nil
end

--- 通过物品id添加物品
---@param player any
---@param inventoryType any
---@param itemId any
---@param amount any
---@return boolean success
---@return table 元素结构为{ item, index, amount }的数组
function InventorySystem:addItemByItemId(player, inventoryType, itemId, amount, ...)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local config = ItemConfig:getCfgByItemId(itemId)
            local type_alias = config.type_alias
            local isOverlay = config.isOverlay == 1
            ---@type Item
            local cls = Define.ITEM_CLASS[type_alias]
            if not cls then
                Lib.logError("Error:Not found the class when add item by item id, item id:", itemId, " type alias:", type_alias)
            end
            --- 判断是否能堆叠
            if isOverlay then
                ---@type Item, number, Slot
                local item, slotIndex, slot = self:getItemByItemId(player, inventoryType, itemId)
                if slot then
                    slot:setAmount(slot:getAmount() + amount)
                    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, player, item, amount)
                    local items = {}
                    items[#items + 1] = { item = item, index = slotIndex, amount = slot:getAmount() }
                    return true, items
                end
                ---@type Item
                local item = cls:new(uuid(), itemId, ...)
                item:setTime(os.time())
                local success, slotIndex = inventory:addItem(item, amount)
                if success then
                    ---@type Slot
                    local slot = inventory:retrieveSlotByIndex(slotIndex)
                    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, player, slot:getItem(), amount)
                    local items = {}
                    items[#items + 1] = { item = slot:getItem(), index = slotIndex, amount = slot:getAmount() }
                    return true, items
                end
            else
                local items
                local success = false
                if amount == 0 then
                    --- 不能堆叠的物品不支持

                    -- ---@type Item
                    -- local item = cls:new(uuid(), itemId, ...)
                    -- item:setTime(os.time())
                    -- local flag, slotIndex = inventory:addItem(item, amount)
                    -- if not flag then
                    --     return false
                    -- end
                    -- success = true
                    -- ---@type Slot
                    -- local slot = inventory:retrieveSlotByIndex(slotIndex)
                    -- items = items or {}
                    -- items[#items + 1] = { item = slot:getItem(), index = slotIndex, amount = slot:getAmount() }
                    -- Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, player, slot:getItem(), amount)
                else
                    for i = 1, amount do
                        ---@type Item
                        local item = cls:new(uuid(), itemId, ...)
                        item:setTime(os.time())
                        local flag, slotIndex = inventory:addItem(item, 1)
                        if not flag then
                            break
                        end
                        success = true
                        ---@type Slot
                        local slot = inventory:retrieveSlotByIndex(slotIndex)
                        items = items or {}
                        items[#items + 1] = { item = slot:getItem(), index = slotIndex, amount = slot:getAmount() }
                        Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, player, slot:getItem(), 1)
                    end
                end
                return success, items
            end
        end
    end
    return false
end

--- 改变物品数量
---@param player Entity
---@param inventoryType any
---@param id any
---@param changeNum number 变化数量
---@param clear boolean 当数量为0时是否清除槽位置
function InventorySystem:changeItemNumById(player, inventoryType, id, changeNum, clear)
    ---@type Item, number, Slot
    local item, slotIndex, slot = self:getItemById(player, inventoryType, id)
    if item then
        local amount = slot:getAmount()
        if changeNum < 0 and amount + changeNum < 0 then
            return false
        end
        --- 变化数量
        local addAmount = amount
        --- 当前数量
        amount = math.max(amount + changeNum, 0)
        addAmount = amount - addAmount
        if clear and amount == 0 then
            self:removeItemByIndex(player, inventoryType, slotIndex)
        else
            --- 只修改数量
            slot:setAmount(amount)
        end
        Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, player, item, addAmount)
        return true, item, slotIndex, slot
    end
    return false
end

--- 改变物品数量
---@param player Entity
---@param inventoryType any
---@param itemId any
---@param changeNum number 变化数量
---@param clear boolean 当数量为0时是否清除槽位置
function InventorySystem:changeItemNumByItemId(player, inventoryType, itemId, changeNum, clear)
    ---@type Item, number, Slot
    local item, slotIndex, slot = self:getItemByItemId(player, inventoryType, itemId)
    if item then
        local amount = slot:getAmount()
        --- 变化数量
        local addAmount = amount
        --- 当前数量
        amount = math.max(amount + changeNum, 0)
        addAmount = amount - addAmount
        if clear and amount == 0 then
            self:removeItemByIndex(player, inventoryType, slotIndex)
        else
            --- 只修改数量
            slot:setAmount(amount)
        end
        Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, player, item, addAmount)
        return true, item, slotIndex, slot
    end
    return false
end

--- 改变物品数量
---@param player Entity
---@param inventoryType any
---@param itemAlias any
---@param changeNum number 变化数量
---@param clear boolean 当数量为0时是否清除槽位置
function InventorySystem:changeItemNumByItemAlias(player, inventoryType, itemAlias, changeNum, clear)
    local config = ItemConfig:getCfgByItemAlias(itemAlias)
    return self:changeItemNumByItemId(player, inventoryType, config.item_id, changeNum, clear)
end

--- 通过物品别称添加物品
---@param player any
---@param inventoryType any
---@param itemAlias any 物品别称
---@param amount any
---@return boolean
---@return table 元素结构为{ item, index, amount }的数组
function InventorySystem:addItemByItemAlias(player, inventoryType, itemAlias, amount, ...)
    local config = ItemConfig:getCfgByItemAlias(itemAlias)
    return self:addItemByItemId(player, inventoryType, config.item_id, amount, ...)
end

--- 设置背包物品
---@param player any
---@param inventoryType any
---@param slotIndex any
---@param item any
---@param amount any
function InventorySystem:setItem(player, inventoryType, slotIndex, item, amount)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local isAdd = true
            local slot = inventory:retrieveSlotByIndex(slotIndex)
            local addAmount = amount
            --- 原本就有的数据
            if slot then
                ---@type Item
                local slotItem = slot:getItem()
                if slotItem and slotItem:getId() == item:getId() then
                    isAdd = false
                    addAmount = amount - slot:getAmount()
                end
            end
            inventory:setItem(slotIndex, item, amount)
            
            if isAdd then
                slot = inventory:retrieveSlotByIndex(slotIndex)
                Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, player, slot:getItem(), addAmount)
            else
                slot = inventory:retrieveSlotByIndex(slotIndex)
                Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, player, slot:getItem(), addAmount)
            end
        end
    end
end

--- 反序列化物品
---@param itemData any
---@return Item
function InventorySystem:deserializeItem(itemData)
    local itemId = itemData.itemId
    local config = ItemConfig:getCfgByItemId(itemId)
    local type_alias = config.type_alias
    ---@type Item
    local cls = Define.ITEM_CLASS[type_alias]
    if not cls then
        Lib.logError("Error:Not found the class when add item by item id, item id:", itemId, " type alias:", type_alias)
    end
    ---@type Item
    local item = cls:new()
    item:deserialize(itemData)
    return item
end

--- 获取所有物品
---@param player any
---@param inventoryType any
---@return table|Slot
function InventorySystem:getAllSlots(player, inventoryType)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            return inventory:retrieveSlots()
        end
    end
    return nil
end

--- 移除物品
---@param player any
---@param inventoryType any
---@param slotIndex number
---@return boolean success
function InventorySystem:removeItemByIndex(player, inventoryType, slotIndex)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            return inventory:removeItem(slotIndex)
        end
    end
    return false
end

--- 通过id移除物品
---@param player any
---@param inventoryType any
---@param id any
function InventorySystem:removeItemById(player, inventoryType, id)
    ---@type Item, number
    local item, slotIndex = self:getItemById(player, inventoryType, id)
    if item then
        return self:removeItemByIndex(slotIndex)
    end
    return false
end

--- 通过索引获取物品
---@param player any
---@param inventoryType any
---@param slotIndex any
---@param ignoreAmount any
---@return Item
function InventorySystem:getItemByIndex(player, inventoryType, slotIndex, ignoreAmount)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            ---@type Slot
            local slot = inventory:retrieveSlotByIndex(slotIndex)
            if slot then
                if ignoreAmount or slot:getAmount() > 0 then
                    return slot:getItem()
                end
            end
        end
    end
    return false
end

--- 获取对应物品id的所有物品
---@param player any
---@param inventoryType any
---@param itemId any
---@return table Item类型的数组
function InventorySystem:getItemListByItemId(player, inventoryType, itemId)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local list = nil
            local slots = inventory:retrieveSlots()
            ---@type number, Slot
            for _, slot in pairs(slots) do
                ---@type Item
                local item = slot:getItem()
                if item and item:getItemId() == itemId then
                    list = list or {}
                    list[#list + 1] = item
                end
            end
            return list
        end
    end
    return nil
end

--- 通过物品配置表别称获取数量
---@param player Entity
---@param inventoryType number 背包类型,定义在Define.INVENTORY_TYPE
---@param itemAlias string 物品别称
function InventorySystem:getItemAmountByItemAlias(player, inventoryType, itemAlias)
    local itemId = ItemConfig:getCfgByItemAlias(itemAlias).item_id
    return self:getItemAmountByItemId(player, inventoryType, itemId)
end

--- 通过物品配置表id获取数量
---@param player Entity
---@param inventoryType number 背包类型,定义在Define.INVENTORY_TYPE
---@param itemId number 物品配置表id
function InventorySystem:getItemAmountByItemId(player, inventoryType, itemId)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            local amount = 0
            local slots = inventory:retrieveSlots()
            ---@type number, Slot
            for _, slot in pairs(slots) do
                ---@type Item
                local item = slot:getItem()
                if item and item:getItemId() == itemId then
                    amount = amount + slot:getAmount()
                end
            end
            return amount
        end
    end
    return 0
end

--- 通过物品id获取数量
---@param player Entity
---@param inventoryType number 背包类型,定义在Define.INVENTORY_TYPE
---@param id number 物品id
function InventorySystem:getItemAmountById(player, inventoryType, id)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        ---@type Inventory
        local inventory = inventoryComponent:getInventory(inventoryType)
        if inventory then
            ---@type Slot
            local slot = inventory:retrieveSlotById(id)
            if slot then
                return slot:getAmount()
            end
        end
    end
    return 0
end

--- 获取背包
---@param player Entity
---@param inventoryType number 背包类型,定义在Define.INVENTORY_TYPE
---@return Inventory 背包
function InventorySystem:getInventory(player, inventoryType)
    ---@type InventoryComponent
    local inventoryComponent = player:getComponent("inventory")
    if inventoryComponent then
        return inventoryComponent:getInventory(inventoryType)
    end
    return nil
end

InventorySystem:init()

return InventorySystem