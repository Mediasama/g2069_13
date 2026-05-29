---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@class WidgetAbilityItemWidget : CEGUILayout
local WidgetAbilityItemWidget = M

---@private
function WidgetAbilityItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetAbilityItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemIcon = self.ItemIcon
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
	---@type CEGUIStaticImage
	self.siNoneBg = self.NoneBg
    ---@type CEGUIStaticImage
    self.siSkillTypeIcon = self.SkillTypeIcon
end

---@private
function WidgetAbilityItemWidget:initUI()
	-- self.stItemLevel:setText(Lang:toText(""))
end

---@private
function WidgetAbilityItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function()
        if not self.aid or not self.aidx then
            return
        end
        --- 红点
        self.siRedDot:setVisible(false)
        self:callHandler("select", self.aid, self.aidx)
	end
end

---@private
function WidgetAbilityItemWidget:onOpen()
    self:initData()
    self:subscribeEvents()
end

function WidgetAbilityItemWidget:initData()
    self.aid = nil
    self.aidx = nil
    self.regFuncs = {}
    self.events = {}
end

--- 注册回调
---@param context any
---@param func any
function WidgetAbilityItemWidget:registerCallHandler(key, context, func)
    self.regFuncs[key] = { this = context, func = func }
end

--- 回调
function WidgetAbilityItemWidget:callHandler(key, ...)
    local data = self.regFuncs[key]
    if data then
        local this = data.this
        local func = data.func
        return func(this, key, ...)
    end
end

--- 刷新
---@param ability Ability
function WidgetAbilityItemWidget:updateInfo(ability, index)
    self.aidx = index
    if ability then
        self.aid = ability:getId()
        local level = ability:getLevel()
        local itemConfig = ItemConfig:getCfgByItemId(ability:getItemId())
        self.stItemLevel:setText("LV." .. level)
        self.siItemIcon:setImage(itemConfig.icon)

        local abilityConfig = AbilityConfig:getCfgByAbilityId(ability:getItemId())

        local dmgBg = Define.DAMAGE_TYPE_ICON_HOLLOW[abilityConfig.damageType]
        self.siSkillTypeIcon:setImage(dmgBg)

        --- 品质
        local qualityBg = Define.ITEM_QUALITY_BG[itemConfig.quality_alias]
        self.siItemQuality:setImage(qualityBg)

        --- 是否已装备
        local equipped = self:callHandler("equipped", self.aid)
        local selected = self:callHandler("selected", self.aid)
        local inspected = self:callHandler("inspected", self.aidx)
        
        self.siEquippedStatus:setVisible(equipped or false)
        self.siSelectedStatus:setVisible(selected or false)
        --- 红点
        self.siRedDot:setVisible(not equipped and not selected and not inspected)
        
        self.stItemLevel:setVisible(true)
        self.btnClickButton:setVisible(true)
        self.siItemQuality:setVisible(true)
        self.siItemIcon:setVisible(true)
        self.siNoneBg:setVisible(false)
        self.siSkillTypeIcon:setVisible(true)
    else
        self.aid = nil
        self.siEquippedStatus:setVisible(false)
        self.siSelectedStatus:setVisible(false)
        self.siRedDot:setVisible(false)
        self.stItemLevel:setVisible(false)
        self.btnClickButton:setVisible(false)
        self.siItemQuality:setVisible(false)
        self.siItemIcon:setVisible(false)
        self.siSkillTypeIcon:setVisible(false)
        self.siNoneBg:setVisible(true)
    end
end

function WidgetAbilityItemWidget:subscribeEvents()
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
        if not self.aid or not success then
            return
        end
        self.siEquippedStatus:setVisible(self.aid == ability:getId())
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY, function(aid)
        if not self.aid then
            return
        end
        self.siSelectedStatus:setVisible(aid == self.aid)
    end)
    
end

function WidgetAbilityItemWidget:unsubscribeEvents()
    if self.events then
		for _, func in pairs(self.events) do
			func()
		end
		self.events = nil
	end
end

---@private
function WidgetAbilityItemWidget:onDestroy()
    self:unsubscribeEvents()
    self.regFuncs = nil
end

WidgetAbilityItemWidget:init()
