--- entity_event.lua

local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)
---@type TargetConditionHelper
local TargetConditionHelper = T(Lib, "TargetConditionHelper")

local events = {}

function entity_event(entity, event, ...)
    entityEventEngineHandler(entity, event, ...)
    local func = events[event]
    if func then
        func(entity, ...)
    end
end

---@param part Instance
---@param collidePos any
---@param normalOnSecondObject any
---@param distance any
function events:entityTouchPartBegin(part, collidePos, normalOnSecondObject, distance)
    if not self:isValid() or not part or not part:isValid() or not self.isPlayer then
        return
    end

    local partName = part:getProperty("name")
    if not partName then
        return
    end


    if part:isSceneDropItem() then
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_ITEM, self, part)
    elseif part:isDropAbility() then
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_ABILITY, self, part)
    elseif part:isTreasureBox() then
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_TREASURE_BOX, self, part)
    elseif part:isMagmaPart() then
        if World.cfg.magmaPartHurtBuff and World.cfg.magmaPartHurtBuff > 0 then
            self:updateSkillBuffById(World.cfg.magmaPartHurtBuff, true)
        end
    end
    local partId = part:getInstanceID()
    TargetConditionHelper:updatePlayerPartRegionData(self, partName, partId, true)
end

function events:entityTouchPartUpdate(part, collidePos, normalOnSecondObject, distance)

end

function events:entityTouchPartEnd(part, collidePos, normalOnSecondObject, distance)
    if not self:isValid() or not part or not part:isValid() or not self.isPlayer then
        return
    end

    local partName = part:getProperty("name")
    if not partName then
        return
    end

    if part:isMagmaPart() then
        if World.cfg.magmaPartHurtBuff and World.cfg.magmaPartHurtBuff > 0 then
            self:updateSkillBuffById(World.cfg.magmaPartHurtBuff, false)
        end
    end
    local partId = part:getInstanceID()
    TargetConditionHelper:updatePlayerPartRegionData(self, partName, partId, false)
end