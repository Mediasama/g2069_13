local ai_control_mgr = require("entity.ai.ai_control_mgr")
local AIStateMachine = require("server.entity.ai.ai_state_machine_engine_overwrite")
local AIStateAttack = require("server.entity.ai.ai_state_attack_engine_overwrite")
local AIStateChase = require("server.entity.ai.ai_state_chase_engine_overwrite")
local AIStateIdle = require("server.entity.ai.ai_state_idle_engine_overwrite")
local AIStateRandMove = require("server.entity.ai.ai_state_randmove_engine_overwrite")
local AIEvaluator = require("server.entity.ai.ai_evaluator_engine_overwrite")

---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")

local traceback = traceback
local math = math
local mrand = math.random
local mmax = math.max
local mmin = math.min
local msin = math.sin
local mcos = math.cos
local PI = math.pi
local pairs = pairs
local ipairs = ipairs
local lossEnemyTime = 40
local socket = require("socket.core")

local function newAIState(self, stateClass)
	local state = Lib.derive(stateClass)
	state:init(self)
	return state
end

function AIControl:loadDataByConfig()
	local entity = self:getEntity()
	local config = entity:cfg()

	self:setAiData("randMoveTime", config.randMoveTime)

	local monsterCfg = MonsterConfig:getCfgByMonsterId(config.monsterId)
	if monsterCfg then
		self:setAiData("dangerDistance", monsterCfg.dangerDistance or 0)
		self:setAiData("chaseDistance", monsterCfg.chaseDistance or 0)
		self:setAiData("hurtChaseTime", monsterCfg.hurtChaseTime or 0)
		self:setAiData("attackSkill", monsterCfg.attackSkill or {})
		self:setAiData("skillGroup", monsterCfg.skillGroup or {})
		self:setAiData("skillTotalCD", monsterCfg.skillTotalCD or 0)
		self:setAiData("monsterType", monsterCfg.monsterType or 1)
	end
	entity:data("main").lastFreeSkillTime = socket.gettime()

	self:setAiData("pauseState", false)
	self:setAiData("idleStartTime", -1)
	self:setAiData("dangerHatred", {})
	self:setAiData("hurtHatred", {})
	self:setAiData("enterIdlePos", Lib.v3(0,0,0))
end

function AIControl:start()
	local entity = self:getEntity()
	self:loadDataByCfg()
	self:loadDataByConfig()
	local machine = self:aiData("stateMachine")
	if machine then
		machine:stopAI()
	end
	
	if self:aiData("enableStateMachine") == false then
		return
	end

	self:setAiData("homePos", entity:getPosition())

	machine = AIStateMachine.create(self)
	self:setAiData("stateMachine", machine)

	local stateAttack, stateChase, stateIdle, stateRandMove

	stateAttack = newAIState(self, AIStateAttack)
	stateChase = newAIState(self, AIStateChase)
	stateIdle = newAIState(self, AIStateIdle)
	stateRandMove = newAIState(self, AIStateRandMove)

	local list = {
			stateIdle,
			stateRandMove,
			stateChase,
			stateAttack,
		}
	for _, state in pairs(list) do
		machine:addState(state)
		machine:addTransition(state, stateAttack, AIEvaluator.CanAttackEnemy)
		machine:addTransition(state, stateChase, AIEvaluator.CanChaseEnemy)
		machine:addTransition(state, stateRandMove, function(control)
			local idleProb = self:aiData("idleProb") or 0.5
			if idleProb >= 1 then
				local lastState = control:getLastState()
				if not lastState then
					return true
				end
				if lastState.NAME == "CHASE" or lastState.NAME == "ATTACK" then
					return true
				end
			end
			return mrand() > idleProb
		end)
		machine:addTransition(state, stateIdle, AIEvaluator.True)
	end
	machine:setState(stateRandMove)
	machine:startAI()
end

function AIControl:stop()
	self:setTargetPos(nil, false)
	local machine = self:getMachine()
	if machine then
		machine:stopAI()
	end
	local entity = self:getEntity()
	if entity then
		entity.isMoving = false
	end
end

