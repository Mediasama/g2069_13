---@class WinCombinationGiftLayout : CEGUILayout
local WinCombinationGiftLayout = M

---@type LimitedTimeGiftCombinedConfig
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")

---@type LimitTimeClientHelper
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
---@type LimitedTimeGiftItemConfig
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"

---@private
function WinCombinationGiftLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinCombinationGiftLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticText
	self.stMainWindowTitle = self.MainWindow.Title
	---@type CEGUIStaticImage
	self.siMainWindowRemainIcon = self.MainWindow.RemainIcon
	---@type CEGUIStaticText
	self.stMainWindowRemainIconRemianTime = self.MainWindow.RemainIcon.RemianTime
	---@type CEGUIStaticImage
	self.siMainWindowBubbleIcon = self.MainWindow.BubbleIcon
	---@type CEGUIStaticText
	self.stMainWindowBubbleIconBubbleTip = self.MainWindow.BubbleIcon.BubbleTip
	---@type CEGUIStaticImage
	self.siMainWindowOffIcon = self.MainWindow.OffIcon
	---@type CEGUIStaticText
	self.stMainWindowOffIconOffText = self.MainWindow.OffIcon.OffText
	---@type CEGUIStaticText
	self.stMainWindowOffIconPerText = self.MainWindow.OffIcon.PerText
	---@type CEGUIScrollableView
	self.wMainWindowSvItem = self.MainWindow.SvItem
	---@type CEGUIHorizontalLayoutContainer
	self.wMainWindowSvItemLvItem = self.MainWindow.SvItem.LvItem
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
	---@type CEGUIButton
	self.btnMainWindowBuyButton = self.MainWindow.BuyButton
	---@type CEGUIStaticImage
	self.siMainWindowBuyButtonFinalDiaIcon = self.MainWindow.BuyButton.FinalDiaIcon
	---@type CEGUIStaticText
	self.stMainWindowBuyButtonFinalDiaIconFinalPrice = self.MainWindow.BuyButton.FinalDiaIcon.FinalPrice
	---@type CEGUIStaticImage
	self.siMainWindowBuyButtonInitDiaIcon = self.MainWindow.BuyButton.InitDiaIcon
	---@type CEGUIStaticText
	self.stMainWindowBuyButtonInitDiaIconInitPrice = self.MainWindow.BuyButton.InitDiaIcon.InitPrice
	---@type CEGUIStaticImage
	self.siMainWindowBuyButtonInitDiaIconInitPriceLine = self.MainWindow.BuyButton.InitDiaIcon.InitPrice.Line
	---@type CEGUIButton
	self.btnMainWindowBoughtButton = self.MainWindow.BoughtButton
end

---@private
function WinCombinationGiftLayout:initUI()
	-- self.stMainWindowTitle:setText(Lang:toText(""))
	-- self.stMainWindowRemainIconRemianTime:setText(Lang:toText(""))
	-- self.stMainWindowBubbleIconBubbleTip:setText(Lang:toText(""))
	-- self.stMainWindowOffIconOffText:setText(Lang:toText(""))
	-- self.stMainWindowOffIconPerText:setText(Lang:toText(""))
	-- self.stMainWindowBuyButtonFinalDiaIconFinalPrice:setText(Lang:toText(""))
	-- self.stMainWindowBuyButtonInitDiaIconInitPrice:setText(Lang:toText(""))

    self.txtTitleText = self.stMainWindowTitle
	self.txtRemainText = self.stMainWindowRemainIconRemianTime
	self.txtOFFText = self.stMainWindowOffIconOffText
	self.txtPerText = self.stMainWindowOffIconPerText
	self.txtLimitText = self.stMainWindowBubbleIconBubbleTip
	self.btnBuyBtn = self.btnMainWindowBuyButton
	self.imgFinalDiaIcon = self.siMainWindowBuyButtonFinalDiaIcon
	self.txtFinalPrice = self.stMainWindowBuyButtonFinalDiaIconFinalPrice
	self.imgInitDiaIcon = self.siMainWindowBuyButtonInitDiaIcon
	self.txtInitPrice = self.stMainWindowBuyButtonInitDiaIconInitPrice

	self.txtOFFText:setText(Lang:toText("gui.limit.time.combined.off"))
	self.txtLimitText:setText(Lang:toText({ "g2069.gui.limit.time.combined.limit", 1 }))
	self.btnMainWindowBoughtButton:setText(Lang:toText("gui.limit.time.combined.purchased"))

end

---@private
function WinCombinationGiftLayout:initEvent()
	self.btnMainWindowCloseButton.onMouseClick = function()
        if self.isBuying then
			Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
            return
        end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
        UI:closeWindow(self)
	end
	self.btnMainWindowBuyButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        if not self.activityData then
			return
		end
		if self.isBuying then
			return
		end
		if Lib.checkMoney(Me, 0, self.activityData.finalPrice, true) then
			local params = {
				activityId = self.activityData.activityId,
				id = self.activityData.id,
			}
			LimitedTimeActivityGameMgr:clientClickBoughtBtn(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT, params)
		else
			LimitedTimeActivityGameMgr:showBuyFailTip()
		end
	end
