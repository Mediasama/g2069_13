
---@class CastStrategyBase
local CastStrategyBase = Lib.class("CastStrategyBase")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")

local castCharge= require "client.cast_helper.cast_charge"


function CastStrategyBase:ctor()
end

function CastStrategyBase:cleanALlSkillState(skillId)

end

function CastStrategyBase:onTouchDown(skillId)

end

function CastStrategyBase:onTouchUp(skillId)

end

function CastStrategyBase:onTouchClick(skillId)

end

function CastStrategyBase:getFirstMove(skillId)
    local cfg=SkillConfig:getSkillConfig(skillId)
    if cfg then
        return cfg.skillMoves[1]
    end
end

function CastStrategyBase:getCastCharge()
    if not self.castCharge then
        self.castCharge=castCharge.new()
    end
    return self.castCharge
end

function CastStrategyBase:isCharge(skillMoveId)
    return
end

return CastStrategyBase