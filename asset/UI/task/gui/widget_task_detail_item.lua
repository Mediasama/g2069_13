---@class WidgetTaskDetailItemWidget : CEGUILayout
local WidgetTaskDetailItemWidget = M
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@private
function WidgetTaskDetailItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetTaskDetailItemWidget:findAllWindow()
	---@type CEGUIStaticText
	self.stRewardText = self.rewardText
	---@type CEGUIStaticImage
	self.siExpIconIcon = self.expIcon
	---@type CEGUIStaticImage
	self.siGoldIcon = self.goldIcon
end

---@private
function WidgetTaskDetailItemWidget:initUI()
end

---@private
function WidgetTaskDetailItemWidget:initEvent()
end

function WidgetTaskDetailItemWidget:initData(data)
	local item_alias = data.item_alias
	local item_num = data.item_num
	self.stRewardText:setText(item_num)

	if item_alias == Define.ITEM_ALIAS.GOLD_COIN then
		self.siExpIconIcon:setVisible(false)
		self.siGoldIcon:setVisible(true)
	elseif item_alias == Define.ITEM_ALIAS.ROLE_EXP then
		self.siExpIconIcon:setVisible(true)
		self.siGoldIcon:setVisible(false)
		self.siExpIconIcon:setImage("asset/imageset/main:img_0_exp")
	elseif item_alias == Define.ITEM_ALIAS.ABILITY_EXP then
		self.siExpIconIcon:setVisible(true)
		self.siGoldIcon:setVisible(false)
		self.siExpIconIcon:setImage("asset/imageset/main:img_0_ability_exp")
	end
end

---@private
function WidgetTaskDetailItemWidget:onOpen()

end

---@private
function WidgetTaskDetailItemWidget:onDestroy()

end

WidgetTaskDetailItemWidget:init()
