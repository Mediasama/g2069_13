---@class MissionStageWaveInfoConfig
local MissionStageWaveInfoConfig = T(Config, "MissionStageWaveInfoConfig")

local settings = {}
local waveSettings = {}

--- 解析坐标格式
---@param str string
local function parsePosition(str)
    local position = Lib.splitString(str, "#", true)
    return Vector3.new(position[1], position[2], position[3])
end

--- 判断是否空字符串
---@param str any
local function isStringNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
end

function MissionStageWaveInfoConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/mission_stage_wave_info.csv", 2)
    for _, vConfig in pairs(config) do
        local hp_losts = nil
        local hp_tips = nil
        if not isStringNullOrEmpty(vConfig.s_hp_lost) then
            hp_losts = Lib.splitString(vConfig.s_hp_lost, "#", true)
            hp_tips = Lib.splitString(vConfig.s_hp_tips, "#")
        end

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            wave_id = tonumber(vConfig.n_wave_id) or 0,
            wave_type = tonumber(vConfig.n_wave_type) or 0,
            monster_id = tonumber(vConfig.n_monster_id) or 0,
            hp_losts = hp_losts,
            hp_tips = hp_tips,
            born_position = parsePosition(vConfig.s_born_position),
            maxHpPct = not isStringNullOrEmpty(vConfig.s_maxHpPct) and Lib.splitString(vConfig.s_maxHpPct, "#", true) or nil,
            hpRegen = not isStringNullOrEmpty(vConfig.s_hpRegen) and Lib.splitString(vConfig.s_hpRegen, "#", true) or nil,
            attDamagePct = not isStringNullOrEmpty(vConfig.s_attDamagePct) and Lib.splitString(vConfig.s_attDamagePct, "#", true) or nil,
            defDamagePct = not isStringNullOrEmpty(vConfig.s_defDamagePct) and Lib.splitString(vConfig.s_defDamagePct, "#", true) or nil,
            attDominantPct = not isStringNullOrEmpty(vConfig.s_attDominantPct) and Lib.splitString(vConfig.s_attDominantPct, "#", true) or nil,
            use_player_skin = tonumber(vConfig.s_use_player_skin) or 0,
        }
        --- 处理属性相关
        local attribute = nil
        local attribute_pct = nil
        for _, id in pairs(Define.ATTR) do
            local addValue = data[id]
            local pctValue = data[id .. "Pct"]
            if addValue then
                attribute = attribute or {}
                attribute[id] = addValue
            end
            if pctValue then
                attribute_pct = attribute_pct or {}
                attribute_pct[id] = pctValue
            end
        end
        data.attribute = attribute
        data.attribute_pct = attribute_pct

        settings[data.id] = data
        local waveId = data.wave_id
        local waveSetting = waveSettings[waveId] or {}
        waveSetting[#waveSetting + 1] = data
        waveSettings[waveId] = waveSetting
    end
end

function MissionStageWaveInfoConfig:getCfgById(id)
    if not settings[id] then
        Lib.logError("Error:Not found the data in mission_stage_wave_info.csv, id:", id)
    end
    return settings[id]
end

function MissionStageWaveInfoConfig:getCfgsByWaveId(waveId)
    if not waveSettings[waveId] then
        Lib.logError("Error:Not found the data in mission_stage_wave_info.csv, wave id:", waveId)
    end
    return waveSettings[waveId]
end

function MissionStageWaveInfoConfig:getAllCfgs()
    return settings
end

MissionStageWaveInfoConfig:init()

return MissionStageWaveInfoConfig

