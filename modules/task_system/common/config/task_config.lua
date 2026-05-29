---@class TaskConfig
local TaskConfig = T(Config, "TaskConfig")

local settings = {}
local taskConditionList = {}
local taskPartList = {}
local nextTaskList = {}
---@type TargetConditionHelper
local TargetConditionHelper = T(Lib, "TargetConditionHelper")

function TaskConfig:initCondition()
    for key, val in pairs(Define.TargetConditionKey) do
        taskConditionList[key] = {}
        taskConditionList[key].complete = {}
        taskConditionList[key].open = {}
    end
end

function TaskConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/task.csv", 3)
    for _, vConfig in pairs(config) do
        --- 奖励物品
        local rewards = nil
        if vConfig.s_taskRewards and vConfig.s_taskRewards ~= "" then
            local itemAliasList = Lib.splitString(vConfig.s_taskRewards, "#")
            local itemNumList = Lib.splitString(vConfig.s_rewardCount, "#", true)
            rewards = {}
            for i = 1, #itemAliasList, 1 do
                rewards[#rewards + 1] = { item_alias = itemAliasList[i] , item_num = itemNumList[i] }
            end
        end

        local data = {
            taskId = tonumber(vConfig.n_taskId) or 0,
            taskName = vConfig.s_taskName or "",
            taskType = tonumber(vConfig.n_taskType) or 0,
            preTask = tonumber(vConfig.n_preTask) or 0,
            limitCounts = tonumber(vConfig.n_limitCounts) or 0,
            guideMap = vConfig.s_guideMap or "",
            rewards = rewards,
        }
        if data.preTask and data.preTask > 0 then
            if not nextTaskList[data.preTask] then
                nextTaskList[data.preTask] = {}
            end
            table.insert(nextTaskList[data.preTask], data.taskId)
        end
        data.autoIssue = (tonumber(vConfig.n_autoIssue) or 1) == 1
        data.canGiveUp = tonumber(vConfig.n_canGiveUp) == 1
        data.autoGuide = (tonumber(vConfig.n_autoGuide) or 1) == 1
        data.branchLogin = (tonumber(vConfig.n_branchLogin) or 0) == 1

        local guidePos = Lib.splitString(vConfig.s_guidePos or "", "#", true)
        data.guidePos = Lib.v3(guidePos[1] or 0, guidePos[2] or 0, guidePos[3] or 0)

        data.taskCondition = {}
        local taskCondition = Lib.splitString(vConfig.s_taskCondition or "", "$")
        for index, val in pairs(taskCondition) do
            local temp = Lib.splitString(val, "#")
            if not data.taskCondition[temp[1]] then
                data.taskCondition[temp[1]] = {}
            end
            local conditionInfo = TargetConditionHelper:initConditionData(temp)
            if conditionInfo then
                if temp[1] == Define.TargetConditionKey.LOCATION then
                    taskPartList[temp[2]] = true
                end
                conditionInfo.taskId = data.taskId
                table.insert(taskConditionList[temp[1]]["open"], conditionInfo)
                table.insert(data.taskCondition[temp[1]], conditionInfo)
            end
        end

        data.taskCompleteCondition = {}
        local taskCompleteCondition = Lib.splitString(vConfig.s_taskCompleteCondition or "", "$")
        for index, val in pairs(taskCompleteCondition) do
            local temp = Lib.splitString(val, "#")
            if not data.taskCompleteCondition[temp[1]] then
                data.taskCompleteCondition[temp[1]] = {}
            end
            local conditionInfo = TargetConditionHelper:initConditionData(temp)
            if conditionInfo then
                if temp[1] == Define.TargetConditionKey.LOCATION then
                    taskPartList[temp[2]] = true
                end
                conditionInfo.taskId = data.taskId
                table.insert(taskConditionList[temp[1]]["complete"], conditionInfo)
                table.insert(data.taskCompleteCondition[temp[1]], conditionInfo)
            end
        end

        settings[data.taskId] = data
    end
end

function TaskConfig:getCfgById(id)
    if not settings[id] then
        Lib.logError("can not find cfgTaskConfig, id:", id )
        return
    end
    return settings[id]
end

function TaskConfig:getNextTaskById(id)
    if not nextTaskList[id] then
        return
    end
    return nextTaskList[id]
end

function TaskConfig:getTaskListByCondition(conditionKey)
    return taskConditionList[conditionKey]
end

function TaskConfig:checkIsTaskRegionPart(partName)
    return taskPartList[partName]
end

function TaskConfig:getAllCfgs()
    return settings
end

TaskConfig:initCondition()
TaskConfig:init()

return TaskConfig

