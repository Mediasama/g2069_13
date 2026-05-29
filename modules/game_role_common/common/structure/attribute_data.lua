---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class AttributeData : middleclass
---@field data table 加点等级数据
---@field idx number 当前使用方案
---@field uidx number 解锁索引
---@field rtimes number 重置次数
local AttributeData = class("AttributeData")

--- 初始化
---@param data AttributeData
function AttributeData:initialize()
    --- 记录属性点相关
    self.data = {}
    self.idx = 1
    self.uidx = 1
    self.rtimes = 0
end

--- 获取属性等级
---@param id string
---@return number 等级
function AttributeData:getLevelByIndex(id, index)
    local data = self.data[index]
    if data then
        return data[id] or 1
    end
    return 1
end

--- 获取属性等级
---@param id string
---@return number 等级
function AttributeData:getLevel(id)
    local data = self.data[self.idx]
    if data then
        return data[id] or 1
    end
    return 1
end

--- 设置属性等级
---@param id string 属性id
---@param level number 等级
function AttributeData:setLevel(id, level)
    local data = self.data[self.idx] or {}
    data[id] = level
    self.data[self.idx] = data
end

--- 设置属性等级
---@param id string 属性id
---@param level number 等级
function AttributeData:setLevelByIndex(id, level, index)
    local data = self.data[index] or {}
    data[id] = level
    self.data[index] = data
end

--- 序列化数据
function AttributeData:serialize()
    local data = {}
    data.data = Lib.copy(self.data)
    data.idx = self.idx
    data.uidx = self.uidx
    data.rtimes = self.rtimes
    return data
end

--- 反序列化数据
---@param data AttributeData
function AttributeData:deserialize(data)
    self.data = data and Lib.copy(data.data) or {}
    self.idx = data and data.idx or 1
    self.uidx = data and data.uidx or 1
    self.rtimes = data and data.rtimes or 0
end

return AttributeData