--点击玩家头像弹窗
local ChatHelper = T(Lib, "ChatHelper")

function M:init()
    self.detailInf=nil
    self.isMyFriend=false
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.widgetHead=UI:openWidget("UI/new_chat/gui/widget_chat_player_head")
    self.widgetHead.hasAction=false
    self.Panel.PanelPlayer.PanelHead:addChild(self.widgetHead)
    self.textPlayerName=self.Panel.PanelPlayer.TextName
    self.buttonFriend=self.Panel.ButtonFriend
    self.panelHeight=self.Panel:getHeight()[2]
    self.rootHeight=self:getPixelSize().height
    self:child("ButtonChat"):setText(Lang:toText("new_chat_private"))
    self:child("ButtonInvite"):setText(Lang:toText("new.chat.invite"))

    self.Panel.ButtonInvite:setVisible(false)
end

function M:initEvent()
    self.Panel.ButtonChat.onMouseClick=function()
        if self.detailInf then
            self:close()
            if not UI:isOpenWindow("UI/new_chat/gui/win_chat_main") then
                UI:openWindow("UI/new_chat/gui/win_chat_main")
            end
            if UI:isOpenWindow("UI/new_chat/gui/win_chat_mini") then
                UI:closeWindow("UI/new_chat/gui/win_chat_mini")
            end
            if UI:isOpenWindow("UI/friend/gui/win_g2060Friend") then
                UI:closeWindow("UI/friend/gui/win_g2060Friend")
            end
            Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_TAB,Define.ChatPage.Private)
            Lib.emitEvent(Event.EVENT_CHAT_SET_CUR_CHAT_TARGET,self.detailInf.userId)
        end
    end
    self.Panel.ButtonInvite.onMouseClick=function()
        if self.detailInf then
            self:sendInviteMsg(self.detailInf.userId)
            self:close()
        end
    end
    self.buttonFriend.onMouseClick=function()
        if self.detailInf then
            if self.isMyFriend then
                --UIChatManage:doDeleteFriendOperate(self.curSelPlayerUserId, self.curSelPlayerName)
                AsyncProcess.FriendOperation(FriendManager.operationType.DELETE, self.detailInf.userId)
            else
                AsyncProcess.FriendOperation(FriendManager.operationType.ADD_FRIEND, self.detailInf.userId)
                Me:friendRequestReport(FriendManager.operationType.ADD_FRIEND,self.detailInf.userId,true)
            end
        end
        self:close()
    end
    self.onWindowTouchDown=function()
        self:close()
    end
end

function M:initData(detailInf)
    --Lib.logInfo("dialog_box:initData():",detailInf)
    if detailInf then
        self.detailInf=detailInf
        self.textPlayerName:setText(detailInf.nickName or detailInf.name)
        self.widgetHead:initData(detailInf)
        self.isMyFriend=Me:checkPlayerIsMyFriend(detailInf.userId)~=Define.friendStatus.notFriend
        self.buttonFriend:setVisible(true)
        if self.isMyFriend then
            self.buttonFriend:setText(Lang:toText("new.chat.player_delFriend"))
            self.Panel.ButtonChat:setEnabled(true)
        else
            self.buttonFriend:setText(Lang:toText("new.chat.player_addFriend"))
            self.Panel.ButtonChat:setEnabled(false)
        end
    end
end

function M:setPanelPos(x,y)
    local finalY=math.min(y,self.rootHeight-self.panelHeight)
    --Lib.logInfo("player_dialog_box:setPanelPos():,touch pos:",self:getPixelSize())
    self.Panel:setPosition(UDim2.new(0, x, 0, finalY))
end

function M:onOpen()
    self:setUsingAutoRenderingSurface(true)
end

function M:sendInviteMsg(userId)
    ChatHelper:sendInviteMsg(userId)
end



M:init()