--- entity_event.lua
local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)

local events = {}
---@type TargetConditionHelper
local TargetConditionHelper = T(Lib, "TargetConditionHelper")

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

    --- 是否掉落物品
    if part:isTeleport() and not part:isTeleportClose() then
        local teleport_map = part:getAttribute("teleport_map")
        local to_teleport_id = part:getAttribute("to_teleport_id")
        --- 传送
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_TRIGGER_TELEPORT, self, teleport_map, to_teleport_id)
    elseif part:isMissionGate() and not part:isMissionGateClose() then
        --- 进入副本
        --- 传送
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_TRIGGER_MISSION_TELEPORT, self, part)
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
    local partId = part:getInstanceID()
    TargetConditionHelper:updatePlayerPartRegionData(self, partName, partId, false)
end