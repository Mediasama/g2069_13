---@class NpcDialogueReplyConfig
local NpcDialogueReplyConfig = T(Config, "NpcDialogueReplyConfig")

local settings = {}

function NpcDialogueReplyConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_dialogue_reply.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {
            replyId = tonumber(vConfig.n_replyId) or 0,
            replyText = vConfig.s_replyText or "",
            replyType = tonumber(vConfig.n_replyType) or 0,
            shopId = tonumber(vConfig.n_shopId) or 0,
            deliverMap = vConfig.s_deliverMap or "",
            taskId = tonumber(vConfig.n_taskId) or 0,
            jumpDialogId = tonumber(vConfig.n_jumpDialogId) or 0,
            replySuccess = tonumber(vConfig.n_replySuccess) or 0,
            replyFail = tonumber(vConfig.n_replyFail) or 0
        }

        local deliverCoordinate = Lib.splitString(vConfig.s_deliverCoordinate or "", "#", true)
        data.deliverCoordinate = Lib.v3(deliverCoordinate[1] or 0, deliverCoordinate[2] or 0, deliverCoordinate[3] or 0)

        --- 奖励物品
        local rewards = nil
        if vConfig.s_dialogRewards and vConfig.s_dialogRewards ~= "" then
            local itemAliasList = Lib.splitString(vConfig.s_dialogRewards, "#")
            local itemNumList = Lib.splitString(vConfig.s_itemCounts, "#", true)
            rewards = {}
            for i = 1, #itemAliasList, 1 do
                rewards[#rewards + 1] = { item_alias = itemAliasList[i] , item_num = itemNumList[i] }
            end
        end
        data.rewards = rewards

        settings[data.replyId] = data
    end
end

function NpcDialogueReplyConfig:getCfgById(replyId)
    if not settings[replyId] then
        Lib.logError("can not find cfgNpcDialogueReplyConfig, replyId:", replyId )
        return
    end
    return settings[replyId]
end

function NpcDialogueReplyConfig:getAllCfgs()
    return settings
end

NpcDialogueReplyConfig:init()

return NpcDialogueReplyConfig

