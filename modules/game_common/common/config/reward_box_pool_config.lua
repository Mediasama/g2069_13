---@class RewardBoxPoolConfig
local RewardBoxPoolConfig = T(Config, "RewardBoxPoolConfig")

local settings = {}
local pool2settings = {}

function RewardBoxPoolConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/reward_box_pool.csv", 2)
    for _, vConfig in pairs(config) do
        local item = {}
        local list = Lib.splitString(vConfig.s_item, "#")
        item.item_alias = list[1]
        item.item_num = tonumber(list[2])
        if list[3] then
            item.item_num_max = tonumber(list[3])
        end

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            pool_id = tonumber(vConfig.n_pool_id) or 0,
            item = item,
            weight = tonumber(vConfig.n_weight) or 0,
        }
        settings[data.id] = data

        local pools = pool2settings[data.pool_id] or {}
        pools[#pools + 1] = data
        pool2settings[data.pool_id] = pools
    end
end

function RewardBoxPoolConfig:getCfgByPoolId(poolId)
    if not pool2settings[poolId] then
        Lib.logError("Error:Not found the data in reward_box_pool.csv, pool id:", poolId)
    end
    return pool2settings[poolId]
end

function RewardBoxPoolConfig:getAllCfgs()
    return settings
end

RewardBoxPoolConfig:init()

return RewardBoxPoolConfig

