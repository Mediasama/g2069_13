---@class SkinSystem
local SkinSystem = T(Lib, "SkinSystem")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

function SkinSystem:init()
    
end

--- 修改buff皮肤
---@param player Entity
---@param part any
---@param skin any
function SkinSystem:changeBuffSkinPart(player, part, skin)
    ---@type SkinComponent
    local skinComponent = player:getComponent("skin")
    if skinComponent then
        skinComponent:changeSkinPart(Define.SKIN_LAYER.BUFF, part, skin)
    end
end

--- 切换能力皮肤
---@param player Entity
---@param before number ability id
---@param after number ability id
function SkinSystem:switchAbilitySkin(player, before, after)
    ---@type SkinComponent
    local skinComponent = player:getComponent("skin")
    if skinComponent then
        local originSkins = skinComponent:getLayerSkin(Define.SKIN_LAYER.ORIGINAL)
        local skinData = {}
        if before then
            local config = AbilityConfig:getCfgByAbilityId(before)
            local parts = config.parts
            if parts then
                for part, _ in pairs(parts) do
                    skinData[part] = originSkins[part] or "0"
                end
            end
            local conflictParts = config.conflictParts
            if conflictParts then
                for _, part in pairs(conflictParts) do
                    skinData[part] = originSkins[part] or "0"
                end
            end
            local conflictOriginals = config.conflictOriginals
            if conflictOriginals then
                for _, part in pairs(conflictOriginals) do
                    if originSkins[part] then
                        skinData[part] = originSkins[part]
                    end
                end
            end

            --- 还原
            local skin_color = config.skin_color
            if skin_color then
                if originSkins.skin_color and not Lib.isSameTable(originSkins.skin_color, Define.EMPTY_SKIN_COLOR) then
                    skinData["skin_color"] = Lib.copy(originSkins.skin_color)
                else
                    skinData["skin_color"] = Lib.copy(Define.DEFAULT_SKIN_COLOR)
                end
            end

            local origin = AbilityAwakeConfig:getOriginAbilityId(before)
            if origin then
                local awake_effect = AbilityAwakeConfig:getCfgByAbilityId(origin).awake_effect
                if awake_effect and #awake_effect > 0 then
                    skinData[awake_effect[1]] = "0"
                end
            end
        end
        if after then
            local config = AbilityConfig:getCfgByAbilityId(after)
            local parts = config.parts
            if parts then
                for part, skin in pairs(parts) do
                    skinData[part] = skin
                end
            end
            local conflictParts = config.conflictParts
            if conflictParts then
                for _, part in pairs(conflictParts) do
                    skinData[part] = "0"
                end
            end
            local conflictOriginals = config.conflictOriginals
            if conflictOriginals then
                for _, part in pairs(conflictOriginals) do
                    if originSkins[part] then
                        skinData[part] = "0"
                    end
                end
            end

            --- 设置
            local skin_color = config.skin_color
            if skin_color then
                skinData["skin_color"] = Lib.copy(skin_color)
            end

            local origin = AbilityAwakeConfig:getOriginAbilityId(after)
            if origin then
                local awake_effect = AbilityAwakeConfig:getCfgByAbilityId(origin).awake_effect
                if awake_effect and #awake_effect > 0 then
                    ---@type Ability
                    local ability = InventorySystem:getItemByItemId(player, Define.INVENTORY_TYPE.ABILITY, origin)
                    if ability and ability:isMaxAwake() then
                        skinData[awake_effect[1]] = awake_effect[2]
                    end
                end
            end
        end
        skinComponent:setLayerSkin(Define.SKIN_LAYER.ABILITY, skinData)
    end
end

return SkinSystem