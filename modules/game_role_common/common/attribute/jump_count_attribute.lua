---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type GameLib
local GameLib = T(Lib, "GameLib")

---@type CompositeAttribute
local CompositeAttribute = require "common.attribute.composite_attribute"

---@class JumpCountAttribute : CompositeAttribute
local JumpCountAttribute = class("JumpCountAttribute", CompositeAttribute)

--- 计算当前属性值
---@param baseValue number 基础属性
function JumpCountAttribute:calculateFinalValue(baseValue)
    local value = CompositeAttribute.calculateFinalValue(self, baseValue)
    --- 向上取整
    return math.ceil(value)
end

return JumpCountAttribute