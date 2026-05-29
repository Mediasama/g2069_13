---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type Item
local Item = require "common.inventory.item"

--- 装备
---@class Equipment : Item
---@field id string 物品唯一id
---@field itemId number 物品配置表id
local Equipment = class("Equipment", Item)

function Equipment:initialize(id, itemId)
    Item.initialize(self, id, itemId)
end

--- 触发装备
---@param player any
function Equipment:equip(player)
    
end

--- 触发卸下
---@param player any
function Equipment:unequip(player)
    
end

--- 获取装备槽类型
---@return number 装备槽类型,定义在Define.EQUIPMENT_PART_TYPE
function Equipment:getPartType()
    local type = self:getItemType()
    return Define.EQUIPMENT_PART_TYPE[type]
end

return Equipment