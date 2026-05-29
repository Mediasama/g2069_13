--- item.lua
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

--- 通用物品
---@class Item : middleclass
---@field id string 物品唯一id
---@field itemId number 物品配置表id
---@field ts number 物品获得时间
---@field inspected number 检视状态，1为已检视
local Item = class("Item")

--- 初始化
---@param id string 唯一id
---@param itemId number 配置表id
function Item:initialize(id, itemId)
    self.id = id
    self.itemId = itemId
    self.ts = 0
    --- 检视状态
    self.inspected = 0
end

--- 设置物品唯一id
---@param id string 唯一id
function Item:setId(id)
    self.id = id
end

--- 获取物品唯一id
---@return string 唯一id
function Item:getId()
    return self.id
end

--- 设置物品配置表id
---@param itemId number 配置表id
function Item:setItemId(itemId)
    self.itemId = itemId
end

--- 获取物品配置表id
---@return number 配置表id
function Item:getItemId()
    return self.itemId
end

--- 获取物品获得时间
function Item:getTime()
    return self.ts
end

--- 设置物品获得时间
---@param ts number
function Item:setTime(ts)
    self.ts = ts
end

--- 是否已检视
---@return boolean
function Item:isInspected()
    return self.inspected == 1
end

--- 设置检视状态
---@param inspected number
function Item:setInspected(inspected)
    self.inspected = inspected
end

--- 序列化
function Item:serialize()
    local data = {}
    data.id = self.id
    data.itemId = self.itemId
    data.ts = self.ts
    if self.inspected ~= 0 then
        data.inspected = self.inspected
    end
    return data
end

--- 反序列化
---@param data any
function Item:deserialize(data)
    self.id = data.id
    self.itemId = data.itemId
    self.ts = data.ts or 0
    self.inspected = data.inspected or 0
end

--- 获取物品类型
---@return string 物品type别称
function Item:getItemType()
    return ItemConfig:getCfgByItemId(self.itemId).type_alias
end

--- 获取物品别称
function Item:getItemAlias()
    return ItemConfig:getCfgByItemId(self.itemId).item_alias
end

--- 获取物品icon
function Item:getIcon()
    return ItemConfig:getCfgByItemId(self.itemId).icon
end

--- 获取品质
function Item:getQuality()
    return ItemConfig:getCfgByItemId(self.itemId).quality_alias
end

function Item:getItemSubType()
    return ItemConfig:getCfgByItemId(self.itemId).sub_type_alias
end

function Item:getName()
    return ItemConfig:getCfgByItemId(self.itemId).name
end

--- 复制
---@return Item
function Item:copy()
    local type = self:getItemType()
    ---@type Item
    local cls = Define.ITEM_CLASS[type]
    if not cls then
        Lib.logError("Error:Not found the item class, item type:", type)
    end
    ---@type Item
    local item = cls:new()
    item:deserialize(self:serialize())
    return item
end

return Item
