
---@class CastCharge
local CastCharge = Lib.class("CastCharge")

function CastCharge:ctor()
    self.curCastTime=0
    self.curSkillId=0
    self.curMoveIndex=0
end

function CastCharge:onTouchDown(skillId,skillMoveId,isBurst)
    --print("-------------------CastStrategyNormal:onTouchDown",skillMoveId)
    self:clientStartChargeGameSkill(skillId,skillMoveId,isBurst)
end

function CastCharge:onTouchUp(skillId,skillMoveId,isBurst)
    --print("-------------------CastStrategyNormal:onTouchUp",skillMoveId)
    self:clientStopChargeGameSkill(skillId,skillMoveId,isBurst)
end

function CastCharge:onTouchClick(skillId,skillMoveId)
    --print("-------------------CastStrategyNormal:onTouchClick",skillMoveId)
end

function CastCharge:clear()
end

function CastCharge:clientStartChargeGameSkill(skillId,skillMoveId,isBurst)
    local canFree, skillCd = Me:checkCanFreeSkill(skillId,{skillMoveId=skillMoveId})
    if canFree then
        Me:sendPacket({ pid = "onStartChargeGameSkill", skillId = skillId,skillMoveId=skillMoveId,isBurst=isBurst })
        Me:enterStateType(Define.RoleStatus.SKILL_CHARGE_STATE,skillId,skillMoveId,isBurst)
    end
end

function CastCharge:clientStopChargeGameSkill(skillId,skillMoveId,isBurst)
    Me:sendPacket({ pid = "onStopChargeGameSkill", skillId = skillId,skillMoveId=skillMoveId})
end

return CastCharge
