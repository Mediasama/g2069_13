local ChatHelper = T(Lib, "ChatHelper")
local UITool = T(UILib, "UITool")

function  M:init()
    self.curTab=nil
    self.privateChatTarget=nil
    self.panelList={}
    self._allEvent={}
    self:initUI()
    self:initEvent()
    Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_TAB,Define.ChatPage.World)
    -- 好友邀请消息
    AsyncProcess.LoadUserRequests()
    ChatHelper:requestPlayerOnlineState()
end

function M:initUI()
    self.PanelInput:addChild(UI:openWidget("UI/new_chat/gui/widget_chat_input_panel"))
    self.tabList=self.PanelTab.VerticalLayoutTabList
    self.panelChat=self.PanelChat
    for _,v in ipairs(World.cfg.chatSetting.tabConfig ) do
        if v.switch then
            if ChatHelper:checkShowTab(v.chatPage) then
                local tabItem=UI:openWidget(v.tabWidget)
                tabItem:initTab(v)
                self.tabList:addChild(tabItem)
                local panel=UI:openWidget(v.layout)
                panel:setVisible(false)
                self.panelList[v.chatPage]=panel
                self.panelChat:addChild(panel)
            end
        end
    end
end

function M:initEvent()
    self.PanelClose.onMouseClick=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
        UI:closeWindow(self)
        UI:openWindow("UI/new_chat/gui/win_chat_mini")
    end
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
        self:onSetTab(tab)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, function(id)
        self.privateChatTarget=id
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_FINISH_PARSE_REQUESTS_DATA, function()
        local num=0
        local requests=FriendManager.requests
        for _, data in pairs(requests) do
            num=num+1
        end
        Lib.emitEvent(Event.EVENT_UPDATE_FRIEND_APPLY_RED_DOT,num)
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_HIDE_CHAT, function()
        UI:closeWindow(self)
    end)
end

function M:onSetTab(tab)
    --Lib.logInfo("win_chat_main:onSetTab(tab):",tab)
    if self.curTab==tab then
        return
    end
    if self.panelList[self.curTab] then
        self.panelList[self.curTab]:setVisible(false)
    end
    self.panelList[tab]:setVisible(true)
    self.curTab=tab
    local showInput=self.panelList[tab]:canShowInputPanel()
    self:setInputVisible(showInput)
end

function M:stopVoiceDataPlaying(list)
    if not list then
        return
    end
    for _, v in pairs(list) do
        if v.msgType  ==Define.MsgType.Voice  then
            v.isPlaying = false
        end
    end
end

function M:onClose()
    --print("win_chat_main:onClose()")
    Lib.emitEvent(Event.EVENT_VOICE_TOUCH_OUT_AREA)
    UI:closeWindow("UI/new_chat/gui/win_chat_voice_record")
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    self:stopVoiceDataPlaying(ChatHelper:getPageMsgList(Define.ChatPage.World))
    Lib.emitEvent(Event.EVENT_CHAT_MAIN_CLOSE)
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

function M:setInputVisible(show)
    self.PanelInput:setVisible(show)
end

function M:test()
    --UI:openWindow("UI/new_chat/gui/win_chat_car_shop")
end

M:init()

