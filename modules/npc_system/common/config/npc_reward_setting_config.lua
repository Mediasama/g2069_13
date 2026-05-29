---@class NpcRewardSettingConfig
local NpcRewardSettingConfig = T(Config, "NpcRewardSettingConfig")

local settings = {}

function NpcRewardSettingConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_reward_setting.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            pool_id = tonumber(vConfig.n_pool_id) or 0,
            poolGroup = tonumber(vConfig.n_poolGroup) or 0,
            kValue = tonumber(vConfig.n_kValue) or 0,
            bValue = tonumber(vConfig.n_bValue) or 0,
            item_alias = vConfig.s_item_alias or "",
            coolTime = tonumber(vConfig.n_coolTime) or 0,
            isFirstDraw = tonumber(vConfig.n_isFirstDraw) or 0,
        }
        data.openLevel = Lib.splitString(vConfig.s_openLevel or "", "#",true)
        settings[data.pool_id] = data
    end
end

function NpcRewardSettingConfig:getCfgByPoolId(pool_id)
    if not settings[pool_id] then
        Lib.logError("can not find cfgNpcRewardSettingConfig, pool_id:", pool_id )
        return
    end
    return settings[pool_id]
end

function NpcRewardSettingConfig:getCfgByGroupAndLv(groupId, level)
    for key, val in pairs(settings) do
        if (val.poolGroup == groupId) and (val.isFirstDraw == 0) then
            local min = val.openLevel[1] or -1
            local max = val.openLevel[2] or -1
            if (level >= min) and (level <= max) then
                return val
            end
        end
    end
    Lib.logError("can not find NpcRewardSettingConfig getCfgByGroupAndLv:", groupId, level )
    return nil
end

function NpcRewardSettingConfig:getCfgByGroupAFirst(groupId, level)
    for key, val in pairs(settings) do
        if (val.poolGroup == groupId) and (val.isFirstDraw == 1) then
            local min = val.openLevel[1] or -1
            local max = val.openLevel[2] or -1
            if (level >= min) and (level <= max) then
                return val
            end
        end
    end
    Lib.logError("can not find NpcRewardSettingConfig getCfgByGroupAFirst:", groupId, level )
    return nil
end

function NpcRewardSettingConfig:getAllCfgs()
    return settings
end

NpcRewardSettingConfig:init()

return NpcRewardSettingConfig

