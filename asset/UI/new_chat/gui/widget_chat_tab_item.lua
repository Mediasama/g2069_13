--聊天大窗Tab按钮
local ChatHelper = T(Lib, "ChatHelper")
local chatSetting = World.cfg.chatSetting

function M:init()
    self.chatPage=""
    self._allEvent={}
    self.hideRedDot=false
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.textTabName=self.TextTabName
    self.imageRedDot=self.ImageRedDot
    self.textRedDotNum=self.ImageRedDot.TextCount
end

function M:initEvent()
    self.onMouseButtonDown=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_TAB,self.chatPage)
    end

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
        --Lib.logInfo("chat tab receive EVENT_CHAT_SET_CUR_TAB:",tab)
        self:onSetTab(tab)
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_UPDATE_RED_POINT, function(chatPage,keyId)
        --Lib.logInfo("chat tab receive EVENT_CHAT_UPDATE_RED_POINT,chatPage,self.chatPage,keyId:",chatPage,self.chatPage,keyId)
        if chatPage==self.chatPage and self.chatPage ~= Define.ChatPage.Friend  then
            self:updateRedDot()
        end
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_UPDATE_FRIEND_APPLY_RED_DOT, function(num)
        if self.chatPage == Define.ChatPage.Friend then
            self:updateApplyRedNum(num)
        end
    end)

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_PUSH_CHAT_MSG, function(msgData)
        --print("chat tab receive EVENT_PUSH_CHAT_MSG,msgData.pageType,self.chatPage:",msgData.pageType,self.chatPage)
        if msgData.pageType==self.chatPage and self.chatPage~=Define.ChatPage.Private and ChatHelper:getCurPage()==self.chatPage then
            ChatHelper:clearNewMsgCounter(self.chatPage)
        end
    end)

end

function M:initTab(tabConfig)
    --Lib.logInfo("widget_tab_item::initTab(tabConfig):",tabConfig)
    if tabConfig then
        self.chatPage=tabConfig.chatPage
        self.textTabName:setText(Lang:toText(tabConfig.tabNameText))
        self.hideRedDot=tabConfig.hideRedDot
        if not self:canShowRedDot() then
            self.imageRedDot:setVisible(false)
        else
            self:updateRedDot()
        end
    end
end

function M:onSetTab(tab)
    --print("M:onSetTab(tab) ",tab,self.chatPage)
    self.ImageBG:setVisible(tab and tab==self.chatPage)
    local cfg=chatSetting.tabUIConfig.textColor
    if cfg then
        if tab and tab==self.chatPage then
            self.TextTabName:setProperty("TextColours", cfg.selected or "FF100E0D")
        else
            self.TextTabName:setProperty("TextColours", cfg.unselected or "FFEBDAA9")
        end
    end
    if self.chatPage~=Define.ChatPage.Private and tab==self.chatPage then
        ChatHelper:clearNewMsgCounter(self.chatPage)
    end
end

function M:updateRedDot()
    if not self:canShowRedDot() then
        return
    end
    local num=ChatHelper:getNewMsgCounter(self.chatPage)
    if num>0 then
        self.textRedDotNum:setText(tostring(num>99 and "99+" or num))
        self.imageRedDot:setVisible(true)
    else
        self.imageRedDot:setVisible(false)
    end
end

function  M:updateApplyRedNum(num)
    self.imageRedDot:setVisible(num>0)
    if num>0 then
        self.textRedDotNum:setText(tostring(num>99 and "99+" or num))
    end
end

function M:canShowRedDot()
    return not self.hideRedDot and ((self.chatPage~=ChatHelper:getCurPage() or self.chatPage==Define.ChatPage.Private)
        or self.chatPage==Define.ChatPage.Friend)
end

function M:onClose()
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



