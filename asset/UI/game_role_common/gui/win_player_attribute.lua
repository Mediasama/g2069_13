---@class WinPlayerAttributeLayout : CEGUILayout
local WinPlayerAttributeLayout = M

local reg = "^[1-9]%d*$"

local CALL_EVENT = {
	UNLOCK_POINT_SET = "unlock",
	SELECT_POINT_SET = "select",
	ADD_ATTRIBUTE_POINT = "add",
	CLOSE_WINDOW = "close",
	RESET_POINT_SET = "reset",
	IS_SELECTED_POINT_SET = "selected",
}

---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")
---@type AttributeLevelConfig
local AttributeLevelConfig = T(Config, "AttributeLevelConfig")
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type WalletSystem
local WalletSystem = T(Lib, "WalletSystem")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

local mn = math.pow(10, 9)
--- 浮点数精度既定常数
local e = 1e-9

local formatCombatPower = function(cp)
	local text = nil
	local em = nil
	for i = 1, 1000, 1 do
		if cp <= 0 then
			break
		end
		if cp >= mn then
			cp = math.floor(cp / mn + e)
			em = (em or "") .. "M"
		else
			local n = cp % 1000
			local str = cp == n and tostring(n) or string.format("%03d", tostring(n))
			if text then
				text = str .. "," .. text
			else
				text = str
			end
			cp = math.floor((cp - n) / 1000 + e)
		end
	end
	if em then
		return (text or tostring(cp)) .. em
	end
	return text or tostring(cp)
end

---@private
function WinPlayerAttributeLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.MainWindow
end

---@private
function WinPlayerAttributeLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticText
	self.stMainWindowTitle = self.MainWindow.Title
	---@type CEGUIDefaultWindow
	self.wMainWindowActorInfo = self.MainWindow.ActorInfo
	---@type CEGUIStaticImage
	self.siMainWindowActorInfoBg = self.MainWindow.ActorInfo.Bg
	---@type CEGUIActorWindow
	self.awMainWindowActorInfoPlayerActor = self.MainWindow.ActorInfo.PlayerActor
	---@type CEGUIStaticImage
	self.siMainWindowCPIcon = self.MainWindow.CPIcon
	---@type CEGUIStaticText
	self.stMainWindowCPValue = self.MainWindow.CPValue
	---@type CEGUIStaticText
	self.stMainWindowRemainPoint = self.MainWindow.RemainPoint
	---@type CEGUIStaticText
	self.stMainWindowRemainPointPointValue = self.MainWindow.RemainPoint.PointValue
	---@type CEGUIDefaultWindow
	self.wMainWindowLevelInfo = self.MainWindow.LevelInfo
	---@type CEGUIStaticImage
	self.siMainWindowLevelInfoBg = self.MainWindow.LevelInfo.Bg
	---@type CEGUIStaticText
	self.stMainWindowLevelInfoTitle = self.MainWindow.LevelInfo.Title
	---@type CEGUIProgressBar
	self.pbMainWindowLevelInfoExpBar = self.MainWindow.LevelInfo.ExpBar
	---@type CEGUIStaticText
	self.stMainWindowLevelInfoExpValue = self.MainWindow.LevelInfo.ExpValue
	---@type CEGUIStaticText
	self.stMainWindowLevelInfoLevelValue = self.MainWindow.LevelInfo.LevelValue
	---@type CEGUIDefaultWindow
	self.wMainWindowAttributeInfo = self.MainWindow.AttributeInfo
	---@type CEGUIStaticImage
	self.siMainWindowAttributeInfoBg = self.MainWindow.AttributeInfo.Bg
	---@type CEGUIStaticText
	self.stMainWindowAttributeInfoTitle = self.MainWindow.AttributeInfo.Title
	---@type CEGUIEditbox
	self.wMainWindowAttributeInfoInputPoint = self.MainWindow.AttributeInfo.InputPoint
	---@type CEGUIScrollableView
	self.wMainWindowAttributeInfoSvAttribute = self.MainWindow.AttributeInfo.SvAttribute
	---@type CEGUIVerticalLayoutContainer
	self.wMainWindowAttributeInfoSvAttributeLvAttribute = self.MainWindow.AttributeInfo.SvAttribute.LvAttribute
	---@type CEGUIScrollableView
	self.wMainWindowSvPointSet = self.MainWindow.SvPointSet
	---@type CEGUIVerticalLayoutContainer
	self.wMainWindowSvPointSetLvPointSet = self.MainWindow.SvPointSet.LvPointSet
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
	---@type CEGUIButton
	self.btnMainWindowResetButton = self.MainWindow.ResetButton