function AIControl:setPauseState(value,priority)
	local entity = self:getEntity()
	if not entity or not entity:isValid() then
		return
	end

	if not entity.pauseStateFlag then
		entity.pauseStateFlag={}
	end
	local pri=priority or Define.PauseStatePriority.BlowAway
	local flag=false
	entity.pauseStateFlag[pri]=value
	for i = Define.PauseStatePriorityLen, 1,-1 do
		local v=entity.pauseStateFlag[i]
		--print("************ setPauseState",i,v)
		if v~=nil then
			flag=v
			break
		end
	end
	--print("************ setPauseState",flag)
	self:setAiData("pauseState", flag)
end

function AIControl:getPauseState()
	return self:aiData("pauseState")
end

function AIControl:getDangerDistanceEnemy()
	local entity = self:getEntity()
	local dangerDistance = self:aiData("dangerDistance")
	local dangerSqr
	if dangerDistance then
		dangerSqr = dangerDistance*dangerDistance
	end

	local curMap = entity.map
	local curMiniDanger, dangerEnemy
	for playerId, target in pairs(curMap.players or {}) do
		if target.isPlayer then
			if target:isInCanChasedState() then
				local disSqr = entity:distanceSqr(target)
				if dangerSqr and disSqr <= dangerSqr then
					if curMiniDanger and (disSqr <= curMiniDanger) then
						dangerEnemy, curMiniDanger = target, disSqr
					else
						dangerEnemy, curMiniDanger = target, disSqr
					end
				end
			end
		end
	end

	if dangerEnemy then
		local dangerHatred = self:aiData("dangerHatred") or {}
		dangerHatred.fromObjID = dangerEnemy.objID
		dangerHatred.fromTime = World.Now()
		self:setAiData("dangerHatred", dangerHatred)
	end
	return dangerEnemy
end

function AIControl:getChaseFinishDistance()
	local miniChaseDis =  self:aiData("miniChaseDis")
	if miniChaseDis then
		return miniChaseDis -0.1
	else
		local minRange = 9999999
		local attackSkill = self:aiData("attackSkill")
		local freeRange1 = attackSkill[2] or 2
		if freeRange1 < minRange then
			minRange = freeRange1
		end

		local skillGroup = self:aiData("skillGroup")
		for _, skillData in pairs(skillGroup) do
			local freeRange = skillData.freeRange or 4
			if freeRange < minRange then
				minRange = freeRange
			end
		end
		self:setAiData("miniChaseDis", minRange)
		return minRange-0.1
	end
end

function AIControl:getHurtSelfEnemy()
	local entity = self:getEntity()
	local hurtChaseTime = self:aiData("hurtChaseTime")
	local hurtHatred = self:aiData("hurtHatred") or {}
	if hurtHatred.fromObjID then
		local target = World.CurWorld:getObject(hurtHatred.fromObjID)
		if not target or not target:isValid() then
			self:setAiData("hurtHatred", {})
		else
			if entity.map.name ~= target.map.name then
				self:setAiData("hurtHatred", {})
				return
			end
			local hatredTime = hurtHatred.fromTime
			if World.Now() - hatredTime <= hurtChaseTime*20 then
				if target:isInCanChasedState() then
					return target
				else
					self:setAiData("hurtHatred", {})
				end
			else
				self:setAiData("hurtHatred", {})
			end
		end
	end
end

function AIControl:getChaseDistanceEnemy()
	local entity = self:getEntity()
	local chaseDistance = self:aiData("chaseDistance")
	local chaseSqr
	if chaseDistance then
		chaseSqr = chaseDistance*chaseDistance
	end

	local dangerHatred = self:aiData("dangerHatred") or {}
	if dangerHatred.fromObjID then
		local target = World.CurWorld:getObject(dangerHatred.fromObjID)
		if not target or not target:isValid() then
			self:setAiData("dangerHatred", {})
		else
			if entity.map.name ~= target.map.name then
				self:setAiData("dangerHatred", {})
				return
			end
			local disSqr = entity:distanceSqr(target)
			if chaseSqr and disSqr <= chaseSqr then
				if target:isInCanChasedState() then
					return target
				else
					self:setAiData("dangerHatred", {})
				end
			else
				self:setAiData("dangerHatred", {})
			end
		end
	end
