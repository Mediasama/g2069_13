---@class BattleSystem
local BattleSystem = T(Lib, "BattleSystem")
---@type GameLib
local GameLib = T(Lib, "GameLib")

---@type AttackParam
local AttackParam = require "common.structure.attack_param"
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type AttributeLevelConfig
local AttributeLevelConfig = T(Config, "AttributeLevelConfig")
---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")

function BattleSystem:init()
    self.showCalc = false
    self.showCalcCP = false
end

--- 判断是否闪避
---@param attacker Entity
---@param defender Entity
function BattleSystem:isDodge(attacker, defender)
    if (attacker:isMonster() and defender.isPlayer) or (attacker.isPlayer and defender.isPlayer) then
        local dodge
        if attacker.isPlayer then
            --- PVP中，闪避率走属性公式
            dodge = AttributeSystem:getAttributeValue(defender, Define.ATTR.DEF_DODGE)
        else
            --- PVE中，判断角色等级减怪物等级，若结果大于20，则闪避率恒定100%；若小于20，闪避率走属性公式；若小于0，则闪避率恒定为0。
            local defLevel = GrowthSystem:getLevel(defender)
            local atkLevel = MonsterConfig:getCfgByMonsterId(attacker:getMonsterId()).monsterLevel

            local delLevel = defLevel - atkLevel
            if delLevel >=20 then
                dodge = 1
            elseif delLevel <= 0 then
                dodge = 0
            else
                dodge = AttributeSystem:getAttributeValue(defender, Define.ATTR.DEF_DODGE)
            end
        end

        if dodge > 0 and (math.random(0, 9999) < dodge * 10000) then
            defender:onDodge(attacker)
            return true
        end
    end
    return false
end

--- 伤害公式
---@param attacker Entity
---@param defender Entity
---@param skill any 攻击技能
---@return AttackParam 攻击参数
function BattleSystem:attack(attacker, defender, skill, exParam)
    ---@type AttackParam
    local param = AttackParam:new({
        attacker = attacker.objID,
        defender = defender.objID,
        skillId = skill and skill.skillId or 0,
        monster = defender:getMonsterId(),
        exParam = exParam
    })

    ---@type AttributeComponent 
    local atkAttributeComponent = attacker:getComponent("attribute")
    ---@type AttributeComponent 
    local defAttributeComponent = defender:getComponent("attribute")
    if atkAttributeComponent and defAttributeComponent then
        --- 判断是否闪避
        --local dodge = defAttributeComponent:getAttributeValue(Define.ATTR.DEF_DODGE)
        --if dodge and dodge > 0 then
        --    if math.random(0, 10000) < dodge * 10000 then
        --        param.dodge = true
        --        defender:onDodge(attacker, param)
        --        return param
        --    end
        --end

        attacker:onAttackBefore(defender, param)
        defender:onDefendBefore(attacker, param)
        
        -- 伤害公式

        --- 攻击力,霸气值
        local atk, dominant
        --- 判断物理或元素伤害
        ---@type AbilityComponent
        local abilityComponent = attacker:getComponent("ability")
        if abilityComponent and abilityComponent:getDamageType() == Define.DAMAGE_TYPE.ELEMENT then
            atk = atkAttributeComponent:getAttributeValue(Define.ATTR.ELE_DAMAGE)
            dominant = atkAttributeComponent:getAttributeValue(Define.ATTR.ELE_DOMINANT)
        else
            atk = atkAttributeComponent:getAttributeValue(Define.ATTR.ATK_DAMAGE)
            dominant = atkAttributeComponent:getAttributeValue(Define.ATTR.ATK_DOMINANT)
        end
        --- 防御力
        local def = defAttributeComponent:getAttributeValue(Define.ATTR.DEF_DAMAGE)

        --- 基础伤害=最终攻击力+max（最终霸气-最终防御，0）
        local damageBase = atk + math.max(dominant - def, 0)

        --- 是否暴击
        local isCrit = false
        --- 暴击系数
        local critRatio = 1
        --- 判断是否暴击
        if damageBase > 0 then
            --- 暴击概率
            local critRand = atkAttributeComponent:getAttributeValue(Define.ATTR.ATK_CRIT_RATE)
            if critRand and critRand > 0 and math.random(0, 10000) < critRand * 10000 then
                isCrit = true
                critRatio = math.max(atkAttributeComponent:getAttributeValue(Define.ATTR.ATK_CRIT_DAMAGE), critRatio)
            end
        end

        --- 技能伤害百分比
        local skillRate = 1
        local powerUp=0
        local chargeTimeRate=0
        if param.skillId > 0 then
            local skillConfig = SkillMovesConfig:getNewSkillConfig(param.skillId)
            if skillConfig.storageParam then
                chargeTimeRate=(exParam and exParam.packet and exParam.packet.chargeTimeRate) and  exParam.packet.chargeTimeRate or 0
                powerUp=skillConfig.storageParam.dmg*chargeTimeRate
                --print("---------------------- BattleSystem:attack powerUp,chargeTimeRate,dmg",powerUp,chargeTimeRate,skillConfig.storageParam.dmg)
            else
                --print("---------------------- BattleSystem:attack no powerUp")
            end
            skillRate = skillConfig.movesDmg*(1+powerUp)
        end

        --- 最终伤害=基础伤害*暴击修正*技能伤害百分比（普攻时恒定为1）
        local damage = damageBase * critRatio * skillRate

        if attacker:isInvincible() then
            damage = defAttributeComponent:getAttributeValue(Define.ATTR.MAX_HP)
        elseif defender:isInvincible() then
            damage = 0
        end

        if damage > 0 then
            damage = GameLib.keepPreciseDecimal(damage, 1)
            self:changeHp(defender, -damage)
        end

        if self.showCalc then
            Lib.logDebug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n" .. 
            " 攻击者：", attacker.name .. "\n",
            " 被击者：", defender.name .. "\n",
            " 基础伤害:", damageBase .. "\n",
            " 攻击力:", atk .. "\n",
            " 霸气:", dominant .. "\n",
            " 防御:", def .. "\n",
            " 最终伤害:", damage .. "\n",
            " 是否暴击：", tostring(isCrit) .. "\n",
            " 暴击修正:", critRatio .. "\n",
            " 技能Id：", param.skillId .. "\n",
            " 技能伤害百分比:", skillRate)
        end
        
        --- 参数相关
        param.crit = isCrit
        param.damage = damage

        attacker:onAttack(defender, param)
        defender:onDefend(attacker, param)

        --- 判断死亡
        if self:isDead(defender) then
            param.dead = true
            defender:onDeadExtend(attacker, param)
        end
    end
    return param