end

---@private
function WinPlayerAttributeLayout:initUI()
	self.stMainWindowLevelInfoTitle:setText(Lang:toText("g2069_role_level"))
	self.stMainWindowAttributeInfoTitle:setText(Lang:toText("g2069_role_attribute"))
	self.stMainWindowRemainPoint:setText(Lang:toText("g2069_attribute_remain_point"))
	self.btnMainWindowResetButton:setText(Lang:toText("g2069_reset_button"))
	local cache = AttributeSystem.ATTRIBUTE_CACHE_POINT
	if cache and string.match(cache, reg) then
		self.wMainWindowAttributeInfoInputPoint:setText(cache)
	else
		self.wMainWindowAttributeInfoInputPoint:setText("1")
	end
end

---@private
function WinPlayerAttributeLayout:initEvent()
	self.btnMainWindowCloseButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.CLOSE_WINDOW)
	end
	self.btnMainWindowResetButton.onMouseClick = function()
		self:onCallHandler(CALL_EVENT.RESET_POINT_SET)
	end

	local preText = nil
	local lock = false

	self.wMainWindowAttributeInfoInputPoint.onTextChanged = function()
		if lock then
			return
		end
		local text = self.wMainWindowAttributeInfoInputPoint:getText()
		if preText and preText == text then
			return
		end
		preText = text
		if text ~= "" and text ~= "1" then
			--- 字符串不匹配
			if string.match(text, reg) then
				AttributeSystem.ATTRIBUTE_CACHE_POINT = text
			else
				Me:showGameTopTips(Lang:toText("g2069_attribute_num_setting"))
				lock = true
				self.wMainWindowAttributeInfoInputPoint:setText("1")
				lock = false
			end
		end
	end
end

---@private
function WinPlayerAttributeLayout:onOpen()
	self:initData()
	self:initAttributeUI()
	self:subscribeEvents()
	self:updateInfo()
	self:updateLevelInfo()
	self:updatePlayerActor()
end

--- 获取加点
function WinPlayerAttributeLayout:getAddPoint()
	local text = self.wMainWindowAttributeInfoInputPoint:getText()
	local point = 1
	if text ~= "" and text ~= "1" then
		if string.match(text, reg) then
			point = tonumber(text) or 1
		end
	end
	return point
end

function WinPlayerAttributeLayout:updateCombatPower()
	local power = BattleSystem:getCombatPower(Me, self.selectedIndex)
	local text = formatCombatPower(power)

	self.stMainWindowCPValue:setText(text)
end

function WinPlayerAttributeLayout:updateLevelInfo()
	local level = GrowthSystem:getLevel(Me)
	local maxLevel = PlayerLevelConfig:getMaxLevel()

	self.stMainWindowLevelInfoLevelValue:setText("LV." .. level)
	if level < maxLevel then
		local exp = GrowthSystem:getExp(Me)
		local needExp = PlayerLevelConfig:getNeedExp(level)
		local pro = math.clamp(exp / needExp, 0, 1)
		self.pbMainWindowLevelInfoExpBar:setProgress(pro)
		self.stMainWindowLevelInfoExpValue:setVisible(true)
		self.stMainWindowLevelInfoExpValue:setText(tostring(exp) .. "/" .. tostring(needExp))
	else
		self.pbMainWindowLevelInfoExpBar:setProgress(1)
		self.stMainWindowLevelInfoExpValue:setVisible(false)
	end
end

function WinPlayerAttributeLayout:initAttributeUI()
	local this = self
	---@type widget_virtual_vert_list
	self.lvPointSet = widget_virtual_vert_list:init(
		self.wMainWindowSvPointSet,
		self.wMainWindowSvPointSetLvPointSet,
		function(_, parent)
			---@type WidgetPointSetWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_point_set")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.SELECT_POINT_SET, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.UNLOCK_POINT_SET, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_SELECTED_POINT_SET, this, this.onCallHandler)
			return node
		end,
		function(_, node, data)
			local levelIndex = data.levelIndex or 1
			local unlockIndex = data.unlockIndex or levelIndex
			this.pointSets[levelIndex] = true
			node:updateInfo(levelIndex, unlockIndex)
		end
	)

	---@type widget_virtual_vert_list
	self.lvAttribute = widget_virtual_vert_list:init(
		self.wMainWindowAttributeInfoSvAttribute,
		self.wMainWindowAttributeInfoSvAttributeLvAttribute,
		function(_, parent)
			---@type WidgetPlayerAttributeWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_player_attribute")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.ADD_ATTRIBUTE_POINT, this, this.onCallHandler)
			return node
		end,
		function(_, node, data)
			local levelIndex = data.levelIndex or 1
			local attributeId = data.attributeId
			local attributeLevel = data.attributeLevel
			node:updateInfo(levelIndex, attributeId, attributeLevel)
		end
	)
