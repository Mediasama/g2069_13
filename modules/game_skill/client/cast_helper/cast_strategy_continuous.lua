
---@type CastStrategyBase
local CastStrategyBase = require "client.cast_helper.cast_strategy_base"
---@class CastStrategyContinuous
local CastStrategyContinuous = Lib.class("CastStrategyContinuous","CastStrategyBase")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")

function CastStrategyContinuous:ctor()
    CastStrategyBase.ctor(self)
    self.curCastTime=0
    self.curSkillId=0
    self.curMoveIndex=0

    Lib.subscribeEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function()
        self:clear()
    end)

    Lib.subscribeEvent(Event.EVENT_CLIENT_PLAYER_DEAD, function()
        self:clear()
    end)

    Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player)
        if not success then
            return
        end
        if player and  player:isValid() then
            self:clear()
        end
    end)
end

function CastStrategyContinuous:onTouchDown(skillId)
    CastStrategyBase.onTouchDown(self,skillId)
    self.curContinuousSkill=skillId
    self.curContinuousMove=CastStrategyBase.getFirstMove(self,skillId)
    --print("-------------------CastStrategyContinuous:onTouchDown",skillId)
    self:castSkill(skillId)
end

function CastStrategyContinuous:onTouchUp(skillId)
    CastStrategyBase.onTouchUp(self,skillId)
    --print("-------------------CastStrategyContinuous:onTouchUp",skillId)
    if Me.ContinuousCostMPTimer then
        self:stopContinuous(skillId,CastStrategyBase.getFirstMove(self,skillId))
    end
end

function CastStrategyContinuous:onTouchClick(skillId)
    CastStrategyBase.onTouchClick(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchClick",skillId)
end

function CastStrategyContinuous:clear()
    self:stopTimer()
end

function CastStrategyContinuous:castSkill(skillId)
    local moveId=CastStrategyBase.getFirstMove(self,skillId)
    local canFree, skillCd = Me:checkCanFreeSkill(skillId,{skillMoveId=moveId})
    if canFree then
        if self:castMoveSkill(moveId,skillId) then
            local config = SkillConfig:getSkillConfig(skillId)
            self:stopTimer()
            Me.ContinuousCostMPTimer=World.Timer(20,function()
                Me:requestCostMp(skillId,function(mp)
                    if mp <= 0 then
                        self:stopContinuous(skillId,moveId)
                    end
                end)
                return true
            end)
        end
    end
end

function CastStrategyContinuous:castMoveSkill(moveSkill,skillId)
    --print("===================================== castMoveSkill",moveSkill,id)
    local config = SkillMovesConfig:getNewSkillConfig(moveSkill)
    if config and config.skillName then
        Skill.Cast(config.skillName,{skillId=skillId})
        return true
    end
    return false
end

function CastStrategyContinuous:stopTimer()
    if Me.ContinuousCostMPTimer then
        Me.ContinuousCostMPTimer()
        Me.ContinuousCostMPTimer=nil
    end
end

function CastStrategyContinuous:stopContinuous(skillId,moveSkillId,exCD)
    self:stopTimer()
    Me:sendPacket({ pid = "RequestStopContinuous",skillId=skillId,moveSkillId=moveSkillId})
    Lib.emitEvent(Event.EventButtonCDTimer,skillId,exCD)
end



return CastStrategyContinuous
