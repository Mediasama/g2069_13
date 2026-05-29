--世界聊天页签

function M:init()
    self.delayInited=false
    self._allEvent={}
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
        if tab == Define.ChatPage.World then
            self:delayInit()
            self:initOnEnter()
        end
    end)
end

function M:initUI()
    self.contentPanel=UI:openWidget("UI/new_chat/gui/widget_chat_content_panel")
    self.contentPanel:delayInit(Define.ChatPage.World)
    self.contentPanel:initData()
    self.PanelChatContent:addChild(self.contentPanel)
end

function M:initEvent()
end

function M:delayInit()
    --print(">>>>>>>>>>>>>>>>> widget_chat_panel_world:delayInit() ",self.delayInited)
    if  not self.delayInited then
        self:initUI()
        self:initEvent()
        self.delayInited=true
    end
end

--每次进入界面的初始化
function M:initOnEnter()
    if self.contentPanel then
        self.contentPanel:initOnEnter()
    end
end

function M:canShowInputPanel()
    return true
end

function M:onClose()
    --print("widget_chat_panel_world:onClose()")
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