
---@type CastStrategyBase
local CastStrategyBase = require "client.cast_helper.cast_strategy_base"
---@class CastStrategyCombo
local CastStrategyCombo = Lib.class("CastStrategyCombo","CastStrategyBase")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
local socket = require("socket")
---@type GameSkillHelper
local GameSkillHelper = T(Lib, "GameSkillHelper")

function CastStrategyCombo:ctor()
    self.curCastTime=0
    self.curSkillId=0
    self.curMoveIndex=0
end

function CastStrategyCombo:onTouchDown(skillId)
    CastStrategyBase.onTouchDown(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchDown",skillId)
    if self.longTouchTimer then
        self.longTouchTimer()
        self.longTouchTimer=nil
    end
    self.longTouchTimer=World.Timer(1,function ()
        self:onTouchClick(skillId)
        return true
    end)
end

function CastStrategyCombo:onTouchUp(skillId)
    CastStrategyBase.onTouchUp(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchUp",skillId)
    if self.longTouchTimer then
        self.longTouchTimer()
        self.longTouchTimer=nil
    end
end

function CastStrategyCombo:onTouchClick(skillId)
    CastStrategyBase.onTouchClick(self,skillId)
    --print("-------------------CastStrategyNormal:onTouchClick",skillId)
    --local moveType=CastStrategyBase.getSkillMoveType(self,skillId)
    --if moveType then
    --    moveType:onTouchClick(skillId)
    --end
    if self:needStoreCmd(skillId) then
        self:tryStoreCmd(skillId)
    end
    self:castSkill(skillId,false)
end

function CastStrategyCombo:resetSkillInf(skillId)
    self.curSkillId=skillId
    self.curMoveIndex=0
    self:resetComboInf()
end

function CastStrategyCombo:resetComboInf()
    self.comboMoveSkill=nil
    self.nextMoveIndex=1
end

function CastStrategyCombo:clear()
    self:resetComboInf()
    self:stopComboTimer()
end

function CastStrategyCombo:needStoreCmd(skillId)
    return self.curSkillId==skillId and not self.comboMoveSkill
end

function CastStrategyCombo:tryStoreCmd(skillId)
    if not Me:canStoreSkillCmd() then
        return
    end
    local nextMove,minTime,MaxTime,nextIndex=self:getNextSkillMove(skillId)
    if nextMove then
        local now=socket.gettime()
        if now-self.curCastTime>minTime and now-self.curCastTime<MaxTime then
            self.comboMoveSkill=nextMove
            self.nextMoveIndex=nextIndex
            --print("++++++++++++++++++++++++++++++++++++ tryStoreCmd ",nextMove,self.curMoveIndex,nextIndex)
        else
            self:resetComboInf()
            --print("------------ tryStoreCmd",self.curMoveIndex)
        end
    end
end

function CastStrategyCombo:getNextSkillMove(skillId)
    local cfg=SkillConfig:getSkillConfig(skillId)
    if not cfg or next(cfg.skillMoves)==nil or next(cfg.skillTimes)==nil or self.curMoveIndex<=0 then
        return
    end

    local nextIndex=self.curMoveIndex<#cfg.skillMoves and self.curMoveIndex+1 or 1
    --print("************************* ",nextIndex,self.curMoveIndex,#cfg.skillMoves)
    local skillMove=cfg.skillMoves[nextIndex]
    local minTime,maxTime=SkillConfig:getSkillMoveTime(skillId,nextIndex)
    return skillMove,minTime/1000,maxTime/1000,nextIndex
end

function CastStrategyCombo:castSkill(skillId)
    local skillMoveId=CastStrategyBase.getFirstMove(self,skillId)
    local canFree, skillCd = Me:checkCanFreeSkill(skillId,{skillMoveId=skillMoveId})
    if canFree then
        if skillId~=self.curSkillId then
            self:resetSkillInf(skillId)
        end
        local skillMove=self.comboMoveSkill or skillMoveId
        if self:castMoveSkill(skillMove,skillId) then
            Me:requestCostMp(skillId)
            Lib.emitEvent(Event.EventButtonCDTimer,skillId)
            return true
        end
    end
    return false
end

function CastStrategyCombo:castMoveSkill(moveSkill,skillId)
    --print("===================================== castMoveSkill",moveSkill,id)
    local config = SkillMovesConfig:getNewSkillConfig(moveSkill)
    if config and config.skillName then
        Skill.Cast(config.skillName)
        self:afterCastMoveSkill()
        self:resetComboInf()
        self:startComboTimer(moveSkill)
        return true
    end
    return false
end

function CastStrategyCombo:afterCastMoveSkill()
    self.curMoveIndex=self.nextMoveIndex
    self.curCastTime=socket.gettime()
    --print("^^^^^^^^^^^^^^afterCastMoveSkill",self.curMoveIndex)
end

function CastStrategyCombo:startComboTimer(skillId)
    self:stopComboTimer()
    local duration=(GameSkillHelper:getSkillTotalTime(skillId,Me)/1000)*20
    --print("-----startComboTimer",duration)
    self.comboTimer=World.Timer(duration,function ()
        --print("-----startComboTimer end ",self.comboMoveSkill)
        if self.comboMoveSkill and Me:checkCanFreeSkillMove(false,nil,self.comboMoveSkill) then
            self:castMoveSkill(self.comboMoveSkill)
        end
    end)
end

function CastStrategyCombo:stopComboTimer()
    if self.comboTimer then
        self.comboTimer()
        self.comboTimer=nil
    end
end

function CastStrategyCombo:getFirstMove(skillId)
    local cfg=SkillConfig:getSkillConfig(skillId)
    if cfg then
        return cfg.skillMoves[1]
    end
end

return CastStrategyCombo
