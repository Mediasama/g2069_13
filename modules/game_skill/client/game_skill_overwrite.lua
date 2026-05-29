
---@type setting
local setting = require "common.setting"
local oldCastByServer = Skill.CastByServer
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")

local castSceneEffectOffset={0,-0.1,0.1,0.2,-0.2}
function Skill.CastByServer(packet)
    oldCastByServer(packet)
    local entity=World.CurWorld:getEntity(packet.fromID)
    if not entity or not entity:isValid() then
        return
    end
    ---@type ModMeta
    local CfgMod = setting:mod("skill")
    local cfg = CfgMod:get(packet.name)
    if cfg and cfg.skillId and cfg.type~="MeleeAttack" then
        Lib.emitEvent(Event.EventCastSkill,cfg.skillId,entity,packet)
    end

    if cfg.castSceneEffect and cfg.castSceneEffect.effect then
        if not entity.castSceneEffectOffsetIndex then
            entity.castSceneEffectOffsetIndex=1
        end
        local effectInf=Lib.copy(cfg.castSceneEffect)
        local offset=castSceneEffectOffset[entity.castSceneEffectOffsetIndex] or 0
        entity.castSceneEffectOffsetIndex=entity.castSceneEffectOffsetIndex+1
        if entity.castSceneEffectOffsetIndex > #castSceneEffectOffset then
            entity.castSceneEffectOffsetIndex=1
        end
        --print("_________________ offset",offset,entity.castSceneEffectOffsetIndex)
        effectInf.pos.x=effectInf.pos.x+offset
        --print("---------------Skill.CastByServer castSceneEffect_",cfg.skillId,entity.objID,cfg.castSceneEffect.effect,packet.autoCast)
        local name = string.format("castSceneEffect_%d_%d_%d", entity.objID, cfg.skillId or 0,World.CurWorld:getTickCount())
        local delay=cfg.castSceneEffect.delay or 0
        World.Timer(delay*20,function ()
            if entity:isValid() then
                if packet.autoCast then
                    local pos=(packet.startPos or entity:getPosition()) + effectInf.pos
                    local dur=World.cfg.game_skillSetting.castSceneEffectDuration or 4000
                    Blockman.instance:playEffectByPos(effectInf.effect,pos,
                            360 - entity:getBodyYaw(), effectInf.time or dur, effectInf.scale or {x = 1, y = 1, z = 1})
                    --local clonePosition = Vector3.new(effectInf.effect.pos.x, 0,effectInf.effect.pos.z)
                    --local yaw = -self:getBodyYaw()
                    --local rotation = Vector3.new(0, yaw, 0)
                    --Lib.rotate(clonePosition, rotation)
                    --clonePosition.y=effectInf.effect.pos.y
                    --local pos = self:getPosition() + clonePosition
                    --Blockman.instance:playEffectByPos(effectInf.effect.effect, pos, 360 - self:getBodyYaw() + effectInf.effect.yaw,
                    --        effectInf.effect.time or dur, effectInf.effect.scale or {x = 1, y = 1, z = 1})
                else
                    entity:showSkillSceneEffect(effectInf,nil,name)
                end
            end
        end)
    end
end

local SkillBase = Skill.GetType("Base")
local oldPreCast=SkillBase.preCast
function SkillBase:preCast(packet, from)
    if self.type=="MeleeAttack" then
        return
    end
    oldPreCast(self,packet, from)
    if from and from:isValid() and self.skillId then
        if from:isInStateType(Define.RoleStatus.SKILL_ACTION_STATE) then
            from:exitStateType(Define.RoleStatus.SKILL_ACTION_STATE)
        end
        from:enterStateType(Define.RoleStatus.SKILL_ACTION_STATE,self.skillId,packet.chargeTimeRate)
        local cfg=SkillMovesConfig:getNewSkillConfig(self.skillId)
        --print(">>>>>>>>>>>>>>>>>> SkillBase:preCast from:getCurChildActor() ",from:getCurChildActor())
        if cfg and cfg.childActorAction and from:getCurChildActor() then
            from:playChildBaseAction(from:getCurChildActor(), cfg.skillInf.castAction)
        end
    end
end

