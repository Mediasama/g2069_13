--私聊页签
local ChatHelper = T(Lib, "ChatHelper")
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
--local widget_virtual_vert_list = require "client.ui.widget_virtual_vert_list_temp"

--面板状态
M.PanelState = {
    History= 1,           --聊天历史记录
    PrivateChat = 2,      --私聊内容
}

function M:init()
    self.delayInited=false
    self.panelState=nil
    self._allEvent={}
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
        if tab == Define.ChatPage.Private   then
            self:delayInit()
            self:initOnEnter()
        end
    end)
end

function M:initUI()
    self.contentPanel=nil
    self.PanelHistory.PanelTop.TextTitle:setText(Lang:toText("new.chat.recent.private.chat"))
    self.textPlayerName=self.PanelChat.PanelTop.TextPlayerName
    self.panelBack=self.PanelChat.PanelTop.PanelBack
    self.scrollView=self.PanelHistory.PanelChatContent.ScrollableView
    self.verticalLayoutHistory  =self.scrollView.VerticalLayout
    self.historyItemView = widget_virtual_vert_list:init(self.scrollView, self.verticalLayoutHistory,
            function(self, parentWindow)
                --print(">>>>>>>> create chat_item :",ChatUIHelper:getContentItemType(M.chatPage))
                local item=UI:openWidget("UI/new_chat/gui/widget_chat_private_history_item")
                parentWindow:addChild(item:getWindow())
                return item
            end,
            function(self, childWindow, msg)
                childWindow:initData(msg)
            end
    )
end

function M:initEvent()
    self.panelBack.onMouseClick=function()
        self:setPanelState(M.PanelState.History)
    end
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET, function(id)
        print("panel_private receive EVENT_CHAT_SET_CUR_CHAT_TARGET,target_id ",id)
        self:setPanelState(M.PanelState.PrivateChat,id)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_PUSH_CHAT_MSG, function(msgData)
        print("panel private receive EVENT_PUSH_CHAT_MSG,msgData.pageType,self.chatPage:",msgData.pageType,msgData.keyId,
                self.contentPanel and self.contentPanel.privateChatTarget or nil,self.panelState)
        if msgData.pageType==Define.ChatPage.Private and self.panelState==M.PanelState.PrivateChat
                and  self.contentPanel.privateChatTarget==msgData.keyId then
            print(">>>>>>>>>> panel private receive EVENT_PUSH_CHAT_MSG,clear msg counter")
            ChatHelper:clearNewMsgCounter(msgData.pageType,msgData.keyId)
        end
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_UPDATE_RED_POINT, function(tab)
        if tab == Define.ChatPage.Private and self.panelState == M.PanelState.History then
            self.historyItemView:clearVirtualChild()
            local msgListGroup=ChatHelper:getPageMsgListGroup(Define.ChatPage.Private)
            for k,v in pairs(msgListGroup) do
                local msg=ChatHelper:getLatestMsg(Define.ChatPage.Private,k)
                if msg then
                    self.historyItemView:addVirtualChild(msg[1])
                end
            end
        end
    end)
end

function M:delayInit()
    --print(">>>>>>>>>>>>>>>>> widget_chat_panel_private:delayInit() ",self.delayInited)
    if not self.delayInited then
        self:initUI()
        self:initEvent()
        self:setPanelState(M.PanelState.History)
        self.delayInited=true
    end
end

function M:setPanelState(state,privateChatTarget)
    self.panelState=state
    self.PanelHistory:setVisible(state==M.PanelState.History)
    self.PanelChat:setVisible(state==M.PanelState.PrivateChat)
    local winMain = UI:isOpenWindow("UI/new_chat/gui/win_chat_main")
    if state == M.PanelState.History then
        winMain:setInputVisible(false)
        self.historyItemView:clearVirtualChild()
        local msgListGroup=ChatHelper:getPageMsgListGroup(Define.ChatPage.Private)
        --Lib.logInfo("setPanelState(),groupList num ",state,#msgListGroup)
        for k,v in pairs(msgListGroup) do
            local msg=ChatHelper:getLatestMsg(Define.ChatPage.Private,k)
            --Lib.logInfo("setPanelState(),lastMsg:",msg,k)
            if msg and next(msg) then
                self.historyItemView:addVirtualChild(msg[1])
            end
        end
    else
        winMain:setInputVisible(true)
        --Lib.logInfo("setPanelState(),chat ",state,privateChatTarget)
        --local detailInf = ChatHelper:getUserDetailInfo(privateChatTarget)
        ----Lib.logInfo("setPanelState(),detailInf ",detailInf)
        --if detailInf then
        --    self.textPlayerName:setText(detailInf.nickName)
        --end
        UserInfoCache.LoadCacheByUserIds({privateChatTarget}, function ()
            local data = UserInfoCache.GetCache(privateChatTarget) or {}
            if self:isAlive() then
                self.textPlayerName:setText(data.nickName or "")
            end
        end)
        if not self.contentPanel then
            --Lib.logInfo("setPanelState(),init content panel")
            self.contentPanel=UI:openWidget("UI/new_chat/gui/widget_chat_content_panel")
            self.contentPanel:delayInit(Define.ChatPage.Private,privateChatTarget)
            self.contentPanel:initData()
            self.PanelChat.PanelChatContent:addChild(self.contentPanel)
        else
            --Lib.logInfo("setPanelState(),enter content panel:",self.contentPanel.privateChatTarget,privateChatTarget)
            if self.contentPanel.privateChatTarget~=privateChatTarget then
                self.contentPanel.privateChatTarget=privateChatTarget
                self.contentPanel:clearData()
                self.contentPanel:initData()
            end
        end
    end
    self:initOnEnter()
end

--每次进入界面的初始化
function M:initOnEnter()
    if self.contentPanel and self.panelState==M.PanelState.PrivateChat then
        self.contentPanel:initOnEnter()
    end
end

function M:canShowInputPanel()
    return self.panelState==M.PanelState.PrivateChat
end


function M:onClose()
    --print("widget_chat_panel_world:onClose()")
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    if self.historyItemView then
        self.historyItemView:clearVirtualChild()
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