---@class DangerProtectConfig
local DangerProtectConfig = T(Config, "DangerProtectConfig")

local settings = {}

function DangerProtectConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/danger_protect.csv", 1)
    for _, vConfig in pairs(config) do
        local data = Lib.splitString(vConfig.userId_score or "", ",")
        local regionStr = Lib.splitString(data[3] or "", "-")
        local userId = tonumber(data[1]) or 0

        settings[userId] = {
            userId = userId,
            score = tonumber(data[2]) or 0,
            regionId = tonumber(regionStr[1]) or 0,
            regionExtra = regionStr[2] or ""
        }
    end
end

function DangerProtectConfig:getCfgById(userId)
    if not settings[userId] then
        Lib.logError("can not find cfgDangerProtectConfig, userId:", userId )
        return
    end
    return settings[userId]
end

function DangerProtectConfig:getAllCfgs()
    return settings
end

DangerProtectConfig:init()

return DangerProtectConfig

