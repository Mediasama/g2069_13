
---@type CastStrategyBase
local CastStrategyBase = require "client.cast_helper.cast_strategy_base"
---@class CastStrategyNormal
local CastStrategyNormal = Lib.class("CastStrategyNormal","CastStrategyBase")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
---@type GameSkillHelper
local GameSkillHelper = T(Lib, "GameSkillHelper")

function CastStrategyNormal:ctor()
    CastStrategyBase.ctor(self)
    self.curCastTime=0
    self.curSkillId=0
    self.curMoveIndex=0
end

function CastStrategyNormal:onTouchDown(skillId)
    CastStrategyBase.onTouchDown(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchDown",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        CastStrategyBase.getCastCharge(self):onTouchDown(skillId,skillMove)
    end
end

function CastStrategyNormal:onTouchUp(skillId)
    CastStrategyBase.onTouchUp(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchUp",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        CastStrategyBase.getCastCharge(self):onTouchUp(skillId,skillMove)
    end
end

function CastStrategyNormal:onTouchClick(skillId)
    CastStrategyBase.onTouchClick(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchClick",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if not SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        self:castSkill(skillId,false)
    end
end

function CastStrategyNormal:clear()
end

function CastStrategyNormal:castSkill(skillId)
    local skillMoveId=CastStrategyBase.getFirstMove(self,skillId)
    local canFree, skillCd = Me:checkCanFreeSkill(skillId,{skillMoveId=skillMoveId})
    if canFree then
        if self:castMoveSkill(skillMoveId,skillId) then
            local config = SkillConfig:getSkillConfig(skillId)
            Me:requestCostMp(skillId)
            Lib.emitEvent(Event.EventButtonCDTimer,skillId)
            return true
        end
    end
    return false
end

function CastStrategyNormal:castMoveSkill(moveSkill,skillId)
    --print("===================================== castMoveSkill",moveSkill,id)
    local config = SkillMovesConfig:getNewSkillConfig(moveSkill)
    if config and config.skillName then
        Skill.Cast(config.skillName,{skillId=skillId})
        return true
    end
    return false
end

return CastStrategyNormal
