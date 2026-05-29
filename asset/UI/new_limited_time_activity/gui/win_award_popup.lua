---@class WinAwardPopupLayout : CEGUILayout
local WinAwardPopupLayout = M
---@type LimitedTimeGiftItemConfig
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@private
function WinAwardPopupLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinAwardPopupLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticImage
	self.siMainWindowItemBg = self.MainWindow.ItemBg
	---@type CEGUIStaticText
	self.stMainWindowTitle = self.MainWindow.Title
	---@type CEGUIStaticText
	self.stMainWindowTip = self.MainWindow.Tip
	---@type CEGUIScrollableView
	self.wMainWindowSvItem = self.MainWindow.SvItem
	---@type CEGUIHorizontalLayoutContainer
	self.wMainWindowSvItemLvItem = self.MainWindow.SvItem.LvItem
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
end

---@private
function WinAwardPopupLayout:initUI()
	-- self.stMainWindowTitle:setText(Lang:toText(""))
	-- self.stMainWindowTip:setText(Lang:toText(""))

    self.imgBg = self.siMainWindowBg
	self.imgItemBg = self.siMainWindowItemBg
	self.txtTitle = self.stMainWindowTitle
	self.txtTip = self.stMainWindowTip
	self.txtTip:setText(Lang:toText("gui.limit.time.activity.click.on.the.screen.to.continue"))

	self.imgItemBg:setVisible(false)
end

---@private
function WinAwardPopupLayout:initEvent()
    self.btnMainWindowCloseButton.onMouseClick = function()
        if self._timer then
            return
        end
        UI:closeWindow(self)
	end
end

---@private
function WinAwardPopupLayout:onOpen(addition, title)
    self:initData()
    self:initAwardPopupUI()
    self:initView(addition, title)
	Me:playUiSoundByKey("getAwardSound")
	self:showPerform()
	Me.inShowLimitedTimeActivityAwardPopup = true
end

function WinAwardPopupLayout:initData()
    self._timer = nil
    self.awardData = LimitedTimeGiftItemConfig:getAllCfgs()
	self.cells = {}
end

function WinAwardPopupLayout:showPerform()
	local initAlpha = 0.3
    local root = self
	root:setAlpha(initAlpha)
    self._timer = LuaTimer:scheduleTicker(function()
        initAlpha = math.min(initAlpha + 0.08, 1)
		root:setAlpha(initAlpha)
        if initAlpha >= 1 then
            LuaTimer:cancel(self._timer)
            self._timer = nil
        end
    end, 1) 
end

function WinAwardPopupLayout:initAwardPopupUI()
    ---@type widget_virtual_horz_list
	self.lvItem = widget_virtual_horz_list:init(
		self.wMainWindowSvItem,
		self.wMainWindowSvItemLvItem,
		---@type any, CEGUIWindow
		function(self, parent)
			---@type WidgetAbilityItemWidget
			local node = UI:openWidget("UI/new_limited_time_activity/gui/widget_activity_item")
			parent:addChild(node:getWindow())
			return node
		end,
		---@type any, WidgetAbilityItemWidget, table
		function(self, node, data)
			node:updateInfo(data)
		end
	)
end

function WinAwardPopupLayout:initView(addition, title)
	if not addition then
		return
	end
	local item = addition.item
	if title then
		self.txtTitle:setText(Lang:toText(title))
	else
		self.txtTitle:setText(Lang:toText("gui.limit.time.activity.congratulations"))
	end
	if item then
		local showItemBg = addition.showItemBg or (item.luckyDrawType and item.luckyDrawType == Define.LUCKY_DRAW_TYPE.TEN)
		-- self.imgItemBg:setVisible(showItemBg)
		local giftContent = addition.item.giftContent or {}
		local data = {}
		for _, id in pairs(giftContent) do
			if self.awardData and self.awardData[id] then
				if self.awardData[id].itemName == "" then
					self.awardData[id].itemName = addition.item.name
				end
				if not self.awardData[id].quality then
					self.awardData[id].quality = addition.item.quality
				end
				self.awardData[id].isShowEffect = true
				if addition.isCombined then
					self.awardData[id].combinedNum = addition.item.giftNum
				end
                data[#data + 1] = self.awardData[id]
			end
		end
        if #data > 0 then
            self.lvItem:addVirtualChildList(data)
        end
	end
end

---@private
function WinAwardPopupLayout:onDestroy()

end

---@private
function WinAwardPopupLayout:onClose()
    if self._timer then
		LuaTimer:cancel(self._timer)
        self._timer = nil
	end
	Me:stopUiSoundByKey("getAwardSound")
	Me.inShowLimitedTimeActivityAwardPopup = false
	Me:showCombinedLimitTimeCardRewards()
end

WinAwardPopupLayout:init()
