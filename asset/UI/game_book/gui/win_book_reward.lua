---@class WinBookRewardLayout : CEGUILayout
local WinBookRewardLayout = M
---@type BookRewardConfig
local BookRewardConfig = T(Config, "BookRewardConfig")
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type BookInfoConfig
local BookInfoConfig = T(Config, "BookInfoConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@private
function WinBookRewardLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinBookRewardLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMask = self.Mask
	---@type CEGUIDefaultWindow
	self.wPanel = self.Panel
	---@type CEGUIStaticImage
	self.siPanelBg = self.Panel.Bg
	---@type CEGUIStaticText
	self.stPanelTitleText = self.Panel.TitleText
	---@type CEGUIStaticImage
	self.siPanelContentBg = self.Panel.ContentBg
	---@type CEGUIScrollableView
	self.wPanelContentBgScrollableView = self.Panel.ContentBg.ScrollableView
	---@type CEGUIVerticalLayoutContainer
	self.wPanelContentBgScrollableViewVerticalLayoutContainer = self.Panel.ContentBg.ScrollableView.VerticalLayoutContainer
	---@type CEGUIButton
	self.btnPanelCloseBtn = self.Panel.CloseBtn
end

---@private
function WinBookRewardLayout:initUI()
	self.stPanelTitleText:setText(Lang:toText("g2069_book_reward_ui_title"))

	self.haveBookNum = 0
	self:initVirtualUI()
end

function WinBookRewardLayout:initVirtualUI()
	local this = self
	self.gvItem = widget_virtual_vert_list:init(
			self.wPanelContentBgScrollableView,
			self.wPanelContentBgScrollableViewVerticalLayoutContainer,
			function(self, parent)
				---@type WidgetBookRewardItemWidget
				local node = UI:openWidget("UI/game_book/gui/widget_book_reward_item")
				parent:addChild(node:getWindow())
				return node
			end,
			---@type any, WidgetBookRewardItemWidget, table
			function(self, node, data)
				node:initData(data, this.haveBookNum)
			end)
end

---@private
function WinBookRewardLayout:initEvent()
	self.btnPanelCloseBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:closeWindow("UI/game_book/gui/win_book_reward")
	end

	self._allEvent = {}
	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_BOOK_REWARD_STATE, function()
		self:updateItemListShow()
	end)
end

function WinBookRewardLayout:initView()
	self.haveBookNum = 0
	local allBook = BookInfoConfig:getAllCfgs()
	local inventoryType = Define.ITEM_INVENTORY_TYPE[Define.ITEM_TYPE.ABILITY]
	for _, data in pairs(allBook) do
		local ability = InventorySystem:getItemByItemId(Me, inventoryType, data.abilityId)
		if ability then
			self.haveBookNum = self.haveBookNum + 1
		end
	end
	self:updateItemListShow()
end

function WinBookRewardLayout:updateItemListShow()
	local rewardList = Lib.copyTable1(BookRewardConfig:getAllCfgs())
	local bookRewardState = Me:getBookRewardState()
	for key, data in pairs(rewardList) do
		if self.haveBookNum >= data.collectNum then
			if bookRewardState[data.Id] then
				rewardList[key].receiveState = 3
			else
				rewardList[key].receiveState = 1
			end
		else
			rewardList[key].receiveState = 2
		end
	end
	table.sort(rewardList, function(a, b)
		if a.receiveState == b.receiveState then
			return a.Id < b.Id
		else
			return a.receiveState < b.receiveState
		end
	end)
	self.gvItem:setVirtualBarPosition(0)
	self.gvItem:clearVirtualChild()
	self.gvItem:addVirtualChildList(rewardList)
end

---@private
function WinBookRewardLayout:onOpen()
	self:initView()
end

---@private
function WinBookRewardLayout:onDestroy()

end

---@private
function WinBookRewardLayout:onClose()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WinBookRewardLayout:init()
