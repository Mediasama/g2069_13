
local AIEvaluator = require("entity.ai.ai_evaluator")
local socket = require("socket.core")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")

function AIEvaluator.CanSkillAttackEnemy(control)
	local entity = control:getEntity()
	local curState = control:getCurState()
	if curState and curState.NAME == "IDLE" then
		return false
	end
	local skillGroup = control:aiData("skillGroup")
	local skillTotalCD = control:aiData("skillTotalCD") or 0

	local lastFreeTime = entity:data("main").lastFreeSkillTime or 0
	if socket.gettime() - lastFreeTime < skillTotalCD / 1000 then
		return false
	end

	local nearEnemy = control:getCanChaseEnemy()
	local canFreeSkill = {}
	for _, skillData in pairs(skillGroup) do
		local skillId = skillData.skillId
		local freeRange = skillData.freeRange
		if not entity:checkCanFreeSkill(skillId) then
			goto CONTINUE
		end
		local skillCfg=SkillConfig:getSkillConfig(skillId)
		local movesConfig
		local stopMove=true
		if skillCfg then
			movesConfig=skillCfg.isEngineSkill and SkillMovesConfig:getNewSkillConfig(skillId) or SkillMovesConfig:getSkillConfig(skillId)
			if movesConfig then
				if skillCfg.isEngineSkill then
					stopMove=movesConfig.isStopMove
				end
				if nearEnemy and nearEnemy:isValid() and
						(entity:distance(nearEnemy) <= freeRange) then
					table.insert(canFreeSkill, { skillId = skillId, isStopMove = stopMove, skillWeight = skillData.skillWeight })
				end
			end
		end
		::CONTINUE::
	end
	local counts = #canFreeSkill
	if counts > 0 then
		local totalWeight = 0
		for i = 1, counts do
			totalWeight = totalWeight + canFreeSkill[i].skillWeight
		end
		if totalWeight == 0 then
			return false
		end
		local randomWeight = math.random(1, totalWeight)
		local weight = 0
		local index = 1
		for i = 1, counts do
			weight = weight + canFreeSkill[i].skillWeight
			if randomWeight <= weight then
				index = i
				break
			end
		end

		local myPos = entity:getPosition()
		local enemyPos = nearEnemy:getPosition()
		if canFreeSkill[index].isStopMove or Lib.getPosDistance(enemyPos, myPos) < control:getChaseFinishDistance() then
			control:setTargetPos()
		else
			control:setTargetPos(enemyPos, true)
		end
		return canFreeSkill[index].skillId, nearEnemy
	end
	return false
end

function AIEvaluator.CanNormalAttackEnemy(control)
	local entity = control:getEntity()
	local attackSkill = control:aiData("attackSkill")
	local skillId = attackSkill[1]
	local freeRange = attackSkill[2] or 2
	if not entity:checkCanFreeSkill(skillId) then
		return false
	end

	local nearEnemy = control:getCanChaseEnemy()
	local myPos = entity:getPosition()
	if nearEnemy and nearEnemy:isValid() and nearEnemy.isPlayer and
			(entity:distance(nearEnemy) <= freeRange)  then
		local enemyPos = nearEnemy:getPosition()
		if Lib.getPosDistance(enemyPos, myPos) < control:getChaseFinishDistance() then
			control:setTargetPos()
		else
			control:setTargetPos(enemyPos, true)
		end
		return skillId, nearEnemy
	end
	return false
end

function AIEvaluator.CanAttackEnemy(control)
	local entity = control:getEntity()
	if entity:isInImmobilityState() then
		return false
	end
	local aiData = entity:data("aiData")

	local skillId, nearEnemy = AIEvaluator.CanSkillAttackEnemy(control)
	if skillId and nearEnemy and nearEnemy:isValid() and nearEnemy.isPlayer then
		aiData.skillId = skillId
		aiData.skillTarget = nearEnemy
		aiData.isNormalAttack = false
		return true
	end
	local skillId, nearEnemy = AIEvaluator.CanNormalAttackEnemy(control)
	if skillId and nearEnemy and nearEnemy:isValid() and nearEnemy.isPlayer then
		aiData.skillId = skillId
		aiData.skillTarget = nearEnemy
		aiData.isNormalAttack = true
		return true
	end
	aiData.skillId = nil
	aiData.skillTarget = nil
	return false
end

function AIEvaluator.CanChaseEnemy(control)
	local entity = control:getEntity()
	if entity:isInImmobilityState() then
		control:setTargetPos()
		return false
	end
	local nearEnemy = control:getCanChaseEnemy()
	local myPos = entity:getPosition()
	if nearEnemy and nearEnemy:isValid() and nearEnemy.isPlayer then
		local enemyPos = nearEnemy:getPosition()
		local distance = Lib.getPosDistance(enemyPos, myPos)
		local minChaseDis = control:getChaseFinishDistance()
		if distance < minChaseDis then
			control:setTargetPos()
			return false
		end
		control:setTargetPos(enemyPos, true)
		return true
	end
	control:setTargetPos()
	return false
end
RETURN(AIEvaluator)
