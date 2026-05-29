--聊天消息体
local ChatHelper = T(Lib, "ChatHelper")
local EmojiConfig = T(Config, "EmojiConfig")
local ShortConfig = T(Config, "ShortConfig")
local MsgType = Define.MsgType

M.VoiceImageList = {
    "gameres|asset/imageset/chat2:img_0_voiceicon_other",
    "gameres|asset/imageset/chat2:img_0_voiceicon_other01",
    "gameres|asset/imageset/chat2:img_0_voiceicon_other02",
}
M.VoiceImageListSelf = {
    "gameres|asset/imageset/chat2:img_0_voiceicon_self",
    "gameres|asset/imageset/chat2:img_0_voiceicon_self01",
    "gameres|asset/imageset/chat2:img_0_voiceicon_self02",
}

function M:init()
    --print(">>>>>>>>>>>>>>>>>>>>>>>> chat_item_text init() ",self)
    self.userId = nil
    self._allEvent = {}
    self.voiceAniIndex = 1
    self.voiceAniTimer = nil
    self.data = nil
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.panelHead = self.PanelHead
    self.widgetHead = UI:openWidget("UI/new_chat/gui/widget_chat_player_head")
    self.panelHead:addChild(self.widgetHead)
    self.textName = self.TextName
    self.panelText = self.PanelText
    self.imageBubble = self.PanelText.ImageBubble
    self.textMsg = self.imageBubble.TextMsg
    self.imageEmoji = self.ImageEmoji
    self.panelVoice = self.PanelVoice
    self.imageBubbleVoice = self.PanelVoice.ImageBubbleVoice
    self.imageVoiceOther = self.PanelVoice.ImageBubbleVoice.ImageVoiceOther
    self.imageVoiceSelf = self.PanelVoice.ImageBubbleVoice.ImageVoiceSelf
    self.textVoiceTime = self.PanelVoice.ImageBubbleVoice.TextVoiceTime
    self.redDot = self.PanelVoice.ImageBubbleVoice.ImageRedDot
    self.panelHeadOffsetX = self.panelHead:getXPosition()[2]
    self.textNameOffsetX = self.textName:getXPosition()[2]
    self.textMsgOffsetX = self.textMsg:getXPosition()[2]
    self.panelTextOffsetX = self.panelText:getXPosition()[2]
    self.rootInitHeight = self:getHeight()[2]
    self.textMsgInitW = self.textMsg:getWidth()[2]
    self.textMsgInitH = self.textMsg:getHeight()[2]
    self.imageBubbleWidthGap = self.imageBubble:getWidth()[2] - self.textMsgInitW
    self.imageBubbleHeightGap = self.imageBubble:getHeight()[2] - self.textMsg:getHeight()[2]
    self.rootHeightGap = self:getHeight()[2] - self.textMsg:getHeight()[2]
    self.imageEmojiOffsetX = self.imageEmoji:getXPosition()[2]
    self.imageVoiceOffsetX = self.imageVoiceOther:getXPosition()[2]
    self.textVoiceTimeOffsetX = self.textVoiceTime:getXPosition()[2]

    self.textMsg:setProperty("AutoScale", '2')
end

function M:initEvent()
    self.imageBubbleVoice.onWindowClick = function()
        --if self:isVoiceDataPlaying() then
        --    self:stopSoundAni()
        --else
        --    self:playSound()
        --end
        self:playSound()
    end

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_VOICE_START, function(path)
        print(">>>>>>>>>>>>>>>>>>>>>>>>  start play:", path)
        if self:isThisVoiceItem(path) then
            self:playSoundAni()
        end
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_VOICE_END, function(path)
        print("<<<<<<<<<<<<<<<<<<<<<<<<  play end:", path)
        if self:isThisVoiceItem(path) then
            self:stopSoundAni(path)
        end
    end)
end

function M:playSound()
    self:setVoiceDataPlayed(true)
    self.redDot:setVisible(false)
    print("M:playSound(),uri:", self.data.msg.uri)
    VoiceManager:playVoice(self.data.msg.uri, math.floor(self.data.msg.voiceTime / 1000))
    --self:playSoundAni()
end

function M:playSoundAni()
    self:setVoiceDataPlaying(true)
    print("M:playSoundAni():", self.data.msg.uri)
    self.voiceAniIndex = 1
    self.voiceAniTimer = World.Timer(10, function()
        local num = #M.VoiceImageList
        local index = self.voiceAniIndex % num + 1
        --print(">>>>>>>>>playSoundAni(),index :",index)
        if self:isSelfMsg() then
            self.imageVoiceSelf:setImage(M.VoiceImageListSelf[index])
            self.voiceAniIndex = self.voiceAniIndex + 1
        else
            self.imageVoiceOther:setImage(M.VoiceImageList[index])
            self.voiceAniIndex = self.voiceAniIndex + 1
        end
        return true
    end)
