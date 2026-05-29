--好友页签
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
--local widget_virtual_vert_list = require "client.ui.widget_virtual_vert_list_temp"
--面板状态
M.PanelState = {
    FriendApply= 1,      --好友申请
    FriendList = 2,      --好友列表
}

function M:init()
    self.delayInited=false
    self.panelState=nil
    self.friendApplyData = {}
    self._allEvent={}
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
        self:onClose()
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_SET_CUR_TAB, function(tab)
        if tab == Define.ChatPage.Friend then
            self:delayInit()
            self:initOnEnter()
        end
    end)
end

function M:initUI()
    self.imageBack=self.PanelFriendApply.PanelTop.PanelBack.ImageBack
    local verticalLayout=self.PanelFriend.PanelFriendContent.ScrollableView.VerticalLayout
    self.friendTitleItemList={}
    self.friendTitleItemList[Define.chatFriendType.apply]
        = UI:openWidget("UI/new_chat/gui/widget_chat_friend_title_apply", nil,Define.chatFriendType.apply)
    verticalLayout:addChild(self.friendTitleItemList[Define.chatFriendType.apply])

    self.friendTitleItemList[Define.chatFriendType.game]
        = UI:openWidget("UI/new_chat/gui/widget_chat_friend_title_normal", nil,Define.chatFriendType.game)
    verticalLayout:addChild(self.friendTitleItemList[Define.chatFriendType.game])

    self.friendTitleItemList[Define.chatFriendType.platform]
    = UI:openWidget("UI/new_chat/gui/widget_chat_friend_title_normal", nil,Define.chatFriendType.platform)
    verticalLayout:addChild(self.friendTitleItemList[Define.chatFriendType.platform])

    self.scrollView=self.PanelFriendApply.PanelApply.ScrollableView
    self.applyListView = widget_virtual_vert_list:init(self.scrollView,
            self.scrollView.VerticalLayout,
            function(self, parentWindow)
                print(">>>>>>>> create friend apply item ")
                local item = UI:openWidget("UI/new_chat/gui/widget_chat_friend_apply_item")
                parentWindow:addChild(item:getWindow())
                return item
            end,
            function(self, childWindow, data)
                childWindow:initData(data)
            end
    )

    self.buttonReject=self.PanelFriendApply.PanelBottom.ButtonReject
    self.buttonAccept=self.PanelFriendApply.PanelBottom.ButtonAccept
    self.buttonReject:setText(Lang:toText("new_chat_reject_all"))
    self.buttonAccept:setText(Lang:toText("new_chat_accept_all"))
end

function M:initEvent()
    self.imageBack.onWindowTouchDown=function()
        self:setPanelState(M.PanelState.FriendList)
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    self.buttonReject.onWindowTouchDown=function()
        if self.friendApplyData and #self.friendApplyData>0 then
            Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY,-1,false)
        end
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    self.buttonAccept.onWindowTouchDown=function()
        if self.friendApplyData and #self.friendApplyData>0 then
            Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY,-1,true)
        end
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_ENTER_FRIEND_APPLY, function()
        self:setPanelState(M.PanelState.FriendApply)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_FINISH_PARSE_REQUESTS_DATA, function()
        Lib.logInfo("receive Event.EVENT_FINISH_PARSE_REQUESTS_DATA ")
        self:updateFriendApplyList(FriendManager.requests)
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_RESPONSE_FRIEND_APPLY, function(userId,agree)
        Lib.logInfo("receive Event.EVENT_RESPONSE_FRIEND_APPLY ",userId,agree)
        if userId then
            if userId >=0 then
                self:dealOneFriendApply(userId,agree)
            else
                self:dealAllFriendApply(agree)
            end
        end
    end)
end

function M:delayInit()
    --print(">>>>>>>>>>>>>>>>> widget_chat_panel_friend:delayInit() ",self.delayInited)
    if  not self.delayInited then
        self:initUI()
        self:initEvent()
        self:setPanelState(M.PanelState.FriendList)
        self.delayInited=true
        -- 好友邀请消息
        AsyncProcess.LoadUserRequests()
        -- 好友列表
        Me:doRequestServerFriendInfo(Define.chatFriendType.game,0)
        Me:doRequestServerFriendInfo(Define.chatFriendType.platform,0)
    end
end

function M:setPanelState(state)
    self.panelState=state
    self.PanelFriend:setVisible(state==M.PanelState.FriendList)
    self.PanelFriendApply:setVisible(state==M.PanelState.FriendApply)
    if state==M.PanelState.FriendApply then

    elseif state==M.PanelState.FriendList then

    end
end

function M:updateFriendApplyList(requests)
    self:cleanFriendApplyList()
    for _, data in pairs(requests) do
        self:addOneFriendApply(data)
    end
end

function M:cleanFriendApplyList()
    self.applyListView:clearVirtualChild()
    self.friendApplyData = {}
end

function M:addOneFriendApply(data)
    table.insert(self.friendApplyData,data)
    self.applyListView:addVirtualChild(data)
end

-- 同意、拒绝好友申请
function M:dealOneFriendApply(userId, agree)
    --print(">>>>>>>>>>>>> M:dealOneFriendApply  ",userId,agree)
    local opType=agree and FriendManager.operationType.AGREE or FriendManager.operationType.REFUSE
    Me:friendRequestReport(opType,userId,true)
    AsyncProcess.FriendOperation(opType, userId)
end

-- 同意、拒绝所有好友申请
function M:dealAllFriendApply(agree)
    if self.friendApplyData then
        for _, v in pairs(self.friendApplyData) do
            self:dealOneFriendApply(v.userId,agree)
        end
    end
end

--每次进入界面的初始化
function M:initOnEnter()
end

function M:canShowInputPanel()
    return false
end

function M:onClose()
    --print("widget_chat_panel_world:onClose()")
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    if self.applyListView then
        self.applyListView:clearVirtualChild()
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