--输入控件
local chatSetting = World.cfg.chatSetting
---@type ChatHelper
local ChatHelper = T(Lib, "ChatHelper")
---@type ChatUIHelper
local ChatUIHelper = T(World, "ChatUIHelper")

--widget状态
M.InputState = {
    InputText = 1,           --输入文本
    InputVoice = 2,          --输入语音
    InputDisable = 3,        --输入禁用
}

function M:init()
    self._allEvent={}
    self:initUI()
    self:initEvent()
    self:setInputState(M.InputState.InputText)
end

function M:initUI()
    self.panelInputText=self.PanelInputText
    self.textTipsText=self.PanelInputText.EditboxInput.TextTipsText
    self.textVoiceTips=self.PanelInputVoice.ImageVoiceInput.TextVoiceTips
    self.editbox=self.PanelInputText.EditboxInput
    self.buttonEmoji=self.ButtonEmoji
    self.buttonMic=self.PanelInputText.ButtonMic
    self.panelInputVoice=self.PanelInputVoice
    self.buttonKeyboard=self.PanelInputVoice.ButtonKeyboard
    self.imageVoiceInput=self.PanelInputVoice.ImageVoiceInput
    self.imageVoiceInputSize=self.imageVoiceInput:getPixelSize()
    self.panelInputDisable=self.PanelInputDisable
    self.buttonSend=self.ButtonSend
    self.textSoundNum=self.PanelInputText.ButtonMic.TextSoundNum
    self.editbox:setMaxTextLength(chatSetting.maxMsgSize or 150)
    self.textTipsText:setText(Lang:toText("new_chat_input_tips"))
    self.textVoiceTips:setText(Lang:toText("new_chat_input_tips_voice"))
    self:resetSoundNum()
end

function M:initEvent()
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)
    --文本输入
    self.editbox.onMouseButtonDown=function()
        --Lib.logInfo("=========>self.editbox.onMouseButtonDown")
        self.textTipsText:setText("")
    end
    self.editbox.onMouseButtonUp=function()
        --Lib.logInfo("=========>self.editbox.onMouseButtonUp")
    end
    self.editbox.onTextAccepted=function()
        --Lib.logInfo("=========>self.editbox.onTextAccepted")
    end
    self.buttonSend.onMouseButtonUp=function()
        local inputText=self.editbox:getText()
        if inputText and #inputText >0 then
            self:sendTextMsg(inputText)
        end
        --self.editbox:setText("")
        self.editbox:setProperty("Text", "")
        self.textTipsText:setText(Lang:toText("new_chat_input_tips"))
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    --表情/短语弹窗
    self.buttonEmoji.onMouseButtonUp=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        UI:openWindow("UI/new_chat/gui/win_chat_emoji")
    end
    --语音输入
    self.buttonMic.onMouseButtonUp=function()
        if not Me:getCanSendSound() then
            ChatUIHelper:openCardShop()
            return
        end
        self:setInputState(M.InputState.InputVoice)
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    self.buttonKeyboard.onMouseButtonUp=function()
        self:setInputState(M.InputState.InputText)
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    self.imageVoiceInput.onMouseButtonDown=function()
        if not Me:getCanSendSound() then
            ChatUIHelper:openCardShop()
            return
        end
        UI:openWindow("UI/new_chat/gui/win_chat_voice_record")
    end
    self.imageVoiceInput.onMouseButtonUp=function()
        UI:closeWindow("UI/new_chat/gui/win_chat_voice_record")
    end
    self.imageVoiceInput.onMouseMove=function(instance, window, x, y)
        if UI:isOpenWindow("UI/new_chat/gui/win_chat_voice_record") then
            local nodeX = CEGUICoordConverter.screenToWindowX1(self.imageVoiceInput:getWindow(), x)
            local nodeY= CEGUICoordConverter.screenToWindowY1(self.imageVoiceInput:getWindow(), y)
            --Lib.logInfo(">>>>>>>>>>>>>>>>>>>>> imageVoiceInput touch move",nodeX,nodeY,self.imageVoiceInputSize)
            if nodeY<0 or nodeX<0 or nodeX>self.imageVoiceInputSize.width then
                Lib.emitEvent(Event.EVENT_VOICE_TOUCH_OUT_AREA)
            else
                Lib.emitEvent(Event.EVENT_VOICE_TOUCH_IN_AREA)
            end
        end
    end
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent( Event.EVENT_CHAT_SEND_VOICE, function(time, url)
        self:sendVoiceMsg(time, url)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_VOICE_FILE_ERROR, function(errorType)
        Client.ShowTip(1, Lang:toText("new.chat.voice.fail"), Define.TipsShowTime)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_SOUND_TIME_CHANGE, function(value)
        self:resetSoundNum()
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_SOUND_MOON_CHANGE, function(value)
        self:resetSoundNum()
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_FREE_SOUND_TIME_CHANGE, function(value)
        self:resetSoundNum()
    end)
end

function M:sendVoiceMsg(time, url)
    local chatPage=ChatHelper:getCurPage()
    local chatTarget=ChatHelper:getCurChatTarget()
    if not ChatHelper:canSend(chatPage) then
        Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
        return
    end
    print("M:sendVoiceMsg(inputText) ",chatPage,chatTarget)
    ChatHelper:sendChatMsg(chatPage, {
        fromId = Me.platformUserId,
        msg = {
            uri = url,
            voiceTime = time
        },
        msgType = Define.MsgType.Voice,
        targetUserId =chatTarget
    })
    --self:sendTimeCount()
end

function M:sendTextMsg(inputText)
    local chatPage=ChatHelper:getCurPage()
    local chatTarget=ChatHelper:getCurChatTarget()
    if not ChatHelper:canSend(chatPage) then
        Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
        return
    end
    print("M:sendTextMsg(inputText) ",chatPage,chatTarget)
    ChatHelper:sendChatMsg(chatPage, {
        fromId = Me.platformUserId,
        msg = inputText,
        msgType = Define.MsgType.Text,
        targetUserId =chatTarget
    })
end

---setInputState 设置控件状态
---@param state number
function M:setInputState(state)
    self.panelInputText:setVisible(state==M.InputState.InputText)
    self.panelInputVoice:setVisible(state==M.InputState.InputVoice)
    self.panelInputDisable:setVisible(state==M.InputState.InputDisable)
end

function M:resetSoundNum()
    self.textSoundNum:setText(Me:getSoundTimesString())
end

function M:onClose()
    --print("widget_chat_input_panel:onClose()")
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
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
end

M:init()