end

--- 刷新表现
function WinPlayerAttributeLayout:updatePlayerActor()
	
	self.actorTimer = nil
	local this = self
	
	local loadSkins = function()
		local skins = Me:data("skins")
		local vipSkinInfo = Me:data("vipSkinInfos")
		for _, v in pairs(vipSkinInfo or {}) do
			if CEGUIActorWindow.changePartsTexture then
				this.awMainWindowActorInfoPlayerActor:changePartsTexture(v.masterName, v.slaveName, v.nickName, v.color)
			end
		end
		if skins then
			for k, v in pairs(skins) do
				if k == "skin_color" then
					this.awMainWindowActorInfoPlayerActor:setActorCustomColor(v)
				else
					local t = type(v)
					if t == nil or (t == "string" and (v == "" or v == "0")) or (t == "number" and v == 0) then
						this.awMainWindowActorInfoPlayerActor:unloadBodyPart(k)
					else
						if t == "table" then
							for _, item in ipairs(v) do
								if CEGUIActorWindow.useBodyPartDyeColor and EntityClient.getPartDyeColor then
									local color = Me:getPartDyeColor(k, v)
									self.awMainWindowActorInfoPlayerActor:useBodyPartDyeColor(k, tostring(item), color)
								else
									self.awMainWindowActorInfoPlayerActor:useBodyPart(k, tostring(item))
								end
							end
						else
							if CEGUIActorWindow.useBodyPartDyeColor and EntityClient.getPartDyeColor then
								local color = Me:getPartDyeColor(k, v)
								self.awMainWindowActorInfoPlayerActor:useBodyPartDyeColor(k, v, color)
							else
								self.awMainWindowActorInfoPlayerActor:useBodyPart(k, v)
							end
						end
					end
				end
			end
		end
	end

	local abilityId = AbilitySystem:getAbilitySkin(Me)
	if not abilityId then
		local ability = AbilitySystem:getAbility(Me)	
		abilityId = ability:getAwakeAbilityId()
	end
	local config = AbilityConfig:getCfgByAbilityId(abilityId)
	self.awMainWindowActorInfoPlayerActor:setActorName(Me:getActorName())
	self.awMainWindowActorInfoPlayerActor:setSkillName(config.idleAction)
	
	if self.awMainWindowActorInfoPlayerActor:isActorPrepared() then
		loadSkins()
	else
		self.actorTimer = LuaTimer:scheduleTicker(function()
			if not self.awMainWindowActorInfoPlayerActor:isActorPrepared() then
				return
			end
			loadSkins()
			LuaTimer:cancel(self.actorTimer)
			self.actorTimer = nil
		end, 2)
	end
end

--- 获取剩余点
---@return number 剩余属性点
function WinPlayerAttributeLayout:getRemainPoint()
	if not self.remainPoint then
		self.remainPoint = AttributeSystem:getRemainPointByIndex(Me, self.selectedIndex)
	end
	return self.remainPoint
end

