---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@class WinSimpleAbilityBagLayout : CEGUILayout
local WinSimpleAbilityBagLayout = M

local CALL_EVENT = {
	CLOSE_WINDOW = "close",
	EQUIP = "equip",
	IS_EQUIPPED = "equipped",
	IS_SELECTED = "selected",
	SELECT = "select",
	IS_INSPECTED = "inspected",
}

---@private
function WinSimpleAbilityBagLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinSimpleAbilityBagLayout:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wWinBody = self.WinBody
	---@type CEGUIStaticImage
	self.siWinBodyBg = self.WinBody.Bg
	---@type CEGUIStaticText
	self.stWinBodyTitle = self.WinBody.Title
	---@type CEGUIScrollableView
	self.wWinBodySvItem = self.WinBody.SvItem
	---@type CEGUIGridView
	self.gvWinBodySvItemGvItem = self.WinBody.SvItem.GvItem
	---@type CEGUIButton
	self.btnWinBodyEquipButton = self.WinBody.EquipButton
	---@type CEGUIButton
	self.btnWinBodyCloseButton = self.WinBody.CloseButton
end

---@private
function WinSimpleAbilityBagLayout:initUI()
	self.stWinBodyTitle:setText(Lang:toText("g2069_choose_ability_switch"))
	self.btnWinBodyEquipButton:setVisible(false)
	self.btnWinBodyEquipButton:setText(Lang:toText("g2069_equip_button"))
end

---@private
function WinSimpleAbilityBagLayout:initEvent()
	self.btnWinBodyEquipButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.EQUIP)
	end
	self.btnWinBodyCloseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.CLOSE_WINDOW)
	end
end

---@private
function WinSimpleAbilityBagLayout:onOpen()
	self:initData()
	self:initVirtualUI()
	self:subscribeEvents()
	self:startPushTimer()
	UI:closeWindow("UI/player_action/gui/win_player_action")
end

