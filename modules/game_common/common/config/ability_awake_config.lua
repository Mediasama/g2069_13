---@class AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")

local settings = {}
local awake2origin = {}

--- 判断是否空字符串
---@param str any
local function isStringNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
end

--- 解析物品格式
---@param str any
local function parseItemList(str)
    if not isStringNullOrEmpty(str) then
        local itemList = {}
        local list1 = Lib.splitString(str, ";")
        for index, v in pairs(list1) do
            itemList[index] = {}
            local list2 = Lib.splitString(v, ",")
            for _, vv in pairs(list2) do
                local item = Lib.splitString(vv, "#")
                itemList[index][#itemList[index] + 1] = {
                    item_alias = item[1],
                    item_num = tonumber(item[2]),
                }
            end
        end
        return itemList
    end
    return nil
end

function AbilityAwakeConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/ability_awake.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            ability_id = tonumber(vConfig.n_ability_id) or 0,
            awake_ids = Lib.splitString(vConfig.s_awake_ids, "#", true),
            max_awake = tonumber(vConfig.n_max_awake) or 0,
            coin_nums = Lib.splitString(vConfig.s_coin_nums, "#", true),
            item_nums = Lib.splitString(vConfig.s_item_nums, "#", true),
            item_costs = parseItemList(vConfig.s_item_cost),
            awake_tips = Lib.splitString(vConfig.s_awake_tips, "#"),
            awake_effect = not isStringNullOrEmpty(vConfig.s_awake_effect) and Lib.splitString(vConfig.s_awake_effect, "#") or nil,
        }
        settings[data.ability_id] = data

        awake2origin[data.ability_id] = data.ability_id
        for _, abilityId in pairs(data.awake_ids) do
            awake2origin[abilityId] = data.ability_id
        end
    end
end

function AbilityAwakeConfig:getCfgByAbilityId(abilityId)
    if not settings[abilityId] then
        Lib.logError("Error:Not found the data in ability_awake.csv, ability id:", abilityId)
        return
    end
    return settings[abilityId]
end

--- 获取觉醒能力id
---@param origin any
---@param awake any
function AbilityAwakeConfig:getAwakeAbilityId(origin, awake)
    if awake == 0 then
        return origin
    end
    local config = self:getCfgByAbilityId(origin)
    if config then
        return config.awake_ids[awake] or origin
    end
    return origin
end

--- 获取初始能力
---@param abilityId any
function AbilityAwakeConfig:getOriginAbilityId(abilityId)
    return awake2origin[abilityId]
end

--- 获取最大觉醒
---@param origin any
function AbilityAwakeConfig:getMaxAwake(origin)
    local config = self:getCfgByAbilityId(origin)
    if config then
        return config.max_awake or 0
    end
    return 0
end

--- 判断是否最大觉醒能力
---@param abilityId any
function AbilityAwakeConfig:isMaxAwakeAbility(abilityId)
    local origin = self:getOriginAbilityId(abilityId)
    if origin then
        local awake_ids = self:getCfgByAbilityId(origin).awake_ids
        if abilityId == awake_ids[#awake_ids] then
            return true
        end
    end
    return false
end

--- 判断是否能觉醒
---@param origin any
function AbilityAwakeConfig:canAwake(origin)
    if settings[origin] then
        return true
    end
    return false
end

function AbilityAwakeConfig:getAllCfgs()
    return settings
end

AbilityAwakeConfig:init()

return AbilityAwakeConfig

