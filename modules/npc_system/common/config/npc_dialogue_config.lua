---@class NpcDialogueConfig
local NpcDialogueConfig = T(Config, "NpcDialogueConfig")

---@type TargetConditionHelper
local TargetConditionHelper = T(Lib, "TargetConditionHelper")

local settings = {}
local dialogGroupList = {}
function NpcDialogueConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_dialogue.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {
            dialogId = tonumber(vConfig.n_dialogId) or 0,
            dialogGroupID = tonumber(vConfig.n_dialogGroupID) or 0,
            dialogueTimes = tonumber(vConfig.n_dialogueTimes) or 0,
            showShopId = tonumber(vConfig.n_showShopId) or 0,
            showTaskId = tonumber(vConfig.n_showTaskId) or 0,
            luckyDrawId = tonumber(vConfig.n_luckyDrawId) or 0,
            missionGroup = tonumber(vConfig.n_mission_group) or 0,
            dialogueText = vConfig.s_dialogueText or "",
        }

        data.openCondition = {}
        local openCondition = Lib.splitString(vConfig.s_openCondition or "", "$")
        for index, val in pairs(openCondition) do
            local temp = Lib.splitString(val, "#")
            if not data.openCondition[temp[1]] then
                data.openCondition[temp[1]] = {}
            end
            local conditionInfo = TargetConditionHelper:initConditionData(temp)
            if conditionInfo then
                table.insert(data.openCondition[temp[1]], conditionInfo)
            end
        end

        data.dialogueInput = {}
        local dialogueInput = Lib.splitString(vConfig.s_dialogueInput or "", "$")
        for index, val in pairs(dialogueInput) do
            local temp = Lib.splitString(val, "#")
            table.insert(data.dialogueInput, temp)
        end

        if vConfig.s_replyList ~= "" then
            data.replyList = Lib.splitString(vConfig.s_replyList, "#", true)
        end

        settings[data.dialogId] = data
        if not dialogGroupList[data.dialogGroupID] then
            dialogGroupList[data.dialogGroupID] = {}
        end
        table.insert(dialogGroupList[data.dialogGroupID], data)
    end
    for dialogGroupID, val in pairs(dialogGroupList) do
        table.sort(dialogGroupList[dialogGroupID], function(a, b)
            return a.dialogId < b.dialogId
        end)
    end
end

function NpcDialogueConfig:getCfgById(dialogId)
    if not settings[dialogId] then
        Lib.logError("can not find cfgNpcDialogueConfig, dialogId:", dialogId )
        return
    end
    return settings[dialogId]
end

function NpcDialogueConfig:getCfgByGroupId(groupId)
    if not dialogGroupList[groupId] then
        Lib.logError("can not find NpcDialogueConfig getCfgByGroupId, groupId:", groupId )
        return {}
    end
    return dialogGroupList[groupId]
end

function NpcDialogueConfig:getAllCfgs()
    return settings
end

NpcDialogueConfig:init()

return NpcDialogueConfig

