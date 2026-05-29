---@class WinAbilityBookWndLayout : CEGUILayout
local WinAbilityBookWndLayout = M
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
	SELECT_AWAKE = "select_awake",
	IS_SELECTED = "selected"
}

---@private
function WinAbilityBookWndLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinAbilityBookWndLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticImage
	self.siMainWindowBgActorBg = self.MainWindow.Bg.ActorBg
	---@type CEGUIActorWindow
	self.awMainWindowBgActorWindow = self.MainWindow.Bg.ActorWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg2 = self.MainWindow.Bg2
	---@type CEGUIStaticImage
	self.siMainWindowBg2TitleBg = self.MainWindow.Bg2.TitleBg
	---@type CEGUIStaticText
	self.stMainWindowBg2Title = self.MainWindow.Bg2.Title
	---@type CEGUIDefaultWindow
	self.wMainWindowItemInfo = self.MainWindow.ItemInfo
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
	---@type CEGUIScrollableView
	self.wMainWindowSvItem = self.MainWindow.SvItem
	---@type CEGUIVerticalLayoutContainer
	self.wMainWindowSvItemLvItem = self.MainWindow.SvItem.LvItem
	---@type CEGUIStaticImage
	self.siMainWindowNoItemBg = self.MainWindow.NoItemBg
	---@type CEGUIStaticText
	self.stMainWindowNoItemBgTitle = self.MainWindow.NoItemBg.Title
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
end

---@private
function WinAbilityBookWndLayout:initUI()
	self.stMainWindowBg2Title:setText(Lang:toText("g2069_book_ability_ui_title"))
	self.stMainWindowNoItemBgTitle:setText(Lang:toText("g2069_ui_wake_no_open_tips"))
end

---@private
function WinAbilityBookWndLayout:initEvent()
	self.btnMainWindowCloseButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		UI:closeWindow(self)
	end
end

---@private
function WinAbilityBookWndLayout:onOpen(abilityId)
	self.curAbilityId = abilityId
	self.selectedAwake = 1

	self:initData()
	self:initVirtualUI()

	if self.awakeList and #self.awakeList > 0 then
		self.lvItem:setVirtualBarPosition(0)
		self.lvItem:addVirtualChildList(self.awakeList)
		self.siMainWindowNoItemBg:setVisible(false)

		local abilityId = self.awakeList[1].abilityId
		self.selectedAwake = self.awakeList[1].awake
		self:selectAwake(abilityId, self.selectedAwake, true)
	else
		self.lvItem:clearVirtualChild()
		self.siMainWindowNoItemBg:setVisible(true)
		self:updatePlayerActor(self.curAbilityId, 1)
	end

	self:updateAbilityInfo()
end

function WinAbilityBookWndLayout:initData()
	local abilityId = self.curAbilityId
	self.awakeList = {}

	local config = AbilityAwakeConfig:getCfgByAbilityId(abilityId)
	if config then
		local coinNumList = config.coin_nums
		local itemNumList = config.item_nums
		local awakeAbilityIdList = config.awake_ids

		for i = 1, #awakeAbilityIdList, 1 do
			self.awakeList[#self.awakeList + 1] = { abilityId = awakeAbilityIdList[i], awake = i, coinNum = coinNumList[i], itemNum = itemNumList[i], origin = abilityId }
		end
	end
end

function WinAbilityBookWndLayout:initVirtualUI()
	local this = self
	---@type widget_virtual_vert_list
	self.lvItem = widget_virtual_vert_list:init(
			self.wMainWindowSvItem,
			self.wMainWindowSvItemLvItem,
			function(self, parent)
				---@type WidgetAbilityAwakeItemWidget
				local node = UI:openWidget("UI/game_book/gui/widget_ability_book_item")
				parent:addChild(node:getWindow())
				node:registerCallHandler(CALL_EVENT.IS_SELECTED, this, this.onCallHandler)
				node:registerCallHandler(CALL_EVENT.SELECT_AWAKE, this, this.onCallHandler)
				return node
			end, function(self, node, data)
				node:updateInfo(data)
			end
	)
	self.awMainWindowBgActorWindow:setActorName(Me:getActorName())
end

--- 回调处理
---@param event any
function WinAbilityBookWndLayout:onCallHandler(event, ...)
	if event == CALL_EVENT.IS_SELECTED then
		local abilityId, awake = table.unpack({ ... })
		return awake == self.selectedAwake
	elseif event == CALL_EVENT.SELECT_AWAKE then
		local abilityId, awake = table.unpack({ ... })
		--- 刷新玩家状态
		self:selectAwake(abilityId, awake)
	end
end

--- 刷新信息
function WinAbilityBookWndLayout:updateAbilityInfo()
	local abilityId = self.curAbilityId
	local abilityCfg = AbilityConfig:getCfgByAbilityId(abilityId)
	local damageType = abilityCfg.damageType
	local config = ItemConfig:getCfgByItemId(abilityId)
	local quality = config.quality_alias
	local icon = abilityCfg.unlimited_icon

	local name = abilityCfg.unlimited_name
	local qualityName = Define.ITEM_QUALITY_LANG[quality]
	local qualityBg = Define.ITEM_QUALITY_BG[quality]
	local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality]
	local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
	local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
	local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]

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
function WinAbilityBookWndLayout:selectAwake(abilityId, awake, force)
	if not force and self.selectedAwake == awake then
		return
	end
	self.selectedAwake = awake
	self:updatePlayerActor(abilityId, awake)
	Lib.emitEvent(Event.EVENT_GAME_BOOK_ABILITY_SELECT, abilityId, awake)
end

--- 刷新角色形象
---@param ability Ability
---@param awake any
function WinAbilityBookWndLayout:updatePlayerActor(abilityId, awake)
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
	local isActorPrepared = self.awMainWindowBgActorWindow:isActorPrepared()
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
				self.awMainWindowBgActorWindow:setActorCustomColor(skin)
			else
				if skin == "" or skin == "0" then
					self.awMainWindowBgActorWindow:unloadBodyPart(part)
				else
					self.awMainWindowBgActorWindow:useBodyPart(part, skin)
				end
			end
		end
		self.awMainWindowBgActorWindow:setSkillName(config.idleAction)
	else
		self.actorTimer = LuaTimer:scheduleTicker(function()
			if self.awMainWindowBgActorWindow:isActorPrepared() then
				LuaTimer:cancel(self.actorTimer)
				self.actorTimer = nil
				self:updatePlayerActor(abilityId, awake)
			end
		end, 1)
	end
end

---@private
function WinAbilityBookWndLayout:onDestroy()
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

---@private
function WinAbilityBookWndLayout:onClose()
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

WinAbilityBookWndLayout:init()