end

function M:stopSoundAni()
    print("M:stopSoundAni():", self.data.msg.uri)
    self:setVoiceDataPlaying(false)
    if self.voiceAniTimer then
        self.voiceAniTimer()
        self.voiceAniTimer = nil
    end
    if self:isSelfMsg() then
        self.imageVoiceSelf:setImage(M.VoiceImageListSelf[1])
    else
        self.imageVoiceOther:setImage(M.VoiceImageList[1])
    end
end

function M:isVoiceDataPlaying()
    if self.data then
        return self.data.isPlaying
    end
    return false
end
function M:setVoiceDataPlaying(isPlaying)
    if self.data then
        self.data.isPlaying = isPlaying
    end
end

function M:isVoiceDataPlayed()
    if self.data then
        return self.data.isPlayed
    end
    return false
end
function M:setVoiceDataPlayed(isPlayed)
    if self.data then
        self.data.isPlayed = isPlayed
    end
end

function M:isThisVoiceItem(voicePath)
    if self.data and voicePath then
        local myPath = self.data.msg.uri
        if myPath then
            return myPath:sub(-19) == voicePath:sub(-19)
        end
    end
    return false
end

---initData 外部调用此函数初始化数据
---@param msgData table
function M:initData(msgData)
    --print(">>>>>>>>>>>>>>>>>>>>>>>> chat_item_text initData():",self)
    if not msgData then
        return
    end
    self:reset()
    self.data = msgData
    self.userId = msgData.fromId
    self:setMsgContent(msgData)
    local detailInf = ChatHelper:getUserDetailInfo(self.userId)
    if detailInf then
        self:cancelDetailListener()
        self:setDetailInf(detailInf)
    else
        self:listenDetailInfo(self.userId)
    end
    self:setSide(msgData, not self:isSelfMsg())
end

function M:setDetailInf(detailInf)
    --print(">>>>>>>widget_chat_item:setDetailInf(msgData):",detailInf, self.userId)
    if detailInf then
        self.textName:setText(detailInf.nickName)
        self.widgetHead:initData(detailInf)
        if self:isSelfMsg() then
            self.redDot:setVisible(false)
        end
    end
end

function M:listenDetailInfo(userId)
    if not userId then
        Lib.logError("widget_chat_item_txt:listenDetailInfo id is nil!")
        return
    end
    self:cancelDetailListener()
    self.userDetailInfoCancel = Lib.subscribeEvent("EVENT_USER_DETAIL" .. userId, function(data)
        self:setDetailInf(data)
    end)
    ChatHelper:initDetailInfo(userId)
end

function M:cancelDetailListener()
    if self.userDetailInfoCancel then
        self.userDetailInfoCancel()
        self.userDetailInfoCancel = nil
    end
end

---setMsgContent 设置消息体内容
---@param msgData table
function M:setMsgContent(msgData)
    self.panelText:setVisible(msgData.msgType == MsgType.Text or msgData.msgType == MsgType.ShortMsg or msgData.msgType == MsgType.FollowHello)
    self.imageEmoji:setVisible(msgData.msgType == MsgType.Emoji)
    self.panelVoice:setVisible(msgData.msgType == MsgType.Voice)
    self:setHeight({ 0, self.rootInitHeight })
    if msgData.msgType == MsgType.Text or msgData.msgType == MsgType.ShortMsg or msgData.msgType == MsgType.FollowHello then
        self:setTextWidget(self.textMsg, self.textMsgInitW, self.textMsgInitH)
        local textSize = self.textMsg:getSize()
        local bubbleSize = UDim2.new(0, textSize.width[2] + self.imageBubbleWidthGap, 0, textSize.height[2] + self.imageBubbleHeightGap)
        self.imageBubble:setSize(bubbleSize)
        self.panelText:setSize(bubbleSize)
        self:setHeight({ 0, bubbleSize[2][2] + self.rootHeightGap })
    elseif msgData.msgType == MsgType.Emoji then
        local data = EmojiConfig:getCfgById(tonumber(msgData.msg))
        if data then
            self.imageEmoji:setImage(data.icon)
        end
    elseif msgData.msgType == MsgType.Voice then
        local times = math.floor(msgData.msg.voiceTime / 1000)
        self.textVoiceTime:setText(times .. "''")
        self.redDot:setVisible(not self:isVoiceDataPlayed())
        self.imageVoiceOther:setVisible(not self:isSelfMsg())
        self.imageVoiceSelf:setVisible(self:isSelfMsg())
        if self:isVoiceDataPlaying() then
            self:playSoundAni()
        end
    end
end

