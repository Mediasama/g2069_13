---@class WinAbilityAwakeLayout : CEGUILayout
local WinAbilityAwakeLayout = M
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

local CALL_EVENT = {
	CLOSE_WINDOW = "close",
	ABILITY_AWAKE = "awake",
	SELECT_AWAKE = "select_awake",
	IS_SELECTED = "selected",
	IS_UNLOCK = "unlock",
	IS_AWAKE = "is_awake",
	EQUIP = "equip",
	UNEQUIP = "unequip",
	CAN_EQUIP = "can_equip",
	CAN_UNEQUIP = "can_unequip",
}

---@private
function WinAbilityAwakeLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinAbilityAwakeLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticImage
	self.siMainWindowBg2 = self.MainWindow.Bg2
	---@type CEGUIStaticImage
	self.siMainWindowActorBg = self.MainWindow.ActorBg
	---@type CEGUIActorWindow
	self.awMainWindowActorWindow = self.MainWindow.ActorWindow
	---@type CEGUIDefaultWindow
	self.wMainWindowItemInfo = self.MainWindow.ItemInfo
	---@type CEGUIStaticImage
	self.siMainWindowItemInfoBg = self.MainWindow.ItemInfo.Bg
	---@type CEGUIStaticText
	self.stMainWindowItemInfoTitle = self.MainWindow.ItemInfo.Title
	---@type CEGUIStaticText
	self.stMainWindowItemInfoItemName = self.MainWindow.ItemInfo.ItemName
	---@type CEGUIStaticImage
	self.siMainWindowItemInfoItemQualiltyIcon = self.MainWindow.ItemInfo.ItemQualiltyIcon
	---@type CEGUIStaticImage
	self.siMainWindowItemInfoItemQualiltyIconItemIcon = self.MainWindow.ItemInfo.ItemQualiltyIcon.ItemIcon
	---@type CEGUIStaticText
	self.stMainWindowItemInfoItemQualiltyName = self.MainWindow.ItemInfo.ItemQualiltyName
	---@type CEGUIStaticImage
	self.siMainWindowItemInfoDamageIcon = self.MainWindow.ItemInfo.DamageIcon
	---@type CEGUIStaticText
	self.stMainWindowItemInfoDamageIconDamageName = self.MainWindow.ItemInfo.DamageIcon.DamageName
	---@type CEGUIProgressBar
	self.pbMainWindowItemInfoItemExpBar = self.MainWindow.ItemInfo.ItemExpBar
	---@type CEGUIStaticText
	self.stMainWindowItemInfoItemLevel = self.MainWindow.ItemInfo.ItemLevel
	---@type CEGUIStaticText
	self.stMainWindowItemInfoItemExp = self.MainWindow.ItemInfo.ItemExp
	---@type CEGUIScrollableView
	self.wMainWindowSvItem = self.MainWindow.SvItem
	---@type CEGUIVerticalLayoutContainer
	self.wMainWindowSvItemLvItem = self.MainWindow.SvItem.LvItem
	---@type CEGUIStaticImage
	self.siMainWindowNoItemBg = self.MainWindow.NoItemBg
	---@type CEGUIStaticText
	self.stMainWindowNoItemBgNoItemText = self.MainWindow.NoItemBg.NoItemText
	---@type CEGUIButton
	self.btnMainWindowAwakeButton = self.MainWindow.AwakeButton
	---@type CEGUIButton
	self.btnMainWindowEquipButton = self.MainWindow.EquipButton
	---@type CEGUIButton
	self.btnMainWindowUnequipButton = self.MainWindow.UnequipButton
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
end

---@private
function WinAbilityAwakeLayout:initUI()
	self.stMainWindowItemInfoTitle:setText(Lang:toText("g2069_awakening_title"))
	self.stMainWindowItemInfoItemName:setText(Lang:toText(""))
	self.stMainWindowItemInfoItemQualiltyName:setText(Lang:toText(""))
	self.stMainWindowItemInfoDamageIconDamageName:setText(Lang:toText(""))
	self.stMainWindowItemInfoItemLevel:setText(Lang:toText(""))
	self.stMainWindowItemInfoItemExp:setText(Lang:toText(""))
	self.stMainWindowNoItemBgNoItemText:setText(Lang:toText("g2069_awakening_unopened"))
	self.btnMainWindowAwakeButton:setText(Lang:toText("g2069_awakening_button_awakening"))
	self.btnMainWindowEquipButton:setText(Lang:toText("g2069_awakening_button_equip"))
	self.btnMainWindowUnequipButton:setText(Lang:toText("g2069_awakening_button_unequip"))
