--- base_attribute.lua
--- 基础属性
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class BaseAttribute : middleclass
local BaseAttribute = class('BaseAttribute')

---@type GameLib
local GameLib = T(Lib, "GameLib")

local modifierSort = function(mod1, mod2)
    return mod1:getOrder() < mod2:getOrder()
end

--- 初始化
---@param value number 基础数值
function BaseAttribute:initialize(id, value)
    self.id = id
    --- 基础值
    self.baseValue = value or 0
    --- 当前值
    self.curValue = self.baseValue
    --- 修饰器
    self.modifiers = {}
    --- 是否脏数据
    self.dirty = true
end

function BaseAttribute:getId()
    return self.id
end

--- 添加属性修饰器
---@param modifier AttributeModifier 修饰器
function BaseAttribute:addModifier(modifier)
    self.dirty = true
    self.modifiers[#self.modifiers + 1] = modifier
    table.sort(self.modifiers, modifierSort)
end

--- 移除属性修饰器
---@param modifier AttributeModifier 修饰器
---@return boolean 是否成功
function BaseAttribute:removeModifier(modifier)
    for i = #self.modifiers, 1, -1 do
        if self.modifiers[i] == modifier then
            self.dirty = true
            table.remove(self.modifiers, i)
            return true            
        end
    end
    return false
end

--- 移除指定source属性修饰器
---@param source any 源头
---@return boolean 是否成功
function BaseAttribute:removeAllModifiersFromSource(source)
    local flag = false
    for i = #self.modifiers, 1, -1 do
        local modifier = self.modifiers[i]
        if modifier:getSource() == source then
            self.dirty = true
            table.remove(self.modifiers, i)
            flag = true
        end
    end
    return flag
end

--- 计算当前属性值
---@param baseValue 基础值
---@return number 当前值
function BaseAttribute:calculateFinalValue(baseValue)
    local finalValue = baseValue
    local finalAdd = 0
    local sumPercentAdd = 1
    local sumPercentMult = 1

    for i = 1, #self.modifiers do
        local mod = self.modifiers[i]
        if mod:getType() == Define.ATTR_MOD_TYPE.RAW then
            finalValue = finalValue + mod:getValue()
        elseif mod:getType() == Define.ATTR_MOD_TYPE.PERCENTADD then
            sumPercentAdd = sumPercentAdd + mod:getValue()
        elseif mod:getType() == Define.ATTR_MOD_TYPE.PERCENTMULT then
            sumPercentMult = sumPercentMult * (1 + mod:getValue())
        elseif mod:getType() == Define.ATTR_MOD_TYPE.ADD then
            finalAdd = finalAdd + mod:getValue()
        end
    end

    finalValue = finalValue * sumPercentMult * sumPercentAdd + finalAdd

    --- 保留2位小数
    return GameLib.keepPreciseDecimal(finalValue, 2)
end

--- 获取当前属性值
---@return number 当前值
function BaseAttribute:getValue()
    if self:isDirty() then
        self.dirty = false
        self.curValue = self:calculateFinalValue(self.baseValue)
    end
    return self.curValue
end

--- 是否脏数据
function BaseAttribute:isDirty()
    return self.dirty
end

--- 设置基础值
---@param baseValue any
function BaseAttribute:setBaseValue(baseValue)
    self.baseValue = baseValue
    self.dirty = true
end

--- 获取基础值
function BaseAttribute:getBaseValue()
    return self.baseValue
end

--- 是否可成长属性
---@return boolean
function BaseAttribute:isGrowth()
    return false
end

--- 是否复合属性
---@return boolean
function BaseAttribute:isComposite()
    return false
end

return BaseAttribute