---@class WinAbilityBagLayout : CEGUILayout
local WinAbilityBagLayout = M

---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

local SHOW_ITEM_NUM = 25

local CALL_EVENT = {
	CLOSE_WINDOW = "close",
	EQUIP = "equip",
	DROP = "drop",
	SELECT = "select",
	IS_EQUIPPED = "equipped",
	IS_SELECTED = "selected",
	INSPECT_ABILITY = "inspect",
	IS_INSPECTED = "inspected",
	UNEQUIP = "unequip",
}

---@private
function WinAbilityBagLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.WinBody
end

---@private
function WinAbilityBagLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wWinBody = self.WinBody
	---@type CEGUIStaticImage
	self.siWinBodyBg = self.WinBody.Bg
	---@type CEGUIScrollableView
	self.wWinBodySvItem = self.WinBody.SvItem
	---@type CEGUIGridView
	self.gvWinBodySvItemGvItem = self.WinBody.SvItem.GvItem
	---@type CEGUIStaticImage
	self.siWinBodyNoItemBg = self.WinBody.NoItemBg
	---@type CEGUIStaticText
	self.stWinBodyNoItemBgTitle = self.WinBody.NoItemBg.Title
	---@type CEGUIDefaultWindow
	self.wWinBodyItemInfo = self.WinBody.ItemInfo
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoBg = self.WinBody.ItemInfo.Bg
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemName = self.WinBody.ItemInfo.ItemName
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoItemQualiltyIcon = self.WinBody.ItemInfo.ItemQualiltyIcon
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoItemQualiltyIconItemIcon = self.WinBody.ItemInfo.ItemQualiltyIcon.ItemIcon
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemQualiltyName = self.WinBody.ItemInfo.ItemQualiltyName
	---@type CEGUIProgressBar
	self.pbWinBodyItemInfoItemExpBar = self.WinBody.ItemInfo.ItemExpBar
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemLevel = self.WinBody.ItemInfo.ItemLevel
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemExp = self.WinBody.ItemInfo.ItemExp
	---@type CEGUIScrollableView
	self.wWinBodyItemInfoSvSkill = self.WinBody.ItemInfo.SvSkill
	---@type CEGUIVerticalLayoutContainer
	self.wWinBodyItemInfoSvSkillLvSkill = self.WinBody.ItemInfo.SvSkill.LvSkill
	---@type CEGUIButton
	self.btnWinBodyItemInfoEquipButton = self.WinBody.ItemInfo.EquipButton
	---@type CEGUIButton
	self.btnWinBodyItemInfoUnequipButton = self.WinBody.ItemInfo.UnequipButton
	---@type CEGUIButton
	self.btnWinBodyItemInfoDropButton = self.WinBody.ItemInfo.DropButton
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoDamageIcon = self.WinBody.ItemInfo.DamageIcon
	---@type CEGUIStaticText
	self.stWinBodyItemInfoDamageName = self.WinBody.ItemInfo.DamageName
	---@type CEGUIButton
	self.btnWinBodyCloseButton = self.WinBody.CloseButton
end

---@private
function WinAbilityBagLayout:initUI()
	-- self.stWinBodyItemInfoItemName:setText(Lang:toText(""))
	-- self.stWinBodyItemInfoItemQualiltyName:setText(Lang:toText(""))
	-- self.stWinBodyItemInfoItemLevel:setText(Lang:toText(""))
	-- self.stWinBodyItemInfoItemExp:setText(Lang:toText(""))
	self.stWinBodyNoItemBgTitle:setText(Lang:toText("g2069_ability_empty_tips"))
	self.btnWinBodyItemInfoEquipButton:setText(Lang:toText("g2069_ability_equip"))
	self.btnWinBodyItemInfoDropButton:setText(Lang:toText("g2069_ability_drop"))
	self.btnWinBodyItemInfoUnequipButton:setText(Lang:toText("g2069_ability_unequip"))
end

---@private
function WinAbilityBagLayout:initEvent()
	self.btnWinBodyItemInfoEquipButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.EQUIP)
	end
	self.btnWinBodyItemInfoDropButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.DROP)
	end
	self.btnWinBodyCloseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.CLOSE_WINDOW)
	end

	self.btnWinBodyItemInfoUnequipButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.UNEQUIP)
	end
end

---@private
function WinAbilityBagLayout:onOpen()
	self:initData()
	self:initAbilityUI()
	self:updateAbilityInfo(self:getSelectedAbility())
	self:subscribeEvents()
	self:startPushTimer()
