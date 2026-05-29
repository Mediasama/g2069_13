

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

function StateSkill:cast(packet, from)
    SkillBase.cast(self,packet,from)
    if not from then
        return
    end
    if not from then
        return
    end
    --print("------------------------- StateSkill cast")
    --local CfgMod = setting:mod("skill")
    --local cfg = CfgMod:get(self.fullName)
end

