---@class MonsterRegionConfig
local MonsterRegionConfig = T(Config, "MonsterRegionConfig")

local settings = {}

function MonsterRegionConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/monster_region.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            regionName = vConfig.s_regionName or "",
            maxExistNum = tonumber(vConfig.n_maxExistNum) or 0,
            refreshTime = tonumber(vConfig.n_refreshTime) or 0,
            fixedPos = tonumber(vConfig.n_fixedPos) or 0,
        }
        if vConfig.n_birthY and vConfig.n_birthY ~= "" then
            data.birthY = tonumber(vConfig.n_birthY) or 0
        end
        data.monsterList = Lib.splitString(vConfig.s_monsterList or "", '#', true)
        data.resetToBorn = Lib.splitString(vConfig.s_resetToBorn or "", '#', true)
        settings[data.regionName] = data
    end
end

function MonsterRegionConfig:getCfgById(regionName)
    if not settings[regionName] then
        return
    end
    return settings[regionName]
end

function MonsterRegionConfig:getAllCfgs()
    return settings
end

MonsterRegionConfig:init()

return MonsterRegionConfig