end

--- 直接伤害
---@param attacker any
---@param defender any
function BattleSystem:directAttack(attacker, defender, damage)
    damage = GameLib.keepPreciseDecimal(damage, 1)
    ---@type AttackParam
    local param = AttackParam:new({
        attacker = attacker.objID,
        defender = defender.objID,
        monster = defender:getMonsterId(),
        damage = damage,
    })
    attacker:onAttackBefore(defender, param)
    defender:onDefendBefore(attacker, param)
    self:changeHp(defender, -damage)
    attacker:onAttack(defender, param)
    defender:onDefend(attacker, param)
    --- 判断死亡
    if self:isDead(defender) then
        param.dead = true
        defender:onDeadExtend(attacker, param)
    end
    return param
end

--- 血量恢复
---@param entity any
function BattleSystem:hpRegen(entity)
    local hpRegen = AttributeSystem:getAttributeValue(entity, Define.ATTR.HP_REGEN)
    if hpRegen and hpRegen > 0 then
        local maxHp = AttributeSystem:getAttributeValue(entity, Define.ATTR.MAX_HP)
        BattleSystem:changeHp(entity, maxHp * hpRegen)
    end
end

--- 精力恢复
---@param entity any
function BattleSystem:mpRegen(entity)
    local mpRegen = AttributeSystem:getAttributeValue(entity, Define.ATTR.MP_REGEN)
    local maxMp = AttributeSystem:getAttributeValue(entity, Define.ATTR.MAX_MP)
    if mpRegen and mpRegen > 0 and maxMp and maxMp > 0 then
        BattleSystem:changeMp(entity, maxMp * mpRegen)
    end
end

--- 修改血量
---@param player any
---@param hp number 可正负
function BattleSystem:changeHp(entity, hp)
    ---@type AttributeComponent 
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local maxHp = attributeComponent:getAttributeValue(Define.ATTR.MAX_HP)
        local curHp = entity:getCurHp()
        if hp > 0 then
            if curHp >= maxHp then
                return
            end
            curHp = math.min(curHp + hp, maxHp)
        else
            curHp = math.max(curHp + hp, 0)
        end
        if curHp > 0 then
            curHp = GameLib.keepPreciseDecimal(curHp, 1)
        end
        entity:setCurHp(curHp)
    end
end

