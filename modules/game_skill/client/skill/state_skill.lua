
---@type SkillBase
local SkillBase = Skill.GetType("Base")
local StateSkill = Skill.GetType("State")

---@type setting
local setting = require "common.setting"
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")

StateSkill.targetType = "Any"

function StateSkill:getStartPos(from)
    return SkillBase.getStartPos(self,from)
end

function StateSkill:canCast(packet, from)
    if not SkillBase.canCast(self,packet, from) then
        return false
    end
    return true
end

function StateSkill:setStartPos(packet, from)
    SkillBase.setStartPos(self,packet,from)
end

function StateSkill:preCast(packet, from)
    SkillBase.preCast(self,packet,from)
    if not from then
        return
    end
    if from:isControl() then
    end
end

function StateSkill:cast(packet, from)
    SkillBase.cast(self,packet,from)
    --local CfgMod = setting:mod("skill")
    --local cfg = CfgMod:get(self.fullName)
    --print("------------------------- StateSkill cast")
end

