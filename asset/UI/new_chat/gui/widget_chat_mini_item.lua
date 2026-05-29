local MsgType = Define.MsgType
local miniChatCfg = World.cfg.chatSetting.miniChatCfg
local EmojiConfig = T(Config, "EmojiConfig")
local ShortConfig = T(Config, "ShortConfig")
local ChatHelper = T(Lib, "ChatHelper")

function M:init()
    self:initEvent()
    self.msgText = self:child("MsgText")
    self.textPageTag = self:child("TextPageTag")
    self.imageVoice = self:child("ImageVoice")
    self.textVoiceTime = self:child("VoiceTime")
    --self.itemWidth = self:getWidth()[2]
    self.itemWidth = self:getPixelSize().width
    --self.imageVoice.onMouseClick = function()
    --    Lib.logWarning("playVoice  ", self.msgData)
    --    VoiceManager:playVoice(self.msgData.msg.uri, math.floor(self.msgData.msg.voiceTime / 1000))
    --end
    self.textPageTag:setVisible(miniChatCfg.pageTagSwitch)
end

function M:initEvent()

end

-- 名字过长的截取两个字符部分名字
function M:getOneShortName(name)
    -- name = "&$[ffca00ff-fbd33fff-cad2ceff-23b8feff-677dffff-ac61ffff-fd15ffff]$"..name.."$&"
    local p1,p2 = string.find(name,"&%$", 1)
    local nameStr = name
    local preStr = ""
    local endStr = ""

    -- 去除炫彩昵称后的名字
    if p1 and p2 then
        local p3,p4 = string.find(name,"%$", p2 + 1)
        if p3 and p4 then
            local p5, p6 = string.find(name,"%$&", p4 + 1)
            if p5 and p6 then
                nameStr = string.sub(name,p4+1,p5-1)
                preStr = string.sub(name,1, p4)
                endStr = string.sub(name,p5)
            end
        end
    end

    -- 去除VIP铭牌后的名字
    local p7 = string.find(nameStr,"%[S=", 1)
    local p8 = string.find(nameStr,".json%]", -6)
    if p7 and p8 then
        nameStr = string.sub(nameStr,1, p7-1)
    end

    local endIndex = Lib.subStringGetTotalIndex(nameStr)
    local maxLen = miniChatCfg.miniChatNameMaxLen or 7
    if endIndex > maxLen then
        local content = Lib.subStringUTF8(nameStr, 1, maxLen)
        local result = preStr .. content .. endStr .. "..."
        return result
    else
        return name
    end
end

function M:initData(msgData)
    if self.userDetailInfoCancel then
        self.userDetailInfoCancel()
        self.userDetailInfoCancel = nil
    end
    self.msgData = msgData
    self.imageVoice:setVisible(false)
    self.textVoiceTime:setVisible(false)
    local msgColor = self:getTextColor(msgData.pageType, msgData.fromId)
    local tagStr = self:getPageTagStr(msgData.pageType)

    local detailInfo = ChatHelper:getUserDetailInfo(msgData.fromId)
    if detailInfo then
        msgData.fromName = self:getOneShortName(detailInfo.nickName or "")
    else
        msgData.fromName = self:getOneShortName(msgData.fromName or "")
        self:listenDetailInfo(msgData.fromId, msgData.fromName)
    end
    self.textPageTag:setText(tagStr)
    local tagWidth = self.textPageTag:getWindowRenderer():getDocumentWidth()
    --local msgWidth = self.itemWidth - tagWidth
    --self.msgText:setWidth({0, msgWidth})
    --self.msgText:setXPosition({0, tagWidth})
    if not miniChatCfg.pageTagSwitch then
        tagWidth = 0
    end


    if msgData.msgType == MsgType.Text then
        local fixMsg = self:fixShowMsg(msgData.msg)
        local text = msgColor..string.format("%s:%s", msgData.fromName, fixMsg)
        self.msgText:setText(text)
    elseif msgData.msgType == MsgType.Emoji then
        local data = EmojiConfig:getCfgById(tonumber(msgData.msg))
        if data then
            local fixMsg = self:fixShowMsg(Lang:toText(data.text))
            self.msgText:setText(msgColor..string.format("%s:【%s】", msgData.fromName, fixMsg))
        end
    elseif msgData.msgType == MsgType.ShortMsg then
        local data = ShortConfig:getCfgById(tonumber(msgData.msg))
        if data then
            local fixMsg = self:fixShowMsg(Lang:toText(data.text))
            self.msgText:setText(msgColor..string.format("%s:%s", msgData.fromName, fixMsg))
        end
    elseif msgData.msgType == MsgType.Voice then
        self.msgText:setText(msgColor..string.format("%s:", msgData.fromName))
        local width = self.msgText:getWindowRenderer():getDocumentWidth()
        self.imageVoice:setVisible(true)
        self.imageVoice:setXPosition({0, tagWidth + width})
        local times = math.floor(msgData.msg.voiceTime/1000)
        self.textVoiceTime:setText( times.."''")
        self.textVoiceTime:setVisible(true)
        self.textVoiceTime:setXPosition({0, tagWidth + width + self.imageVoice:getWidth()[2]})
    elseif msgData.msgType == MsgType.FollowHello then
        local fixMsg = self:fixShowMsg(Lang:toText({"g2060_friend_follow_hello", msgData.msg}))
        self.msgText:setText(msgColor..string.format("%s:%s", msgData.fromName, fixMsg))
    end
    local height = self.msgText:getWindowRenderer():getDocumentHeight()
    self:setHeight({ 0, height})
end

function M:getTextColor(pageType, fromId)
    local color = nil
    if fromId == Me.platformUserId then
        color = miniChatCfg.textColor.selfTextColor
    else
        color = miniChatCfg.textColor[pageType]
    end
    if not color then
        color = miniChatCfg.textColor.defaultTextColor
    end
    return string.format("[colour='%s']", color)
end

function M:getPageTagStr(pageType)
    local tagConfig = miniChatCfg.pageTag[pageType]
    if tagConfig and miniChatCfg.pageTagSwitch then
        local color = tagConfig.color or "FFFFFFFF"
        return string.format("[colour='%s']【%s】", color, Lang:toText(tagConfig.name))
    end
    return ""
end

function M:fixShowMsg(str, len)
    if not miniChatCfg.textLimitChatSwitch then
        return str
    end
    if not len then
        len = miniChatCfg.textLimitChatLen
    end
    local showMsg = Lib.getStringLen(str) > len and Lib.subString(str, len) .. "..." or str
    return showMsg
end

function M:listenDetailInfo(userId, fromName)
    if not userId then
        return
    end
    self.userDetailInfoCancel = Lib.lightSubscribeEvent("","EVENT_USER_DETAIL"..userId, function(data)
        local showName = self:getOneShortName(data.nickName or "")
        self.msgText:setText(string.gsub(self.msgText:getText(), fromName, showName,1))
        if self.msgData.msgType == MsgType.Voice then
            local width = self.msgText:getWindowRenderer():getDocumentWidth()
            self.imageVoice:setXPosition({0, width})
            self.textVoiceTime:setXPosition({0, width + self.imageVoice:getWidth()[2]})
        end
        if self.userDetailInfoCancel then
            self.userDetailInfoCancel()
        end
    end)
    ChatHelper:initDetailInfo(userId)
end

function M:onDestroy()
    self:destroy()
end

function M:destroy()
    if self.userDetailInfoCancel then
        self.userDetailInfoCancel()
        self.userDetailInfoCancel = nil
    end
end

M:init()