end

---@private
function WinAbilityAwakeLayout:initEvent()
	self.btnMainWindowAwakeButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.ABILITY_AWAKE)
	end
	self.btnMainWindowCloseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.CLOSE_WINDOW)
	end
	self.btnMainWindowEquipButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.EQUIP)
	end
	self.btnMainWindowUnequipButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.UNEQUIP)
	end
end

---@private
function WinAbilityAwakeLayout:onOpen()
	self:initData()
	self:initVirtualUI()
	self:subscribeEvents()
	
	---@type Ability
	local ability = AbilitySystem:getAbility(Me)
	self:updateAbilityInfo(ability)

	if self.awakeList and #self.awakeList > 0 then
		self.lvItem:addVirtualChildList(self.awakeList)
		local data = self:getDataByAwake(self.selectedAwake)
		self:selectAwake(data.abilityId, data.awake, true)
		self.siMainWindowNoItemBg:setVisible(false)
	else
		--- 隐藏按钮
		self:updatePlayerActor(ability:getItemId(), 0)
		self:updateAwakeBtnState()
		self.siMainWindowNoItemBg:setVisible(true)
	end
end

function WinAbilityAwakeLayout:initData()
	self.onWait = false
	self.selectedAwake = 0
	---@type Ability
	local ability = AbilitySystem:getAbility(Me)
	self.equippedId = ability:getId()
	self.awakeList = {}
	local origin = ability:getItemId()
	if AbilityAwakeConfig:canAwake(origin) then
		local config = AbilityAwakeConfig:getCfgByAbilityId(origin)
		local awakeAbilityIdList = config.awake_ids
		self.selectedAwake = math.min(ability:getAwake() + 1, config.max_awake)
		for i = 1, #awakeAbilityIdList, 1 do
			self.awakeList[#self.awakeList + 1] = { 
				abilityId = awakeAbilityIdList[i],
				origin = origin,
				awake = i,
			}
		end
	end
end

function WinAbilityAwakeLayout:initVirtualUI()
	local this = self
	---@type widget_virtual_vert_list
	self.lvItem = widget_virtual_vert_list:init(
		self.wMainWindowSvItem,
		self.wMainWindowSvItemLvItem,
		function(self, parent)
			---@type WidgetAbilityAwakeItemWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_ability_awake_item")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.IS_SELECTED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_UNLOCK, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_AWAKE, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.SELECT_AWAKE, this, this.onCallHandler)
			return node
		end, function(self, node, data)
			node:updateInfo(data)
		end
	)
	self.awMainWindowActorWindow:setActorName(Me:getActorName())
end

function WinAbilityAwakeLayout:getDataByAwake(awake)
	for _, data in pairs(self.awakeList) do
		if data.awake == awake then
			return data
		end
	end
	return nil
end

function WinAbilityAwakeLayout:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_AWAKE, function(success, player, ability)
		if success and ability:getId() == self.equippedId then
			---@type Ability
			local ability = AbilitySystem:getAbility(Me)
			self:updateAbilityInfo(ability)
			local awake = math.min(#self.awakeList, ability:getAwake() + 1)
			local data = self:getDataByAwake(awake)
			if data then
				self:selectAwake(data.abilityId, data.awake, true)
			else
				self:updateAwakeBtnState()
			end
		end
		self.onWait = false
	end)

	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SWITCH_ABILITY_SKIN, function(player, success)
		if success then
			self:updateAwakeBtnState()
		end
	end)
end

--- 刷新按钮显示
---@param ability any
function WinAbilityAwakeLayout:updateAwakeBtnState()
	local showAwake = false
	---@type Ability
	local ability = AbilitySystem:getAbility(Me)
	local canAwake = AbilityAwakeConfig:canAwake(ability:getItemId())
	if canAwake then
		local origin = ability:getItemId()
		local awake = ability:getAwake()
		local config = AbilityAwakeConfig:getCfgByAbilityId(origin)
		showAwake = awake < config.max_awake and (awake + 1 == self.selectedAwake)
	end
	self.btnMainWindowAwakeButton:setVisible(showAwake)
	if showAwake or not canAwake then
		self.btnMainWindowEquipButton:setVisible(false)
		self.btnMainWindowUnequipButton:setVisible(false)
	else
		local canEquip = self:onCallHandler(CALL_EVENT.CAN_EQUIP)
		local canUnequip = self:onCallHandler(CALL_EVENT.CAN_UNEQUIP)
		self.btnMainWindowEquipButton:setVisible(canEquip and not canUnequip)
		self.btnMainWindowUnequipButton:setVisible(canUnequip and not canEquip)
	end
