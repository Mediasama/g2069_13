--- growth_component.lua
--- 成长组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")
---@type LevelData
local LevelData = require "common.structure.level_data"
---@class GrowthComponent : middleclass
local GrowthComponent = class("GrowthComponent")

--- 初始化
---@param owner any 持有者
---@param levelData LevelData
function GrowthComponent:initialize(owner, levelData)
    self.owner = owner
    self.levelData = LevelData:new(levelData)
end

function GrowthComponent:getLevel()
    return self.levelData.level
end

function GrowthComponent:setLevel(level)
    self.levelData.level = level
end

function GrowthComponent:getExp()
    return self.levelData.exp
end

function GrowthComponent:setExp(exp)
    self.levelData.exp = exp
end

--- 反序列化
---@param data LevelData
function GrowthComponent:deserialize(data)
    self.levelData:deserialize(data)
end

--- 序列化数据
---@return LevelData
function GrowthComponent:serialize()
    return self.levelData:serialize()
end

--- 获取当前等级对应属性点
---@return number 当前等级所有属性点
function GrowthComponent:getAttributePoint()
    return PlayerLevelConfig:getCfgByLevel(self.levelData.level).total_attr_point
end

return GrowthComponent