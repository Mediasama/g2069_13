---@class WinBookWndLayout : CEGUILayout
local WinBookWndLayout = M
---@type BookInfoConfig
local BookInfoConfig = T(Config, "BookInfoConfig")
---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"

---@private
function WinBookWndLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinBookWndLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siMask = self.Mask
    ---@type CEGUIDefaultWindow
    self.wPanel = self.Panel
    ---@type CEGUIStaticImage
    self.siPanelBg = self.Panel.Bg
    ---@type CEGUIStaticImage
    self.siPanelContentBg = self.Panel.ContentBg
    ---@type CEGUIScrollableView
    self.wPanelScrollableView = self.Panel.ScrollableView
    ---@type CEGUIHorizontalLayoutContainer
    self.wPanelScrollableViewHorizontalLayoutContainer = self.Panel.ScrollableView.HorizontalLayoutContainer
    ---@type CEGUIButton
    self.btnPanelCloseBtn = self.Panel.CloseBtn
    ---@type CEGUIButton
    self.btnPanelRewardBtn = self.Panel.RewardBtn
    ---@type CEGUIStaticImage
    self.siPanelRewardBtnRedIcon = self.Panel.RewardBtn.redIcon
end

---@private
function WinBookWndLayout:initUI()
    self.btnPanelRewardBtn:setText(Lang:toText("g2069_book_reward_button_title"))

    self:initVirtualUI()
end

function WinBookWndLayout:initVirtualUI()
    local this = self
    self.gvItem = widget_virtual_horz_list:init(
            self.wPanelScrollableView,
            self.wPanelScrollableViewHorizontalLayoutContainer,
            function(self, parent)
                ---@type WidgetMissionSelectItemWidget
                local node = UI:openWidget("UI/game_book/gui/widget_book_role")
                parent:addChild(node:getWindow())
                return node
            end,
            ---@type any, WidgetMissionSelectItemWidget, table
            function(self, node, data)
                node:initData(data)
            end)
end

---@private
function WinBookWndLayout:initEvent()
    self.events = {}

    self.btnPanelCloseBtn.onMouseClick = function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        UI:closeWindow("UI/game_book/gui/win_book_wnd")
    end
    self.btnPanelRewardBtn.onMouseClick = function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        UI:openWindow("UI/game_book/gui/win_book_reward")
    end

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, function(player, item, addAmount)
        if item:getItemType() == Define.ITEM_TYPE.ABILITY then
            self:updateRewardRedDot()
        end
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_BOOK_REWARD_STATE, function()
        self:updateRewardRedDot()
    end)
end

function WinBookWndLayout:initView()
    local bookList = BookInfoConfig:getAllCfgs()
    self.gvItem:setVirtualBarPosition(0)
    self.gvItem:clearVirtualChild()
    self.gvItem:addVirtualChildList(bookList)

    self:updateRewardRedDot()
end

function WinBookWndLayout:updateRewardRedDot()
    local isShow = Me:isHaveBookRewardRed()
    self.siPanelRewardBtnRedIcon:setVisible(isShow)
end

---@private
function WinBookWndLayout:onOpen()
    self:initView()
end

---@private
function WinBookWndLayout:onDestroy()

end

---@private
function WinBookWndLayout:onClose()
    if self.events then
        for _, func in pairs(self.events) do
            func()
        end
        self.events = {}
    end
end

WinBookWndLayout:init()