end

--- 判断是否打断
---@param event any
function WinAbilityAwakeLayout:checkInterupt(event)
	if event == CALL_EVENT.ABILITY_AWAKE
		or event == CALL_EVENT.CLOSE_WINDOW
		or event == CALL_EVENT.EQUIP
		or event == CALL_EVENT.UNEQUIP
	then
		return self.onWait
	end
	return false
end

--- 音效
---@param event any
function WinAbilityAwakeLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WINDOW then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event ~= CALL_EVENT.IS_SELECTED and event ~= CALL_EVENT.IS_UNLOCK and event ~= CALL_EVENT.IS_AWAKE then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

--- 回调处理
---@param event any
function WinAbilityAwakeLayout:onCallHandler(event, ...)
	self:checkSound(event)
	if self:checkInterupt(event) then
		return
	end
	if event == CALL_EVENT.CLOSE_WINDOW then
		UI:closeWindow(self)
	elseif event == CALL_EVENT.IS_SELECTED then
		local abilityId, awake = table.unpack({ ... })
		return awake == self.selectedAwake
	elseif event == CALL_EVENT.IS_UNLOCK then
		local abilityId, awake = table.unpack({ ... })
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		local curAwake = ability:getAwake()
		return curAwake + 1 >= awake
	elseif event == CALL_EVENT.IS_AWAKE then
		local abilityId, awake = table.unpack({ ... })
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		local curAwake = ability:getAwake()
		return curAwake >= awake
	elseif event == CALL_EVENT.ABILITY_AWAKE then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		local this = self
		--- 打开界面
		UI:openWindow("UI/game_role_common/gui/win_awake_confirm", nil, nil, {
			ability = ability,
			confirmCallback = function()
				this.onWait = true
			end,
		})
	elseif event == CALL_EVENT.SELECT_AWAKE then
		local abilityId, awake = table.unpack({ ... })
		--- 刷新玩家状态
		self:selectAwake(abilityId, awake)
	elseif event == CALL_EVENT.EQUIP then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if ability:getAwake() < self.selectedAwake then
			return
		end
		local data = self:getDataByAwake(self.selectedAwake)
		if data then
			local abilityId = AbilitySystem:getAbilitySkin(Me)
			if abilityId == data.abilityId then
				return
			end
			local this = self
			this.onWait = true
			Me:sendPacket({
				pid = "C2SSwitchAbilitySkin",
				abilityId = data.abilityId,
				awake = self.selectedAwake
			}, function()
				this.onWait = false
			end)
		end
	elseif event == CALL_EVENT.UNEQUIP then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if ability:getAwake() < self.selectedAwake then
			return
		end
		local data = self:getDataByAwake(self.selectedAwake)
		if data then
			local abilityId = AbilitySystem:getAbilitySkin(Me)
			if abilityId ~= data.abilityId then
				return
			end
			local this = self
			this.onWait = true
			Me:sendPacket({
				pid = "C2SSwitchAbilitySkin",
				awake = self.selectedAwake,
				unequip = 1,
			}, function()
				this.onWait = false
			end)
		end
	elseif event == CALL_EVENT.CAN_EQUIP then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if ability:getAwake() >= self.selectedAwake then
			local data = self:getDataByAwake(self.selectedAwake)
			local abilityId = AbilitySystem:getAbilitySkin(Me)
			if data and data.abilityId ~= abilityId then
				return true
			end
		end
		return false
	elseif event == CALL_EVENT.CAN_UNEQUIP then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if ability:getAwake() >= self.selectedAwake then
			local data = self:getDataByAwake(self.selectedAwake)
			local abilityId = AbilitySystem:getAbilitySkin(Me)
			if data and data.abilityId == abilityId then
				return true
			end
		end
		return false
	end
end

