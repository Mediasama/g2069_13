---@class WidgetSimpleAbilityItemWidget : CEGUILayout
local WidgetSimpleAbilityItemWidget = M

---@private
function WidgetSimpleAbilityItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetSimpleAbilityItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemIcon = self.ItemIcon
	---@type CEGUIStaticImage
	self.siSkillTypeIcon = self.SkillTypeIcon
	---@type CEGUIStaticText
	self.stItemLevel = self.ItemLevel
	---@type CEGUIStaticImage
	self.siEquippedStatus = self.EquippedStatus
	---@type CEGUIStaticImage
	self.siSelectedStatus = self.SelectedStatus
	---@type CEGUIStaticImage
	self.siRedDot = self.RedDot
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetSimpleAbilityItemWidget:initUI()
end

---@private
function WidgetSimpleAbilityItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function()
		if not self.ability then
			return
		end
		self:callHandler("select", self.ability)
	end
end

---@private
function WidgetSimpleAbilityItemWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetSimpleAbilityItemWidget:initData()
	self.ability = nil
    self.callHandlers = {}
end

function WidgetSimpleAbilityItemWidget:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
        if not self.ability or not success then
            return
        end
        self.siEquippedStatus:setVisible(self.ability:getId() == ability:getId())
    end)

    self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY, function(aid)
        if not self.ability then
            return
        end
		local selected = aid == self.ability:getId()
        self.siSelectedStatus:setVisible(selected)
		if selected then
			self.siRedDot:setVisible(false)
		end
    end)
    
end

--- 注册回调
---@param context any
---@param func any
function WidgetSimpleAbilityItemWidget:registerCallHandler(key, context, func)
    self.callHandlers[key] = { this = context, func = func }
end

--- 回调
function WidgetSimpleAbilityItemWidget:callHandler(key, ...)
    local data = self.callHandlers[key]
    if data then
        local this = data.this
        local func = data.func
        return func(this, key, ...)
    end
end

--- 刷新信息
---@param ability Ability
function WidgetSimpleAbilityItemWidget:updateInfo(ability)
	self.ability = ability

	local level = ability:getLevel()
	local icon = ability:getIcon()
	local damageType = ability:getDamageType()
	local dmgBg = Define.DAMAGE_TYPE_ICON_HOLLOW[damageType]
	local quality = ability:getQuality()
	--- 品质
	local qualityBg = Define.ITEM_QUALITY_BG[quality]
	--- 是否已装备
	local equipped = self:callHandler("equipped", ability)
	local selected = self:callHandler("selected", ability)
	local inspected = self:callHandler("inspected", ability)

	self.stItemLevel:setText("LV." .. level)
	self.siItemIcon:setImage(icon)
	self.siSkillTypeIcon:setImage(dmgBg)
	self.siItemQuality:setImage(qualityBg)
	
	self.siEquippedStatus:setVisible(equipped or false)
	self.siSelectedStatus:setVisible(selected or false)
	--- 红点
	self.siRedDot:setVisible(not equipped and not selected and not inspected)
end

---@private
function WidgetSimpleAbilityItemWidget:onDestroy()

end

WidgetSimpleAbilityItemWidget:init()
