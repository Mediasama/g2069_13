--- equipment_component.lua
--- 装备组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@class EquipmentComponent : middleclass
local EquipmentComponent = class("EquipmentComponent")

--- 初始化
---@param owner Entity 持有者
function EquipmentComponent:initialize(owner)
    ---@type Entity
    self.owner = owner
    --- 装备中数据
    self.equippedData = {}
end

--- 获取部位装备唯一id
---@param part number 部位id,Define.EQUIPMENT_PART_TYPE
---@return string 装备唯一id
function EquipmentComponent:getPartEquipmentId(part)
    return self.equippedData[part]
end

--- 装备
---@param part number 部位id,Define.EQUIPMENT_PART_TYPE
---@param equipment Equipment
function EquipmentComponent:equip(part, equipment)
    self.equippedData[part] = equipment:getId()
end

--- 卸下
---@param equipment Equipment
---@return boolean 是否成功
function EquipmentComponent:unequip(equipment)
    local part = equipment:getPartType()
    if self.equippedData[part] == equipment:getId() then
        self.equippedData[part] = nil
        return true
    end
    return false
end

--- 卸下
---@param part number 部位id,Define.EQUIPMENT_PART_TYPE
---@return boolean 是否成功
function EquipmentComponent:unequipByPart(part)
    if self.equippedData[part] then
        self.equippedData[part] = nil
        return true
    end
    return false
end

--- 序列化
function EquipmentComponent:serialize()
    local data = {}
    for part, eqptId in pairs(self.equippedData) do
        data[part] = eqptId
    end
    return data
end

--- 反序列化
---@param data any
function EquipmentComponent:deserialize(data)
    for _, part in pairs(Define.EQUIPMENT_PART_TYPE) do
        self.equippedData[part] = data[part] or nil
    end
end

return EquipmentComponent