--系统公告消息体
local ChatHelper = T(Lib, "ChatHelper")

function M:init()
    --self._allEvent={}
    self.data=nil
    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.textMsg=self.TextMsg
    self.textMsgInitW=self.textMsg:getWidth()[2]
    self.textMsgInitH=self.textMsg:getHeight()[2]
    self.rootHeightGap=self:getHeight()[2]-self.textMsg:getHeight()[2]
end

function M:initEvent()
    --self._allEvent[#self._allEvent + 1] =Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
    --    self:onClose()
    --end)

end

---initData 外部调用此函数初始化数据
---@param msgData table
function M:initData(msgData)
    if not msgData then
        return
    end
    self.data=msgData
    self:setMsgContent()
end

---setMsgContent 设置消息体内容
---@param msgData table
function M:setMsgContent()
    self:setTextWidget(self.textMsg,self.textMsgInitW,self.textMsgInitH)
    local textSize=self.textMsg:getSize()
    self:setHeight({0,textSize["height"][2]+self.rootHeightGap})
end

---setTextWidget 设置文本控件的内容并调整size
---@param textWidget table 文本控件
---@param initW number 初始宽度
---@param initH number 初始高度
function M:setTextWidget(textWidget,initW,initH)
    local msgText=self:getMsgText()
    textWidget:setHeight({0,initH})
    textWidget:setProperty("AutoScale", '1')
    textWidget:setProperty("HorzFormatting", 'CentreAligned')
    textWidget:setText(msgText)
    --文本长度超长，文本框改为自适应高度
    if textWidget:getWidth()[2]>initW  then
        textWidget:setProperty("AutoScale", '2')
        textWidget:setProperty("HorzFormatting", 'WordWrapCentreAligned')
        --self.textMsg:setProperty("TextWordBreak", 'true')
        textWidget:setWidth({0,initW})
        textWidget:setText(msgText)
        --Lib.logInfo("text size adjust : ",textWidget:getSize())
    end
end

function M:getMsgText()
    return  self.data.msg
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