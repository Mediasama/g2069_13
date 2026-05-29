
---@type CastStrategyBase
local CastStrategyBase = require "client.cast_helper.cast_strategy_base"
---@class CastStrategyBurst
local CastStrategyBurst = Lib.class("CastStrategyBurst","CastStrategyBase")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")

function CastStrategyBurst:ctor()
    CastStrategyBase.ctor(self)
    self.curCastTime=0
    self.curSkillId=0
    self.curMoveIndex=0
end

function CastStrategyBurst:onTouchDown(skillId)
    CastStrategyBase.onTouchDown(self,skillId)
    --print("-------------------CastStrategyBurst:onTouchDown",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        CastStrategyBase.getCastCharge(self):onTouchDown(skillId,skillMove,true)
    end
end

function CastStrategyBurst:onTouchUp(skillId)
    CastStrategyBase.onTouchUp(self,skillId)
    --print("-------------------CastStrategyBurst:onTouchUp",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        CastStrategyBase.getCastCharge(self):onTouchUp(skillId,skillMove,true)
    end
end

function CastStrategyBurst:onTouchClick(skillId)
    CastStrategyBase.onTouchClick(self,skillId)
    --print("-------------------CastStrategyBurst:onTouchClick",skillId)
    local skillMove=CastStrategyBase.getFirstMove(self,skillId)
    if not SkillMovesConfig:getIsChargeSkillMove(skillMove) then
        local canFree= Me:checkCanFreeSkill(skillId,{skillMoveId=skillMove})
        if canFree then
            Me:enterStateType(Define.RoleStatus.SKILL_BURST_STATE,skillId)
        end
    end
end

function CastStrategyBurst:clear()
end

Lib.subscribeEvent(Event.EVENT_BURST_CAST_SKILL,function (skillId,skillIndex,isCharge,chargeTimeRate)
    if not skillId or not skillIndex then
        return
    end
    --print("================================== receive Event.EVENT_BURST_CAST_SKILL",skillId,skillIndex,isCharge,chargeTimeRate)
    local cfg=SkillConfig:getSkillConfig(skillId)
    if not cfg or not cfg.skillMoves[skillIndex]then
        return
    end
    local moveCfg = SkillMovesConfig:getNewSkillConfig(cfg.skillMoves[skillIndex])
    if moveCfg and moveCfg.skillName then
        if Me:checkCanFreeSkillMove(true,nil,cfg.skillMoves[skillIndex]) then
            local needCheckCD=skillIndex==1 and not isCharge
            local packet={}
            if needCheckCD then
                packet.skillId=skillId
            end
            packet.chargeTimeRate=chargeTimeRate
            Skill.Cast(moveCfg.skillName,packet)
            if skillIndex ==1 then
                local config = SkillConfig:getSkillConfig(skillId)
                Me:requestCostMp(skillId)
                Lib.emitEvent(Event.EventButtonCDTimer,skillId)
            end
        end
    end
end)

return CastStrategyBurst
