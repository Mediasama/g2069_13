---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type RewardHelper
local RewardHelper = T(Lib, "RewardHelper")
---@type AttackParam
local AttackParam = require "common.structure.attack_param"
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type GameLib
local GameLib = T(Lib, "GameLib")

--- 通知指定客户端
---@param attacker any
---@param defender any
---@param packet any
local sendPacketToTracking = function(attacker, defender, packet, includeSelf)
    if includeSelf == nil then
        includeSelf = true
    end
    attacker:sendPacketToTracking(packet, attacker.isPlayer and includeSelf)
end

--- 通知所有客户端
-- WorldServer.BroadcastPacket

---@class BattleManagerServer : singleton
local BattleManagerServer = class("BattleManagerServer")
BattleManagerServer:include(singleton)

function BattleManagerServer:initialize()
    self.isInited = false
    --- 缓存entity，提高遍历效率
    self.entities = {}
    self.events = {}
    self.timer = nil
    self.secTimer = nil
end

--- 初始化
function BattleManagerServer:init()
    if self.isInited then
        return
    end
    self.isInited = true
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
        if player.isPlayer and addLevel ~= 0 and not BattleSystem:isDead(player) then
            BattleSystem:resetHp(player)
            BattleSystem:resetMp(player)
        end
    end)

    self.timer = LuaTimer:scheduleTicker(function()
        self:tickPerTick()
    end, 1)

    self.secTimer = LuaTimer:scheduleTicker(function()
        self:tickPerSecond()
    end, 20)
end

--- 直接伤害
---@param attacker any
---@param defender any
---@param damage any
function BattleManagerServer:directAttack(attacker, defender, damage)
    if BattleSystem:isDead(defender) then
        return
    end
    damage = GameLib.keepPreciseDecimal(damage, 1)
    ---@type AttackParam
    local param = AttackParam:new({
        attacker = attacker.objID,
        defender = defender.objID,
        monster = defender:getMonsterId(),
        damage = damage,
    })
    BattleSystem:changeHp(defender, -damage)
    --- 判断死亡
    if BattleSystem:isDead(defender) then
        param.dead = true
        defender:onDeadExtend(attacker, param)
    end

    local packet = {
        pid = "S2COnAttack",
        attacker = param.attacker,
        defender = param.defender,
        damage = param.damage,
        dead = param.dead,
        monster = param.monster,
    }

    --- 被击者死亡时，发送给自己的数据特殊处理
    sendPacketToTracking(attacker, defender, packet)

    if defender:isBossMonster() and param.damage > 0 then
        defender:addOneHurtRecord(attacker, param.damage)
    end

    if param.dead then
        if attacker.isPlayer and defender:isMonster() then
            self:distributeKillReward(attacker, defender)
        end

        if defender:isMonster() then
            --- 掉落物品处理
            Plugins.CallTargetPluginFunc("scene_object", "onKillMonsterDropItem", defender)
        end

        local cfg = defender:cfg()
        local delay = (cfg.destroyTime or 0) + 1
        World.LightTimer("onDeadExtend_delay_time", delay, function()
            if defender and defender:isValid() then
                defender:onDestroyExtend(attacker)
            end
        end)
    end

end

--- 攻击
---@param attacker Entity
---@param defender Entity
---@param skill BaseSkill
function BattleManagerServer:attack(attacker, defender, skill, exParam)
    if BattleSystem:isDead(defender) then
        return
    end
    ---@type AttackParam
    local data = BattleSystem:attack(attacker, defender, skill, exParam)

    local packet = {
        pid = "S2COnAttack",
        attacker = data.attacker,
        defender = data.defender,
        damage = data.damage,
        crit = data.crit,
        dodge = data.dodge,
        dead = data.dead,
        skillId = data.skillId,
        monster = data.monster,
        exParam = exParam
    }

    local movesConfig = SkillMovesConfig:getSkillConfig(skill.skillId)
    if defender:isInStateType(Define.RoleStatus.KNOCK_DOWN) then
        packet.hurtAction = nil
    else
        if movesConfig and movesConfig.hurtAction and movesConfig.hurtAction~= "" then
            packet.hurtAction = movesConfig.hurtAction
        else
            packet.hurtAction = defender:cfg().hurtAction
        end
    end
    local hitMoveTime = 0
    if defender:isInStateType(Define.RoleStatus.BLOW_AWAY) and movesConfig and movesConfig.hitMoveDuration then
        hitMoveTime = movesConfig.hitMoveDuration or 5
        packet.hitMoveTime = hitMoveTime
    end

    --- 被击者死亡时，发送给自己的数据特殊处理
    sendPacketToTracking(attacker, defender, packet)

    if defender:isBossMonster() and data.damage > 0 then
        defender:addOneHurtRecord(attacker, data.damage)
    end

    if data.dead then
        if attacker.isPlayer and defender:isMonster() then
            self:distributeKillReward(attacker, defender)
        end

        if defender:isMonster() then
            --- 掉落物品处理
            Plugins.CallTargetPluginFunc("scene_object", "onKillMonsterDropItem", defender)
        end

        local cfg = defender:cfg()
        local delay = (cfg.destroyTime or 0) + 1 + hitMoveTime
        World.LightTimer("onDeadExtend_delay_time", delay, function()
            if defender and defender:isValid() then
                defender:onDestroyExtend(attacker)
            end
        end)
    end
