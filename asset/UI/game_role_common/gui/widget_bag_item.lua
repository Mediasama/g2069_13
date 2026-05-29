---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@class WidgetBagItemWidget : CEGUILayout
local WidgetBagItemWidget = M

---@private
function WidgetBagItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetBagItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siNoneBg = self.NoneBg
	---@type CEGUIDefaultWindow
	self.wItemInfo = self.ItemInfo
	---@type CEGUIStaticImage
	self.siItemInfoItemQuality = self.ItemInfo.ItemQuality
	---@type CEGUIStaticImage
	self.siItemInfoItemIcon = self.ItemInfo.ItemIcon
	---@type CEGUIStaticImage
	self.siItemInfoDamageIcon = self.ItemInfo.DamageIcon
	---@type CEGUIStaticText
	self.stItemInfoItemLevel = self.ItemInfo.ItemLevel
	---@type CEGUIStaticImage
	self.siItemInfoEquippedStatus = self.ItemInfo.EquippedStatus
	---@type CEGUIStaticImage
	self.siItemInfoSelectedStatus = self.ItemInfo.SelectedStatus
	---@type CEGUIStaticImage
	self.siItemInfoRedDot = self.ItemInfo.RedDot
	---@type CEGUIButton
	self.btnItemInfoClickButton = self.ItemInfo.ClickButton
end

---@private
function WidgetBagItemWidget:initUI()
end

---@private
function WidgetBagItemWidget:initEvent()
	self.btnItemInfoClickButton.onMouseClick = function()
		if not self.bagItem then
			return
		end
		
		self:callHandler("select", self.bagItem, self.itemIndex)
	end
end

---@private
function WidgetBagItemWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetBagItemWidget:initData()
	---@type Item
    self.bagItem = nil
	self.itemAmount = 0
	self.itemIndex = -1
    self.callHandlers = {}
end

--- 注册回调
---@param context any
---@param func any
function WidgetBagItemWidget:registerCallHandler(key, context, func)
    self.callHandlers[key] = { this = context, func = func }
end

--- 回调
function WidgetBagItemWidget:callHandler(key, ...)
    local data = self.callHandlers[key]
    if data then
        local this = data.this
        local func = data.func
        return func(this, key, ...)
    end
end

--- 更新信息
---@param item Item
function WidgetBagItemWidget:updateInfo(data)
	---@type Item
	local item = data.item
	self.bagItem = item
	self.itemIndex = data.index
	
	if item then
		self.wItemInfo:setVisible(true)
		self.siNoneBg:setVisible(false)

		--- 显示icon
		local config = ItemConfig:getCfgByItemId(item:getItemId())

		local quality_alias = config.quality_alias
		local qualityBg = Define.ITEM_QUALITY_BG[quality_alias]
		local icon = config.icon
		local amount = data.amount or 0

		self.stItemInfoItemLevel:setText("x" .. tostring(amount))

		self.siItemInfoItemIcon:setImage(icon)
		self.siItemInfoItemQuality:setImage(qualityBg)
		if item:getItemType() == Define.ITEM_TYPE.ABILITY then
			self.siItemInfoDamageIcon:setVisible(true)
			---@type Ability
			local ability = item
			local damageType = ability:getDamageType()
			local dmgBg = Define.DAMAGE_TYPE_ICON_HOLLOW[damageType]
			local equipped = self:callHandler("equipped", item)
			self.siItemInfoEquippedStatus:setVisible(equipped or false)
			self.siItemInfoDamageIcon:setImage(dmgBg)
		else
			self.siItemInfoDamageIcon:setVisible(false)
			self.siItemInfoEquippedStatus:setVisible(false)
		end

		local selected = self:callHandler("selected", item)
		local inspected = self:callHandler("inspected", item)
		self.siItemInfoSelectedStatus:setVisible(selected)
		self.siItemInfoRedDot:setVisible(not inspected and not selected)
	else
		self.wItemInfo:setVisible(false)
		self.siNoneBg:setVisible(true)
	end
end

function WidgetBagItemWidget:subscribeEvents()
	--- 选中物品
	---@param item any
    self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_BAG_ITEM, function(item)
		if self.bagItem then
			local selected = self.bagItem:getId() == item:getId()
			self.siItemInfoSelectedStatus:setVisible(selected)
			if selected then
				self.siItemInfoRedDot:setVisible(false)
			end
		end
	end)

	--- 切换能力
	---@param success any
	---@param player any
	---@param ability Ability
	---@param oldAbility Ability
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
		if not self.bagItem or not success then
			return
		end
		--- 判断是否装备中
		if self.bagItem:getItemType() == Define.ITEM_TYPE.ABILITY then
			self.siItemInfoEquippedStatus:setVisible(self.bagItem:getId() == ability:getId())
		end
	end)

	--- 插入数据
	---@param data any
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_INSERT_BAG_ITEM, function(data)
		if self.itemIndex ~= data.index then
			return
		end
		self:updateInfo(data)
	end)

	--- 插入数据
	---@param data any
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_BAG_ITEM, function(data)
		if not self.bagItem or self.bagItem:getId() ~= data.item:getId() then
			return
		end
		--- 只修改数量
		local amount = self:callHandler("amount", self.bagItem)
		self.stItemInfoItemLevel:setText("x" .. tostring(amount))
	end)
end

---@private
function WidgetBagItemWidget:onDestroy()

end

WidgetBagItemWidget:init()
