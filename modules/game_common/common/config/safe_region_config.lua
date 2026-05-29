---@class SafeRegionConfig
local SafeRegionConfig = T(Config, "SafeRegionConfig")

local settings = {}

function SafeRegionConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/safe_region.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            regionName = vConfig.s_regionName or "",
            isMissionSafe = tonumber(vConfig.n_isMissionSafe) or 0,
        }
        settings[data.regionName] = data
    end
end

function SafeRegionConfig:getCfgByRegionName(regionName)
    if not settings[regionName] then
        --Lib.logError("can not find cfgSafeRegionConfig, regionName:", regionName )
        return
    end
    return settings[regionName]
end

function SafeRegionConfig:getCfgMissionRegion(regionName)
    if not settings[regionName] then
        --Lib.logError("can not find cfgSafeRegionConfig, regionName:", regionName )
        return
    end
    return settings[regionName].isMissionSafe == 1
end

function SafeRegionConfig:getAllCfgs()
    return settings
end

SafeRegionConfig:init()

return SafeRegionConfig

