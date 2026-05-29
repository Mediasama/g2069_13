---@class WidgetFlyNewTipsWidget : CEGUILayout
local WidgetFlyNewTipsWidget = M

---@private
function WidgetFlyNewTipsWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetFlyNewTipsWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.bg
	---@type CEGUIDefaultWindow
	self.wNormalPanel = self.NormalPanel
	---@type CEGUIStaticText
	self.stNormalPanelNormalStr = self.NormalPanel.NormalStr
	---@type CEGUIDefaultWindow
	self.wSpecialPanel = self.SpecialPanel
end

---@private
function WidgetFlyNewTipsWidget:initUI()

end

---@private
function WidgetFlyNewTipsWidget:initEvent()
end

function WidgetFlyNewTipsWidget:initItemData(itemInfo)
	self.itemInfo = itemInfo
	local flyTipsSetting = World.cfg.fly_new_tipsSetting or {}
	self:setYPosition({0, flyTipsSetting.initPosY})
	self.wSpecialPanel:cleanupChildren()

	self:setHeight({ 0, flyTipsSetting.itemHeight })
	if itemInfo.type == Define.FlyNewTipsType.Normal then
		self.wSpecialPanel:setVisible(false)
		self.wNormalPanel:setVisible(true)
		self.stNormalPanelNormalStr:setText(Lang:toText(itemInfo.content))

		self.stNormalPanelNormalStr:setFontSize(flyTipsSetting.fontSize)
		self.stNormalPanelNormalStr:setProperty("TextColours", flyTipsSetting.textColours)
		self.stNormalPanelNormalStr:setProperty("BorderColor", flyTipsSetting.borderColor)
		self.stNormalPanelNormalStr:setProperty("BorderWidth", flyTipsSetting.borderWidth)

		local tagWidth = self.stNormalPanelNormalStr:getWindowRenderer():getDocumentWidth()
		local width = math.clamp(tagWidth + 200, 256, 1280)
		self.siBg:setWidth({ 0, width })
	elseif itemInfo.type == Define.FlyNewTipsType.Special then
		self.wSpecialPanel:setVisible(true)
		self.wNormalPanel:setVisible(false)
		self:updateSpecialShow()
	end
end

function WidgetFlyNewTipsWidget:updateSpecialShow()
	local flyTipsSetting = World.cfg.fly_new_tipsSetting or {}
	local totalWidth = 0
	for index, data in ipairs(self.itemInfo.content) do
		local node
		local width = 0
		if data.sType == Define.FlySpecialTipsType.Text then
			node = self:createOneTextNode(index, data)
			width = node:getWindowRenderer():getDocumentWidth()
		else
			node = self:createOneImageNode(index, data)
			width = node:getWidth()[2] + 5
			totalWidth = totalWidth + 5
		end
		node:setXPosition({0, totalWidth})
		totalWidth = totalWidth + width
	end
	self.wSpecialPanel:setWidth({ 0, totalWidth })
	local width = math.clamp(totalWidth + 200, 256, 1280)
	self.siBg:setWidth({ 0, width })
end

function WidgetFlyNewTipsWidget:createOneTextNode(index, data)
	local flyTipsSetting = World.cfg.fly_new_tipsSetting or {}
	local textNode =  UI:createStaticText("flyTipsText" .. index .. self:getStartActionTime())
	textNode:setText(Lang:toText(data.text or ""))
	textNode:setProperty("HorizontalAlignment", "Left")
	textNode:setProperty("VerticalAlignment", "Centre")
	textNode:setYPosition({0, 0})
	textNode:setProperty("WindowTouchThroughMode", "MousePassThroughOpen")
	textNode:setFontSize(data.fontSize or flyTipsSetting.fontSize)
	textNode:setProperty("TextColours", data.fontSize or flyTipsSetting.textColours)
	textNode:setProperty("BorderColor", data.borderColor or flyTipsSetting.borderColor)
	textNode:setProperty("BorderWidth", data.borderWidth or flyTipsSetting.borderWidth)
	self.wSpecialPanel:addChild(textNode)
	return textNode
end

function WidgetFlyNewTipsWidget:createOneImageNode(index, data)
	local flyTipsSetting = World.cfg.fly_new_tipsSetting or {}
	local imgNode =  UI:createStaticImage("flyTipsImage" .. index .. self:getStartActionTime())
	imgNode:setProperty("HorizontalAlignment", "Left")
	imgNode:setProperty("VerticalAlignment", "Centre")
	imgNode:setYPosition({0, 0})
	imgNode:setProperty("WindowTouchThroughMode", "MousePassThroughOpen")
	imgNode:setImage(data.imgRes or "")
	imgNode:setWidth({ 0, data.width or flyTipsSetting.imageWidth })
	imgNode:setHeight({ 0, data.height or flyTipsSetting.imageHeight })
	self.wSpecialPanel:addChild(imgNode)
	return imgNode
end

function WidgetFlyNewTipsWidget:getStartActionTime()
	return self.startActionTime or 0
end

function WidgetFlyNewTipsWidget:setStartActionTime(startTime)
	self.startActionTime = startTime
end

function WidgetFlyNewTipsWidget:setToMaxHeightTime(startTime)
	self.toMaxHeightTime = startTime
end

function WidgetFlyNewTipsWidget:getToMaxHeightTime()
	return self.toMaxHeightTime or -9999
end

function WidgetFlyNewTipsWidget:updateAllNodeAlpha(alpha)
	self:setAlpha(alpha)
end

function WidgetFlyNewTipsWidget:setItemYPosition(posY)
	self:setYPosition({0, posY})
end

function WidgetFlyNewTipsWidget:getItemYPosition()
	return self:getYPosition()[2]
end

---@private
function WidgetFlyNewTipsWidget:onOpen()

end

---@private
function WidgetFlyNewTipsWidget:onDestroy()

end

WidgetFlyNewTipsWidget:init()
