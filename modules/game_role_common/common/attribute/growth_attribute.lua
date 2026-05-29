--- growth_attribute.lua
--- 可成长属性
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type AttributeLevelConfig
local AttributeLevelConfig = T(Config, "AttributeLevelConfig")
--- @type BaseAttribute
local BaseAttribute = require "common.attribute.base_attribute"
---@class GrowthAttribute : BaseAttribute
local GrowthAttribute = class("GrowthAttribute", BaseAttribute)

--- 初始化
---@param id any
---@param value any
---@param level any
function GrowthAttribute:initialize(id, value, level)
    BaseAttribute.initialize(self, id, value)
    self.level = level or 1
end

--- 获取等级
function GrowthAttribute:getLevel()
    return self.level
end

--- 设置等级
---@param level any
function GrowthAttribute:setLevel(level)
    if level ~= self.level then
        self.dirty = true
    end
    self.level = level
end

--- 是否可成长属性
---@return boolean
function GrowthAttribute:isGrowth()
    return true
end

--- 获取属性值
---@param id any
function GrowthAttribute:getGrowthBaseValue(id)
    local config = AttributeLevelConfig:getCfgByLevel(self.id, self.level)
    return config[id]
end

return GrowthAttribute