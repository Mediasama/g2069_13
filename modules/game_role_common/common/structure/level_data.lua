---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class LevelData : middleclass
---@field level number
---@field exp number
local LevelData = class("LevelData")

--- 初始化
---@param data LevelData
function LevelData:initialize(data)
    self.level = data and data.level or 1
    self.exp = data and data.exp or 0
end

--- 序列化数据
---@return LevelData
function LevelData:serialize()
    local data = {}
    data.level = self.level
    data.exp = self.exp
    return data
end

--- 反序列化数据
---@param data LevelData
function LevelData:deserialize(data)
    self.level = data and data.level or 1
    self.exp = data and data.exp or 0
end

return LevelData