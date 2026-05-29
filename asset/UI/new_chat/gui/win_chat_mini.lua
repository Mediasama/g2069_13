local chatSetting = World.cfg.chatSetting
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
--local widget_virtual_vert_list = require "client.ui.widget_virtual_vert_list_temp"
---@type ChatHelper
local ChatHelper = T(Lib, "ChatHelper")
---@type ChatUIHelper
local ChatUIHelper = T(World, "ChatUIHelper")

function M:init()
    self.bg = self:child("ImageBg")
    self.scrollViewMsg = self:child("ScrollViewMsg")
    self.msgList = self:child("VerticalMsgList")
    self.txtNewMsg = self:child("TextNewMsg")
    self.imageNewMsgBg = self:child("ImageNewMsgBg")
    self.bgHeight = self.bg:getHeight()
    self.bgWidth = self.bg:getWidth()
    self.newMsgNum = 0
    self.openHeight = self.bgHeight[2] + chatSetting.miniWndExtraHeight
    self.openScrollViewBaseHeight = self.scrollViewMsg:getHeight()[2]
    self.openScrollViewHeight = self.openScrollViewBaseHeight + chatSetting.miniWndExtraHeight
    self.scrollViewMsg:setHeight({0, self.openScrollViewHeight})
    self:setNewMsgTips(false)

    self.messageView = widget_virtual_vert_list:init(self.scrollViewMsg, self.msgList,
        function(self, parentWindow)
            local item = UI:openWidget("UI/new_chat/gui/widget_chat_mini_item")
            parentWindow:addChild(item:getWindow())
            item:setWidth({ 1, 0 })
            return item
        end,
        function(self, childWindow, msg)
            childWindow:initData(msg)
        end
    )
    self.scrollViewMsg:setVisible(true)
    self:initEvent()
    self:initMiniMsg()
end

function M:initEvent()
    self._allEvent = {}
    self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("", Event.EVENT_PUSH_CHAT_MSG, function(msgData)
        if chatSetting.miniChatCfg.showPageType[msgData.pageType] then
            local atBottomNow = (self.messageView:getVirtualBarPosition() == 1)
            local isFull = self:isScrollPanelFull()
            if atBottomNow or not isFull then
                self:addMsg(msgData)
            else
                self:setNewMsgTips(true)
            end
        end
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_VOICE_FILE_ERROR, function(errorType)
        Client.ShowTip(1, Lang:toText("new.chat.voice.fail"), Define.TipsShowTime)
    end)

    self.scrollViewMsg.onScrolled = function()
        local atBottomNow = (self.messageView:getVirtualBarPosition() == 1)
        if atBottomNow then
            self:setNewMsgTips(false)
        end
    end

    self.txtNewMsg.onWindowTouchUp = function()
        self:setNewMsgTips(false)
        self.messageView:setVirtualBarPosition(1)
    end
    self.scrollViewMsg.onWindowTouchUp = function(window, instance, x, y)
        if (Lib.v2(x, y) - self.touchPos):len() < 5 then
            UI:openWindow("UI/new_chat/gui/win_chat_main")
            self:close()
        end
    end

    self.scrollViewMsg.onWindowTouchDown = function(window, instance, x, y)
        self.touchPos = Lib.v2(x, y)
    end
end

function M:isScrollPanelFull()
    local view = self.scrollViewMsg:getWindow():getViewableArea()
    local viewHeight = view.bottom - view.top
    local paneHeight = self.scrollViewMsg:getVirtualSize()[2]
    return paneHeight>=viewHeight
end

function M:addMsg(msgData)
    if self.messageView:getVirtualChildCount() > chatSetting.pageMsgMaxCount * 3 then
        self.messageView:refresh(ChatHelper:getMiniMsgList())
    else
        self.messageView:addVirtualChild(msgData)
        self.messageView:setVirtualBarPosition(1)
    end
end

function M:setNewMsgTips(isAddNew)
    if isAddNew then
        self.newMsgNum = self.newMsgNum + 1
        self.imageNewMsgBg:setVisible(true)
        self.txtNewMsg:setText(Lang:toText({"new_chat_new_msg_tips", self.newMsgNum > 99 and "99+" or self.newMsgNum}))
    else
        if self.newMsgNum > 0 then
            self.messageView:refresh(ChatHelper:getMiniMsgList())
        end
        self.newMsgNum = 0
        self.imageNewMsgBg:setVisible(false)
    end
end


function M:initMiniMsg()
    self.scrollViewMsg:setVisible(true)
    self.messageView:refresh(ChatHelper:getMiniMsgList())
    self.messageView:setVirtualBarPosition(1)
end

function M:onClose()
    for _, v in pairs(self._allEvent) do
        v()
    end
    self._allEvent = {}
    self.isBottom = false
    self.newMsgNum = 0
    self.messageView:clearVirtualChild()
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

