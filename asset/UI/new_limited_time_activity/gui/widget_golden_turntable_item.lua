---@class WidgetGoldenTurntableItemWidget : CEGUILayout
local WidgetGoldenTurntableItemWidget = M

---@private
function WidgetGoldenTurntableItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetGoldenTurntableItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stItemNum = self.ItemNum
	---@type CEGUIStaticImage
	self.siItemTag = self.ItemTag
	---@type CEGUIStaticText
	self.stItemTagTitle = self.ItemTag.Title
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetGoldenTurntableItemWidget:initUI()
    self.imgFrame = self.siItemQuality
	self.imgIcon = self.siItemQualityItemIcon
	self.txtNum = self.stItemNum
	self.imgTag = self.siItemTag
	self.txtTagTxt = self.stItemTagTitle
end

---@private
function WidgetGoldenTurntableItemWidget:initEvent()
    self.btnClickButton.onMouseClick = function(instance, window, x, y)
		if self.data then
			Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
			LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.data, x, y)
		end
	end
end

---@private
function WidgetGoldenTurntableItemWidget:onOpen()

end

function WidgetGoldenTurntableItemWidget:updateInfo(data)
    self.data = data
	local info = LimitedTimeActivityGameMgr:getItemInfo(data)
	self.info = info
	local quality = info.quality
	local qualityBg = Define.ITEM_QUALITY_BG[quality]
	self.imgFrame:setImage(qualityBg)
	self.imgIcon:setImage(info.itemIcon)
	local count = info.itemCount or 0
	-- if count <= 1 then
	-- 	self.txtNum:setText("")
	-- else
	-- 	self.txtNum:setText("x" .. count)
	-- end
	self.txtNum:setText("x" .. count)
	self.imgTag:setVisible(false)
	if data.tag then
		self.imgTag:setVisible(true)
		self.txtTagTxt:setText(data.tag)
	end
end

---@private
function WidgetGoldenTurntableItemWidget:onDestroy()

end

WidgetGoldenTurntableItemWidget:init()
