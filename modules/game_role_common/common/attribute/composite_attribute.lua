--- composite_attribute.lua
--- 复合属性
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
--- @type BaseAttribute
local BaseAttribute = require "common.attribute.base_attribute"

---@class CompositeAttribute : BaseAttribute
local CompositeAttribute = class("CompositeAttribute", BaseAttribute)

function CompositeAttribute:initialize(id, value)
    BaseAttribute.initialize(self, id, value)
    --- 复合属性
    self.attributes = {}
end

--- 添加复合属性
---@param attribute BaseAttribute
function CompositeAttribute:addAttribute(attribute)
    self.dirty = true
    self.attributes[#self.attributes + 1] = attribute
end

--- 检索属性
---@param attribute BaseAttribute
---@return boolean
function CompositeAttribute:retrieveAttribute(attribute)
    for _, _attribute in pairs(self.attributes) do
        if _attribute == attribute then
            return true
        end
    end
    return false
end

--- 移除复合属性
---@param attribute any
---@return boolean 是否成功
function CompositeAttribute:removeAttribute(attribute)
    local len = #self.attributes
    for i = len, 1, -1 do
        if self.attributes[i] == attribute then
            self.dirty = true
            table.remove(self.attributes, i)
            return true
        end
    end
    return false
end

--- 是否脏数据
function CompositeAttribute:isDirty()
    for _, attribute in pairs(self.attributes) do
        if attribute:isDirty() then
            return true
        end
    end
    return self.dirty
end

--- 计算当前属性值（复合属性默认公式）
---@return number 当前值
function CompositeAttribute:calculateFinalValue(baseValue)
    local id = self:getId()
    for _, attribute in pairs(self.attributes) do
        if attribute:isGrowth() then
            local value = attribute:getGrowthBaseValue(id)
            if value then
                baseValue = value
            else
                Lib.logError("Error:Not found the growth value, composite attribute:", id, " growth attribute:", attribute:getId())
            end
        end
    end
    return BaseAttribute.calculateFinalValue(self, baseValue)
end

--- 是否复合属性
---@return boolean
function CompositeAttribute:isComposite()
    return true
end

return CompositeAttribute