---@class WidgetMissionSelectItemWidget : CEGUILayout
local WidgetMissionSelectItemWidget = M
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

---@private
function WidgetMissionSelectItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetMissionSelectItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticImage
	self.siSkillTypeIcon = self.SkillTypeIcon
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetMissionSelectItemWidget:initUI()
	self.callHandlers = {}
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetMissionSelectItemWidget:registerCallHandler(key, context, func)
	self.callHandlers[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetMissionSelectItemWidget:callHandler(key, ...)
	local handler = self.callHandlers[key]
	if handler then
		local this = handler.this
		local func = handler.func
		return func(this, key, ...)
	end
end

---@private
function WidgetMissionSelectItemWidget:initEvent()
	self._allEvent = {}

	self.btnClickButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:callHandler("select_item", self.data.mission_id)
	end

	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_MISSION_SELECT_MISSION, function(missionId)
		self.siSelectedBg:setVisible(missionId == self.data.mission_id)
	end)
end

function WidgetMissionSelectItemWidget:initData(data)
	self.data = data

	local itemConfig = ItemConfig:getCfgByItemAlias(data.ability_alias)
	local qualityBg = Define.ITEM_QUALITY_BG[itemConfig.quality_alias]
	self.siItemQuality:setImage(qualityBg)

	local item_id = itemConfig.item_id
	local abilityCfg = AbilityConfig:getCfgByAbilityId(item_id)
	local dmgBg = Define.DAMAGE_TYPE_ICON_HOLLOW[abilityCfg.damageType]
	self.siSkillTypeIcon:setImage(dmgBg)

	--- 图标
	self.siItemQualityItemIcon:setImage(abilityCfg.unlimited_icon)

	local selected = self:callHandler("selected_item", self.data.mission_id)
	self.siSelectedBg:setVisible(selected or false)
end

---@private
function WidgetMissionSelectItemWidget:onOpen()

end

---@private
function WidgetMissionSelectItemWidget:onDestroy()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WidgetMissionSelectItemWidget:init()