--- 刷新信息
---@param ability Ability
function WinAbilityAwakeLayout:updateAbilityInfo(ability)
	local abilityId = ability:getAwakeAbilityId()
	local level = ability:getLevel()
	local exp = ability:getExp()

	local damageType = AbilityConfig:getCfgByAbilityId(abilityId).damageType
	local config = ItemConfig:getCfgByItemId(abilityId)
	local quality = config.quality_alias
	local icon = config.icon
	if ability:isUnlimited() then
		local uicon = AbilityConfig:getCfgByAbilityId(abilityId).unlimited_icon
        if uicon and uicon ~= "" then
            icon = uicon
        end
	end
	local name = config.name
	local qualityName = Define.ITEM_QUALITY_LANG[quality]
	local qualityBg = Define.ITEM_QUALITY_BG[quality]
	local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality]
	local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
	local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
	local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]

	--- 等级信息
	local maxLevel = AbilityConfig:getMaxLevel(abilityId)
	self.stMainWindowItemInfoItemLevel:setText("LV." .. level)
	if level < maxLevel then
		local upgradePrice = AbilityLevelConfig:getCfgByLevel(level).upgradePrice
		self.stMainWindowItemInfoItemExp:setText(tostring(exp) .. "/" .. tostring(upgradePrice))
		local pro = math.clamp(exp / upgradePrice, 0, 1)
		self.pbMainWindowItemInfoItemExpBar:setProgress(pro)
	else
		self.stMainWindowItemInfoItemExp:setText("")
		self.pbMainWindowItemInfoItemExpBar:setProgress(1)
	end

	self.siMainWindowItemInfoDamageIcon:setImage(dmgBg)
	self.stMainWindowItemInfoDamageIconDamageName:setText(Lang:toText(dmgName))
	if dmgColor then
		self.stMainWindowItemInfoDamageIconDamageName:setProperty("TextColours", dmgColor)
	end

	self.siMainWindowItemInfoItemQualiltyIcon:setImage(qualityBg)
	self.stMainWindowItemInfoItemQualiltyName:setText(Lang:toText(qualityName))
	if qualityColor then
		self.stMainWindowItemInfoItemQualiltyName:setProperty("TextColours", qualityColor)
	end

	self.siMainWindowItemInfoItemQualiltyIconItemIcon:setImage(icon)
	self.stMainWindowItemInfoItemName:setText(Lang:toText(name))
end

--- 选择觉醒相关
---@param abilityId number
---@param awake number
---@param force boolean
function WinAbilityAwakeLayout:selectAwake(abilityId, awake, force)
	if not force and self.selectedAwake == awake then
		return
	end
	self.selectedAwake = awake
	self:updatePlayerActor(abilityId, awake)
	self:updateAwakeBtnState()
	Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY_AWAKE, abilityId, awake)
end

--- 刷新角色形象
---@param ability Ability
---@param awake any
function WinAbilityAwakeLayout:updatePlayerActor(abilityId, awake)
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
	local isActorPrepared = self.awMainWindowActorWindow:isActorPrepared()
	if isActorPrepared then
		local config = AbilityConfig:getCfgByAbilityId(abilityId)
		local parts = config.parts
		local default = ActorManager:Instance():getActorDefaultBodyPart(Me:getActorName()) or {}
		local skins = Lib.copy(default)
		if parts then
			for part, skin in pairs(parts) do
				skins[part] = skin
			end
		end
		local conflictParts = config.conflictParts
		if conflictParts then
			for _, part in pairs(conflictParts) do
				skins[part] = "0"
			end
		end

		local skin_color = config.skin_color
		if skin_color then
			skins["skin_color"] = Lib.copy(skin_color)
		else
			skins["skin_color"] = Lib.copy(Define.DEFAULT_SKIN_COLOR)
		end

		local origin = AbilityAwakeConfig:getOriginAbilityId(abilityId)
		if origin then
			local awake_effect = AbilityAwakeConfig:getCfgByAbilityId(origin).awake_effect
			if awake_effect and #awake_effect > 0 then
				if AbilityAwakeConfig:isMaxAwakeAbility(abilityId) then
					skins[awake_effect[1]] = awake_effect[2]
				else
					skins[awake_effect[1]] = "0"
				end
			end
		end

		--- 设置皮肤
		for part, skin in pairs(skins) do
			if part == "skin_color" then
				self.awMainWindowActorWindow:setActorCustomColor(skin)
			else
				if skin == "" or skin == "0" then
					self.awMainWindowActorWindow:unloadBodyPart(part)
				else
					self.awMainWindowActorWindow:useBodyPart(part, skin)
				end
			end
		end
		
		self.awMainWindowActorWindow:setSkillName(config.idleAction)
	else
		self.actorTimer = LuaTimer:scheduleTicker(function()
			if self.awMainWindowActorWindow:isActorPrepared() then
				LuaTimer:cancel(self.actorTimer)
				self.actorTimer = nil
				self:updatePlayerActor(abilityId, awake)
			end
		end, 1)
	end
end

---@private
function WinAbilityAwakeLayout:onDestroy()
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

---@private
function WinAbilityAwakeLayout:onClose()
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

WinAbilityAwakeLayout:init()
