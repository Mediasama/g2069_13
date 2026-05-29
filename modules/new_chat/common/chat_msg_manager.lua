local ChatPage = Define.ChatPage
local chatSetting = World.cfg.chatSetting

local ChatMsgManager = T(World, "ChatMsgManager")

function ChatMsgManager:init()
    self.msgMap = {}
    self.miniChatMsg = {}
end

function ChatMsgManager:pushMsg(msgData)
    local msgList = self.msgMap[msgData.pageType]
    if not msgList then
        local classSetting = chatSetting.msgList[msgData.pageType]
        if classSetting then
            local msgListClass = require(chatSetting.msgList[msgData.pageType].class)
            if not msgListClass then
                return
            end
            msgList = msgListClass.new(msgData.pageType)
            self.msgMap[msgData.pageType] = msgList
        else
            Lib.logWarning("pushMsg msgData  ---> ", msgData.pageType)
            return
        end
    end
    if msgData.pageType ~= ChatPage.Private then
        msgList:pushMsg(msgData.fromId, msgData)
    else
        msgList:pushMsg(msgData.keyId, msgData)
    end
    if not msgData.isHistory then
        if chatSetting.miniChatCfg.showPageType[msgData.pageType] then
            if #self.miniChatMsg >= chatSetting.pageMsgMaxCount then
                table.remove(self.miniChatMsg, 1)
            end
            table.insert(self.miniChatMsg, msgData)
        end
        Lib.emitEvent(Event.EVENT_PUSH_CHAT_MSG, msgData)
    end
end

function ChatMsgManager:getLatestMiniMsg()
    if #self.miniChatMsg > 0 then
        return self.miniChatMsg[#self.miniChatMsg]
    end
    return nil
end

function ChatMsgManager:getLatestMsg(pageType, targetId)
    return self.msgMap[pageType]:getLatestMsg(1, targetId)
end

function ChatMsgManager:getPageMsgList(pageType, key)
    if self.msgMap[pageType] then
        return self.msgMap[pageType]:getMsgList(key)
    end
    return {}
end

function ChatMsgManager:getPageMsgListGroup(pageType)
    if self.msgMap[pageType] then
        return self.msgMap[pageType]:getMsgListGroup()
    end
    return {}
end

function ChatMsgManager:clearMsgByType(pageType, targetId)
    if self.msgMap[pageType] then
        self.msgMap[pageType]:clearMsg(targetId)
    end
end