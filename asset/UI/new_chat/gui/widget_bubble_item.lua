local chatSetting = World.cfg.chatSetting
local MsgType = Define.MsgType
local EmojiConfig = T(Config, "EmojiConfig")
local ShortConfig = T(Config, "ShortConfig")

function M:init()
    self.textMsg = self:child("TextMsg")
    self.layoutVoice = self:child("LayoutVoice")
    self.textVoiceTime = self:child("TextVoiceTime")
    self.textMsgInitW = self.textMsg:getWidth()[2]
    self.textMsgInitH = self.textMsg:getHeight()[2]
    self.textMsgMinWidth = chatSetting.chatBubbleSetting.bubbleMinWidth
    self.imageBubbleWidthGap = self.ImageBubbleBg:getWidth()[2] - self.textMsgInitW
    self.imageBubbleHeightGap = self.ImageBubbleBg:getHeight()[2] - self.textMsg:getHeight()[2]
    self.rootHeightGap = self:getHeight()[2] - self.ImageBubbleBg:getHeight()[2]
    self.layoutVoiceHeight = self.layoutVoice:getHeight()
    self.layoutVoiceWidth = self.layoutVoice:getWidth()
    self.isCache = false
end

function M:setMsg(msgData)
    self.textMsg:setVisible(msgData.msgType == MsgType.Text or
            msgData.msgType == MsgType.Emoji or
            msgData.msgType == MsgType.ShortMsg or
            msgData.msgType == MsgType.FollowHello
    )
    self.layoutVoice:setVisible(msgData.msgType == MsgType.Voice)
    local msg
    if msgData.msgType == MsgType.Text then
        msg = msgData.msg
        self:setTextContent(msg)
    elseif msgData.msgType == MsgType.Emoji then
        local data = EmojiConfig:getCfgById(tonumber(msgData.msg))
        if data then
            msg = Lang:toText(data.text)
            self:setTextContent(string.format("【%s】", msg))
        end
    elseif msgData.msgType == MsgType.ShortMsg then
        local data = ShortConfig:getCfgById(tonumber(msgData.msg))
        if data then
            msg = Lang:toText(data.text)
            self:setTextContent(msg)
        end
    elseif msgData.msgType == Define.MsgType.Voice then
        local times = math.floor(msgData.msg.voiceTime/1000)
        self.textVoiceTime:setText( times.."''")
        self.ImageBubbleBg:setWidth(self.layoutVoiceWidth)
        self.ImageBubbleBg:setHeight(self.layoutVoiceHeight)
        self:setHeight(self.layoutVoiceHeight)
    elseif msgData.msgType == MsgType.FollowHello then
        msg = Lang:toText({"g2060_friend_follow_hello", msgData.msg})
        self:setTextContent(msg)
    end
end

function M:setTextContent(msg)
    self.textMsg:setProperty("AutoScale", '1')
    self.textMsg:setProperty("HorzFormatting", 'LeftAligned')
    self.textMsg:setHeight({0,self.textMsgInitH})
    self.textMsg:setText(self:fixShowMsg(msg))
    local textWidth = self.textMsg:getWidth()[2]
    --文本长度超长，文本框改为自适应高度
    if textWidth > self.textMsgInitW then
        self.textMsg:setProperty("AutoScale", '2')
        self.textMsg:setProperty("HorzFormatting", 'WordWrapLeftAligned')
        self.textMsg:setWidth({0, self.textMsgInitW})
        self.textMsg:setText(msg)
        textWidth = self.textMsgInitW
    elseif textWidth < self.textMsgMinWidth then
        self.textMsg:setWidth({0, self.textMsgMinWidth})
        textWidth = self.textMsgMinWidth
    end
    local textHeight = self.textMsg:getHeight()[2]
    self.ImageBubbleBg:setWidth({0, textWidth + self.imageBubbleWidthGap})
    self.ImageBubbleBg:setHeight({0, textHeight + self.imageBubbleHeightGap})
    self:setHeight({0, self.ImageBubbleBg:getHeight()[2] + self.rootHeightGap})
end

function M:getItemHeight()
    return self:getHeight()
end

function M:playAlphaAnim()
    if self.isCache then
        return
    end
    if self.alphaTimer then
        self.alphaTimer()
    end
    local animTime = 10
    local tick = 0
    local offset = 1 / animTime
    self.alphaTimer = World.Timer(1, function()
        tick = tick + 1
        self:setAlpha(1 - tick * offset)
        if tick == animTime then
            self:setAlpha(0)
            self.alphaTimer = nil
            self.isCache = true
            return false
        else
            return true
        end
    end)
end

function M:resetAlpha()
    self:setAlpha(1)
    self.isCache = false
end

function M:fixShowMsg(str, len)
    if not chatSetting.chatBubbleSetting.chatLimit then
        return str
    end
    if not len then
        len = chatSetting.chatBubbleSetting.chatLimit
    end
    local showMsg = Lib.getStringLen(str) > len and Lib.subString(str, len) .. "..." or str
    return showMsg
end

function M:destroy()
    if self.alphaTimer then
        self.alphaTimer()
        self.alphaTimer = nil
    end
end

function M:onDestroy()
    self:destroy()
end

M:init()

