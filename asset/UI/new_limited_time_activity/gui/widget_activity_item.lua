---@class WidgetActivityItemWidget : CEGUILayout
local WidgetActivityItemWidget = M

---@private
function WidgetActivityItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetActivityItemWidget:findAllWindow()
	---@type CEGUIEffectWindow
	self.wEffect = self.Effect
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stItemQualityItemNum = self.ItemQuality.ItemNum
	---@type CEGUIStaticText
	self.stItemName = self.ItemName
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetActivityItemWidget:initUI()
    self.imgFrame = self.siItemQuality
	self.imgIcon = self.siItemQualityItemIcon
	self.txtName = self.stItemName
	self.txtNum = self.stItemQualityItemNum
	self.lytEffect = self.wEffect
end

---@private
function WidgetActivityItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function(instance, window, x, y)
        if self.data then
			Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
			LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.data, x, y)
		end
	end
end

---@private
function WidgetActivityItemWidget:onOpen()

end

function WidgetActivityItemWidget:updateInfo(item)
	self.data = item
	
	local info = LimitedTimeActivityGameMgr:getItemInfo(item)
	if item.showName and item.showName ~= "" then
		self.txtName:setText(Lang:toText(item.showName or ""))
	else
		self.txtName:setText(Lang:toText(info.itemName))
	end
	local quality = info.quality
	self.lytEffect:setVisible(quality == Define.ITEM_QUALITY.LEGENDARY and item.isShowEffect)
	local isNeedSpecialCell = LimitedTimeActivityGameMgr:addSpecialCell(self, item)
	if isNeedSpecialCell then
		self:setSpecialModel()
		return
	end
	local qualityBg = Define.ITEM_QUALITY_BG[quality]

	self.imgFrame:setImage(qualityBg)
	self.imgIcon:setImage(info.itemIcon)
	local count = info.itemCount or 0
	if item.combinedNum then
		count = count * item.combinedNum
	end
	-- if count <= 1 then
	-- 	self.txtNum:setText("")
	-- else
	-- 	self.txtNum:setText("x" .. count)
	-- end
	self.txtNum:setText("x" .. count)
end

function WidgetActivityItemWidget:setSpecialModel()
	self.imgFrame:setImage("")
	self.imgIcon:setImage("")
	self.txtNum:setText("")
end

function WidgetActivityItemWidget:onDataChanged(data)
	self.data = data
	self.isClick = data.isClick
	self:updateInfo(data)
end

---@private
function WidgetActivityItemWidget:onDestroy()

end

WidgetActivityItemWidget:init()
