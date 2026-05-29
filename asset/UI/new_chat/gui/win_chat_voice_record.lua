--录音弹窗
---@type ChatHelper
local ChatHelper = T(Lib, "ChatHelper")
---@type ChatUIHelper
local ChatUIHelper = T(World, "ChatUIHelper")

--widget状态
M.RecordState = {
    Recording = 1,           --录音中
    Cancel = 2,              --取消
}

M.RecordImageList = {
    "gameres|asset/imageset/chat2:pbar_0_voice_schedule01",
    "gameres|asset/imageset/chat2:pbar_0_voice_schedule02",
    "gameres|asset/imageset/chat2:pbar_0_voice_schedule03",
    "gameres|asset/imageset/chat2:pbar_0_voice_schedule04"
}

function M:init()
    self._allEvent = {}
    self.recordState=nil
    self.voiceTimer=nil
    self.timeRemain=Define.VoiceRecordMaxTime
    self.imageIndex=0
    self.recordTimeStamp=0
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.imageRecord=self.PanelCenter.PanelRecord.ImageBG
    self.panelRecord=self.PanelCenter.PanelRecord
    self.panelCancel=self.PanelCenter.PanelCancel
    self.PanelCenter.PanelRecord.ImageBG.TextTips:setText(Lang:toText("new.chat.send.voice"))
    self.PanelCenter.PanelCancel.ImageBG.TextTips:setText(Lang:toText("new.chat.cancel.send.voice"))
    self.textTimer=self.PanelCenter.PanelRecord.ImageBG.TextTimer
    self.textTimer:setText(self.timeRemain .. "s")
    self:setRecordState(M.RecordState.Recording)
end

function M:initEvent()
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_VOICE_TOUCH_IN_AREA, function()
        self:setRecordState(M.RecordState.Recording)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_VOICE_TOUCH_OUT_AREA, function()
        self:setRecordState(M.RecordState.Cancel)
    end)

    self.voiceTimer = World.Timer(20, function()
        self.timeRemain = self.timeRemain - 1
        self.textTimer:setText(self.timeRemain .. "s")
        if self.timeRemain <= 0 then
            Client.ShowTip(1, Lang:toText("new.chat.voice.time.limit")..Define.VoiceRecordMaxTime.."s",
                    Define.TipsShowTime)
            self:close()
            return false
        end
        --print(">>>>>>>>> ",self.timeRemain)
        if self.recordState==M.RecordState.Recording then
            local num=#M.RecordImageList
            local index=self.imageIndex%num+1
            self.imageRecord:setImage(M.RecordImageList[index])
            self.imageIndex=self.imageIndex+1
        end
        return true
    end)
    self:startRecord()
end

function M:setRecordState(state)
    self.panelRecord:setVisible(state==M.RecordState.Recording)
    self.panelCancel:setVisible(state==M.RecordState.Cancel)
    self.recordState=state
end

function M:startRecord()
    Lib.logInfo("startRecord()")
    self.recordTimeStamp=World.Now()
    local target = ChatHelper:getCurPage() == Define.ChatPage.Private and ChatHelper:getCurChatTarget() or false
    VoiceManager:startRecord(target)
    --VoiceManager:startRecord()
end

function M:stopRecord()
    Lib.logInfo("stopRecord()")
    if not Me:getCanSendSound() then
        ChatUIHelper:openCardShop()
        return
    end
    local target = ChatHelper:getCurPage() == Define.ChatPage.Private and ChatHelper:getCurChatTarget() or false
    if World.Now()-self.recordTimeStamp<Define.VoiceRecordMinTime*20 then
        Client.ShowTip(1, Lang:toText("new.chat.voice.time.too.short")..Define.VoiceRecordMinTime.."s",
                Define.TipsShowTime)
        VoiceManager:cancelRecord(target)
    else
        VoiceManager:stopRecord(target)
    end
end

function M:cancelRecord()
    Lib.logInfo("cancelRecord()")
    local target = ChatHelper:getCurPage() == Define.ChatPage.Private and ChatHelper:getCurChatTarget() or false
    Client.ShowTip(1, Lang:toText("new.chat.voice.fail"), Define.TipsShowTime)
    VoiceManager:cancelRecord(target)
end

function M:onClose()
    if self.recordState ==M.RecordState.Recording then
        self:stopRecord()
    else
        self:cancelRecord()
    end
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    if self.voiceTimer then
        self.voiceTimer()
        self.voiceTimer = nil
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
    if self.voiceTimer then
        self.voiceTimer()
        self.voiceTimer = nil
    end
end

M:init()