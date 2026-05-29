local AIEvaluator = require("server.entity.ai.ai_evaluator_engine_overwrite")
local AIStateBase = require("entity.ai.ai_state_base")

local AIStateChase = L("AIStateChase", Lib.derive(AIStateBase))
AIStateChase.NAME = "CHASE"

---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")

function AIStateChase:enter()
	local entity = self:getEntity()
	local control = self.control
	local lastState = control:getLastState()
	if not entity:isInStateType(Define.RoleStatus.BATTLE_STATE) then
		entity:enterStateType(Define.RoleStatus.BATTLE_STATE)
	end

	self.endTime = World.Now() + 2

	local chaseMoveSpeed = AttributeSystem:getAttributeValue(entity, Define.ATTR.MOVE_SPEED)
	if chaseMoveSpeed and (chaseMoveSpeed ~= entity:prop("moveSpeed")) then
		entity:setProp("moveSpeed", chaseMoveSpeed)
	end

	control:setAiData("idleStartTime", -1)
end

function AIStateChase:update()
end

function AIStateChase:aiStateIsEnd()
	return self.endTime - World.Now() <= 0
end

function AIStateChase:exit()

end

RETURN(AIStateChase)