

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

function FlySkill:cast(packet, from)
    SkillBase.cast(self,packet,from)
    if not from then
        return
    end
    if not from then
        return
    end
    --local CfgMod = setting:mod("skill")
    --local cfg = CfgMod:get(self.fullName)

    local skillCfg =  SkillMovesConfig:getNewSkillConfig(packet.skillId)
    --print("------------------------- fly skill cast",packet.skillId,#skillCfg.buffList)
    if skillCfg and skillCfg.buffList then
        for _, buffId in pairs(skillCfg.buffList) do
            from:updateSkillBuffById(buffId, true)
        end
    end
    from:enterStateType(Define.RoleStatus.SKILL_FLY_STATE,packet.skillId)
end

