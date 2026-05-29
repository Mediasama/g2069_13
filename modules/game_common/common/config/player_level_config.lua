---@class PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")

local settings = {}

function PlayerLevelConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/player_level.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            level = tonumber(vConfig.n_level) or 0,
            need_exp = tonumber(vConfig.n_need_exp) or 0,
            total_attr_point = tonumber(vConfig.n_total_attr_point) or 0,
        }
        settings[data.level] = data
    end
end

--- 通过等级获取属性
---@param level number 等级
---@return table cfg
function PlayerLevelConfig:getCfgByLevel(level)
    if not settings[level] then
        Lib.logError("Error:Not found the data in attribute_level.csv, level:", level)
    end
    return settings[level]
end

--- 获取最大等级
---@return number 最大等级
function PlayerLevelConfig:getMaxLevel()
    return #settings
end

--- 获取升级经验
---@param level any
function PlayerLevelConfig:getNeedExp(level)
    local config = self:getCfgByLevel(level)
    return config.need_exp
end

function PlayerLevelConfig:getAllCfgs()
    return settings
end

PlayerLevelConfig:init()

return PlayerLevelConfig