function WinPlayerAttributeLayout:initData()
	self.onWait = false
	self.remainPoint = nil
	---@type AttributeData
	self.attributeData = AttributeSystem:getAttributeData(Me)

	self.pointSets = {}
	self.attributes = {}

	--- 获取二级属性
	local attributes = AttributeInfoConfig:getAttributesByType(2)

	for _, config in pairs(attributes) do
		local id = config.attr_id
		self.attributes[#self.attributes + 1] = { id = id, node = nil }
	end

	--- 当前索引
	self.selectedIndex = self.attributeData and self.attributeData.idx or 1
	--- 初始索引
	self.originIndex = self.selectedIndex
end

--- 回调处理
---@param event any
function WinPlayerAttributeLayout:onCallHandler(event, ...)
	self:checkSound(event)
	if self:checkInterupt(event) then
		return
	end
	if event == CALL_EVENT.ADD_ATTRIBUTE_POINT then
		local levelIndex, attributeId = table.unpack({ ... })
		--- 判断是否满级
		local max_level = AttributeLevelConfig:getMaxLevel(attributeId)
		local point = self:getAddPoint()
		if not point or point <= 0 then
			return
		end
		if self.attributeData:getLevelByIndex(attributeId, levelIndex) >= max_level then
			Me:showGameTopTips(Lang:toText("g2069_attribute_max_level"))
			return
		end
		local remainPoint = self:getRemainPoint()
		if remainPoint < 1 then
			Me:showGameTopTips(Lang:toText("g2069_attribute_point_not_enough"))
			return
		end

		--- 取最小值
		point = math.min(point, remainPoint)

		local this = self
		local addCallback = function()
			this.onWait = true
			this.remainPoint = nil
			--- 解锁索引
			Me:sendPacket({
				pid = "C2SAddSetPoint",
				idx = this.selectedIndex,
				aid = attributeId,
				point = point,
			})
		end
		if not self:checkAddConfirm(attributeId, addCallback) then
			return
		end

		addCallback()
		
	elseif event == CALL_EVENT.UNLOCK_POINT_SET then
		--- 已经解锁
		local levelIndex = table.unpack({ ... })
		if levelIndex ~= self.attributeData.uidx + 1 then
			return
		end
		local cost = AttributeSystem:getUnlockCostCube()
		local this = self
		Me:showConfirm(
			nil,
			Lang:toText({ "g2069_attribute_unlock_confirm", cost }),
			function()
				--- 货币不足
				if WalletSystem:getCube(Me) < cost then
					Me:showGameTopTips(Lang:toText("g2069_not_enough_golden_cube"))
					Interface.onRecharge(1)
					return
				end

				this.onWait = true
				--- 解锁索引
				Me:sendPacket({
					pid = "C2SUnlockSetIndex",
					idx = levelIndex,
				})
			end
		)
	elseif event == CALL_EVENT.IS_SELECTED_POINT_SET then
		local levelIndex = table.unpack({ ... })
		return self.selectedIndex == levelIndex
	elseif event == CALL_EVENT.SELECT_POINT_SET then
		local levelIndex = table.unpack({ ... })
		if self.selectedIndex == levelIndex then
			return
		end
		--- 刷新信息
		self.remainPoint = nil
		self.selectedIndex = levelIndex
		self:updateInfo()
		Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_POINT_SET, levelIndex)
	elseif event == CALL_EVENT.RESET_POINT_SET then
		local needReset = false
		local data = self.attributeData.data[self.selectedIndex]
		if data then
			for _, level in pairs(data) do
				if level > 1 then
					needReset = true
					break
				end
			end
		end
		if needReset then
			--- 判断金魔方
			local cost = AttributeSystem:getResetCostCube()
			local this = self

			local freeResetTimes = AttributeSystem:getFreeResetTimes()
    		local rtimes = AttributeSystem:getResetTimes(Me)

			local content
			if rtimes < freeResetTimes then
				content = Lang:toText("g2069_attribute_unlock_confirm_first")
			else
				content = Lang:toText({ "g2069_attribute_reset_confirm", cost })
			end

			Me:showConfirm(
				nil, 
				content,
				function()
					--- 货币不足
					if rtimes >= freeResetTimes and WalletSystem:getCube(Me) < cost then
						Me:showGameTopTips(Lang:toText("g2069_not_enough_golden_cube"))
						Interface.onRecharge(1)
						return
					end

					this.onWait = true
					Me:sendPacket({
						pid = "C2SResetPointSet",
						idx = this.selectedIndex,
					})
				end
			)
			return
		end
		Me:showGameTopTips(Lang:toText("g2069_attribute_no_need_reset"))
	elseif event == CALL_EVENT.CLOSE_WINDOW then
		if self.originIndex ~= self.selectedIndex then
			self.onWait = true
			Me:sendPacket({
				pid = "C2SUpdatePointSetIndex",
				idx = self.selectedIndex,
			})
			return
		end
		UI:closeWindow(self)
	end
end

--- 加点提示
---@param attributeId any
---@param addCallback any
function WinPlayerAttributeLayout:checkAddConfirm(attributeId, addCallback)
	if not self.addConfirm then
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if ability then
			local damageType = ability:getDamageType()
			if (damageType == Define.DAMAGE_TYPE.PHYSICS and attributeId == Define.ATTR.ELEMENT_ATTACK) or
				(damageType == Define.DAMAGE_TYPE.ELEMENT and attributeId == Define.ATTR.ATTACK)
			then
				self.addConfirm = true
				local text
				if damageType == Define.DAMAGE_TYPE.PHYSICS then
					text = Lang:toText("g2069_attribute_point_physics_confirm")
				else
					text = Lang:toText("g2069_attribute_point_element_confirm")
				end
				Me:showConfirm(
					"",
					text,
					addCallback
				)
				return false
			end
		end
	end
	return true
