local AIStateBase = require("entity.ai.ai_state_base")
local AIEvaluator = require("server.entity.ai.ai_evaluator_engine_overwrite")

local AIStateIdle = L("AIStateIdle", Lib.derive(AIStateBase))
AIStateIdle.NAME = "IDLE"

local function sendPlayAction(entity, action, time)
	entity:sendPacketToTracking({
		pid = "EntityPlayAction",
		objID = entity.objID,
		action = action,
		time = time,
	})
end

function AIStateIdle:enter()
	local entity = self:getEntity()
	local control = self.control

	local lastState = control:getLastState()
	if lastState and ((lastState.NAME ~= self.NAME) or (lastState.NAME ~= "RANDMOVE")) then
		control:setAiData("homePos", entity:getPosition())
	end

	local idleAction = control:aiData("idleAction")
	local lastState = control:getLastState()
	if not lastState then
		if idleAction then
			sendPlayAction(entity, idleAction, -1)
			self.playAction = true
		end
	elseif lastState and lastState.NAME ~= self.NAME then
		if idleAction then
			sendPlayAction(entity, idleAction, -1)
			self.playAction = true
		end
		control:setTargetPos()
	end
	if entity:isInStateType(Define.RoleStatus.BATTLE_STATE) then
		entity:exitStateType(Define.RoleStatus.BATTLE_STATE)
	end

	local timeRange = control:aiData("idleTime") or {5, 10}
	local min = math.ceil(timeRange[1])
	local max = math.ceil(timeRange[2])
	local idleTime = math.random(min, max)
	self.endTime = World.Now() + idleTime

	local idleStartTime = control:aiData("idleStartTime")
	if idleStartTime < 0 then
		control:setAiData("idleStartTime", os.time())
		control:setAiData("enterIdlePos", entity:getPosition())
	end
end

function AIStateIdle:update()

end

function AIStateIdle:aiStateIsEnd()
	return self.endTime - World.Now() <= 0
end

function AIStateIdle:exit()
	if self.playAction then
		sendPlayAction(self:getEntity(), "idle", 0)
		self.playAction = nil
	end
end

RETURN(AIStateIdle)
