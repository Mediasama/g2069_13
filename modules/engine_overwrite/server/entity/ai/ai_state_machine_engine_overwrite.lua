
local AIStateMachine = require("entity.ai.ai_state_machine")
local AIEvaluator = require("server.entity.ai.ai_evaluator_engine_overwrite")

function AIStateMachine:addState(state)
	self.states[state.NAME] = state
	self.stateCount = self.stateCount + 1
end

function AIStateMachine:setState(state)
	if not state then
		return
	end
	local curState = self.curState
	if curState and curState.NAME ~= state.NAME then
		curState:exit()
	end
	state:enter()
	self.lastState = self.curState
	self.curState = state
end

function AIStateMachine:startAI()
	if self.updateTimer then
		self.updateTimer()
		self.updateTimer = nil
	end
	self.updateTimer = self.entity:lightTimer("AIStateMachine:startAI", 2, function()
		self:update()
		return true
	end)
end

function AIStateMachine:stopAI()
	local curState = self.curState
	if curState then
		curState:exit()
		self.curState = nil
		self.lastState = nil
	end
	if self.updateTimer then
		self.updateTimer()
		self.updateTimer = nil
	end
	local entityData = self.control:getEntity():data("aiData")
	entityData.stateMachine = nil
end

function AIStateMachine:update()
	local entity = self.entity
	if not entity or not entity:isValid() or entity.curHp <= 0 then
		self:stopAI()
		return
	end

	if self.control:isInForceBackBornPos() then
		return
	end

	if self.control:getPauseState() then
		return
	end

	if not self.curState then
		return
	end
	self.curState:update()

	if (self.curState.NAME == "RANDMOVE") or (self.curState.NAME == "IDLE") then
		local nearEnemy = self.control:getCanChaseEnemy()
		if nearEnemy and nearEnemy:isValid() and nearEnemy.isPlayer then
			self:doTransition()
			return
		end
	end

	if self.curState:aiStateIsEnd() then
		self:doTransition()
	end
end

function AIStateMachine:doTransition()
	local nextState
	local states = self.states
	local control = self.control
	local curState = self.curState

	if not curState then
		self:setIdleState()
		curState = self.curState
	end

	for _, transition in ipairs(self.transitions[curState.NAME]) do
		local state = states[transition.name]
		Profiler:begin("ai evaluator ".. transition.name)
		if state and transition.evaluator(control) then
			Profiler:finish("ai evaluator ".. transition.name)
			nextState = state
			break
		end
		Profiler:finish("ai evaluator ".. transition.name)
	end
	self:setState(nextState)
end

RETURN(AIStateMachine)
