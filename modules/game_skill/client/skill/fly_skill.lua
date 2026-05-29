
---@type SkillBase
local SkillBase = Skill.GetType("Base")
local FlySkill = Skill.GetType("Fly")

---@type setting
local setting = require "common.setting"
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")

FlySkill.targetType = "Any"

function FlySkill:getStartPos(from)
    return SkillBase.getStartPos(self,from)
end

function FlySkill:canCast(packet, from)
    if not SkillBase.canCast(self,packet, from) then
        return false
    end
    return true
end

function FlySkill:setStartPos(packet, from)
    SkillBase.setStartPos(self,packet,from)
end

function FlySkill:preCast(packet, from)
    SkillBase.preCast(self,packet,from)
    if not from then
        return
    end
    if from:isControl() then
    end
end

function FlySkill:cast(packet, from)
    SkillBase.cast(self,packet,from)
    --local CfgMod = setting:mod("skill")
    --local cfg = CfgMod:get(self.fullName)
    --print("------------------------- fly skill cast",cfg.skillId)
end

