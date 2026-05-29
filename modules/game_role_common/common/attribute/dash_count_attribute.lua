---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type GameLib
local GameLib = T(Lib, "GameLib")

---@type CompositeAttribute
local CompositeAttribute = require "common.attribute.composite_attribute"

---@class DashCountAttribute : CompositeAttribute
local DashCountAttribute = class("DashCountAttribute", CompositeAttribute)

--- 计算当前属性值
---@param baseValue number 基础属性
function DashCountAttribute:calculateFinalValue(baseValue)
    local value = CompositeAttribute.calculateFinalValue(self, baseValue)
    --- 向上取整
    return math.ceil(value)
end

return DashCountAttribute