---setTextWidget 设置文本控件的内容并调整size
---@param textWidget table 文本控件
---@param initW number 初始宽度
---@param initH number 初始高度
function M:setTextWidget(textWidget, initW, initH)
    local msgText = self:getMsgText()
    local renderWidth = textWidget:getFont():getTextExtent(msgText, 1.0)
    if renderWidth < initW then
        textWidget:setWidth({ 0, renderWidth + 5 })
    else
        textWidget:setWidth({ 0, initW })
    end
    textWidget:setText(msgText)
end

function M:getMsgText()
    local text = ""
    if self.data.msgType == MsgType.Text then
        text = self.data.msg
    elseif self.data.msgType == MsgType.FollowHello then
        text = Lang:toText({"g2060_friend_follow_hello", self.data.msg})
    elseif self.data.msgType == MsgType.ShortMsg then
        local shortMsgCfg = ShortConfig:getCfgById(tonumber(self.data.msg))
        if shortMsgCfg then
            text = Lang:toText(shortMsgCfg.text)
        end
    end
    return text
end

function M:setSide(msgData, isLeft)
    --isLeft=true
    local alignmentH = isLeft and 0 or 2
    local sign = isLeft and 1 or -1
    local rotation = isLeft and 0 or 180
    self.panelHead:setHorizontalAlignment(alignmentH)
    self.panelHead:setXPosition({ 0, self.panelHeadOffsetX * sign })
    self.textName:setHorizontalAlignment(alignmentH)
    self.textName:setXPosition({ 0, self.textNameOffsetX * sign })
    if msgData.msgType == MsgType.Text or msgData.msgType == MsgType.ShortMsg or msgData.msgType == MsgType.FollowHello then
        self.textMsg:setHorizontalAlignment(alignmentH)
        self.textMsg:setXPosition({ 0, self.textMsgOffsetX * sign })
        self.panelText:setHorizontalAlignment(alignmentH)
        self.panelText:setXPosition({ 0, self.panelTextOffsetX * sign })
        if isLeft then
            self.imageBubble:setImage("gameres|asset/imageset/chat2:img_9_bubble_other")
            self.imageBubble:setProperty("StaticImageStretch", '22 21 19 14')
        else
            self.imageBubble:setImage("gameres|asset/imageset/chat2:img_9_bubble_self")
            self.imageBubble:setProperty("StaticImageStretch", '17 22 31 11')
        end
    elseif msgData.msgType == MsgType.Emoji then
        self.imageEmoji:setHorizontalAlignment(alignmentH)
        self.imageEmoji:setXPosition({ 0, self.imageEmojiOffsetX * sign })
    elseif msgData.msgType == MsgType.Voice then
        self.imageBubbleVoice:setHorizontalAlignment(alignmentH)
        self.panelVoice:setHorizontalAlignment(alignmentH)
        self.panelVoice:setXPosition({ 0, self.panelTextOffsetX * sign })
        if isLeft then
            self.imageBubbleVoice:setImage("gameres|asset/imageset/chat2:img_9_bubble_other")
            self.imageBubbleVoice:setProperty("StaticImageStretch", '28 30 12 12')
        else
            self.imageBubbleVoice:setImage("gameres|asset/imageset/chat2:img_9_bubble_self")
            self.imageBubbleVoice:setProperty("StaticImageStretch", '14 30 28 12')
        end

        if self:isSelfMsg() then
            self.imageVoiceSelf:setHorizontalAlignment(alignmentH)
            self.imageVoiceSelf:setXPosition({ 0, self.imageVoiceOffsetX * sign })
        else
            self.imageVoiceOther:setHorizontalAlignment(alignmentH)
            self.imageVoiceOther:setXPosition({ 0, self.imageVoiceOffsetX * sign })
        end

        --ChatUIHelper:setWidgetRotate(self.imageVoice,rotation,2)
        self.textVoiceTime:setHorizontalAlignment(alignmentH)
        self.textVoiceTime:setXPosition({ 0, self.textVoiceTimeOffsetX * sign })
    end
end

function M:reset()
    if self.voiceAniTimer then
        --print(">>>>>>>>>>>> reset clear  voiceAniTimer")
        self.voiceAniTimer()
        self.voiceAniTimer = nil
    end
end

function M:isSelfMsg()
    return self.userId == Me.platformUserId
end

function M:onClose()
    --print("chat item text onClose() ",self)
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = {}
    end
    if self.voiceAniTimer then
        self.voiceAniTimer()
        self.voiceAniTimer = nil
    end
    self:cancelDetailListener()
end

function M:onDestroy()
    self:destroy()
end

function M:destroy()
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = nil
    end
    if self.voiceAniTimer then
        self.voiceAniTimer()
        self.voiceAniTimer = nil
    end
    self:cancelDetailListener()
end

M:init()