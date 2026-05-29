--- slot.lua
--- 背包槽位
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class Slot : middleclass
local Slot = class("Slot")

--- 初始化
---@param item Item 物品
---@param amount number 物品数量
function Slot:initialize(item, amount)
    ---@type Item
    self.item = item and item:copy() or nil
    self.amount = amount or 0
end

--- 获取Item
---@return Item
function Slot:getItem()
    return self.item
end

--- 获取数量
---@return number
function Slot:getAmount()
    return self.amount
end

--- 设置数量
---@param amount any
function Slot:setAmount(amount)
    self.amount = amount
end

--- 序列化
function Slot:serialize()
    local data = {}
    if self.item then
        data.item = self.item:serialize()
        data.amount = self.amount
    end
    return data
end

--- 反序列化
---@param data any
function Slot:deserialize(data)
    self.item = nil
    self.amount = 0
    local item = data.item
    if item then
        local type_alias = ItemConfig:getCfgByItemId(item.itemId).type_alias
        ---@type Item
        local cls = Define.ITEM_CLASS[type_alias]
        if not cls then
            Lib.logError("Error:Not found the item class when slot deserialize, item id:", item.itemId, " type alias:", type_alias)
        end
        self.item = cls:new()
        self.item:deserialize(item)
        self.amount = data.amount or 0
    end
end

return Slot