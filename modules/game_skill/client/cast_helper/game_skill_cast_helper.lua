
require "client.cast_helper.cast_strategy_base"

---@class GameSkillCastHelper
local GameSkillCastHelper = T(Lib,"GameSkillCastHelper")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")

local CAST_STRATEGY={
    [Define.GameSkillCastType.Normal]=require "client.cast_helper.cast_strategy_normal",
    [Define.GameSkillCastType.Combo]=require "client.cast_helper.cast_strategy_combo",
    [Define.GameSkillCastType.Switch]=require "client.cast_helper.cast_strategy_switch",
    [Define.GameSkillCastType.Burst]=require "client.cast_helper.cast_strategy_burst",
    [Define.GameSkillCastType.Continuous]=require "client.cast_helper.cast_strategy_continuous"
}

function GameSkillCastHelper:onTouchDown(skillId)
    local skillCfg=SkillConfig:getSkillConfig(skillId)
    if not skillCfg then
        return
    end
    local strategy=self:getStrategy(skillCfg.skillMode)
    if not strategy then
        Lib.logError("GameSkillCastHelper:onTouchDown,strategy is nil,skillId:",skillId)
        return
    end
    strategy:onTouchDown(skillId)
end

function GameSkillCastHelper:onTouchUp(skillId)
    local skillCfg=SkillConfig:getSkillConfig(skillId)
    if not skillCfg then
        return
    end
    local strategy=self:getStrategy(skillCfg.skillMode)
    if not strategy then
        Lib.logError("GameSkillCastHelper:onTouchUp,strategy is nil,skillId:",skillId)
        return
    end
    strategy:onTouchUp(skillId)
end

function GameSkillCastHelper:onTouchClick(skillId)
    local skillCfg=SkillConfig:getSkillConfig(skillId)
    if not skillCfg then
        return
    end
    local strategy=self:getStrategy(skillCfg.skillMode)
    if not strategy then
        Lib.logError("GameSkillCastHelper:onTouchClick,strategy is nil,skillId:",skillId)
        return
    end
    strategy:onTouchClick(skillId)
end

function GameSkillCastHelper:cleanAllSkillState()
    local strategy = self:getStrategy(Define.GameSkillCastType.Switch)
    strategy:cleanALlSkillState()
end

function GameSkillCastHelper:clearStrategy(type)
    local strategy = self:getStrategy(type)
    if strategy then
        strategy:clear()
    end
end

---@return CastStrategyBase
function GameSkillCastHelper:getStrategy(skillMode)
    if skillMode and CAST_STRATEGY[skillMode] then
        if not self.castStrategyList then
            self.castStrategyList={}
        end
        if not self.castStrategyList[skillMode] then
            self.castStrategyList[skillMode]=CAST_STRATEGY[skillMode].new()
        end
        return self.castStrategyList[skillMode]
    end
end

