---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type Item
local Item = require "common.inventory.item"
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")

--- 能力
---@class Ability : Item
---@field id string 物品唯一id
---@field itemId number 物品配置表id
---@field level number 能力等级
---@field exp number 能力经验
---@field inspected number 检视状态，1为检视
---@field awake number 觉醒等级
---@field totalExp number 总经验
local Ability = class("Ability", Item)

--- 初始化
---@param id any 物品唯一id
---@param itemId number 配置表物品id
function Ability:initialize(id, itemId)
    Item.initialize(self, id, itemId)
    ------------------- begin 序列化数据 ------------------
    --- 等级与经验
    self.exp = 0
    self.level = 1
    --- 觉醒等级
    self.awake = 0
    --- 是否解锁永久能力
    self.unlimited = 0
    self.u_inspected = 0
    ------------------- end 序列化数据 ------------------
    self.totalExp = 0
    self.dirty = true
end

function Ability:setLevel(level)
    if level ~= self.level then
        self.dirty = true
    end
    self.level = level
end

function Ability:getLevel()
    return self.level    
end

function Ability:setExp(exp)
    if exp ~= self.exp then
        self.dirty = true
    end
    self.exp = exp
end

function Ability:getExp()
    return self.exp
end

--- 设置觉醒等级
---@param awake number
function Ability:setAwake(awake)
    if awake ~= self.awake then
        self.dirty = true
    end
    self.awake = awake
end

function Ability:getAwake()
    return self.awake
end

function Ability:setUnlimitedInspected(inspected)
    self.u_inspected = inspected
end

function Ability:isUnlimitedInspected()
    return self.u_inspected == 1
end

--- 刷新脏数据
function Ability:updateCacheData()
    if self.dirty then
        self.dirty = true

        local totalExp = self.exp
        if self.level > 1 then
            for i = 1, self.level - 1, 1 do
                local config = AbilityLevelConfig:getCfgByLevel(i)
                local needExp = config.upgradePrice
                totalExp = totalExp + needExp
            end
        end

        self.totalExp = totalExp
    end
end

--- 获取总经验
function Ability:getTotalExp()
    self:updateCacheData()
    return self.totalExp
end

--- 序列化
function Ability:serialize()
    local data = Item.serialize(self)
    if self.exp > 0 then
        data.exp = self.exp
    end
    if self.level > 1 then
        data.level = self.level
    end
    if self.awake > 0 then
        data.awake = self.awake
    end
    if self.unlimited > 0 then
        data.unlimited = self.unlimited
    end
    if self.u_inspected > 0 then
        data.u_inspected = self.u_inspected
    end
    return data
end

--- 获取物品icon
function Ability:getIcon()
    local abilityId = self.itemId
    if self.awake and self.awake > 0 then
        abilityId = AbilityAwakeConfig:getAwakeAbilityId(self.itemId, self.awake)
    end
    if self.unlimited == 1 then
        local icon = AbilityConfig:getCfgByAbilityId(abilityId).unlimited_icon
        if icon and icon ~= "" then
            return icon
        end
    end
    return ItemConfig:getCfgByItemId(abilityId).icon
end

--- 获取物品名字
---@param origin boolean
function Ability:getName(origin)
    local abilityId = self.itemId
    if self.awake and self.awake > 0 and not origin then
        abilityId = AbilityAwakeConfig:getAwakeAbilityId(abilityId, self.awake)
    end
	local name = AbilityConfig:getCfgByAbilityId(abilityId).unlimited_name
    if not name or name == "" then
        name = ItemConfig:getCfgByItemId(abilityId).name
    end
    return name
end

--- 获取觉醒能力id
function Ability:getAwakeAbilityId()
    local abilityId = self.itemId
    if self.awake and self.awake > 0 then
        abilityId = AbilityAwakeConfig:getAwakeAbilityId(abilityId, self.awake)
    end
    return abilityId
end

--- 是否永久能力
function Ability:isUnlimited()
    return self.unlimited == 1
end

function Ability:setUnlimited(unlimited)
    self.unlimited = unlimited
end

--- 是否最大觉醒
function Ability:isMaxAwake()
    if AbilityAwakeConfig:canAwake(self.itemId) then
        local config = AbilityAwakeConfig:getCfgByAbilityId(self.itemId)
        return self.awake >= config.max_awake
    end
    return false
end

--- 获取技能伤害类型
---@return string Define.DAMAGE_TYPE
function Ability:getDamageType()
    local abilityId = self.itemId
    if self.awake and self.awake > 0 then
        abilityId = AbilityAwakeConfig:getAwakeAbilityId(self.itemId, self.awake)
    end
    return AbilityConfig:getCfgByAbilityId(abilityId).damageType or Define.DAMAGE_TYPE.PHYSICS
end

function Item:getQuality()
    local abilityId = self.itemId
    if self.awake and self.awake > 0 then
        abilityId = AbilityAwakeConfig:getAwakeAbilityId(abilityId, self.awake)
    end
    return ItemConfig:getCfgByItemId(abilityId).quality_alias
end

--- 反序列化
---@param data any
function Ability:deserialize(data)
    Item.deserialize(self, data)
    self.exp = data.exp or 0
    self.level = data.level or 1
    self.awake = data.awake or 0
    self.unlimited = data.unlimited or 0
    self.u_inspected = data.u_inspected or 0

    self.dirty = true
end



return Ability