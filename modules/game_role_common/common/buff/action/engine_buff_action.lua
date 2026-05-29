---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type BaseBuffAction
local BaseBuffAction = require "common.buff.action.base_buff_action"

---@class EngineBuffAction : BaseBuffAction
local EngineBuffAction = class("EngineBuffAction", BaseBuffAction)

--- 初始化时机
function EngineBuffAction:onAdded()
    if self.holder and self.holder:isValid() then
        local buffName = self.cfg.buffName
        if not World.isClient then
            self.engineBuff = self.holder:addBuff(buffName, nil, self.caster)
        end
    end
end

--- 进入时机
function EngineBuffAction:onEnter()
    
end

---  退出时机
function EngineBuffAction:onExit()
    if self.holder and self.holder:isValid() and self.engineBuff then
        self.holder:removeBuff(self.engineBuff)
    end
end

--- tick
---@param deltaTime any 时间间隔，单位秒
function EngineBuffAction:onTick(deltaTime)
    
end

return EngineBuffAction
