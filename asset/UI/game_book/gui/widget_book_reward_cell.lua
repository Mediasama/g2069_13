---@class WidgetBookRewardCellWidget : CEGUILayout
local WidgetBookRewardCellWidget = M
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@private
function WidgetBookRewardCellWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetBookRewardCellWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stItemQualityItemNum = self.ItemQuality.ItemNum
end

---@private
function WidgetBookRewardCellWidget:initUI()
end

function WidgetBookRewardCellWidget:initData(item)
	--- 物品显示
	--- 品质
	local itemConfig = ItemConfig:getCfgByItemAlias(item.item_alias)
	self.stItemQualityItemNum:setText("x" .. tostring(item.item_num))
	local qualityBg = Define.ITEM_QUALITY_BG[itemConfig.quality_alias]
	self.siItemQuality:setImage(qualityBg)
	--- 图标
	self.siItemQualityItemIcon:setImage(itemConfig.icon)
end

---@private
function WidgetBookRewardCellWidget:initEvent()
end

---@private
function WidgetBookRewardCellWidget:onOpen()

end

---@private
function WidgetBookRewardCellWidget:onDestroy()

end

WidgetBookRewardCellWidget:init()
