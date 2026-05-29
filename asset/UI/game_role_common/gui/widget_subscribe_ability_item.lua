---@class WidgetSubscribeAbilityItemWidget : CEGUILayout
local WidgetSubscribeAbilityItemWidget = M

---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@type BusinessSystem
local BusinessSystem = T(Lib, "BusinessSystem")

---@private
function WidgetSubscribeAbilityItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetSubscribeAbilityItemWidget:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wPanel = self.Panel
	---@type CEGUIStaticImage
	self.siPanelBg = self.Panel.Bg
	---@type CEGUIStaticImage
	self.siPanelItemQuality = self.Panel.ItemQuality
	---@type CEGUIStaticImage
	self.siPanelItemQualityItemIcon = self.Panel.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stPanelItemQualityItemNum = self.Panel.ItemQuality.ItemNum
	---@type CEGUIStaticText
	self.stPanelNameText = self.Panel.NameText
	---@type CEGUIStaticImage
	self.siPanelSoldOutBg = self.Panel.SoldOutBg
	---@type CEGUIStaticText
	self.stPanelSoldOutBgSoldOutText = self.Panel.SoldOutBg.SoldOutText
	---@type CEGUIStaticImage
	self.siPanelSelectedBg = self.Panel.SelectedBg
	---@type CEGUIButton
	self.btnPanelClickButton = self.Panel.ClickButton
end

---@private
function WidgetSubscribeAbilityItemWidget:initUI()
	self.siPanelSoldOutBg:setVisible(false)
end

---@private
function WidgetSubscribeAbilityItemWidget:initEvent()
	self._allEvent = {}

	self.btnPanelClickButton.onMouseClick = function()
		if self.callFunc then
			self.callFunc(self.item_alias)
		end
	end

	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_UPDATE_SUBSCRIBE_SELECT_ABILITY, function(name)
		self.siPanelSelectedBg:setVisible(name == self.item_alias)
	end)

end

function WidgetSubscribeAbilityItemWidget:initData(item_alias, callFunc)
	self.item_alias = item_alias
	self.callFunc = callFunc

	self.stPanelItemQualityItemNum:setText("x1")
	self.stPanelNameText:setText(Lang:toText(item_alias))

	local itemConfig = ItemConfig:getCfgByItemAlias(item_alias)
	local qualityBg = Define.ITEM_QUALITY_BG[itemConfig.quality_alias]
	self.siPanelItemQuality:setImage(qualityBg)
	--- 图标
	self.siPanelItemQualityItemIcon:setImage(itemConfig.icon)
	self.siPanelSelectedBg:setVisible(false)
end

---@private
function WidgetSubscribeAbilityItemWidget:onOpen()

end

---@private
function WidgetSubscribeAbilityItemWidget:onDestroy()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WidgetSubscribeAbilityItemWidget:init()
