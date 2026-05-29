---@class RewardBoxConfig
local RewardBoxConfig = T(Config, "RewardBoxConfig")

local settings = {}

function RewardBoxConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/reward_box.csv", 2)
    for _, vConfig in pairs(config) do
        local reward_num = 0
        local reward_num_max = nil
        if vConfig.s_reward_num and vConfig.s_reward_num ~= "" then
            local list = Lib.splitString(vConfig.s_reward_num, "#", true)
            reward_num = list[1]
            reward_num_max = list[2]
        end
        
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            box_id = tonumber(vConfig.n_box_id) or 0,
            pool_id = tonumber(vConfig.n_pool_id) or 0,
            reward_num = reward_num,
            reward_num_max = reward_num_max,
            consume = vConfig.s_consume or "",
            reward_type = vConfig.s_reward_type or "",
        }
        settings[data.box_id] = data
    end
end

function RewardBoxConfig:getCfgByBoxId(boxId)
    if not settings[boxId] then
        Lib.logError("Error:Not found the data in reward_box.csv, box id:", boxId)
    end
    return settings[boxId]
end

function RewardBoxConfig:getAllCfgs()
    return settings
end

RewardBoxConfig:init()

return RewardBoxConfig

