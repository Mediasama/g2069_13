---@class MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")

local settings = {}
local groupSettings = {}

--- 判断是否空字符串
---@param str any
local function isStringNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
end

--- 解析物品格式
---@param str any
local function parseItemList(str)
    if not isStringNullOrEmpty(str) then
        local itemList = {}
        local list1 = Lib.splitString(str, ",")
        for _, v in pairs(list1) do
            local list2 = Lib.splitString(v, "#")
            local item = {}
            item.item_alias = list2[1]
            item.item_num = tonumber(list2[2])
            itemList[#itemList + 1] = item
        end
        return itemList
    end
    return nil
end

function MissionInfoConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/mission_info.csv", 2)
    for _, vConfig in pairs(config) do
        --- 开启等级
        local open_level_range = nil
        if not isStringNullOrEmpty(vConfig.s_open_level_range) then
            open_level_range = Lib.splitString(vConfig.s_open_level_range, "#", true)
        end
        --- 参与等级
        local join_level_range = nil
        if not isStringNullOrEmpty(vConfig.s_join_level_range) then
            join_level_range = Lib.splitString(vConfig.s_join_level_range, "#", true)
        end
        --- 关卡
        local mission_stages = nil
        if not isStringNullOrEmpty(vConfig.s_mission_stages) then
            mission_stages = Lib.splitString(vConfig.s_mission_stages, "#", true)
        end

        local stage_wait_times = nil
        if not isStringNullOrEmpty(vConfig.s_stages_change_time) then
            stage_wait_times = Lib.splitString(vConfig.s_stages_change_time, "#", true)
        end

        local stage_waitting_battle_times = nil
        if not isStringNullOrEmpty(vConfig.s_stages_waitting_battle_time) then
            stage_waitting_battle_times = Lib.splitString(vConfig.s_stages_waitting_battle_time, "#", true)
        end

        local data = {
            id = tonumber(vConfig.n_id) or 0,
            mission_id = tonumber(vConfig.n_mission_id) or 0,
            mission_name = vConfig.s_mission_name or "",
            mission_group = tonumber(vConfig.n_mission_group) or 0,
            mission_type = tonumber(vConfig.n_mission_type) or 0,
            mission_show = tonumber(vConfig.n_mission_show) or 1,
            mission_stages = mission_stages,
            waitting_time = tonumber(vConfig.n_waitting_time) or 0,
            complete_time = tonumber(vConfig.n_complete_time) or 0,
            quit_time = tonumber(vConfig.n_quit_time) or 0,
            stage_wait_times = stage_wait_times,
            costs =  parseItemList(vConfig.s_costs),
            rewards = parseItemList(vConfig.s_rewards),
            open_level_range = open_level_range,
            join_type = tonumber(vConfig.n_join_type) or 0,
            join_player_max = tonumber(vConfig.n_join_player_max) or 0,
            join_level_range = join_level_range,
            difficulty_text = vConfig.s_difficulty_text or "",
            ability_alias = vConfig.s_ability_alias or "",
            stage_waitting_battle_times = stage_waitting_battle_times,
            mission_alias = vConfig.s_mission_alias or "",
        }

        settings[data.mission_id] = data

        local group = data.mission_group
        local gs = groupSettings[group] or {}
        gs[#gs + 1] = data
        groupSettings[group] = gs
    end
end

function MissionInfoConfig:getCfgByMissionId(missionId)
    if not settings[missionId] then
        Lib.logError("Error:Not found the data in mission_info.csv, mission id:", missionId)
    end
    return settings[missionId]
end

function MissionInfoConfig:getCfgsByGroupId(groupId)
    if not groupSettings[groupId] then
        Lib.logError("Error:Not found the group data in mission_info.csv, group id:", groupId)
    end
    return groupSettings[groupId]
end

function MissionInfoConfig:getCfgsByGroupAndLevel(groupId, level)
    if not groupSettings[groupId] then
        Lib.logError("Error:Not found the group data in mission_info.csv, group id:", groupId)
    end
    local result = {}
    for _, val in pairs(groupSettings[groupId]) do
        if (val.mission_show == 1) and (level >= val.open_level_range[1]) and ((level <= val.open_level_range[2])) then
            table.insert(result, val)
        end
    end
    return result
end

function MissionInfoConfig:getAllCfgs()
    return settings
end

MissionInfoConfig:init()

return MissionInfoConfig

