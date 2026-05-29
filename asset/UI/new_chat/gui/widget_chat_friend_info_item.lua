--好友列表item
local chatSetting = World.cfg.chatSetting

function M:init()
    self.friendInfData=nil
    --self._allEvent={}
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.panelHead=self.PanelHead
    self.widgetHead=UI:openWidget("UI/new_chat/gui/widget_chat_player_head")
    self.panelHead:addChild(self.widgetHead)
end

function M:initEvent()
    --self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
    --    self:onClose()
    --end)
end

function M:initData(data)
    self.friendInfData=data
    if data then
        self.TextName:setText(data.friendData.nickName)
        self.TextLang:setText(data.friendData.language)
        local isOffline=data.friendData.status==Define.onlineStatus.offline
        local cfg=chatSetting.friendPanelCfg.onlineStatusColor
        if isOffline then
            self.TextOnline:setText(Lang:toText("new.chat.status.offline"))
            self.TextOnline:setProperty("TextColours", cfg.offline or "FFFA3F3F")
        else
            self.TextOnline:setText(Lang:toText("new.chat.status.online"))
            self.TextOnline:setProperty("TextColours", cfg.online or "FF1AAB45")
        end
        local detailInf={
            userId=data.friendData.userId,
            nickName=data.friendData.nickName,
            sex=data.friendData.sex,
            picUrl=data.friendData.picUrl
        }
        self.widgetHead:initData(detailInf)
    end
end

--function M:onClose()
--    if self._allEvent then
--        for _, fun in pairs(self._allEvent) do
--            fun()
--        end
--        self._allEvent={}
--    end
--end

M:init()