end

function WinAbilityBagLayout:initData()
	self.onWait = false
	--- 检视id
	self.inspectIds = nil
	--- 检视标记
	self.inspectFlag = nil
	--- 推送timer
	self.pushTimer = nil
	--- 当前装备中能力
    ---@type Ability
    local equippedAbility = AbilitySystem:getAbility(Me)
	if equippedAbility then
		self.equippedId = equippedAbility:getId()
	end
	--- 当前选中索引
	self.selectedIndex = 1
    --- 所有能力数据
    self.abilities = {}
	--- 所有技能数据
	self.skills = {}
	--- 能力背包
    local slots = InventorySystem:getAllSlots(Me, Define.INVENTORY_TYPE.ABILITY)
    if slots then
		local index = 0
        ---@type number, Slot
        for slotIndex, slot in pairs(slots) do
			index = index + 1
            ---@type Ability
            local ability = slot:getItem()
            if ability and ability:getItemAlias() ~= Define.ITEM_ALIAS.DEFAULT_ABILITY and slot:getAmount() > 0 then
                self.abilities[#self.abilities + 1] = { ability = ability, slotIndex = slotIndex, index = index }
            end
        end
    end

    --- 获取上一次装备能力
    local previous = AbilitySystem:getPreviousId(Me)

	--- 排序
    if #self.abilities > 1 then
		local equippedId = self.equippedId
        table.sort(self.abilities, function(e1, e2)
            local id1 = e1.ability:getId()
            local id2 = e2.ability:getId()
            --- 装备中优先级最高
            if id1 == equippedId then
                return true
            elseif id2 == equippedId then
                return false
            end
            --- 上一次装备能力次之
            if previous then
                if id1 == previous then
                    return true
                elseif id2 == previous then
                    return false
                end
            end
            --- 最后是获得时间
            return e1.ability:getTime() < e2.ability:getTime()
        end)

		for index, data in pairs(self.abilities) do
			data.index = index
		end
    end

	if #self.abilities < SHOW_ITEM_NUM then
		local startIndex = #self.abilities + 1
		for i = startIndex, SHOW_ITEM_NUM, 1 do
			self.abilities[#self.abilities + 1] = { index = i }
		end
	end

	--- 处理选中能力
	---@type Ability
	local selectedAbility = self:getSelectedAbility()
	if selectedAbility then
		self:inspectAbility(selectedAbility)
	end
end

--- 获取数据
---@return Ability
function WinAbilityBagLayout:getSelectedAbility()
	local data = self.abilities[self.selectedIndex]
	if data then
		return data.ability
	end
	return nil
end

function WinAbilityBagLayout:initAbilityUI()
	local this = self
	---@type widget_virtual_grid
	self.gvAbility = widget_virtual_grid:init(
		self.wWinBodySvItem, 
		self.gvWinBodySvItemGvItem,
		---@type any, CEGUIWindow
		function(self, parent)
			---@type WidgetAbilityItemWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_ability_item")
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
		5
	)
	self.gvAbility:addVirtualChildList(self.abilities)

	---@type widget_virtual_vert_list
	self.lvSkill = widget_virtual_vert_list:init(
		self.wWinBodyItemInfoSvSkill, 
		self.wWinBodyItemInfoSvSkillLvSkill,
		---@type any, CEGUIWindow
		function(self, parent)
			---@type WidgetAbilitySkillWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_ability_skill")
			parent:addChild(node:getWindow())
			return node
		end,
		---@type any, WidgetAbilityItemWidget, table
		function(self, node, data)
			---@type Ability
			local level = data.level
			local unlockLevel = data.unlock_level
			local skillId = data.skill_id
			local index = data.index
			node:updateInfo(level, unlockLevel, skillId, index)
		end
	)

end

--- 刷新能力信息
---@param ability Ability
function WinAbilityBagLayout:updateAbilityInfo(ability)
	if not ability then
		self.wWinBodyItemInfo:setVisible(false)
		self.siWinBodyNoItemBg:setVisible(true)
		return
	end
	self.siWinBodyNoItemBg:setVisible(false)
	self.wWinBodyItemInfo:setVisible(true)
	local id = ability:getId()
	local abilityId = ability:getItemId()
	local level = ability:getLevel()
	local exp = ability:getExp()
	local askills = self.skills[id]

	if not askills then
		askills = AbilityConfig:getActiveSkillList(ability:getItemId())
		for index, data in pairs(askills) do
			data.level = level
			data.index = index
		end
		self.skills[id] = askills
	end

	local abilityConfig = AbilityConfig:getCfgByAbilityId(ability:getItemId())
	local damageType = abilityConfig.damageType
        
	local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
	local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
	local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]
	self.siWinBodyItemInfoDamageIcon:setImage(dmgBg)
	self.stWinBodyItemInfoDamageName:setText(Lang:toText(dmgName))
	self.stWinBodyItemInfoDamageName:setProperty("TextColours", dmgColor)

	local itemConfig = ItemConfig:getCfgByItemId(abilityId)
	local isDiscard = itemConfig.isDiscard == 1
	self.stWinBodyItemInfoItemName:setText(Lang:toText(itemConfig.name))
	local quality_alias = itemConfig.quality_alias
	local qualityName = Define.ITEM_QUALITY_LANG[quality_alias]
	local qualityBg = Define.ITEM_QUALITY_BG[quality_alias]
	local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality_alias]
	self.stWinBodyItemInfoItemQualiltyName:setText(Lang:toText(qualityName))
	if qualityColor then
		self.stWinBodyItemInfoItemQualiltyName:setProperty("TextColours", qualityColor)
	end
	self.siWinBodyItemInfoItemQualiltyIcon:setImage(qualityBg)
	self.siWinBodyItemInfoItemQualiltyIconItemIcon:setImage(itemConfig.icon)

	--- 等级信息
	local abilityLevelConfig = AbilityLevelConfig:getCfgByLevel(level)
	local maxLevel = AbilityConfig:getMaxLevel(abilityId)
	self.stWinBodyItemInfoItemLevel:setText("LV." .. level)
	if level < maxLevel then
		self.stWinBodyItemInfoItemExp:setText(exp .. "/" .. abilityLevelConfig.upgradePrice)
		local pro = math.clamp(exp / abilityLevelConfig.upgradePrice, 0, 1)
		self.pbWinBodyItemInfoItemExpBar:setProgress(pro)
	else
		self.stWinBodyItemInfoItemExp:setText("")
		self.pbWinBodyItemInfoItemExpBar:setProgress(1)
	end

	self.lvSkill:setVirtualBarPosition(0)
	self.lvSkill:clearVirtualChild()
	if #askills > 0 then
		self.lvSkill:addVirtualChildList(askills)
	end
	self.btnWinBodyItemInfoDropButton:setVisible(isDiscard)

	if self.equippedId then
		local equipped = self.equippedId == id
		self.btnWinBodyItemInfoEquipButton:setVisible(not equipped)
		self.btnWinBodyItemInfoUnequipButton:setVisible(equipped)
	else
		self.btnWinBodyItemInfoEquipButton:setVisible(false)
		self.btnWinBodyItemInfoUnequipButton:setVisible(false)
	end