function WinSimpleAbilityBagLayout:initData()
	self.onWait = false
	self.abilityList = {}
	self.pushTimer = nil
	self.inspectIds = nil
	---@type Ability
	self.equippedAbility = AbilitySystem:getAbility(Me)
	---@type Ability
	self.selectedAbility = nil
	--- 显示永久能力
	local slots = InventorySystem:getAllSlots(Me, Define.INVENTORY_TYPE.ABILITY)
	if slots then
		local index = 0
		---@type number, Slot
		for _, slot in pairs(slots) do
			---@type Ability
			local ability = slot:getItem()
			if ability and ability:isUnlimited() then
				index = index + 1
				self.abilityList[#self.abilityList + 1] = { ability = ability, index = index }
			end
		end
	end

	local equippedIndex = nil
	if #self.abilityList > 1 then
		table.sort(self.abilityList, function(e1, e2)
			---@type Ability
			local ability1 = e1.ability
			---@type Ability
			local ability2 = e2.ability
			return ability1:getItemId() < ability2:getItemId()
		end)
		--- 重现排序
		for index, data in pairs(self.abilityList) do
			data.index = index
			if not equippedIndex and self.equippedAbility and self.equippedAbility:getId() == data.ability:getId() then
				equippedIndex = index
			end
		end
	end

	if equippedIndex then
		self.selectedAbility = self.abilityList[equippedIndex].ability
	else
		self.selectedAbility = self.abilityList[1] and self.abilityList[1].ability or nil
	end

	if self.selectedAbility then
		self:inspectAbility(self.selectedAbility)
	end
end

function WinSimpleAbilityBagLayout:initVirtualUI()
	local this = self
	self.gvItem = widget_virtual_grid:init(
		self.wWinBodySvItem,
		self.gvWinBodySvItemGvItem,
		function(self, parent)
			---@type WidgetAbilityItemWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_simple_ability_item")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.SELECT, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_EQUIPPED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_SELECTED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_INSPECTED, this, this.onCallHandler)
			return node
		end,
		---@type any, WidgetAbilityItemWidget, table
		function(self, node, data)
			---@type Ability
			local ability = data.ability
			local index = data.index
			node:updateInfo(ability, index)
		end,
		3
	)

	if #self.abilityList > 0 then
		self.gvItem:addVirtualChildList(self.abilityList)
	end

	if not self.selectedAbility or (self.equippedAbility and self.selectedAbility:getId() == self.equippedAbility:getId()) then
		self.btnWinBodyEquipButton:setVisible(false)
	else
		self.btnWinBodyEquipButton:setVisible(true)
	end
end

--- 判断是否打断
---@param event any
function WinSimpleAbilityBagLayout:checkInterupt(event)
	if event == CALL_EVENT.EQUIP 
		or event == CALL_EVENT.CLOSE_WINDOW
	then
		return self.onWait
	end
	return false
end

--- 音效
---@param event any
function WinSimpleAbilityBagLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WINDOW then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event == CALL_EVENT.EQUIP 
        or event == CALL_EVENT.SELECT
    then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

--- 回调处理
---@param event any
function WinSimpleAbilityBagLayout:onCallHandler(event, ...)
	self:checkSound(event)
	if self:checkInterupt(event) then
		return
	end
	if event == CALL_EVENT.CLOSE_WINDOW then
		UI:closeWindow(self)
	elseif event == CALL_EVENT.EQUIP then
		if not self.selectedAbility then
			return
		elseif self.equippedAbility and self.equippedAbility:getId() == self.selectedAbility:getId() then
			Me:showGameTopTips(Lang:toText("g2069_ability_equipped"))
			return
		end

		local this = self
		local equip = function()
			this.onWait = true
			Me:sendPacket({
				pid = "C2SSwitchAbility",
				aid = this.selectedAbility:getId(),
			}, function()
				this.onWait = false
			end)
		end

		if self.equippedAbility and not self.equippedAbility:isUnlimited() then
			local name1 = self.equippedAbility:getName()
			local name2 = self.selectedAbility:getName()
			--- 二次确认
			Me:showConfirm(
				"",
				Lang:toText({ "g2069_equip_ability_confirm", name1, name2 }),
				equip
			)
			return
		end
		equip()
		
	elseif event == CALL_EVENT.IS_EQUIPPED then
		if self.equippedAbility then
			---@type Ability
			local ability = table.unpack({ ... })
			return self.equippedAbility:getId() == ability:getId()
		end
	elseif event == CALL_EVENT.IS_SELECTED then
		if self.selectedAbility then
			---@type Ability
			local ability = table.unpack({ ... })
			return self.selectedAbility:getId() == ability:getId()
		end
	elseif event == CALL_EVENT.IS_INSPECTED then
		---@type Ability
		local ability = table.unpack({ ... })
		return ability:isUnlimitedInspected()
	elseif event == CALL_EVENT.SELECT then
		---@type Ability
		local ability = table.unpack({ ... })
		if self.selectedAbility and self.selectedAbility:getId() == ability:getId() then
			return
		end
		self:inspectAbility(ability)
        self.selectedAbility = ability
		if self.equippedAbility and self.equippedAbility:getId() == ability:getId() then
			self.btnWinBodyEquipButton:setVisible(false)
		else
			self.btnWinBodyEquipButton:setVisible(true)
		end
		Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY, ability:getId())
	end
end

function WinSimpleAbilityBagLayout:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
        if success then
            self.equippedAbility = ability
			if self.selectedAbility and self.selectedAbility:getId() == ability:getId() then
				self.btnWinBodyEquipButton:setVisible(false)
			end
        end
    end)
end

--- 检视能力
---@param ability any
function WinSimpleAbilityBagLayout:inspectAbility(ability)
	if not ability:isUnlimitedInspected() then
		ability:setUnlimitedInspected(1)
		self.inspectFlag = true
		self.inspectIds = self.inspectIds or {}
		self.inspectIds[#self.inspectIds + 1] = ability:getId()
		self:pushInspectIds()
	end
end

--- 推送检视状态
function WinSimpleAbilityBagLayout:pushInspectIds(force)
	if not self.inspectIds then
		return
	end
	local len = #self.inspectIds
	if (force and len > 0) or len >= 10 then
		Me:sendPacket({
			pid = "C2SInspectAbility",
			ids = self.inspectIds
		})
		self.inspectIds = nil
	end
end

function WinSimpleAbilityBagLayout:stopPushTimer()
	if self.pushTimer then
		LuaTimer:cancel(self.pushTimer)
		self.pushTimer = nil
	end
end

function WinSimpleAbilityBagLayout:startPushTimer()
	if not self.pushTimer then
		self.pushTimer = LuaTimer:scheduleTicker(function()
			self:pushInspectIds(true)
		end, 20 * 5)
	end
end

---@private
function WinSimpleAbilityBagLayout:onDestroy()

end

---@private
function WinSimpleAbilityBagLayout:onClose()
	self:stopPushTimer()
	self:pushInspectIds(true)
	if self.inspectFlag then
		Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_INSPECT_ABILITY)
	end
end

WinSimpleAbilityBagLayout:init()
