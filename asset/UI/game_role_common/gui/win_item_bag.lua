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
---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")

local SHOW_ITEM_NUM = 25
local COLUMN_ITEM_NUM = 5

local CALL_EVENT = {
	CLOSE_WINDOW = "close",
	DROP = "drop",
	USE_ITEM = "use",
	SELECT = "select",
	IS_SELECTED = "selected",
	IS_INSPECTED = "inspected",
	IS_EQUIPPED = "equipped",
	GET_AMOUNT = "amount",
}

---@class WinItemBagLayout : CEGUILayout
local WinItemBagLayout = M

---@private
function WinItemBagLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.WinBody
end

---@private
function WinItemBagLayout:findAllWindow()
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
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoDescBg = self.WinBody.ItemInfo.DescBg
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemName = self.WinBody.ItemInfo.ItemName
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoItemQualiltyIcon = self.WinBody.ItemInfo.ItemQualiltyIcon
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoItemQualiltyIconItemIcon = self.WinBody.ItemInfo.ItemQualiltyIcon.ItemIcon
	---@type CEGUIStaticText
	self.stWinBodyItemInfoItemQualiltyName = self.WinBody.ItemInfo.ItemQualiltyName
	---@type CEGUIScrollableView
	self.wWinBodyItemInfoSvDesc = self.WinBody.ItemInfo.SvDesc
	---@type CEGUIVerticalLayoutContainer
	self.wWinBodyItemInfoSvDescLvDesc = self.WinBody.ItemInfo.SvDesc.LvDesc
	---@type CEGUIStaticText
	self.stWinBodyItemInfoSvDescLvDescItemDesc = self.WinBody.ItemInfo.SvDesc.LvDesc.ItemDesc
	---@type CEGUIDefaultWindow
	self.wWinBodyItemInfoAbilityInfo = self.WinBody.ItemInfo.AbilityInfo
	---@type CEGUIStaticImage
	self.siWinBodyItemInfoAbilityInfoDamageIcon = self.WinBody.ItemInfo.AbilityInfo.DamageIcon
	---@type CEGUIStaticText
	self.stWinBodyItemInfoAbilityInfoDamageIconDamageName = self.WinBody.ItemInfo.AbilityInfo.DamageIcon.DamageName
	---@type CEGUIProgressBar
	self.pbWinBodyItemInfoAbilityInfoItemExpBar = self.WinBody.ItemInfo.AbilityInfo.ItemExpBar
	---@type CEGUIStaticText
	self.stWinBodyItemInfoAbilityInfoItemLevel = self.WinBody.ItemInfo.AbilityInfo.ItemLevel
	---@type CEGUIStaticText
	self.stWinBodyItemInfoAbilityInfoItemExp = self.WinBody.ItemInfo.AbilityInfo.ItemExp
	---@type CEGUIScrollableView
	self.wWinBodyItemInfoAbilityInfoSvSkill = self.WinBody.ItemInfo.AbilityInfo.SvSkill
	---@type CEGUIVerticalLayoutContainer
	self.wWinBodyItemInfoAbilityInfoSvSkillLvSkill = self.WinBody.ItemInfo.AbilityInfo.SvSkill.LvSkill
	---@type CEGUIButton
	self.btnWinBodyItemInfoUseButton = self.WinBody.ItemInfo.UseButton
	---@type CEGUIButton
	self.btnWinBodyItemInfoDropButton = self.WinBody.ItemInfo.DropButton
	---@type CEGUIButton
	self.btnWinBodyCloseButton = self.WinBody.CloseButton
end

---@private
function WinItemBagLayout:initUI()
	self.btnWinBodyItemInfoDropButton:setText(Lang:toText("g2069_ability_drop"))
	self.btnWinBodyItemInfoUseButton:setText(Lang:toText("g2069_item_use"))
end

---@private
function WinItemBagLayout:initEvent()
	self.btnWinBodyItemInfoUseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.USE_ITEM)
	end
	self.btnWinBodyItemInfoDropButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.DROP)
	end
	self.btnWinBodyCloseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.CLOSE_WINDOW)
	end
end