end

function AIControl:getMissionEnemyDistanceEnemy()
	local entity = self:getEntity()
	local curMap = entity.map
	local curMiniDanger, dangerEnemy
	for playerId, target in pairs(curMap.players or {}) do
		if target.isPlayer then
			if target:isInCanChasedState() then
				local disSqr = entity:distanceSqr(target)
				if curMiniDanger and (disSqr <= curMiniDanger) then
					dangerEnemy, curMiniDanger = target, disSqr
				else
					dangerEnemy, curMiniDanger = target, disSqr
				end
			end
		end
	end
	return dangerEnemy
end

function AIControl:getCanChaseEnemy()
	local monsterType = self:aiData("monsterType")
	if monsterType == Define.MonsterType.MISSION then
		local hurtEnemy = self:getHurtSelfEnemy()
		if hurtEnemy and hurtEnemy:isValid() and hurtEnemy.isPlayer then
			return hurtEnemy
		end
		
		local dangerEnemy = self:getDangerDistanceEnemy()
		if dangerEnemy and dangerEnemy:isValid() and dangerEnemy.isPlayer then
			return dangerEnemy
		end

		local chaseEnemy = self:getChaseDistanceEnemy()
		if chaseEnemy and chaseEnemy:isValid() and chaseEnemy.isPlayer then
			return chaseEnemy
		end

		local missionEnemy = self:getMissionEnemyDistanceEnemy()
		if missionEnemy and missionEnemy:isValid() and missionEnemy.isPlayer then
			return missionEnemy
		end
	else
		local dangerEnemy = self:getDangerDistanceEnemy()
		if dangerEnemy and dangerEnemy:isValid() and dangerEnemy.isPlayer then
			return dangerEnemy
		end

		local hurtEnemy = self:getHurtSelfEnemy()
		if hurtEnemy and hurtEnemy:isValid() and hurtEnemy.isPlayer then
			return hurtEnemy
		end

		local chaseEnemy = self:getChaseDistanceEnemy()
		if chaseEnemy and chaseEnemy:isValid() and chaseEnemy.isPlayer then
			return chaseEnemy
		end
	end
	return false
end

function AIControl:isInForceBackBornPos()
	local entity = self:getEntity()
	local pos1 = entity:getPosition()

	local regionBirthMap = entity:data("main").regionBirthMap
	if entity.map and regionBirthMap.map and entity.map.name ~= regionBirthMap.map.name then
		return true
	end

	local regionBirthPos = entity:data("main").regionBirthPos
	local maxMoveDistance = entity:data("main").regionMaxDis
	local maxHeightDistance = entity:data("main").regionMaxHeight

	local idleStartTime = self:aiData("idleStartTime")
	local cfg = entity:cfg()
	local idleReBornTime = cfg.idleReBornTime or 0
	if (idleStartTime > 0) and (os.time() - idleStartTime > idleReBornTime) then
		local patrolDis = self:aiData("patrolDistance")
		local y = regionBirthPos.y
		local x = regionBirthPos.x + patrolDis
		local z = regionBirthPos.z + patrolDis
		local maxPos = Lib.v3(x, y, z)

		local maxDis =  Lib.getPosDistanceSqr(regionBirthPos, maxPos)
		local curDis =  Lib.getPosDistanceSqr(regionBirthPos, pos1)
		if curDis > maxDis + 2 then
			entity:monsterBackBornPos()
			return true
		end
	end

	if regionBirthPos and maxMoveDistance and maxHeightDistance then
		local dx, dz = pos1.x - regionBirthPos.x, pos1.z - regionBirthPos.z
		if (dx * dx + dz * dz > maxMoveDistance*maxMoveDistance) or
				(math.abs(pos1.y - regionBirthPos.y) > maxHeightDistance) then
			entity:monsterBackBornPos()
			return true
		end
	end
	return false
end

