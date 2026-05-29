--聊天内容面板
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
--local widget_virtual_vert_list = require "client.ui.widget_virtual_vert_list_temp"

local ChatHelper = T(Lib, "ChatHelper")
---@type ChatUIHelper
local ChatUIHelper = T(World, "ChatUIHelper")
local chatSetting = World.cfg.chatSetting

function M:init()
    self._allEvent = {}
    self.newMsgCounter=0
    self.chatPage=nil
    self.privateChatTarget=nil
end

function M:initUI()
    self.layoutMsgList=self.ScrollableView.VerticalLayoutMsgList
    self.panelNewMsg=self.PanelNewMsg
    self.buttonNewMsg=self.PanelNewMsg.ButtonNewMsg
    self.messageView = widget_virtual_vert_list:init(self.ScrollableView, self.layoutMsgList,
            function(self, parentWindow)
                --print(">>>>>>>> create chat_item :",ChatUIHelper:getContentItemType(M.chatPage))
                local item = UI:openWidget(ChatUIHelper:getContentItemType(M.chatPage))
                parentWindow:addChild(item:getWindow())
                return item
            end,
            function(self, childWindow, msg)
                childWindow:initData(msg)
            end
    )
end

function M:initEvent()
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_PUSH_CHAT_MSG, function(msgData)
        if self:isMyMsg(msgData) then
            --Lib.logInfo(">>>>>>>>>> receive msg:",msgData.fromId,msgData.msg)
            local atBottomNow = (self.messageView:getVirtualBarPosition() == 1)
            local isFull = self:isScrollPanelFull()

            if atBottomNow or not isFull then
                if self.messageView:getVirtualChildCount() > chatSetting.pageMsgMaxCount * 3 then
                    local msgList = ChatHelper:getPageMsgList(self.chatPage,self.privateChatTarget)
                    self.messageView:refresh(msgList)
                else
                    self.messageView:addVirtualChild(msgData)
                    self.messageView:setVirtualBarPosition(1)
                end
            else
                self:setNewMsgTipsVisible(true)
                self.newMsgCounter=self.newMsgCounter + 1
                self.buttonNewMsg:setText(Lang:toText({"new_chat_new_msg_tips", self.newMsgCounter > 99 and "99+" or self.newMsgCounter}))
            end
        end

    end)

    self.buttonNewMsg.onMouseClick=function()
        self.messageView:setVirtualBarPosition(1)
        self:setNewMsgTipsVisible(false)
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end

    self.ScrollableView.onScrolled=function()
        local atBottomNow = (self.messageView:getVirtualBarPosition() == 1)
        if atBottomNow then
            self:setNewMsgTipsVisible(false)
        end
    end
end

function M:initData()
    local msgList = ChatHelper:getPageMsgList(self.chatPage,self.privateChatTarget)
    print("content panel init ,all msg num:==========>>",self.chatPage,self.privateChatTarget,msgList and #msgList or "no msg list")
    self.messageView:addVirtualChildList(msgList)
    self.messageView:setVirtualBarPosition(1)
    self:setNewMsgTipsVisible(false)
end

function M:clearData()
    self.messageView:clearVirtualChild()
end

--每次进入界面的初始化
function M:initOnEnter()
    --print("content panel initOnEnter():",self.messageView,self.buttonNewMsg:isVisible())
    if self.messageView and not self.buttonNewMsg:isVisible()then
        self.messageView:setVirtualBarPosition(1)
        self:setNewMsgTipsVisible(false)
    end
end

function M:delayInit(chatPage,privateChatTarget)
    self.chatPage=chatPage
    self.privateChatTarget=privateChatTarget
    self:initUI()
    self:initEvent()
end

--function M:onOpen(chatPage,privateChatTarget)
--    Lib.logInfo("content panel:onOpen(chatPage,privateChatTarget) ",chatPage,privateChatTarget)
--    self.chatPage=chatPage
--    self.privateChatTarget=privateChatTarget
--    self:initUI()
--    self:initEvent()
--end

function M:setNewMsgTipsVisible(visible)
    self.buttonNewMsg:setVisible(visible)
    if not visible then
        if self.newMsgCounter > 0 then
            local msgList = ChatHelper:getPageMsgList(self.chatPage,self.privateChatTarget)
            self.messageView:refresh(msgList)
        end
        self.newMsgCounter=0
    end
end

function M:isScrollPanelFull()
    local view = self.ScrollableView:getWindow():getViewableArea()
    local viewHeight = view.bottom - view.top
    local paneHeight = self.ScrollableView:getVirtualSize()[2]
    --Lib.logInfo("M:isScrollPanelFull():",viewHeight,paneHeight)
    return paneHeight>=viewHeight
end

function M:stopVoiceDataPlaying()

end

function M:isMyMsg(msgData)
    --Lib.logInfo(">>>>>>>>>>>isMyMsg():",msgData,self.chatPage,self.privateChatTarget)
    if msgData then
        if self.chatPage==msgData.pageType then
            if msgData.msgType==Define.ChatPage.Private then
                return msgData.keyId==self.privateChatTarget
            else
                return true
            end
        end
    end
    return false
end

function M:onClose()
    --print("widget_chat_content_panel:onClose()")
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    if self.messageView then
        self.messageView:clearVirtualChild()
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
