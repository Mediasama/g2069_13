--- ability_component.lua
--- 能力组件，依托背包系统
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type AbilityComponent
local AbilityComponent = require "common.component.ability_component"

---@type SkinSystem
local SkinSystem = T(Lib, "SkinSystem")

---@class AbilityComponentServer : AbilityComponent
local AbilityComponentServer = class("AbilityComponentServer", AbilityComponent)

--- 设置皮肤能力
---@param abilityId any
function AbilityComponentServer:setAbilitySkin(abilityId)
    local before = self.skin
    if not before then
        ---@type Ability
        local ability = self:getAbility()
        before = ability:getAwakeAbilityId()
    end
    self.skin = abilityId

    if not before or before ~= self.skin then
        SkinSystem:switchAbilitySkin(self.owner, before, self.skin)
    end
end

--- 反序列化
---@param data any
function AbilityComponentServer:deserialize(data)
    AbilityComponent.deserialize(self, data)
    --- 强制切换
    if self.skin then
        SkinSystem:switchAbilitySkin(self.owner, nil, self.skin)
    end
end

return AbilityComponentServer