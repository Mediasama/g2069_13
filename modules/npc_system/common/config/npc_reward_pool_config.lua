---@class NpcRewardPoolConfig
local NpcRewardPoolConfig = T(Config, "NpcRewardPoolConfig")

local settings = {}

function NpcRewardPoolConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_reward_pool.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            pool_id = tonumber(vConfig.n_pool_id) or 0,
            item_alias = vConfig.s_item_alias or "",
            item_num = tonumber(vConfig.n_item_num) or 0,
            weight = tonumber(vConfig.n_weight) or 0,
            floor = tonumber(vConfig.n_floor) or 0,
        }
        if not settings[data.pool_id] then
            settings[data.pool_id] = {}
        end
        table.insert(settings[data.pool_id], data)
    end
end

function NpcRewardPoolConfig:getCfgByPoolId(pool_id)
    if not settings[pool_id] then
        Lib.logError("can not find cfgNpcRewardPoolConfig, pool_id:", pool_id )
        return
    end
    return settings[pool_id]
end

function NpcRewardPoolConfig:getAllCfgs()
    return settings
end

NpcRewardPoolConfig:init()

return NpcRewardPoolConfig

