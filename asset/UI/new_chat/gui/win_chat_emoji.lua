--表情/短语弹窗
local ChatHelper = T(Lib, "ChatHelper")

function M:init()
    self.tabList={}
    self.contentPanelList={}
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.layoutTabList=self.Panel.PanelTop.HorizontalLayout
    self.panelContent=self.Panel.PanelContent
    for i,v in ipairs(World.cfg.chatSetting.emojiWinCfg.emojiTab ) do
        local tabItem=UI:openWidget("UI/new_chat/gui/widget_chat_emoji_tab")
        tabItem:initTab(v,self)
        table.insert(self.tabList, tabItem)
        self.layoutTabList:addChild(tabItem)
        local panel=UI:openWidget(v.layout)
        self.contentPanelList[v.tabType]=panel
        self.panelContent:addChild(panel)
    end
    self:setTab(Define.ChatEmojiTab.Emoji)
end

function M:initEvent()
    self.onWindowTouchDown=function()
       self:close()
    end
    self.ButtonClose.onWindowTouchDown=function()
        self:close()
    end
end

function M:setTab(tabType)
    print("M:setTab(tabType):",tabType,self.contentPanelList)
    for _,v in ipairs(self.tabList) do
        v:setSelected(v.tabType==tabType)
    end
    for k,v in pairs(self.contentPanelList) do
        v:setVisible(k==tabType)
    end
end

function M:onClose()

end

function M:onOpen()
    self:setUsingAutoRenderingSurface(true)
end

M:init()