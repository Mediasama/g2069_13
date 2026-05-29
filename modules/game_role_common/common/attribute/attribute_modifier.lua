--- attribute_modifier.lua
--- 属性修饰器
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class AttributeModifier : middleclass
local AttributeModifier = class('AttributeModifier')

--- 初始化
---@param value number 数值
---@param type number 叠加类型
---@param order number 排序
---@param source any 源标记
function AttributeModifier:initialize(value, type, order, source)
    self.value = value
    self.type = type
    self.order = order
    self.source = source
end

--- 获取叠加类型
---@return number 叠加类型
function AttributeModifier:getType()
    return self.type
end

--- 获取排序
---@return number 排序
function AttributeModifier:getOrder()
    return self.order
end

--- 获取源标记
---@return any 源标记
function AttributeModifier:getSource()
    return self.source
end

--- 获取数值
---@return number 数值
function AttributeModifier:getValue()
    return self.value
end

return AttributeModifier