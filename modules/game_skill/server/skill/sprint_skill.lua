

local SkillMissile = Skill.GetType("Missile")
local SprintSkill = Skill.GetType("Sprint")

SprintSkill.targetType = "Any"

function SprintSkill:getStartPos(from)
    return SkillMissile.getStartPos(self,from)
end

function SprintSkill:cast(packet, from)
    SkillMissile.cast(self,packet,from)
    if not from then
        return
    end
    --if not from then
    --    return
    --end
    --
end

