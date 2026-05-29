---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type GameLib
local GameLib = T(Lib, "GameLib")

---@type CompositeAttribute
local CompositeAttribute = require "common.attribute.composite_attribute"

---@class MaxHpAttribute : CompositeAttribute
local MaxHpAttribute = class("MaxHpAttribute", CompositeAttribute)

--- 计算当前属性值
---@param baseValue number 基础属性
function MaxHpAttribute:calculateFinalValue(baseValue)
    local value = CompositeAttribute.calculateFinalValue(self, baseValue)
    return GameLib.keepPreciseDecimal(value, 1)
end

return MaxHpAttribute