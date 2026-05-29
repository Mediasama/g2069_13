---@class PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")

local settings = {}

function PlayerBornConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/player_born.csv", 2)
    for _, vConfig in pairs(config) do
        local bornPosition = Lib.splitString(vConfig.s_bornCoordinate, "#", true)
        local rebornPositions = {}
        --- 复活点
        local list = Lib.splitString(vConfig.s_rebornCoordinate, ",")
        for i = 1, #list, 1 do
            local values = Lib.splitString(list[i], "#", true)
            rebornPositions[#rebornPositions + 1] = Vector3.new(values[1], values[2], values[3])
        end

        local born_level = nil
        if vConfig.s_born_level and vConfig.s_born_level ~= "" then
            born_level = Lib.splitString(vConfig.s_born_level, "#", true)
        end

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            mapName = vConfig.s_mapName or "",
            name = vConfig.s_name or "",
            icon = vConfig.s_icon or "",
            bornCoordinate = vConfig.s_bornCoordinate or "",
            rebornMap = vConfig.s_rebornMap or "",
            rebornCoordinate = vConfig.s_rebornCoordinate or "",
            selectableMap = tonumber(vConfig.n_selectableMap) or 0,
            bornPosition = Vector3.new(bornPosition[1], bornPosition[2], bornPosition[3]),
            rebornPositions = rebornPositions,
            bgm = vConfig.s_bgm or "",
            born_icon = vConfig.s_born_icon or "",
            born_level = born_level,
        }
        settings[data.mapName] = data
    end
end

function PlayerBornConfig:getCfgByMapName(mapName)
    if not settings[mapName] then
        Lib.logError("Error:Not found the data in player_born.csv, map name:", mapName)
        return
    end
    return settings[mapName]
end

function PlayerBornConfig:getAllCfgs()
    return settings
end

PlayerBornConfig:init()

return PlayerBornConfig

