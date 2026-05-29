local RoleStateBase = require "common.state.base_state"

--- @class InTeleportState : RoleStateBase
local InTeleportState = Lib.class("InTeleportState", RoleStateBase)

function InTeleportState:init(type)
    RoleStateBase.init(self, type or Define.RoleStatus.IN_TELEPORT)
end

function InTeleportState:enterState(objID, enterTime, totalTime)
    RoleStateBase.enterState(self, objID)
    --- 派发事件
    Lib.emitEvent(Event.EVENT_SCENE_OBJECT_TELEPORT_WAIT, objID)
end

function InTeleportState:exitState(objID)
    RoleStateBase.exitState(self, objID)
    --- 派发事件
    Lib.emitEvent(Event.EVENT_SCENE_OBJECT_TELEPORT_MAP, objID)
end

return InTeleportState