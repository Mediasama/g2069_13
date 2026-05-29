---@class WidgetBookRewardItemWidget : CEGUILayout
local WidgetBookRewardItemWidget = M
---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"

---@private
function WidgetBookRewardItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetBookRewardItemWidget:findAllWindow()
    ---@type CEGUIStaticImage
    self.siBg = self.Bg
    ---@type CEGUIStaticText
    self.stText = self.Text
    ---@type CEGUIButton
    self.btnReceiveBtn = self.ReceiveBtn
    ---@type CEGUIStaticImage
    self.siDoneIcon = self.DoneIcon
    ---@type CEGUIDefaultWindow
    self.wSPanel = self.SPanel
    ---@type CEGUIScrollableView
    self.wSPanelScrollableView = self.SPanel.ScrollableView
    ---@type CEGUIHorizontalLayoutContainer
    self.wSPanelScrollableViewHorizontalLayoutContainer = self.SPanel.ScrollableView.HorizontalLayoutContainer
end

---@private
function WidgetBookRewardItemWidget:initUI()
    self:initVirtualUI()
end

function WidgetBookRewardItemWidget:initVirtualUI()
    local this = self
    self.gvItem = widget_virtual_horz_list:init(
            self.wSPanelScrollableView,
            self.wSPanelScrollableViewHorizontalLayoutContainer,
            function(self, parent)
                ---@type WidgetBookRewardCellWidget
                local node = UI:openWidget("UI/game_book/gui/widget_book_reward_cell")
                parent:addChild(node:getWindow())
                return node
            end,
            ---@type any, WidgetBookRewardCellWidget, table
            function(self, node, data)
                node:initData(data)
            end)
end
---@private
function WidgetBookRewardItemWidget:initEvent()
    self.btnReceiveBtn.onMouseClick = function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        Me:sendPacket({
            pid = "C2SRequestDrawDownReward",
            rewardId = self.data.Id,
        })
    end
end

function WidgetBookRewardItemWidget:initData(data, haveBookNum)
    self.data = data
    local text = haveBookNum .. "/" .. data.collectNum
    if haveBookNum > data.collectNum then
        text = data.collectNum .. "/" .. data.collectNum
    end
    self.stText:setText(Lang:toText({"g2069_book_reward_collect", text}))
    self.haveBookNum = haveBookNum

    self:updateReceiveBtnShow()

    self.gvItem:setVirtualBarPosition(0)
    self.gvItem:clearVirtualChild()
    local showList = data.itemList
    local totalNum = #showList
    if totalNum >=3 then
        self.wSPanelScrollableView:setWidth({ 0, 220 })
    elseif totalNum >=2 then
        self.wSPanelScrollableView:setWidth({ 0, 145 })
    else
        self.wSPanelScrollableView:setWidth({ 0, 62 })
    end
    self.gvItem:addVirtualChildList(showList)
end

function WidgetBookRewardItemWidget:updateReceiveBtnShow()
    if not self.data then
        return
    end
    local bookRewardState = Me:getBookRewardState()
    if self.haveBookNum >= self.data.collectNum then
        self.btnReceiveBtn:setProperty("Disabled", "false")
        self.btnReceiveBtn:setText(Lang:toText("g2069_ui_reward_receive_tips"))
        if bookRewardState[self.data.Id] then
            self.btnReceiveBtn:setVisible(false)
            self.siDoneIcon:setVisible(true)
        else
            self.btnReceiveBtn:setVisible(true)
            self.siDoneIcon:setVisible(false)
        end
    else
        self.btnReceiveBtn:setVisible(true)
        self.siDoneIcon:setVisible(false)
        self.btnReceiveBtn:setProperty("Disabled", "true")
        self.btnReceiveBtn:setText(Lang:toText("g2069_ui_reward_receive_none"))
    end
end

---@private
function WidgetBookRewardItemWidget:onOpen()

end

---@private
function WidgetBookRewardItemWidget:onDestroy()
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = {}
    end
end

WidgetBookRewardItemWidget:init()
