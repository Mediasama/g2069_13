---@class SoundConfig
local SoundConfig = T(Config, "SoundConfig")

local settings = {}

function SoundConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/sound.csv", 2)
    for _, vConfig in pairs(config or {}) do
        ---@class SoundConfigItem
        local data = {
            key = vConfig.s_key or "",
            sound = vConfig.s_sound or "",
            loop = (tonumber(vConfig.n_loop) or 0) == 1,
            volume = tonumber(vConfig.n_volume) or 0,
            is3dSound = (tonumber(vConfig.n_3dSound) or 0) == 1,
            bgm_interval = tonumber(vConfig.n_bgm_interval) or 0,
            bgm_duration = tonumber(vConfig.n_bgm_duration) or 0,
            attenuationType = 0,
            losslessDistance = tonumber(vConfig.n_losslessDistance) or 1,
            maxDistance = tonumber(vConfig.n_maxDistance) or 100,
            attenuationType="0"
        }
        settings[data.key] = data
    end
end

---@return SoundConfigItem
function SoundConfig:getSound(key)
    if not settings[key] then
        --Lib.logWarning("SoundConfig:getSound cfg  can not find , key = ", key)
        return
    end
    return settings[key]
end

SoundConfig:init()

return SoundConfig

