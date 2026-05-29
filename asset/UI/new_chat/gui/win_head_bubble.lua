local chatSetting = World.cfg.chatSetting

function M:init()
    self.showBubbleLimitNum = chatSetting.chatBubbleSetting.bubbleMaxCount
    self.bubbleItemList = {}
    self.panelHeight = self:getHeight()[2]
    self.cacheMsgList = {}
    self.bubbleHideTimerList = {}
    self.playing = false
    self.LayoutItemRoot = self:child("LayoutItemRoot")
end

function M:insertMsg(msgData)
    if self.playing then
        table.insert(self.cacheMsgList, msgData)
    else
        self:showMsg(msgData)
    end
end

function M:showMsg(msgData)
    local item = self:getBubbleItem()
    item:setMsg(msgData)
    self:setBubbleHideTimer(item)
    self:setItemRootHeight()
    self:setListAnim(item:getItemHeight()[2])
end

function M:getBubbleItem()
    local item = nil
    if #self.bubbleItemList > self.showBubbleLimitNum then
        item = table.remove(self.bubbleItemList, 1)
        table.insert(self.bubbleItemList, item)
    else
        --实际气泡显示数量为限制数量+1，为了表现衔接
        item = UI:openWidget("UI/new_chat/gui/widget_bubble_item")
        self.LayoutItemRoot:addChild(item:getWindow())
        table.insert(self.bubbleItemList, item)
    end
    item:resetAlpha()
    return item
end

function M:setItemRootHeight()
    local totalHeight = 0
    for i = 1, #self.bubbleItemList do
        local item = self.bubbleItemList[i]
        if item then
            local itemHeight = item:getItemHeight()
            if i <= (#self.bubbleItemList - self.showBubbleLimitNum) then
                --超出限制数量的气泡透明渐隐
                item:playAlphaAnim()
                self:cancelBubbleHideTimer(item:getName())
            end
            item:setYPosition({0, totalHeight})
            totalHeight = totalHeight + itemHeight[2]
        end
    end
    self.LayoutItemRoot:setHeight({0, totalHeight})
    if #self.bubbleItemList == 1 then
        --第一个气泡直接显示在底部
        self.LayoutItemRoot:setYPosition({0, 0})
    else
        --后续气泡显示在底部外围，准备动画滚动显示出来
        self.LayoutItemRoot:setYPosition({0, self.bubbleItemList[#self.bubbleItemList]:getItemHeight()[2]})
    end
end

--列表滚到
function M:setListAnim(moveYDis)
    if #self.bubbleItemList > 1 then
        self.playing = true
        local addOffset = moveYDis / 10
        local tick = 0
        local startYPos = self.LayoutItemRoot:getYPosition()[2]
        self.moveTimer = World.Timer(1, function()
            tick = tick + 1
            self.LayoutItemRoot:setYPosition({0,  startYPos - addOffset * tick})
            if tick == 10 then
                self.moveTimer = nil
                if #self.cacheMsgList > 0 then
                    local msgData = table.remove(self.cacheMsgList, 1)
                    self:showMsg(msgData)
                else
                    self.playing = false
                end
                return false
            end
            return true
        end)
    end
end

function M:cancelBubbleHideTimer(itemName)
    local bubbleTimer = self.bubbleHideTimerList[itemName]
    if bubbleTimer then
        bubbleTimer()
    end
    self.bubbleHideTimerList[itemName] = nil
end

function M:setBubbleHideTimer(item)
    local itemName = item:getName()
    self:cancelBubbleHideTimer(itemName)
    self.bubbleHideTimerList[itemName] = World.Timer(chatSetting.chatBubbleSetting.time, function()
        item:playAlphaAnim()
        self.bubbleHideTimerList[itemName] = nil
        self:checkCloseWnd()
    end)
end

function M:checkCloseWnd()
    if not next(self.bubbleHideTimerList) then
        self:onClose()
        UI:closeSceneWindow(self:getName())
        local entity = World.CurWorld:getEntity(self.objID)
        if entity then
            entity.headBubbleInstance = nil
        end
        self.closeTimer = nil
    end
end

function M:onOpen(objID)
    self.objID = objID
    self:init()
end

function M:onClose()
    for _, timer in pairs(self.bubbleHideTimerList) do
        timer()
    end
    for i, item in pairs(self.bubbleItemList) do
        self.LayoutItemRoot:removeChild(item)
        item:destroy()
    end
    if self.closeTimer then
        self.closeTimer()
        self.closeTimer = nil
    end
    if self.moveTimer then
        self.moveTimer()
        self.moveTimer = nil
    end
    self.bubbleItemList = {}
    self.cacheMsgList = {}
    self.bubbleHideTimerList = {}
    self.playing = false
end