--- 修改精力
---@param entity any
---@param mp any
function BattleSystem:changeMp(entity, mp)
    ---@type AttributeComponent 
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local maxMp = attributeComponent:getAttributeValue(Define.ATTR.MAX_MP)
        if not maxMp or maxMp <= 0 then
            return
        end
        local curMp = entity:getCurMp()
        if mp > 0 then
            if curMp >= maxMp then
                return
            end
            curMp = math.min(curMp + mp, maxMp)
        else
            curMp = math.max(curMp + mp, 0)
        end

        if curMp > 0 then
            curMp = GameLib.keepPreciseDecimal(curMp, 1)
        end

        entity:setCurMp(curMp)
    end
end

--- 是否死亡
---@param entity Entity
function BattleSystem:isDead(entity)
    return entity:getCurHp() <= 0
end

--- 重置血量
---@param entity Entity
function BattleSystem:resetHp(entity)
    ---@type AttributeComponent 
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local maxHp = attributeComponent:getAttributeValue(Define.ATTR.MAX_HP)
        entity:setCurHp(maxHp)
    end
end

--- 重置mp
---@param entity Entity
function BattleSystem:resetMp(entity)
    ---@type AttributeComponent 
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local maxMp = attributeComponent:getAttributeValue(Define.ATTR.MAX_MP)
        if maxMp > 0 then
            entity:setCurMp(maxMp)
        end
    end
end

--- 获取战力
---@param entity Entity
function BattleSystem:getCombatPower(entity, index)

    --- 公式属性
    local values = {
        [Define.ATTR.ATK_DAMAGE] = 0,
        [Define.ATTR.ELE_DAMAGE] = 0,
        [Define.ATTR.MAX_HP] = 0,
        [Define.ATTR.MAX_MP] = 0,
        [Define.ATTR.DEF_DAMAGE] = 0,
    }

    if index ~= nil then
        ---@type AttributeData
        local attributeData = AttributeSystem:getAttributeData(entity)
        if attributeData then
            local attributes = AttributeInfoConfig:getAttributesByType(2)
            if attributes then
                for _, data in pairs(attributes) do
                    local id = data.attr_id
                    local level = attributeData:getLevelByIndex(id, index)
                    local config = AttributeLevelConfig:getCfgByLevel(id, level)
                    for k, v in pairs(values) do
                        if config[k] then
                            values[k] = config[k]
                        end
                    end
                end
            end
        end
    else
        for id, _ in pairs(values) do
            values[id] = AttributeSystem:getAttributeValue(entity, id)
        end
    end

	local atk = values[Define.ATTR.ATK_DAMAGE]
	local eleAtk = values[Define.ATTR.ELE_DAMAGE]
	local maxHp = values[Define.ATTR.MAX_HP]
	local maxMp = values[Define.ATTR.MAX_MP]
	local def = values[Define.ATTR.DEF_DAMAGE]

    if self.showCalcCP then
		Lib.logDebug(">>>>>>>>>>>>>>>>>>>>>>>> begin 战力计算 >>>>>>>>>>>>>>>>>>>>>>>>\n")
		Lib.logDebug("物理攻击:", atk)
		Lib.logDebug("元素攻击:", eleAtk)
		Lib.logDebug("血量:", maxHp)
		Lib.logDebug("精力:", maxMp)
		Lib.logDebug("防御:", def)
	end

    if self.showCalcCP then
		Lib.logDebug("对应攻击力:", math.max(atk, eleAtk))
	end

    local cp = 0
    local acp = 0
    local cpa = 0

    ---@type Ability
    local ability = AbilitySystem:getAbility(entity)
    if ability then
        local skills = AbilitySystem:getAbilitySkill(entity)
        local skillList = skills.skills
        if skillList and #skillList > 0 then
            for _, data in pairs(skillList) do
                if data.unlock then
                    local config = SkillConfig:getSkillConfig(data.skillId)
                    cp = cp + config.fightCountSkill
                end
            end
        end

        if AbilityConfig:getCfgByAbilityId(ability:getItemId()).damageType == Define.DAMAGE_TYPE.PHYSICS then
			cpa = atk
		else
			cpa = eleAtk
		end

        local levelConfig = AbilityLevelConfig:getCfgByLevel(ability:getLevel())
        acp = levelConfig.fightCount

        if self.showCalcCP then
			Lib.logDebug("能力战力:", cp)
			Lib.logDebug("能力战力对应攻击力:", cpa)
			Lib.logDebug("能力等级对应战力:", acp)
		end
    end

    local power = math.ceil(math.max(atk, eleAtk) * 2 + maxHp * 0.2 + def + maxMp * 0.2 + cp * cpa + acp)

	if self.showCalcCP then
		Lib.logDebug("最终战力:", power)
		Lib.logDebug(">>>>>>>>>>>>>>>>>>>>>>>> end 战力计算 >>>>>>>>>>>>>>>>>>>>>>>>")
	end

    return power
end

BattleSystem:init()

return BattleSystem