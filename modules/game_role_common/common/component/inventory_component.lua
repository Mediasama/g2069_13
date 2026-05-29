--- inventory_component.lua
--- 背包组件
---@type Inventory
local Inventory = require "common.inventory.inventory"

---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class InventoryComponent : middleclass
local InventoryComponent = class('InventoryComponent')

--- 初始化
---@param owner Entity
function InventoryComponent:initialize(owner)
    ---@type Entity
    self.owner = owner
    self.inventories = {}
end

--- 创建背包
---@param type any
---@param capacity any
function InventoryComponent:createInventory(type, capacity)
    local inventory = Inventory:new(type, capacity)
    self.inventories[type] = inventory
end

--- 获取背包
---@param type any
function InventoryComponent:getInventory(type)
    return self.inventories[type]
end

--- 反序列化
---@param data any
function InventoryComponent:deserialize(data)
    for type, info in pairs(data) do
        local inventory = Inventory:new()
        inventory:deserialize(info)
        self.inventories[type] = inventory
    end
end

--- 序列化
function InventoryComponent:serialize()
    local data = {}
    for type, inventory in pairs(self.inventories) do
        data[type] = inventory:serialize()
    end
    return data
end

return InventoryComponent
