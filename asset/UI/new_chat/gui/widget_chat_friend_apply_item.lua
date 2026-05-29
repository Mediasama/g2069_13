--申请者列表item

function M:init()
    self.applyPlayerData=nil
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
    self.ButtonAccept.onWindowClick=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        if self.applyPlayerData then
            Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY,self.applyPlayerData.userId,true)
        end
    end
    self.ButtonReject.onWindowClick=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        if self.applyPlayerData then
            Lib.emitEvent(Event.EVENT_RESPONSE_FRIEND_APPLY,self.applyPlayerData.userId,false)
        end
    end
    --self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
    --    self:onClose()
    --end)
end

--[[
  data:
 {
    ["nickName"] = "&$[ffca00ff-fbd33fff-cad2ceff-23b8feff-677dffff-ac61ffff-fd15ffff]$pc_test01$&",
    ["picUrl"] = "",
    ["colorfulNickName"] = "ffca00ff-fbd33fff-cad2ceff-23b8feff-677dffff-ac61ffff-fd15ffff",
    ["onlineStatus"] = 0,
    ["age"] = 9,
    ["sex"] = 1,
    ["msg"] = "",
    ["status"] = 0,
    ["userId"] = 18512,
    ["language"] = "zh",
    ["requestId"] = 76452,
    ["vip"] = 0
  }
--]]
function M:initData(data)
    self.applyPlayerData=data
    if not data then
        return
    end
    self.TextName:setText(self.applyPlayerData.nickName)
    self.TextLang:setText(self.applyPlayerData.language)
    local detailInf={
        userId=self.applyPlayerData.userId,
        nickName=self.applyPlayerData.nickName,
        sex=self.applyPlayerData.sex,
        picUrl=self.applyPlayerData.picUrl
    }
    self.widgetHead:initData(detailInf)
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