end

--- 音效
---@param event any
function WinPlayerAttributeLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WINDOW then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event == CALL_EVENT.UNLOCK_POINT_SET 
        or event == CALL_EVENT.SELECT_POINT_SET
        or event == CALL_EVENT.ADD_ATTRIBUTE_POINT
		or event == CALL_EVENT.RESET_POINT_SET
    then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

--- 检测是否打断
---@param event any
function WinPlayerAttributeLayout:checkInterupt(event)
	if not self.attributeData then
		Me:showGameTopTips(Lang:toText("g2069_attribute_data_processing"))
		return true
	end
	if event == CALL_EVENT.ADD_ATTRIBUTE_POINT or
		event == CALL_EVENT.CLOSE_WINDOW or
		event == CALL_EVENT.UNLOCK_POINT_SET or
		event == CALL_EVENT.RESET_POINT_SET 
	then
		if self.onWait then
			Me:showGameTopTips(Lang:toText("g2069_attribute_data_processing"))
			return true
		end
	end
	return false
end

--- 刷新版面信息
function WinPlayerAttributeLayout:updateInfo()
	if self.attributeData then
		local selectedIndex = self.selectedIndex
		--- 处理属性
		for _, data in pairs(self.attributes) do
			---@type WidgetPlayerAttributeWidget
			local attributeId = data.id
			local attributeLevel = self.attributeData:getLevelByIndex(attributeId, selectedIndex)
			if not data.node then
				data.node = true
				local pack = {
					levelIndex = selectedIndex,
					attributeId = attributeId,
					attributeLevel = attributeLevel
				}
				self.lvAttribute:addVirtualChild(pack)
			else
				Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_POINT_SET_ATTRIBUTE, selectedIndex, attributeId, attributeLevel)
			end
		end

		local unlockIndex = self.attributeData.uidx
		local endIndex = math.min(AttributeSystem:getAttributeMaxIndex(), unlockIndex + 1)
		if endIndex > 1 then
			for i = 1, endIndex do
				---@type WidgetPointSetWidget
				if not self.pointSets[i] then
					self.pointSets[i] = true
					self.lvPointSet:addVirtualChild({ levelIndex = i, unlockIndex = unlockIndex })
				end
			end
		end
	end
	self:updateRemainPoint()
	self:updateCombatPower()
end

--- 刷新属性点
function WinPlayerAttributeLayout:updateRemainPoint()
	local remainPoint = self:getRemainPoint()
	local text = formatCombatPower(remainPoint)
	self.stMainWindowRemainPointPointValue:setText(text)
end

function WinPlayerAttributeLayout:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA, function()
		self.remainPoint = nil
		self.attributeData = AttributeSystem:getAttributeData(Me)
		self.selectedIndex = self.attributeData.idx
		self.originIndex = self.selectedIndex
		self:updateInfo()
		self:updateLevelInfo()
	end)

	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_UNLOCK, function(success, player, unlockIndex, preIndex)
		self.onWait = false
		if success then
			self.remainPoint = nil
			self.selectedIndex = unlockIndex
			self.originIndex = unlockIndex
			self:updateInfo()
		end
	end)
	
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
		if addLevel ~= 0 then
			self.remainPoint = nil
			--- 刷新信息
			self:updateRemainPoint()
		end
    end)

	--- 刷新数据
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_POINT, function(success, player, levelIndex, attributeId, attributeLevel)
		self.onWait = false
		if success and self.selectedIndex == levelIndex then
			self.remainPoint = nil
			self:updateInfo()
		end
    end)

	--- 更新属性方案
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_INDEX, function(success, player, levelIndex)
		UI:closeWindow(self)
    end)

	--- 重置属性方案
	---@param success any
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_RESET_POINT_SET, function(success, player, levelIndex)
		self.onWait = false
		if success and self.selectedIndex == levelIndex then
			self.remainPoint = nil
			self:updateInfo()
		end
    end)
end

---@private
function WinPlayerAttributeLayout:onDestroy()
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

---@private
function WinPlayerAttributeLayout:onClose()
	self.wMainWindowAttributeInfoInputPoint.onTextChanged = nil
	if self.actorTimer then
		LuaTimer:cancel(self.actorTimer)
		self.actorTimer = nil
	end
end

WinPlayerAttributeLayout:init()
