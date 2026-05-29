--- growth_component.lua
--- 成长组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type GrowthComponent
local GrowthComponent = require "common.component.growth_component"

---@class GrowthComponentServer : GrowthComponent
local GrowthComponentServer = class("GrowthComponentServer", GrowthComponent)

--- 初始化
---@param owner any 持有者
---@param levelData LevelData
function GrowthComponentServer:initialize(owner, levelData)
    GrowthComponent.initialize(self, owner, levelData)
    self.owner:setCurLevel(self.levelData.level)
end

--- 设置等级
---@param level any
function GrowthComponentServer:setLevel(level)
    GrowthComponent.setLevel(self, level)
    if self.owner:getCurLevel() ~= level then
        self.owner:setCurLevel(level)
    end
end

--- 反序列化
---@param data LevelData
function GrowthComponentServer:deserialize(data)
    GrowthComponent.deserialize(self, data)
    if self.owner:getCurLevel() ~= self.levelData.level then
        self.owner:setCurLevel(self.levelData.level)
    end
end

return GrowthComponentServer