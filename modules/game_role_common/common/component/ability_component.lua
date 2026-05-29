--- ability_component.lua
--- 能力组件，依托背包系统
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type AbilitySkill
local AbilitySkill = require "common.structure.ability_skill"
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@class AbilityComponent : middleclass
local AbilityComponent = class("AbilityComponent")

--- 初始化
---@param owner any
function AbilityComponent:initialize(owner)
    ----------------- begin 序列化数据 -----------------
    --- 上一次装备的能力id
    self.previousId = nil
    --- 当前装备能力id
    self.currentId = nil
    --- 能力皮肤
    self.skin = nil
    ----------------- end 序列化数据 -----------------
    self.owner = owner
    --- 索引槽
    self.slotIndex = -1
    --- 能力技能
    ---@type AbilitySkill
    self.skills = AbilitySkill:new()
    --- 伤害类型
    self.damageType = nil
    --- 脏数据
    self.dirty = true
end

--- 设置能力数据
---@param level number 经验
function AbilityComponent:setAbilityLevel(level)
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        if ability:getLevel() ~= level then
            self.dirty = true
        end
        ability:setLevel(level)
    end
end

--- 获取能力经验
---@return number exp
function AbilityComponent:getAbilityExp()
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        return ability:getExp()
    end
    return 0
end

--- 设置能力经验
---@param exp number 经验
function AbilityComponent:setAbilityExp(exp)
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        ability:setExp(exp)
    end
end

--- 获取当前能力等级
function AbilityComponent:getAbilityLevel()
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        return ability:getLevel()
    end
    return 1
end

--- 设置觉醒等级
---@param awake any
function AbilityComponent:setAbilityAwake(awake)
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        if ability:getAwake() ~= awake then
            self.dirty = true
        end
        ability:setAwake(awake)
        self:setAbilitySkin(ability:getAwakeAbilityId())
    end
end

--- 获取觉醒等级
function AbilityComponent:getAbilityAwake()
    ---@type Ability
    local ability = self:getAbility()
    if ability then
        return ability:getAwake()
    end
    return 0
end

--- 设置当前能力
---@param ability Ability
function AbilityComponent:setAbility(ability)
    self.previousId = self.currentId
    self.currentId = ability:getId()
    self.slotIndex = -1
    self.dirty = true
    self:setAbilitySkin(ability:getAwakeAbilityId())
end

--- 获取当前能力
---@return Ability
function AbilityComponent:getAbility()
    if self.slotIndex ~= -1 then
        ---@type Ability
        local ability = InventorySystem:getItemByIndex(self.owner, Define.INVENTORY_TYPE.ABILITY, self.slotIndex, true)
        if ability then
            return ability
        end
    end

    if self.currentId and self.currentId ~= "" then
        ---@type Ability
        local ability, slotIndex = InventorySystem:getItemById(self.owner, Define.INVENTORY_TYPE.ABILITY, self.currentId)
        if ability then
            self.slotIndex = slotIndex
            return ability
        end
    end

    ---@type Ability, number
    local ability, slotIndex = InventorySystem:getItemByItemAlias(self.owner, Define.INVENTORY_TYPE.ABILITY, Define.ITEM_ALIAS.DEFAULT_ABILITY)
    if ability then
        self.slotIndex = slotIndex
        return ability
    end

    return nil
end

--- 获取所有技能
---@return AbilitySkill 技能数据
function AbilityComponent:getAbilitySkill()
    self:updateAbilityData()
    return self.skills
end

--- 获取上一次装备能力
function AbilityComponent:getPreviousId()
    return self.previousId
end

--- 获取伤害类型
function AbilityComponent:getDamageType()
    self:updateAbilityData()
    return self.damageType or Define.DAMAGE_TYPE.PHYSICS
end

--- 刷新数据
function AbilityComponent:updateAbilityData()
    if self.dirty then
        self.dirty = false
        for i = #self.skills.passives, 1, -1 do
            table.remove(self.skills.passives, i)
        end
        for i = #self.skills.skills, 1, -1 do
            table.remove(self.skills.skills, i)
        end
        ---@type Ability
        local ability = self:getAbility()

        if ability then
            local abilityId = ability:getItemId()
            local abilityLevel = ability:getLevel()
            local awake = ability:getAwake()
            if awake and awake > 0 then
                abilityId = AbilityAwakeConfig:getAwakeAbilityId(abilityId, awake)
            end
            local config = AbilityConfig:getCfgByAbilityId(abilityId)
            self.damageType = config.damageType
            self.skills.attack = config.attackSkill
            self.skills.sprint = config.sprintSkill
            self.skills.fly = config.flySkill
            self.skills.addFly = config.addFlySkill
            local buffs = config.buffs
            local unlockLevels = config.unlockLevels

            local skills = config.skills
            if buffs then
                for _, buffId in pairs(buffs) do
                    self.skills.passives[#self.skills.passives + 1] = buffId
                end
            end
            if skills then
                for i = 1, #skills, 1 do
                    self.skills.skills[#self.skills.skills + 1] = { skillId = skills[i], unlock = abilityLevel >= unlockLevels[i], level = unlockLevels[i] }
                end
            end
        end
    end
end

--- 设置皮肤能力
---@param abilityId any
function AbilityComponent:setAbilitySkin(abilityId)
    self.skin = abilityId
end

--- 获取皮肤能力
function AbilityComponent:getAbilitySkin()
    if self.skin then
        return self.skin
    end
    local ability = self:getAbility()
    return ability:getAwakeAbilityId()
end

--- 反序列化
---@param data any
function AbilityComponent:deserialize(data)
    self.currentId = data.currentId
    self.previousId = data.previousId
    self.skin = data.skin or nil
    self.slotIndex = -1
    self.dirty = true

    if not self.skin then
        local after = self:getAbility()
        self.skin = after and after:getAwakeAbilityId() or nil
    end
end

--- 序列化数据
function AbilityComponent:serialize()
    local data = {}
    if self.previousId then
        data.previousId = self.previousId
    end
    if self.currentId then
        data.currentId = self.currentId
    end
    if self.skin then
        data.skin = self.skin
    end
    return data
end

return AbilityComponent