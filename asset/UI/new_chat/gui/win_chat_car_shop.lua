--语音卡商店
---@type VoiceShopConfig
local VoiceShopConfig = T(Config, "VoiceShopConfig")

---@class ChatShopCardItem
---@field cfgIndex number
---@field panelBuy table

function M:init()
    self._allEvent={}
    self:initUI()
    self:initEvent()
    Me:getVoiceCardTime()
end

function M:initUI()
    self.cardItemList={}
    for index = 1, 3 do
        local cfg=VoiceShopConfig:getItemById(index)
        local panel=self:child("PanelItem"..index)
        panel.PanelBuy.TextPrice:setText(cfg.cost)
        panel.TextCardNum:setText(cfg.num)

        ---@type ChatShopCardItem
        local cardItem={}
        cardItem.cfgIndex=index
        cardItem.panelBuy=panel.PanelBuy
        table.insert(self.cardItemList,cardItem)
    end

    local cfg=VoiceShopConfig:getItemById(4)
    local panelBuy=self.Panel.PanelContent.PanelMonthlyCard.PanelBuy
    panelBuy.TextPrice:setText(cfg.cost)
    ---@type ChatShopCardItem
    local cardItem={}
    cardItem.cfgIndex=4
    cardItem.panelBuy=panelBuy
    table.insert(self.cardItemList,cardItem)

    self.btnClose=self.Panel.PanelTop.ButtonClose
    self.panelRemainDay=self.Panel.PanelContent.PanelMonthlyCard.PanelRemainDay
    self.textRemainDay=self.panelRemainDay.TextRemainDay
    self.textRemainNum=self.Panel.PanelContent.PanelNumCard.TextRemainNum
    self.Panel.PanelTop.TextTitle:setText(Lang:toText("new.chat.shopTitle"))
    self.Panel.PanelContent.PanelMonthlyCard.TextMonthlyCar:setText(Lang:toText("new.chat.moonCard"))
    self.textRemainNum:setText(Me:getSoundTimes())
end

function M:initEvent()
    for _,v in pairs(self.cardItemList) do
        ---@type ChatShopCardItem
        local item=v
        item.panelBuy.onMouseClick=function()
            Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
            self:buyById(item.cfgIndex)
        end
    end

    self.btnClose.onMouseClick=function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
        self:close()
    end

    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_CARD_TIME, function(time)
        print(">>>>>>>>>>>>>>>>>>>> receive EVENT_CHAT_CARD_TIME:",time,math.floor(time/(3600*24)))
        self.panelRemainDay:setVisible(time >-1)
        if time >-1 then
            local day = math.floor(time/(3600*24))
            if day>0 then
                self.textRemainDay:setText(Lang:toText({"new.chat.moonTime",day}))
            else
                self.textRemainDay:setText(Lang:toText("new.chat.moonLess"))
            end
        end
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_SOUND_TIME_CHANGE, function(value)
        print(">>>>>>>>>>>>>>>>>>>> receive EVENT_SOUND_TIME_CHANGE ")
        self.textRemainNum:setText(Me:getSoundTimes())
    end)
    self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_SOUND_MOON_CHANGE, function(value)
        print(">>>>>>>>>>>>>>>>>>>> receive EVENT_SOUND_MOON_CHANGE ")
        Me:getVoiceCardTime()
    end)
end

function M:buyById(idx)
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>  buy  id",idx,Me:getSoundMoonCardMac(),Me:data("wallet")["gDiamonds"].count)
    local wallet = Me:data("wallet")
    local cost = VoiceShopConfig:getItemById(idx).cost
    if not cost then
        Lib.logError("CANT FIND VOICE ITEM PRICE,idx:",idx)
        return
    end
    if wallet and wallet["gDiamonds"] and wallet["gDiamonds"].count >=cost then
        Me:sendPacket({
            pid = "BuyVoice",
            idx = idx
        })
    else
        Interface.onRecharge(1)
    end
end

function M:onClose()
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = {}
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