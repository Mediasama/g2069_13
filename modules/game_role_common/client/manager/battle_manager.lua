---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"

---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")

---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@class BattleManagerClient : singleton
local BattleManagerClient = class("BattleManagerClient")
BattleManagerClient:include(singleton)

function BattleManagerClient:initialize()
    self.isInited = false
    self.events = {}
end

function BattleManagerClient:init()
    if self.isInited then
        return
    end
    self.isInited = true
    self:subscribeEvents()
end

function BattleManagerClient:subscribeEvents()
    --- entity onCreate
    ---@param entity Entity
    ---@param isPlayer boolean
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_CREATE, function(entity, isPlayer)
        if isPlayer then
            if Me.objID == entity.objID then
                -- Me:showStaminaBar()
            else
                --entity:setHeadText(0, -1, "LV." .. entity:getCurLevel())
                entity:updateShowName()
            end
        end
    end)

    --- 显示选择初始地图
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SHOW_SELECT_MAP, function()
        UI:openWindow("UI/game_role_common/gui/win_select_born_map")
    end)
end

--- 切换能力
---@param player Entity
---@param ability Ability
function BattleManagerClient:switchAbility(player, ability)
    local oldAbility = AbilitySystem:getAbility(player)
    if oldAbility and oldAbility:getId() == ability:getId() then
        Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, false, player)
        return false
    end
    AbilitySystem:setAbility(player, ability)
    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, true, player, ability, oldAbility)
    return true
end

--- 切换能力
---@param player any
---@param abilityId any
function BattleManagerClient:switchAbilityByAbilityId(player, abilityId)
    ---@type Ability
    local ability = InventorySystem:getItemByItemId(player, Define.INVENTORY_TYPE.ABILITY, abilityId)
    if ability then
        return self:switchAbility(player, ability)
    end
    return false
end

return BattleManagerClient