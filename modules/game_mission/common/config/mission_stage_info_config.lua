---@class MissionStageInfoConfig
local MissionStageInfoConfig = T(Config, "MissionStageInfoConfig")

local settings = {}

--- 判断是否空字符串
---@param str any
local function isStringNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
end

--- 解析坐标数组格式
---@param str string
local function parsePositionList(str)
    local positions = {}
    local list = Lib.splitString(str, ",")
    for _, ps in pairs(list) do
        local position = Lib.splitString(ps, "#", true)
        positions[#positions + 1] = Vector3.new(position[1], position[2], position[3])
    end
    return positions
end

--- 解析条件
---@param str any
local function parseCondition(str)
    local conditions = {}
    local list = Lib.splitString(str, ",")
    for k, v in pairs(list) do
        local condition = Lib.splitString(str, "#")
        local cType = tonumber(condition[1])
        local params = nil
        if #condition > 1 then
            table.remove(condition, 1)
            params = condition
        end
        conditions[#conditions + 1] = { type = cType, params = params }
    end
    return conditions
end

function MissionStageInfoConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/mission_stage_info.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            stage_id = tonumber(vConfig.n_stage_id) or 0,
            stage_map = vConfig.s_stage_map or "",
            born_position = parsePositionList(vConfig.s_born_position),
            complete_condition = parseCondition(vConfig.s_complete_condition),
            boss_waves = not isStringNullOrEmpty(vConfig.s_boss_waves) and Lib.splitString(vConfig.s_boss_waves, "#", true) or nil,
            boss_wave_time = tonumber(vConfig.n_boss_wave_time) or 0,
            monster_waves = not isStringNullOrEmpty(vConfig.s_monster_waves) and Lib.splitString(vConfig.s_monster_waves, "#", true) or nil,
            monster_wave_time = tonumber(vConfig.n_monster_wave_time) or 0,
        }
        settings[data.stage_id] = data
    end
end

function MissionStageInfoConfig:getCfgByStageId(stageId)
    if not settings[stageId] then
        Lib.logError("Error:Not found the data in mission_stage_info.csv, stage id:", stageId)
    end
    return settings[stageId]
end

function MissionStageInfoConfig:getAllCfgs()
    return settings
end

MissionStageInfoConfig:init()

return MissionStageInfoConfig

