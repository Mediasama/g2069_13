

local AIStateBase = require("entity.ai.ai_state_base")
local AIStateAttack = L("AIStateAttack", Lib.derive(AIStateBase))


AIStateAttack.NAME = "ATTACK"
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local socket = require("socket.core")

function AIStateAttack:enter()

	local entity = self.control:getEntity()
	local aiData = entity:data("aiData")

	self.control:setAiData("idleStartTime", -1)

	local lastState = self.control:getLastState()
	if not entity:isInStateType(Define.RoleStatus.BATTLE_STATE) then
		entity:enterStateType(Define.RoleStatus.BATTLE_STATE)
	end

	local chaseMoveSpeed = AttributeSystem:getAttributeValue(entity, Define.ATTR.MOVE_SPEED)
	if chaseMoveSpeed and (chaseMoveSpeed ~= entity:prop("moveSpeed")) then
		entity:setProp("moveSpeed", chaseMoveSpeed)
	end

	self.skillId = aiData.skillId
	self.enemyTarget = aiData.skillTarget

	self.skillConfig = SkillConfig:getSkillConfig(self.skillId)

	if not self.moveIndexInf then
		self.moveIndexInf={}
	end
	if not self.moveIndexInf[self.skillId] then
		self.moveIndexInf[self.skillId]=1
	else
		local lastTime=entity:data("main").lastFreeNormalAttackTime or 0
		local _,moveTime=SkillConfig:getSkillMoveTime(self.skillId,self.moveIndexInf[self.skillId])
		if not moveTime then
			moveTime=0
		end
		if socket.gettime() - lastTime < (moveTime*2)/1000 then
			self.moveIndexInf[self.skillId]=self.moveIndexInf[self.skillId]<#self.skillConfig.skillMoves
					and self.moveIndexInf[self.skillId]+1 or 1
		else
			self.moveIndexInf[self.skillId]=1
		end
	end

	local moveId=self.skillConfig.skillMoves[self.moveIndexInf[self.skillId]]
	if moveId then
		self.movesConfig = SkillMovesConfig:getNewSkillConfig(moveId)
	end

	---@type GameSkillHelper
	local GameSkillHelper = T(Lib, "GameSkillHelper")
	local skillTime = GameSkillHelper:getSkillTotalTime(moveId)
	self.endTime = World.Now() + math.ceil(skillTime/1000*20)

	self.control:face2Pos(self.enemyTarget:getPosition())

	if not aiData.isNormalAttack then
		entity:data("main").lastFreeSkillTime = socket.gettime()
	else
		entity:data("main").lastFreeNormalAttackTime = socket.gettime()

	end
	Plugins.CallPluginFunc("tryEntityFreeSkill", entity, self.skillId, self.enemyTarget.objID,moveId)
end

function AIStateAttack:update()
	if self.enemyTarget and self.enemyTarget:isValid() then
		local entity = self.control:getEntity()
		local myPos = entity:getPosition()
		local enemyPos = self.enemyTarget:getPosition()
		if self.movesConfig.isStopMove or Lib.getPosDistance(enemyPos, myPos) < self.control:getChaseFinishDistance() then
			self.control:setTargetPos()
		else
			if entity:isInImmobilityState() then
				self.control:setTargetPos()
			else
				self.control:setTargetPos(enemyPos, true)
			end
		end
	else
		self.control:setTargetPos()
	end
end

function AIStateAttack:exit()
end

function AIStateAttack:aiStateIsEnd()
	return self.endTime - World.Now() <= 0
end

function AIStateAttack:onEvent(event, ...)
	--local eventFunc = {}
	--function eventFunc.onHurt(self, ... )
	--	self.stage = self.skillCfg and self.skillCfg.hurtStop and END_CAST_SKILL or self.stage
    --end
	--if eventFunc[event] then
	--	eventFunc[event](self, ...)
	--end
end

RETURN(AIStateAttack)