end

--- 判断是否打断
---@param event any
function WinAbilityBagLayout:checkInterupt(event)
	if event == CALL_EVENT.EQUIP 
		or event == CALL_EVENT.UNEQUIP
		or event == CALL_EVENT.DROP
		or event == CALL_EVENT.CLOSE_WINDOW
	then
		return self.onWait
	end
	return false
end

--- 音效
---@param event any
function WinAbilityBagLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WINDOW then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event == CALL_EVENT.EQUIP 
        or event == CALL_EVENT.DROP
        or event == CALL_EVENT.SELECT
		or event == CALL_EVENT.UNEQUIP
    then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

--- 回调处理
---@param event any
function WinAbilityBagLayout:onCallHandler(event, ...)
	self:checkSound(event)
	if self:checkInterupt(event) then
		return
	end
	if event == CALL_EVENT.CLOSE_WINDOW then
		UI:closeWindow(self)
	elseif event == CALL_EVENT.EQUIP then
		--- 刷新信息
		local data = self.abilities[self.selectedIndex]
		if data and data.ability then
			---@type Ability
			local ability = data.ability
			if ability:getId() == self.equippedId then
				Me:showGameTopTips(Lang:toText("g2069_ability_equipped"))
				return
			end
			self.onWait = true
			Me:sendPacket({
				pid = "C2SSwitchAbility",
				aid = ability:getId(),
			})
		end
	elseif event == CALL_EVENT.UNEQUIP then
			--- 刷新信息
		local data = self.abilities[self.selectedIndex]
		if data and data.ability then
			---@type Ability
			local ability = data.ability
			if ability:getId() ~= self.equippedId then
				Me:showGameTopTips(Lang:toText("g2069_ability_unequipped"))
				return
			end
			local defaultAbility = AbilitySystem:getDefaultAbility(Me)
			if not defaultAbility then
				return
			end
			self.onWait = true
			Me:sendPacket({
				pid = "C2SSwitchAbility",
				aid = defaultAbility:getId(),
			})
		end
	elseif event == CALL_EVENT.DROP then
		---@type Ability
		local ability = self:getSelectedAbility()
		if not ability then
			return
		end
		local itemConfig = ItemConfig:getCfgByItemId(ability:getItemId())
		local isDiscard = itemConfig.isDiscard == 1
		if not isDiscard then
			return
		end

		if self.equippedId == ability:getId() then
			local this = self
			Me:showConfirm(
				nil, 
				Lang:toText("g2069_drop_equipped_ability_confirm"), 
				function()
					this.onWait = true
					Me:sendPacket({
						pid = "C2SDropAbility",
						aid = ability:getId(),
					})
				end
			)
		else
			self.onWait = true
			Me:sendPacket({
				pid = "C2SDropAbility",
				aid = ability:getId(),
			})
		end
	elseif event == CALL_EVENT.IS_EQUIPPED then
		local id = table.unpack({ ... })
		return self.equippedId == id
	elseif event == CALL_EVENT.IS_SELECTED then
		local id = table.unpack({ ... })
		---@type Ability
		local ability = self:getSelectedAbility()

		if ability and ability:getId() == id then
			return true
		end
	elseif event == CALL_EVENT.IS_INSPECTED then
		local index = table.unpack({ ... })
		local data = self.abilities[index]
		if data and data.ability then
			return data.ability:isInspected()
		end
	elseif event == CALL_EVENT.SELECT then
        local id, index = table.unpack({ ... })
        if self.selectedIndex == index then
            return nil
        end
        --- 刷新信息
        local data = self.abilities[index]
        if data and data.ability then
			self.selectedIndex = index
            ---@type Ability
            local ability = data.ability
			self:inspectAbility(ability)
			self:updateAbilityInfo(ability)

			Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY, id)
        end
	end
