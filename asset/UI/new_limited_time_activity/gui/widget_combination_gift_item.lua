---@class WidgetCombinationGiftItemWidget : CEGUILayout
local WidgetCombinationGiftItemWidget = M

---@private
function WidgetCombinationGiftItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetCombinationGiftItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticImage
	self.siItemQualityItemNumBg = self.ItemQuality.ItemNumBg
	---@type CEGUIStaticText
	self.stItemQualityItemNum = self.ItemQuality.ItemNum
	---@type CEGUIStaticImage
	self.siItemHave = self.ItemHave
	---@type CEGUIStaticImage
	self.siItemHaveBg = self.ItemHave.Bg
	---@type CEGUIStaticText
	self.stItemHaveItemHaveText = self.ItemHave.ItemHaveText
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetCombinationGiftItemWidget:initUI()
	-- self.stItemQualityItemNumBgItemNum:setText(Lang:toText(""))
	self.stItemHaveItemHaveText:setText(Lang:toText("gui.limit.time.activity.is.have"))

	self.imgGoodsBg = self.siItemQuality
	self.imgGoodsIcon = self.siItemQualityItemIcon
	self.txtGoodsNum = self.stItemQualityItemNum
	self.lytIsHave = self.siItemHave
end

---@private
function WidgetCombinationGiftItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function(instance, window, x, y)
		if self.data then
			Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
			LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.data, x, y)
		end
	end
end

function WidgetCombinationGiftItemWidget:updateInfo(data)
	self.data = data
	-- if data.itemCount <= 1 then
	-- 	self.txtGoodsNum:setText("")
	-- else
	-- 	self.txtGoodsNum:setText("x" .. data.itemCount)
	-- end
	self.txtGoodsNum:setText("x" .. data.itemCount)
	local itemData = LimitedTimeActivityGameMgr:getItemInfo(data)
	if data.itemIcon and data.itemIcon ~= "" then
		self.imgGoodsIcon:setImage(data.itemIcon)
	else
		self.imgGoodsIcon:setImage(itemData.itemIcon or "")
	end
	-- self.lytIsHave:setVisible(itemData.isHave)
	local quality = itemData.quality
	local qualityBg = Define.ITEM_QUALITY_BG[quality]

	self.imgGoodsBg:setImage(qualityBg)

	self.lytIsHave:setVisible(false)
end

---@private
function WidgetCombinationGiftItemWidget:onOpen()

end

---@private
function WidgetCombinationGiftItemWidget:onDestroy()

end

WidgetCombinationGiftItemWidget:init()
