---@class AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")

local settings = {}

function AbilityLevelConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/ability_level.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            level = tonumber(vConfig.n_level) or 0,
            upgradePrice = tonumber(vConfig.n_upgradePrice) or 0,
            fightCount = tonumber(vConfig.n_fightCount) or 0,
        }
        settings[data.level] = data
    end
end

-- function AbilityLevelConfig:getCfgById(id)
--     if not settings[id] then
--         Lib.logError("can not find cfgAbilityLevelConfig, id:", id )
--         return
--     end
--     return settings[id]
-- end

--- 获取升级数据
---@param level any
function AbilityLevelConfig:getCfgByLevel(level)
    if not settings[level] then
        Lib.logError("Error:Not found the data in ability_level.csv, level:", level)
    end
    return settings[level]
end

--- 获取最大等级
---@return number
function AbilityLevelConfig:getMaxLevel()
    return #settings
end

function AbilityLevelConfig:getAllCfgs()
    return settings
end

AbilityLevelConfig:init()

return AbilityLevelConfig