end

function WinAbilityBagLayout:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success, player, ability, oldAbility)
		self.onWait = false
		if success then
			self.equippedId = ability:getId()
			---@type Ability
			local selectedAbility = self:getSelectedAbility()
			self:updateAbilityInfo(selectedAbility)
		end
    end)
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_DROP_ABILITY, function(success, player, ability)
		self.onWait = false
		if success and ability then
			--- 判断是否当前选中的物品
			local len = #self.abilities
			for i = len, 1, -1 do
				---@type Ability
				local temp = self.abilities[i].ability
				if temp and temp:getId() == ability:getId() then
					table.remove(self.abilities, i)
					if i == len then
						self.selectedIndex = self.selectedIndex - 1
					else
						for j = i, len - 1, 1 do
							self.abilities[j].index = self.abilities[j].index - 1
						end
					end
					--- 补数据
					if len - 1 < SHOW_ITEM_NUM then
						self.abilities[#self.abilities + 1] = { index = len }
					end
					break
				end
			end

			--- 重新刷新物品
			self.gvAbility:refresh(self.abilities)

			self:updateAbilityInfo(self:getSelectedAbility())
		end
    end)
	
end


--- 检视能力
---@param ability any
function WinAbilityBagLayout:inspectAbility(ability)
	if not ability:isInspected() then
		ability:setInspected(1)
		self.inspectFlag = true
		self.inspectIds = self.inspectIds or {}
		self.inspectIds[#self.inspectIds + 1] = ability:getId()
		self:pushInspectIds()
	end
end

--- 推送检视状态
function WinAbilityBagLayout:pushInspectIds(force)
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

function WinAbilityBagLayout:stopPushTimer()
	if self.pushTimer then
		LuaTimer:cancel(self.pushTimer)
		self.pushTimer = nil
	end
end

function WinAbilityBagLayout:startPushTimer()
	if not self.pushTimer then
		self.pushTimer = LuaTimer:scheduleTicker(function()
			self:pushInspectIds(true)
		end, 20 * 5)
	end
end

---@private
function WinAbilityBagLayout:onDestroy()
	self:stopPushTimer()
	self:pushInspectIds(true)
end

---@private
function WinAbilityBagLayout:onClose()
	self:stopPushTimer()
	self:pushInspectIds(true)
	if self.inspectFlag then
		Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_INSPECT_ABILITY)
	end
end

WinAbilityBagLayout:init()