end

--- 派发怪物击杀奖励
---@param attacker Entity
---@param defender Entity
function BattleManagerServer:distributeKillReward(attacker, defender)
    local proportionList = {}

    local monsterId = defender:getMonsterId()
    local config = MonsterConfig:getCfgByMonsterId(monsterId)
    
    if config.monsterType == Define.MonsterType.BOSS then
        local hurtProportion = defender:getHurtProportion()
        for _, val in pairs(hurtProportion) do
            local entity = World.CurWorld:getEntity(val.objID)
            if entity and entity:isValid() then
                if entity.map == defender.map then
                    table.insert(proportionList, {entity = entity, ratio = val.ratio})
                end
            end
        end
    else
        if attacker and attacker:isValid() then
            table.insert(proportionList, {entity = attacker, ratio = 1})
        end
    end
    
    for _, val in pairs(proportionList) do
        RewardHelper:gainKillRewards(val.entity, monsterId, val.ratio)
        val.entity:sendPacket({ pid = "PushShowBossKillTips", monsterId = monsterId })
    end
end

--- 添加entity
---@param entity Entity
function BattleManagerServer:addEntity(entity)
    self.entities[entity.objID] = entity
end

--- 移除entity
---@param entity Entity
function BattleManagerServer:removeEntity(entity)
    self.entities[entity.objID] = nil
end

--- 心跳函数
function BattleManagerServer:tickPerTick()
    
end

--- 心跳函数
function BattleManagerServer:tickPerSecond()
    --- 回血与回魔逻辑在此处理
    ---@type number, Entity
    for _, entity in pairs(self.entities) do
        if not BattleSystem:isDead(entity) then
            --- 若是玩家，或者怪物处于非战斗状态
            if entity.isPlayer then
                BattleSystem:hpRegen(entity)
                BattleSystem:mpRegen(entity)
            elseif entity:isMonster() then
                if not entity:isInStateType(Define.RoleStatus.BATTLE_STATE) then
                    --- 怪物只回血不回蓝
                    BattleSystem:hpRegen(entity)
                end
            end
        end
    end
end

--- 获取当前能力buff
---@param player Entity
function BattleManagerServer:getAbilityBuffIds(player)
    ---@type AbilitySkill
    local abilitySkill = AbilitySystem:getAbilitySkill(player)
    if abilitySkill then
        return abilitySkill.passives
    end
    return nil
end

--- 初始化能力
---@param player Entity
function BattleManagerServer:initAbility(player)
    local buffIds = self:getAbilityBuffIds(player)
    if buffIds and #buffIds > 0 then
        ---@type SkillBuffConfig
        local SkillBuffConfig = T(Config, "SkillBuffConfig")
        for _, buffId in pairs(buffIds) do
            local buffCfg = SkillBuffConfig:getCfgByBuffId(buffId)
            if buffCfg then
                player:addBuff(buffCfg.buffName, buffCfg.duration)
            end
        end
    end
end

--- 切换能力
---@param player Entity
---@param ability Ability
function BattleManagerServer:switchAbility(player, ability)
    local oldAbility = AbilitySystem:getAbility(player)
    if oldAbility and oldAbility:getId() == ability:getId() then
        return false
    end
    local buffIds = self:getAbilityBuffIds(player)
    if buffIds and #buffIds > 0 then
        ---@type SkillBuffConfig
        local SkillBuffConfig = T(Config, "SkillBuffConfig")
        for _, buffId in pairs(buffIds) do
            local buffCfg = SkillBuffConfig:getCfgByBuffId(buffId)
            if buffCfg then
                player:removeTypeBuff("fullName", buffCfg.buffName)
            end
        end
    end
    AbilitySystem:setAbility(player, ability)
    --- 初始化能力
    self:initAbility(player)

    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, true, player, ability, oldAbility)

    return true
end

--- 切换能力
---@param player any
---@param abilityId any
function BattleManagerServer:switchAbilityByAbilityId(player, abilityId)
    ---@type Ability
    local ability = InventorySystem:getItemByItemId(player, Define.INVENTORY_TYPE.ABILITY, abilityId)
    if ability then
        return self:switchAbility(player, ability)
    end
    return false
end

--- 显示属性
---@param entity Entity
function BattleManagerServer:showEntityAttributes(entity)
    local attrs = ""
    for key, id in pairs(Define.ATTR) do
        if attrs ~= "" then
            attrs = attrs .. "\r\n"
        end
        attrs = attrs .. key .. ":" .. AttributeSystem:getAttributeValue(entity, id)
    end
    Lib.logDebug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> entity:" .. entity.objID .. " attr:", attrs)
end

return BattleManagerServer
