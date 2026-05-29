
local SkillMissile = Skill.GetType("Missile")
local SprintSkill = Skill.GetType("Sprint")

---@type SprintSkillHelper
local SprintSkillHelper = T(Lib, "SprintSkillHelper")
---@type setting
local setting = require "common.setting"
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")

SprintSkill.targetType = "Any"

function SprintSkill:getStartPos(from)
    return SkillMissile.getStartPos(self,from)
end

function SprintSkill:canCast(packet, from)
    if not SkillMissile.canCast(self,packet, from) then
        return false
    end
    return true
end

function SprintSkill:setStartPos(packet, from)
    SkillMissile.setStartPos(self,packet,from)
end

function SprintSkill:preCast(packet, from)
    SkillMissile.preCast(self,packet,from)
    if not from then
        return
    end
    if from:isControl() then
        -----@type ModMeta
        --local CfgMod = setting:mod("skill")
        --local cfg = CfgMod:get(self.fullName)
        --if cfg and cfg.skillId then
        --    local skillCfg=SkillMovesConfig:getNewSkillConfig(cfg.skillId)
        --    if skillCfg and skillCfg.move then
        --        --print("----------------SprintSkill:cast",Lib.v2s(skillCfg.move))
        --        ---TODO 需要停止上一个计时器
        --        local dirX,dirY,dirZ=SprintSkillHelper:enterSprintSkillState2(from,skillCfg.move)
        --        from:setSprintMotion({dirX,dirY,dirZ})
        --        --print("-----------------------------SprintSkill:preCast,sprintMotion",dirX,dirY,dirZ)
        --        World.Timer(skillCfg.move.duration*20,function ()
        --            SprintSkillHelper:exitSprintSkillState2(from)
        --        end)
        --    end
        --end
    end
end

function SprintSkill:cast(packet, from)
    SkillMissile.cast(self,packet,from)
end

