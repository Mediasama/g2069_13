
local SkillBase = Skill.GetType("Base")
local MeleeAttack = Skill.GetType("MeleeAttack")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")

function MeleeAttack:cast(packet, from)
    local target = World.CurWorld:getEntity(packet.targetID)
    if not target then
        print("MeleeAttack wrong target!", packet.targetID)
        return
    end
    if not from:canAttack(target) then
        return false
    end
    --print("************************************* MeleeAttack:cast, chargeTimeRate",packet.chargeTimeRate,self.fullName)
    packet.damage = from:doAttack({target = target, skill = self, originalSkillName = packet.name or self.fullName,
                                   cause = "ENGINE_MELEE_ATTACK",packet=packet}) or 0

    local v = Lib.v3(0,0,0)
    local self_useExpressionPropMap, from_useExpressionPropMap = self.useExpressionPropMap or {}, from:cfg().useExpressionPropMap or {}
    local hurtDistanceExpression = self_useExpressionPropMap.hurtDistanceExpression or from_useExpressionPropMap.hurtDistanceExpression
    local dis = hurtDistanceExpression and Lib.getExpressionResult(hurtDistanceExpression, {target = target, from = from, packet = packet}) or self.hurtDistance
    if dis ~= 0 then
        v = target:getPosition() - Lib.tov3(from:getPosition())
        v.y = 0
        v:normalize()
        v = v * dis
        v.y = dis
    end
    target:doHurt(v)
    SkillBase.cast(self, packet, from)
end

local oldExtCheckConsume=SkillBase.extCheckConsume
function SkillBase:extCheckConsume(packet, from)
    if not oldExtCheckConsume(packet,from) then
        return false
    end
    if packet.skillId and from and from:isValid() then
        local result=from:checkCanFreeSkill(packet.skillId)
        --print("------------ SkillBase:extCheckConsume,result",result)
        return result
    end
    return true
end

function MissileServer:onHitEntity()
    local cfg = self:cfg()
    local target = self:lastHitEntity()
    if not target then
        return
    end
    local id = self.params.fromID
    ---@type Entity
    local owner = id and self.world:getObject(id)

    local cfg=SkillMovesConfig:getNewSkillConfig(self:cfg().skillId)
    if cfg and cfg.isBeMissAttack then
        local defender = target
        if BattleSystem:isDodge(owner, defender) then
            return
        end
    end

    Trigger.CheckTriggers(target:cfg(), "ENTITY_HITTED", {obj1=target,obj2=owner,missile=self})
    Trigger.CheckTriggers(cfg, "HIT_ENTITY", {obj1=target,obj2=owner,missile=self})
    if owner then
        Trigger.CheckTriggersOnly(owner:cfg(), "HIT_ENTITY", {obj1=owner,obj2=target,missile=self})
    end
    Missile.onHitEntity(self)
end