function AIControl:getTurnTargetByPos(pos)
	if not pos then
		return
	end
	local curState = self:getCurState()
	if curState and curState.NAME == "ATTACK" then
		return pos
	end

	local entity = self:getEntity()
	local curPos = entity:getPosition()
	local dx = pos.x - curPos.x
	local dz = pos.z - curPos.z
	local sign = mrand() < 0.5 and 1 or -1
	return Lib.v3(curPos.x - dz * sign, curPos.y - 0.5, curPos.z + dx * sign)
end

function AIControl:setTargetPos(pos, enable)
	local entity = self:getEntity()
	if not entity or not entity:isValid() then
		return
	end
	if entity.isMeetCollision then
		pos = self:getTurnTargetByPos(pos)
		entity.isMeetCollision = false
	end
	if entity:getCurHp() <= 0 or entity:isInStateType(Define.RoleStatus.DEAD) then
		pos = nil
	end
	if pos then
		self:face2Pos(pos)
		self.targetPos = pos
		if self:aiData("enableNavigate") then
			self:setNavigate2Pos(pos)
		end
	else
		enable = false
	end
	self.enableTargetPos = enable
	self.isMeshNavigation = self:aiData("enableMeshNavigate") and enable or false
	if not enable then
		entity.isMoving = enable
		entity:syncPosDelay()
	end
end

local AIEventHandler = {}
function AIEventHandler.onHurt(self, from, damage)
	local entity = self:getEntity()
	if entity:getCurHp() <= 0 or entity:isInStateType(Define.RoleStatus.DEAD) then
		return
	end
	local enemyID = from.objID
	local owner = from:owner()
	local formId
	if owner and self:aiData("hatredTransfer") then--hatredTransfer仇恨转移到主人身上
		formId = owner.objID
	else
		formId = enemyID
	end

	local hurtHatred = self:aiData("hurtHatred") or {}
	hurtHatred.fromObjID = formId
	hurtHatred.fromTime = World.Now()
	self:setAiData("hurtHatred", hurtHatred)

	local target = self:getCanChaseEnemy()
	if target and target.objID == enemyID then
		self:face2Pos(from:getPosition())
	end
end

function AIEventHandler.arrived_target_pos(self)
	self:getEntity():onAIArrived()
end

function AIEventHandler.move_meet_cliff(self)
	--self:setChaseTarget(nil)
	--if self:aiData("meetCliffBackRun") then
	--	local pos = self:getBackTargetByPos(self:getTargetPos())
	--	self:setTargetPos(pos, true)
	--
	--	local curState = self:getCurState()
	--	if curState then
	--		curState.endTime = World.Now() + math.random(20, 40)
	--	end
	--end
end

-- todo modify
function AIEventHandler.move_meet_collision(self)
	local pos
	local entity = self:getEntity()
	local cfg = entity:cfg()
	if self:aiData("meetCollisionEmptyRun") then
		return
	elseif self:aiData("meetCollisionBackRun") then
		pos = self:getBackTargetByPos(self:getTargetPos())
	else
		pos = self:getTurnTargetByPos(self:getTargetPos())
	end
	if not pos then
		return
	end
	self:setTargetPos(pos, true)
	entity.isMeetCollision = true
end

function AIEventHandler.ai_status_change(self, isRunning)
	ai_control_mgr:controlEventHandle("ai_status_change", self, isRunning)
end

function AIControl:handleEvent(event, ...)
	-- print("AIControl handle event", event, ...)
	local entity = self:getEntity()
	if not entity or not entity:isValid() or not entity:getPosition() then
		return
	end
	local machine = self:getMachine()
	if machine then
		Profiler:begin("AIStateMachine.onEvent."..event)
		local ok, ret = pcall(machine.onEvent, machine, event, ...)
		Profiler:finish("AIStateMachine.onEvent."..event)
		if ok and ret then
			return
		end
	end
	local handler = AIEventHandler[event]
	if handler then
		Profiler:begin("AIEventHandler."..event)
		handler(self, ...)
		Profiler:finish("AIEventHandler."..event)
	else
		print("no handler for ai event", event, ...)
	end
end