function WinItemBagLayout:initData()
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
    self.bagItems = {}
	--- 所有技能数据
	self.skills = {}
	--- buff卡数据
	self.buffCards = nil

	local inventoryTypeList = {
		Define.INVENTORY_TYPE.ABILITY,
		Define.INVENTORY_TYPE.BAG
	}

	local index = 0
	local add = false
	for _, inventoryType in pairs(inventoryTypeList) do
		local slots = InventorySystem:getAllSlots(Me, inventoryType)
		if slots then
			---@type number, Slot
			for _, slot in pairs(slots) do
				---@type Item
				local item = slot:getItem()
				local amount = slot:getAmount()
				add = false
				if item and amount > 0 then
					if item:getItemType() == Define.ITEM_TYPE.ABILITY then
						--- 默认能力不显示
						if item:getItemAlias() ~= Define.ITEM_ALIAS.DEFAULT_ABILITY then
							add = true
						end
					else
						add = true
					end
				end
				if add then
					index = index + 1
					self.bagItems[#self.bagItems + 1] = { item = item, amount = amount, index = index }
				end
			end
		end
	end

	--- 排序
    if #self.bagItems > 1 then
        table.sort(self.bagItems, function(e1, e2)
			---@type Item
			local item1 = e1.item
			---@type Item
			local item2 = e2.item
			return item1:getItemId() < item2:getItemId()
        end)

		for index, data in pairs(self.bagItems) do
			data.index = index
		end
    end

	local bagItemNum = #self.bagItems
	if bagItemNum < SHOW_ITEM_NUM then
		local startIndex = bagItemNum + 1
		for i = startIndex, SHOW_ITEM_NUM, 1 do
			self.bagItems[#self.bagItems + 1] = { index = i }
		end
	elseif bagItemNum % COLUMN_ITEM_NUM ~= 0 then
		local del = COLUMN_ITEM_NUM - bagItemNum % COLUMN_ITEM_NUM
		for i = 1, del, 1 do
			self.bagItems[#self.bagItems + 1] = { index = i }
		end
	end

	--- 处理选中能力
	---@type Item
	local item = self:getSelectedItem()
	if item then
		self:inspectItem(item)
	end
end

--- 获取当前选中物品
---@return Item
function WinItemBagLayout:getSelectedItem()
	local data = self.bagItems[self.selectedIndex]
	if data then
		return data.item
	end
	return nil
end

--- 获取数据
---@param id any
function WinItemBagLayout:getDataById(id)
	for index, data in pairs(self.bagItems) do
		---@type Item
		local item = data.item
		if not item then
			break
		end
		if item:getId() == id then
			return data, index
		end
	end
	return nil
end

--- 检视物品
---@param item Item
function WinItemBagLayout:inspectItem(item)
	if not item:isInspected() then
		item:setInspected(1)
		self.inspectFlag = true
		self.inspectIds = self.inspectIds or {}
		self.inspectIds[#self.inspectIds + 1] = { id = item:getId(), itemId = item:getItemId() }
		self:pushInspectIds()
	end
end

--- 推送检视状态
function WinItemBagLayout:pushInspectIds(force)
	if not self.inspectIds then
		return
	end
	local len = #self.inspectIds
	if (force and len > 0) or len >= 10 then
		local ids = {}
		local itemIds = {}
		for _, data in pairs(self.inspectIds) do
			ids[#ids + 1] = data.id
			itemIds[#itemIds + 1] = data.itemId
		end
		Me:sendPacket({
			pid = "C2SInspectItem",
			ids = ids,
			itemIds = itemIds,
		})
		self.inspectIds = nil
	end
end

function WinItemBagLayout:stopPushTimer()
	if self.pushTimer then
		LuaTimer:cancel(self.pushTimer)
		self.pushTimer = nil
	end
end

function WinItemBagLayout:startPushTimer()
	if not self.pushTimer then
		self.pushTimer = LuaTimer:scheduleTicker(function()
			self:pushInspectIds(true)
		end, 20 * 5)
	end
end

function WinItemBagLayout:subscribeEvents()
	--- 使用物品
	---@param success any
	---@param player Entity
	---@param item Item
	---@param consume number
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_USE_ITEM, function(success, player, item, consume, rewards)
		if success then
			if item:getItemType() == Define.ITEM_TYPE.ABILITY then
				self.equippedId = item:getId()
			end
			self:onItemChangeNum(item, -consume)

			if rewards ~= nil then
				for _, data in pairs(rewards) do
					local itemAlias = data.item_alias
					local itemType = ItemConfig:getCfgByItemAlias(itemAlias).type_alias
					local inventoryType = Define.ITEM_INVENTORY_TYPE[itemType]
					if inventoryType then
						--- 处理数量
						---@type Item, number, Slot
						local _item, slotIndex, slot = InventorySystem:getItemByItemAlias(Me, inventoryType, itemAlias)
						if _item and slot:getAmount() > 0 then
							local amount = slot:getAmount()
							local data = self:getDataById(_item:getId())
							if not data then
								self:onItemChangeNum(_item, amount)
							elseif data.amount ~= amount then
								self:onItemChangeNum(_item, amount - data.amount)
							end
						end
					end
				end
			end
		end
    end)

	--- 丢弃物品
	---@param success any
	---@param player any
	---@param item any
	---@param amount any
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_DROP_ITEM, function(success, player, item, amount)
		if success then
			self:onItemChangeNum(item, -amount)
		end
	end)
end

--- 物品数量修改回调
---@param item Item
---@param changeNum number 必定为正数
function WinItemBagLayout:onItemChangeNum(item, changeNum)
	--- 修改数量
	local data, index = self:getDataById(item:getId())
	if data then
		data.amount = data.amount + changeNum
		if data.amount > 0 then
			--- 刷新信息
			if index == self.selectedIndex then
				self:updateItemInfo(item)	
			end

			Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_BAG_ITEM, data)

		else
			--- 移除数据
			-- table.remove(self.bagItems, index)
			local bagItemNum = #self.bagItems
			--- 重定义索引
			for i = index, bagItemNum, 1 do
				if i ~= bagItemNum then
					self.bagItems[i].item = self.bagItems[i + 1].item
					self.bagItems[i].amount = self.bagItems[i + 1].amount
				else
					self.bagItems[i].item = nil
					self.bagItems[i].amount = nil
				end
			end
			--- 刷新当前选中索引
			if self.bagItems[index] and self.bagItems[index].item then
				self.selectedIndex = index
			else
				self.selectedIndex = math.max(1, index - 1)
			end

			--- 补全数据
			if bagItemNum < SHOW_ITEM_NUM then
				local startIndex = bagItemNum + 1
				for i = startIndex, SHOW_ITEM_NUM, 1 do
					self.bagItems[#self.bagItems + 1] = { index = i }
				end
			elseif bagItemNum % COLUMN_ITEM_NUM ~= 0 then
				local del = COLUMN_ITEM_NUM - bagItemNum % COLUMN_ITEM_NUM
				for i = 1, del, 1 do
					self.bagItems[#self.bagItems + 1] = { index = i }
				end
			elseif bagItemNum > SHOW_ITEM_NUM then
				local sub = math.floor((bagItemNum - SHOW_ITEM_NUM) / COLUMN_ITEM_NUM)
				for i = sub, 1, -1 do
					local idx = SHOW_ITEM_NUM + COLUMN_ITEM_NUM * (i - 1) + 1
					if not self.bagItems[idx] or self.bagItems[idx].item == nil then
						--- 移除
						for j = #self.bagItems, idx, -1 do
							table.remove(self.bagItems, j)
						end
					end
				end
			end

			--- 刷新背包
			self.gvItem:refresh(self.bagItems)
			--- 刷新物品信息
			self:updateItemInfo(self:getSelectedItem())
		end
	else
		local bagItemNum = #self.bagItems
		local insertData = nil
		for i = 1, bagItemNum, 1 do
			if self.bagItems[i].item == nil then
				self.bagItems[i].item = item
				self.bagItems[i].amount = changeNum
				insertData = self.bagItems[i]
				break
			end
		end
		if not insertData then
			local startIndex = bagItemNum + 1
			for i = startIndex, SHOW_ITEM_NUM, 1 do
				self.bagItems[#self.bagItems + 1] = { index = i }
				if i == startIndex then
					self.bagItems[i].item = item
					self.bagItems[i].amount = changeNum
				end
			end
			--- 刷新背包
			self.gvItem:refresh(self.bagItems)
		else
			Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_INSERT_BAG_ITEM, insertData)
		end
	end
end

--- 显示物品信息
---@param item Item
function WinItemBagLayout:updateItemInfo(item)
	if not item then
		self.wWinBodyItemInfo:setVisible(false)
		self.siWinBodyNoItemBg:setVisible(true)
		return
	end
	self.siWinBodyNoItemBg:setVisible(false)
	self.wWinBodyItemInfo:setVisible(true)
	local id = item:getId()
	local itemId = item:getItemId()
	local config = ItemConfig:getCfgByItemId(itemId)
	local isDiscard = config.isDiscard == 1
	local isUse = config.isUse == 1
	local quality_alias = config.quality_alias
	local qualityName = Define.ITEM_QUALITY_LANG[quality_alias]
	local qualityBg = Define.ITEM_QUALITY_BG[quality_alias]
	local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality_alias]
	local name = config.name
	local icon = config.icon
	local desc = config.desc

	self.btnWinBodyItemInfoDropButton:setVisible(isDiscard)

	self.stWinBodyItemInfoItemName:setText(Lang:toText(name))
	self.stWinBodyItemInfoItemQualiltyName:setText(Lang:toText(qualityName))
	self.siWinBodyItemInfoItemQualiltyIcon:setImage(qualityBg)
	self.siWinBodyItemInfoItemQualiltyIconItemIcon:setImage(icon)
	if qualityColor then
		self.stWinBodyItemInfoItemQualiltyName:setProperty("TextColours", qualityColor)
	end

	if item:getItemType() == Define.ITEM_TYPE.ABILITY then
		self.wWinBodyItemInfoAbilityInfo:setVisible(true)
		---@type Ability
		local ability = item
		local level = ability:getLevel()
		local exp = ability:getExp()
		local askills = self.skills[id]
		local damageType = ability:getDamageType()
		local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
		local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
		local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]
		if not askills then
			askills = AbilityConfig:getActiveSkillList(itemId)
			for index, data in pairs(askills) do
				data.level = level
				data.index = index
			end
			self.skills[id] = askills
		end
		--- 等级信息
		local maxLevel = AbilityConfig:getMaxLevel(itemId)
		self.stWinBodyItemInfoAbilityInfoItemLevel:setText("LV." .. level)
		if level < maxLevel then
			local upgradePrice = AbilityLevelConfig:getCfgByLevel(level).upgradePrice
			self.stWinBodyItemInfoAbilityInfoItemExp:setText(tostring(exp) .. "/" .. tostring(upgradePrice))
			local pro = math.clamp(exp / upgradePrice, 0, 1)
			self.pbWinBodyItemInfoAbilityInfoItemExpBar:setProgress(pro)
		else
			self.stWinBodyItemInfoAbilityInfoItemExp:setText("")
			self.pbWinBodyItemInfoAbilityInfoItemExpBar:setProgress(1)
		end

		self.siWinBodyItemInfoAbilityInfoDamageIcon:setImage(dmgBg)
		self.stWinBodyItemInfoAbilityInfoDamageIconDamageName:setText(Lang:toText(dmgName))
		if dmgColor then
			self.stWinBodyItemInfoAbilityInfoDamageIconDamageName:setProperty("TextColours", dmgColor)
		end

		self.lvSkill:setVirtualBarPosition(0)
		self.lvSkill:clearVirtualChild()
		if #askills > 0 then
			self.lvSkill:addVirtualChildList(askills)
		end

		self.btnWinBodyItemInfoUseButton:setVisible(isUse and self.equippedId ~= id)


		--- 设置描述高
		self.wWinBodyItemInfoSvDesc:setHeight({ 0, 104 })
		self.siWinBodyItemInfoDescBg:setHeight({ 0, 114 })
	else
		self.siWinBodyItemInfoDescBg:setHeight({ 0, 240 })
		self.wWinBodyItemInfoSvDesc:setHeight({ 0, 230 })

		self.wWinBodyItemInfoAbilityInfo:setVisible(false)
		self.btnWinBodyItemInfoUseButton:setVisible(isUse)
	end

	self.stWinBodyItemInfoSvDescLvDescItemDesc:setText(Lang:toText(desc))
end

--- 判断是否打断
---@param event any
function WinItemBagLayout:checkInterupt(event)
	if event == CALL_EVENT.USE_ITEM
		or event == CALL_EVENT.DROP
		or event == CALL_EVENT.CLOSE_WINDOW
	then
		return self.onWait
	end
	return false
end

--- 音效
---@param event any
function WinItemBagLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WINDOW then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event == CALL_EVENT.USE_ITEM 
        or event == CALL_EVENT.DROP
        or event == CALL_EVENT.SELECT
    then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

local list2keyMap = function(list, values)
	if not list then
		return nil
	end
	local map = {}
	for i = 1, #list, 1 do
		local k = list[i]
		map[k] = values and values[i] or true
	end
	return map
end

--- 检测使用
---@param item Item
---@param useCallback function
function WinItemBagLayout:checkUseItem(item, useCallback)
	local itemType = item:getItemType()
	if itemType == Define.ITEM_TYPE.BUFF_CARD then
		--- 检测是否有buff
		local itemConfig = ItemConfig:getCfgByItemId(item:getItemId())
		local subType = itemConfig.sub_type_alias
		if subType == "exp_buff" or subType == "ap_buff" or subType == "gold_buff" then
			if not self.buffCards then
				self.buffCards = {}
				local itemList = ItemConfig:getItemListByType(Define.ITEM_TYPE.BUFF_CARD)
				for _, config in pairs(itemList) do
					local st = config.sub_type_alias
					self.buffCards[st] = self.buffCards[st] or {}
					local buffId = config.params["buff_id"]
					local buffConfig = SkillBuffConfig:getCfgByBuffId(buffId)
					self.buffCards[st][buffId] = { buffName = SkillBuffConfig:getBuffName(buffId), avoidBuff = list2keyMap(buffConfig.avoidBuff), name = buffConfig.name }
				end
			end

			local buffCards = self.buffCards[subType]
			if buffCards then
				local name = itemConfig.name
				local buffId = itemConfig.params["buff_id"]
				local buffName = buffCards[buffId].buffName
				local avoidBuff = buffCards[buffId].avoidBuff

				for bid, data in pairs(buffCards) do
					if bid ~= buffId and Me:getTypeBuff("fullName", data.buffName) then
						--- 判断是否有高级buff
						if data.avoidBuff and data.avoidBuff[buffName] then
							Me:showGameTopTips(Lang:toText("g2069_use_buff_card_avoid"))
							return false
						end
						--- 判断是否替换低级buff
						if avoidBuff and avoidBuff[data.buffName] then
							Me:showConfirm(
								"",
								Lang:toText({ "g2069_use_buff_card_confirm", data.name, name }),
								useCallback
							)
							return false
						end
					end
				end
			end
		elseif subType == "hp_regen_buff" then
			local curHp = Me:getCurHp()
			local maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
			if curHp >= maxHp then
				Me:showGameTopTips(Lang:toText("g2069_use_buff_card_hp_max"))
				return false
			end
		elseif subType == "mp_regen_buff" then
			local curMp = Me:getCurMp()
			local maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
			if curMp >= maxMp then
				Me:showGameTopTips(Lang:toText("g2069_use_buff_card_mp_max"))
				return false
			end
		end
	elseif itemType == Define.ITEM_TYPE.ABILITY then
		--- 当前使用能力
		---@type Ability
		local useAbility = AbilitySystem:getAbility(Me)
		if useAbility:getItemId() ~= item:getItemId() then
			local name1 = useAbility:getName()
			local name2 = item:getName()

			--- 优先处理属性
			local attack = AttributeSystem:getLevel(Me, Define.ATTR.ATTACK)
			local element = AttributeSystem:getLevel(Me, Define.ATTR.ELEMENT_ATTACK)

			local damageType = item:getDamageType()
			if (attack > element and damageType == Define.DAMAGE_TYPE.ELEMENT) 
				or (element > attack and damageType == Define.DAMAGE_TYPE.PHYSICS) 
			then
				local before = Define.DAMAGE_TYPE_NAME[useAbility:getDamageType()]
				local after = Define.DAMAGE_TYPE_NAME[damageType]
				-- 当前加点方案中{.}攻击力最高，替换后的{.}能力为{.}能力，确定替换{.}能力切换为{.}能力
				Me:showConfirm(
					"",
					Lang:toText({ "g2069_use_ability_type_confirm", name1, before, name2, after }),
					useCallback
				)
			else
				Me:showConfirm(
					"",
					Lang:toText({ "g2069_use_ability_confirm", name1, name2 }),
					useCallback
				)
			end
			return false
		else
			Me:showGameTopTips(Lang:toText({ "g2069_use_ability_success", useAbility:getName() }))
			return false
		end
	end
	return true
end

--- 回调处理
---@param event any
function WinItemBagLayout:onCallHandler(event, ...)
	self:checkSound(event)
	if self:checkInterupt(event) then
		return
	end
	if event == CALL_EVENT.CLOSE_WINDOW then
		UI:closeWindow(self)
	elseif event == CALL_EVENT.USE_ITEM then
		local data = self.bagItems[self.selectedIndex]
		if data and data.item then
			if data.amount <= 0 then
				--- 弹出提示框
				Me:showGameTopTips(Lang:toText("g2069_item_amount_not_enough"))
			else
				---@type Item
				local item = data.item
				local this = self

				local useItem = function()
					this.onWait = true
					Me:sendPacket({
						pid = "C2SUseItem",
						itemId = item:getItemId(),
						id = item:getId(),
					}, function()
						this.onWait = false
					end)
				end

				if not self:checkUseItem(item, useItem) then
					return
				end
				useItem()
			end
		end
	elseif event == CALL_EVENT.DROP then
		---@type Item
		local item = self:getSelectedItem()
		if not item then
			return
		end
		local config = ItemConfig:getCfgByItemId(item:getItemId())
		local isDiscard = config.isDiscard == 1
		if not isDiscard then
			return
		end
		self.onWait = true
		local this = self
		Me:sendPacket({
			pid = "C2SDropItem",
			id = item:getId(),
			itemId = item:getItemId(),
		}, function()
			this.onWait = false
		end)
	elseif event == CALL_EVENT.IS_SELECTED then
		---@type Item
		local item = table.unpack({ ... })
		---@type Item
		local selectedItem = self:getSelectedItem()

		if selectedItem and selectedItem:getId() == item:getId() then
			return true
		end
	elseif event == CALL_EVENT.IS_INSPECTED then
		---@type Item
		local item = table.unpack({ ... })
		return item:isInspected()
	elseif event == CALL_EVENT.IS_EQUIPPED then
		if self.equippedId then
			---@type Item
			local item = table.unpack({ ... })
			return self.equippedId == item:getId()
		end
	elseif event == CALL_EVENT.GET_AMOUNT then
		---@type Item
		local item = table.unpack({ ... })
		local data = self:getDataById(item:getId())
		if data then
			return data.amount or 0
		end
		return 0
	elseif event == CALL_EVENT.SELECT then
		---@type Item, number
        local item, index = table.unpack({ ... })
        if self.selectedIndex == index then
            return
        end
        --- 刷新信息
        if self.bagItems[index] then
			self.selectedIndex = index
			self:inspectItem(item)
			self:updateItemInfo(item)

			Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_BAG_ITEM, item)
        end
	end
end

function WinItemBagLayout:initVirtualUI()
	local this = self
	---@type widget_virtual_grid
	self.gvItem = widget_virtual_grid:init(
		self.wWinBodySvItem, 
		self.gvWinBodySvItemGvItem,
		---@type any, CEGUIWindow
		function(self, parent)
			---@type WidgetBagItem
			local node = UI:openWidget("UI/game_role_common/gui/widget_bag_item")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.SELECT, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_SELECTED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_INSPECTED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_EQUIPPED, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.GET_AMOUNT, this, this.onCallHandler)
			return node
		end,
		---@type any, WidgetBagItem, table
		function(self, node, data)
			node:updateInfo(data)
		end,
		COLUMN_ITEM_NUM
	)

	---@type widget_virtual_vert_list
	self.lvSkill = widget_virtual_vert_list:init(
		self.wWinBodyItemInfoAbilityInfoSvSkill, 
		self.wWinBodyItemInfoAbilityInfoSvSkillLvSkill,
		---@type any, CEGUIWindow
		function(self, parent)
			---@type WidgetAbilitySkillWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_ability_skill")
			parent:addChild(node:getWindow())
			return node
		end,
		---@type any, WidgetAbilityItemWidget, table
		function(self, node, data)
			local level = data.level
			local unlockLevel = data.unlock_level
			local skillId = data.skill_id
			local index = data.index
			node:updateInfo(level, unlockLevel, skillId, index)
		end
	)
end

---@private
function WinItemBagLayout:onOpen()
	self:initData()
	self:initVirtualUI()
	self:subscribeEvents()
	self.gvItem:addVirtualChildList(self.bagItems)
	self:updateItemInfo(self:getSelectedItem())
	self:startPushTimer()
end

---@private
function WinItemBagLayout:onDestroy()

end

---@private
function WinItemBagLayout:onClose()
	self:stopPushTimer()
	self:pushInspectIds(true)
	if self.inspectFlag then
		--- 派发事件
		Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_INSPECT_ITEM)
	end
end

WinItemBagLayout:init()
