---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@class EquipmentSystem
local EquipmentSystem = T(Lib, "EquipmentSystem")

function EquipmentSystem:init()

end

--- 获取部位装备
---@param player Entity
---@param part number 部位类型，定义在Define.EQUIPMENT_PART_TYPE
---@return Equipment 装备物品
---@return number 索引
---@return Slot 物品槽
function EquipmentSystem:getPartEquipment(player, part)
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("equipment")
    if equipmentComponent then
        local id = equipmentComponent:getPartEquipmentId(part)
        if id and id ~= "" then
            return InventorySystem:getItemById(player, Define.INVENTORY_TYPE.EQUIPMENT, id)
        end
    end
    return nil, -1, nil
end

--- 装备物品
---@param player Entity
---@param equipment Equipment
function EquipmentSystem:equip(player, equipment)
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("equipment")
    if equipmentComponent then
        local part = equipment:getPartType()
        equipmentComponent:equip(part, equipment)
        equipment:equip(player)
        return true
    end
    return false
end

--- 卸下装备
---@param player any
---@param equipment Equipment
---@return boolean 是否成功
function EquipmentSystem:unequip(player, equipment)
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("equipment")
    if equipmentComponent then
        if equipmentComponent:unequip(equipment) then
            equipment:unequip(player)
            return true
        end
    end
    return false
end

--- 通过part卸下装备
---@param player any
---@param part any
---@return boolean 是否成功
---@return Equipment 卸下的装备
function EquipmentSystem:unequipByPart(player, part)
    ---@type EquipmentComponent
    local equipmentComponent = player:getComponent("equipment")
    if equipmentComponent then
        local id = equipmentComponent:getPartEquipmentId(part)
        if id and id ~= "" then
            equipmentComponent:unequipByPart(part)
            ---@type Equipment
            local equipment = InventorySystem:getItemById(player, Define.INVENTORY_TYPE.EQUIPMENT, id)
            if equipment then
                equipment:unequip(player)
            end
            return true, equipment
        end
    end
    return false, nil
end

EquipmentSystem:init()

return EquipmentSystem