end


local function getTimeByArray(array)
	return os.time({year = array[1] or 0, month = array[2] or 0, day = array[3] or 0, hour = array[4] or 0, min = array[5] or 0, sec = array[6] or 0})
end

---@private
function WinCombinationGiftLayout:onOpen()
    self:initCombinationUI()
    self:initView()
    self:subscribeEvents()
    LimitedTimeActivityGameMgr:updateCombinedLimitBtnRedDot(false)
end

function WinCombinationGiftLayout:initCombinationUI()
    self.lvItem = widget_virtual_horz_list:init(
        self.wMainWindowSvItem,
        self.wMainWindowSvItemLvItem,
        ---@type any, CEGUIWindow
		function(self, parent)
            ---@type WidgetCombinationGiftItemWidget
			local node = UI:openWidget("UI/new_limited_time_activity/gui/widget_combination_gift_item")
			parent:addChild(node:getWindow())
			return node
		end,
		function(self, node, data)
			node:updateInfo(data)
		end
    )
end

function WinCombinationGiftLayout:subscribeEvents()
    self:subscribeEvent(Event.EVENT_LIMITED_TIME_COMBINATION_BUY, function(combinedGiftData)
		self:updateBoughtBtnShow(combinedGiftData)
	end)

	self:subscribeEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, function(value)
		self:updateBuyingState(value)
	end)
end

--界面数据初始化
function WinCombinationGiftLayout:initView()
	self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
	self.curTime = LimitedTimeActivityGameMgr:getServerTime()
	self.endTime = self.activityInfo.endNumTime or getTimeByArray(self.activityInfo.endTime)

	self:updateActivityGoodsShow()

	self:updateActivityTimeShow()
	self:startDownTimer()
end

function WinCombinationGiftLayout:updateBuyingState(value)
	self.isBuying = value
end

function WinCombinationGiftLayout:getBuyingState()
	return self.isBuying
end

function WinCombinationGiftLayout:updateActivityGoodsShow()
	self.activityData = LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activityInfo.id)
	if not self.activityData then
		return
	end

	if self.activityData.giftName and self.activityData.giftName ~= "" then
		self.txtTitleText:setText(Lang:toText(self.activityData.giftName))
	else
		self.txtTitleText:setText(Lang:toText("gui.limit.time.combined.title"))
	end
	self.txtPerText:setText(self.activityData.percent)

	local combinedGiftData = Me:getCombinedGiftData()
	self:updateBoughtBtnShow(combinedGiftData)

	self:updateGoodsItemShow()
end

function WinCombinationGiftLayout:updateBoughtBtnShow(combinedGiftData)
	local giftKey = self.activityData.giftKey
	if combinedGiftData[giftKey] then
		self.imgInitDiaIcon:setVisible(false)
		self.imgFinalDiaIcon:setVisible(false)
		-- self.btnBuyBtn:setText(Lang:toText("gui.limit.time.combined.purchased"))
		-- self.btnBuyBtn:setEnabled(false)
		self.btnBuyBtn:setVisible(false)
		self.btnMainWindowBoughtButton:setVisible(true)

		local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
		LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(isOpen)
	else
		-- self.btnBuyBtn:setEnabled(true)
		-- self.btnBuyBtn:setText("")
		self.btnBuyBtn:setVisible(true)
		self.btnMainWindowBoughtButton:setVisible(false)
		self.imgInitDiaIcon:setVisible(true)
		self.imgFinalDiaIcon:setVisible(true)

		self.txtFinalPrice:setText(self.activityData.finalPrice)
		self.txtInitPrice:setText(self.activityData.initPrice)
	end
end

function WinCombinationGiftLayout:updateGoodsItemShow()
    self.lvItem:clearVirtualChild()
	for _, value in pairs(self.activityData.giftContent or {}) do
		local itemInfo = LimitedTimeGiftItemConfig:getCfgById(value)
		if itemInfo then
            self.lvItem:addVirtualChild(itemInfo)
		end
	end
end

function WinCombinationGiftLayout:updateActivityTimeShow()
	local remainTime = self.endTime - self.curTime
	if remainTime < 0 then
		UI:closeWindow(self)
		return
	end
	local text = string.format("%02d:%02d:%02d",Lib.timeFormatting(remainTime))
	if remainTime > (3600*24) then
		local day = math.floor(remainTime/3600/24) or 0
		text = day .. "d " .. text
	end
	self.txtRemainText:setText(text)
end

function WinCombinationGiftLayout:startDownTimer()
	self:stopDownTimer()
	self.downTimer = World.Timer(20,function()
		self.curTime = self.curTime + 1
		self:updateActivityTimeShow()
		return true
	end)
end

function WinCombinationGiftLayout:stopDownTimer()
	if self.downTimer then
		self.downTimer()
		self.downTimer = nil
	end
end

---@private
function WinCombinationGiftLayout:onDestroy()

end

---@private
function WinCombinationGiftLayout:onClose()
    self:stopDownTimer()
end

WinCombinationGiftLayout:init()
