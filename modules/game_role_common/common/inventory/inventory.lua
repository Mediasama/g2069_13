--- inventory.lua
--- 背包
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
--- @type Slot
local Slot = require "common.inventory.slot"

---@class Inventory : middleclass
---@field type number 类型
---@field capacity number 容量
---@field expand number 扩展次数
---@field slots table 槽
local Inventory = class("Inventory")

--- 初始化
---@param type number 背包类型
---@param capacity number 初始容量
function Inventory:initialize(type, capacity)
    self.type = type
    self.capacity = capacity or 0
    self.expand = 0
    self.slots = {}
end

--- 添加物品
---@param item Item
---@param amount number
---@return boolean 是否成功
---@return number 索引
function Inventory:addItem(item, amount)
    local size = Lib.getTableSize(self.slots)
    if size >= self.capacity then
        return false, -1
    end

    --- 遍历
    for slotIndex = 1, self.capacity do
        if not self.slots[slotIndex] then
            self:setItem(slotIndex, item, amount)
            return true, slotIndex
        end
    end

    return false, -1
end

--- 扩容
---@param size any
function Inventory:addCapacity(size)
    self.capacity = self.capacity + size
    self.expand = self.expand + 1
end

--- 设置物品
---@param slotIndex any
---@param item any
---@param amount any
function Inventory:setItem(slotIndex, item, amount)
    local slot = Slot:new(item, amount)
    self.slots[slotIndex] = slot
end

--- 移除物品
---@param slotIndex 索引
---@return boolean
function Inventory:removeItem(slotIndex)
    if self.slots[slotIndex] then
        self.slots[slotIndex] = nil
        return true
    end
    return false
end

--- 判断是否满了
---@return boolean
function Inventory:isFull()
    return self.capacity <= Lib.getTableSize(self.slots)
end

--- 获取所有槽
function Inventory:retrieveSlots()
    return self.slots
end

--- 通过itemId获取槽
---@param itemId any
---@return Slot 槽
---@return number 索引
function Inventory:retrieveSlotByItemId(itemId)
    if self.slots then
        for slotIndex, slot in pairs(self.slots) do
            local item = slot:getItem()
            if item and item:getItemId() == itemId then
                return slot, slotIndex
            end
        end
    end
    return nil, -1
end

--- 通过物品uid获取槽
---@param id any
---@return Slot 槽
---@return number 索引
function Inventory:retrieveSlotById(id)
    if self.slots then
        for slotIndex, slot in pairs(self.slots) do
            local item = slot:getItem()
            if item and item:getId() == id then
                return slot, slotIndex
            end
        end
    end
    return nil, -1
end

--- 获取槽
---@param slotIndex number 索引
---@return Slot
function Inventory:retrieveSlotByIndex(slotIndex)
    return self.slots[slotIndex]
end

--- 序列化
function Inventory:serialize()
    local data = {}
    data.type = self.type
    data.capacity = self.capacity
    data.expand = self.expand
    if next(self.slots) then
        data.slots = {}
        for slotIndex, slot in pairs(self.slots) do
            if slot:getItem() then
                data.slots[slotIndex] = slot:serialize()
            end
        end
    end
    return data
end

--- 反序列化
---@param data any
function Inventory:deserialize(data)
    self.type = data.type
    self.capacity = data.capacity
    self.expand = data.expand
    self.slots = {}
    if data.slots then
        for slotIndex, info in pairs(data.slots) do
            if info.item then
                local slot = Slot:new()
                slot:deserialize(info)
                self.slots[slotIndex] = slot
            end
        end
    end
end

return Inventory
