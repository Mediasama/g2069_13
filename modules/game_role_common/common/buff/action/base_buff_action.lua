---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")

---@class BaseBuffAction : middleclass
local BaseBuffAction = class("BaseBuffAction")

--- 初始化
---@param buffActionId any
---@param buff BaseBuff
function BaseBuffAction:initialize(buffActionId, buff)
    --- 获取参数
    self.holderId = buff:getHolderId()
    self.casterId = buff:getCasterId()
    self.topCasterId = buff:getTopCasterId()
    self.buffActionId = buffActionId
    self.buffId = buff:getBuffId()
    self.id = buff:getId()
    self.cfg = SkillBuffConfig:getCfgByBuffId(self.buffId)
    ---@type Entity
    self.holder = World.CurWorld:getEntity(self.holderId)
    ---@type Entity
    self.caster = World.CurWorld:getEntity(self.casterId)
end

--- 初始化时机
function BaseBuffAction:onAdded()
    
end

--- 进入时机
function BaseBuffAction:onEnter()
    
end

---  退出时机
function BaseBuffAction:onExit()
    
end

--- tick
---@param deltaTime any 时间间隔，单位秒
function BaseBuffAction:onTick(deltaTime)
    
end

return BaseBuffAction
