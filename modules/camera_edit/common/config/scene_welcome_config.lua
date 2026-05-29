---@class SceneWelcomeConfig
local SceneWelcomeConfig = T(Config, "SceneWelcomeConfig")

local settings = {}

function SceneWelcomeConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/scene_welcome.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            mapName = vConfig.s_mapName or "",
            name = vConfig.s_name or "",
            camera_path = vConfig.s_camera_path or "",
            sound = vConfig.s_sound or "",
        }
        data.enemy = {}
        data.gotoMap = {}
        local bothTb = Lib.splitString(vConfig.s_info or "", "@")
        local idx = 1
        print("bothTbbothTb:",Lib.v2s(bothTb))
        for _, infoTb in pairs(bothTb) do
            print("infoTb:",Lib.v2s(infoTb))
            local info = Lib.splitString(infoTb or "", "#")
            print("info:"..Lib.v2s(info))
            if idx== 1 then
                idx= idx+1
                data.enemy = info
            elseif idx == 2 then

                data.gotoMap = info
                print("data.gotoMap:"..Lib.v2s(data.gotoMap))
            end

        end
        settings[data.mapName] = data
    end
end

function SceneWelcomeConfig:getCfgByMapName(mapName)
    if not settings[mapName] then
        Lib.logError("can not find cfgSceneWelcomeConfig, mapName:", mapName )
        return
    end
    return settings[mapName]
end

function SceneWelcomeConfig:getAllCfgs()
    return settings
end

SceneWelcomeConfig:init()

return SceneWelcomeConfig

