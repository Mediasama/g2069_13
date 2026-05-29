---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type PlayerLevelConfig
local PlayerLevelConfig = T(Config, "PlayerLevelConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type AbilityLevelConfig
local AbilityLevelConfig = T(Config, "AbilityLevelConfig")
---@type LimitTimeClientHelper
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")

---@type GameLib
local GameLib = T(Lib, "GameLib")


--- 测试，扣血公式
---@param deltaValue number 变化值
---@param maxValue number 最大值
local testSub = function(deltaValue, maxValue)
	--- 最大帧
	local maxFrame = 6
	--- 最小帧
	local minFrame = 2
	--- 系数
	local k = 5
	--- 变化绝对值
	local value = math.abs(deltaValue)
	--- 变化率
	local r = value / maxValue
	--- 变化帧
	local frame = math.ceil(r * k * (maxFrame - minFrame) + minFrame)
	--- 取范围值
	return math.clamp(frame, minFrame, maxFrame)
end

--- 进度条刷新间隔，单位帧
local PROGRESS_INTERVAL = 1
--- 文本刷新间隔，单位帧
local TEXT_INTERVAL = 10
--- 扣除后等待更新间隔
local WAIT_INTERVAL = 20

---@class WidgetPlayerBattleInfoWidget : CEGUILayout
local WidgetPlayerBattleInfoWidget = M

---@private
function WidgetPlayerBattleInfoWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetPlayerBattleInfoWidget:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wBody = self.Body
	---@type CEGUIDefaultWindow
	self.wBodyLevelInfo = self.Body.LevelInfo
	---@type CEGUIStaticText
	self.stBodyLevelInfoLevelValue = self.Body.LevelInfo.LevelValue
	---@type CEGUIStaticText
	self.stBodyLevelInfoLevelValueExpValue = self.Body.LevelInfo.LevelValue.ExpValue
	---@type CEGUIDefaultWindow
	self.wBodyBuffLocation1 = self.Body.BuffLocation1
	---@type CEGUIStaticImage
	self.siBodyBuffLocation1BuffIcon = self.Body.BuffLocation1.BuffIcon
	---@type CEGUIStaticText
	self.stBodyBuffLocation1BuffLeftTime = self.Body.BuffLocation1.BuffLeftTime
	---@type CEGUIDefaultWindow
	self.wBodyBuffLocation2 = self.Body.BuffLocation2
	---@type CEGUIStaticImage
	self.siBodyBuffLocation2BuffIcon = self.Body.BuffLocation2.BuffIcon
	---@type CEGUIStaticText
	self.stBodyBuffLocation2BuffLeftTime = self.Body.BuffLocation2.BuffLeftTime
	---@type CEGUIProgressBar
	self.pbBodyHpBar = self.Body.HpBar
	---@type CEGUIStaticText
	self.stBodyHpBarValue = self.Body.HpBar.Value
	---@type CEGUIStaticImage
	self.siBodyHpBarIcon = self.Body.HpBar.Icon
	---@type CEGUIProgressBar
	self.pbBodyStaminaBar = self.Body.StaminaBar
	---@type CEGUIStaticText
	self.stBodyStaminaBarValue = self.Body.StaminaBar.Value
	---@type CEGUIStaticImage
	self.siBodyStaminaBarIcon = self.Body.StaminaBar.Icon
	---@type CEGUIStaticText
	self.stBodyAbilityLevel = self.Body.AbilityLevel
	---@type CEGUIStaticText
	self.stBodyAbilityLevelAbilityName = self.Body.AbilityLevel.AbilityName
	---@type CEGUIButton
	self.btnBodyAttributeButton = self.Body.AttributeButton
	---@type CEGUIStaticImage
	self.siBodyAttributeButtonIcon = self.Body.AttributeButton.Icon
	---@type CEGUIStaticImage
	self.siBodyAttributeButtonRedDot = self.Body.AttributeButton.RedDot
	---@type CEGUIStaticText
	self.stBodyAttributeButtonRedDotNum = self.Body.AttributeButton.RedDot.Num
	---@type CEGUIStaticText
	self.stBodyAttributeButtonTitle = self.Body.AttributeButton.Title
	---@type CEGUIButton
	self.btnBodyBagButton = self.Body.BagButton
	---@type CEGUIStaticImage
	self.siBodyBagButtonIcon = self.Body.BagButton.Icon
	---@type CEGUIStaticImage
	self.siBodyBagButtonRedDot = self.Body.BagButton.RedDot
	---@type CEGUIStaticText
	self.stBodyBagButtonTitle = self.Body.BagButton.Title
	---@type CEGUIButton
	self.btnBodyBookButton = self.Body.BookButton
	---@type CEGUIStaticImage
	self.siBodyBookButtonIcon = self.Body.BookButton.Icon
	---@type CEGUIStaticImage
	self.siBodyBookButtonRedDot = self.Body.BookButton.RedDot
	---@type CEGUIStaticText
	self.stBodyBookButtonTitle = self.Body.BookButton.Title
	---@type CEGUIButton
	self.btnBodyRankButton = self.Body.RankButton
	---@type CEGUIStaticImage
	self.siBodyRankButtonIcon = self.Body.RankButton.Icon
	---@type CEGUIStaticImage
	self.siBodyRankButtonRedDot = self.Body.RankButton.RedDot
	---@type CEGUIStaticText
	self.stBodyRankButtonTitle = self.Body.RankButton.Title
	---@type CEGUIButton
	self.btnBodyAwakeButton = self.Body.AwakeButton
	---@type CEGUIStaticImage
	self.siBodyAwakeButtonIcon = self.Body.AwakeButton.Icon
	---@type CEGUIStaticImage
	self.siBodyAwakeButtonRedDot = self.Body.AwakeButton.RedDot
	---@type CEGUIStaticText
	self.stBodyAwakeButtonTitle = self.Body.AwakeButton.Title
	---@type CEGUIButton
	self.btnBodySubscribeButton = self.Body.SubscribeButton
	---@type CEGUIEffectWindow
	self.wBodySubscribeButtonSubscribeEffect = self.Body.SubscribeButton.SubscribeEffect
	---@type CEGUIStaticImage
	self.siBodySubscribeButtonIcon = self.Body.SubscribeButton.Icon
	---@type CEGUIStaticImage
	self.siBodySubscribeButtonRedDot = self.Body.SubscribeButton.RedDot
	---@type CEGUIStaticText
	self.stBodySubscribeButtonTitle = self.Body.SubscribeButton.Title
	---@type CEGUIButton
	self.btnBodyGoldenWheelButton = self.Body.GoldenWheelButton
	---@type CEGUIStaticImage
	self.siBodyGoldenWheelButtonIcon = self.Body.GoldenWheelButton.Icon
	---@type CEGUIStaticImage
	self.siBodyGoldenWheelButtonRedDot = self.Body.GoldenWheelButton.RedDot
	---@type CEGUIStaticText
	self.stBodyGoldenWheelButtonTitle = self.Body.GoldenWheelButton.Title
	---@type CEGUIButton
	self.btnBodyCombinationGiftButton = self.Body.CombinationGiftButton
	---@type CEGUIStaticImage
	self.siBodyCombinationGiftButtonIcon = self.Body.CombinationGiftButton.Icon
	---@type CEGUIStaticImage
	self.siBodyCombinationGiftButtonRedDot = self.Body.CombinationGiftButton.RedDot
	---@type CEGUIStaticText
	self.stBodyCombinationGiftButtonTitle = self.Body.CombinationGiftButton.Title
	---@type CEGUIButton
	self.btnBodyAbilityButton = self.Body.AbilityButton
	---@type CEGUIStaticImage
	self.siBodyAbilityButtonIcon = self.Body.AbilityButton.Icon
	---@type CEGUIStaticImage
	self.siBodyAbilityButtonRedDot = self.Body.AbilityButton.RedDot
	---@type CEGUIStaticText
	self.stBodyAbilityButtonRedDotNum = self.Body.AbilityButton.RedDot.Num
	---@type CEGUIStaticText
	self.stBodyAbilityButtonTitle = self.Body.AbilityButton.Title
	---@type CEGUIButton
	self.btnBodyPlayerActionButton = self.Body.PlayerActionButton
	---@type CEGUIStaticImage
	self.siBodyPlayerActionButtonIcon = self.Body.PlayerActionButton.Icon
	---@type CEGUIStaticText
	self.stBodyPlayerActionButtonTitle = self.Body.PlayerActionButton.Title
	---@type CEGUIDefaultWindow
	self.wBodyMissionInfo = self.Body.MissionInfo
	---@type CEGUIStaticImage
	self.siBodyMissionInfoCountDown = self.Body.MissionInfo.CountDown
	---@type CEGUIStaticText
	self.stBodyMissionInfoCountDownLeftTime = self.Body.MissionInfo.CountDown.LeftTime
	---@type CEGUIStaticText
	self.stBodyMissionInfoStateText = self.Body.MissionInfo.StateText
end

---@private
function WidgetPlayerBattleInfoWidget:initUI()
	self.stBodyAttributeButtonTitle:setText(Lang:toText("g2069_role_attribute"))
	self.stBodyAbilityButtonTitle:setText(Lang:toText("g2069_role_ability"))
	self.stBodyBagButtonTitle:setText(Lang:toText("g2069_role_bag"))
	self.stBodyRankButtonTitle:setText(Lang:toText("g2069_role_rank"))
	self.stBodyGoldenWheelButtonTitle:setText(Lang:toText("gui.limit.time.activity.gold.wheel.title"))
	self.stBodyCombinationGiftButtonTitle:setText(Lang:toText("gui.limit.time.combined.title"))
	self.stBodySubscribeButtonTitle:setText(Lang:toText("subscribe_vip_entrance"))
	self.stBodyBookButtonTitle:setText(Lang:toText("g2069_book_main_ui_title"))
	self.stBodyAwakeButtonTitle:setText(Lang:toText("g2069_awakening_title"))
	--self.siBodySubscribeButtonIcon:setImage("setting/DuiGou")

	local engine_version = EngineVersionSetting:getEngineVersion()
	if engine_version >= 20083 then
		self.btnBodySubscribeButton:setVisible(true)
	else
		self.btnBodySubscribeButton:setVisible(false)
	end
end

---@private
function WidgetPlayerBattleInfoWidget:initEvent()
	self.btnBodyBookButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:openWindow("UI/game_book/gui/win_book_wnd")
	end

	self.btnBodySubscribeButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Plugins.CallTargetPluginFunc("subscribe_vip", "UpdateSubscribeVipUIOpen", true)
	end

	self.btnBodyAttributeButton.onMouseClick = function()
		local ability = AbilitySystem:getAbility(Me)
		if not ability then
			return
		end
		
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--- 打开属性方案
		UI:openWindow("UI/game_role_common/gui/win_player_attribute")
	end

	self.btnBodyAbilityButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--- 打开能力界面
		UI:openWindow("UI/game_role_common/gui/win_simple_ability_bag")
	end
	self.btnBodyBagButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:openWindow("UI/game_role_common/gui/win_item_bag")
	end

	self.btnBodyRankButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--- 打开排行榜界面
		UI:openWindow("UI/rank/gui/win_rank")
	end
	self.btnBodyPlayerActionButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--- 打开玩家动作界面
		UI:openWindow("UI/player_action/gui/win_player_action")
	end

	self.btnBodyGoldenWheelButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Plugins.CallTargetPluginFunc("new_limited_time_activity", "openLimitTimeGoldenWheelWnd")
	end

	self.btnBodyCombinationGiftButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Plugins.CallTargetPluginFunc("new_limited_time_activity", "openLimitTimeCombinedWnd")
	end

	self.btnBodyAwakeButton.onMouseClick = function()
		---@type Ability
		local ability = AbilitySystem:getAbility(Me)
		if not ability then
			return
		end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:openWindow("UI/game_role_common/gui/win_ability_awake")
	end

end

--- 刷新按钮状态
function WidgetPlayerBattleInfoWidget:updateAwakeBtnState()
	if not self.btnList then
		self.btnList = {
			self.btnBodyAttributeButton,
			self.btnBodyAwakeButton,
			self.btnBodyBagButton,
			self.btnBodyBookButton,
			self.btnBodyRankButton,
		}
	end

	local showAwake = true
	local openLevel = World.cfg.awakeOpenLevel
	if openLevel and openLevel > 0 then
		local level = GrowthSystem:getLevel(Me)
		showAwake = level >= openLevel
	end
	self.btnBodyAwakeButton:setVisible(showAwake)

	if showAwake then
		local index = 2
		local startX = -30
		local space = -100
		for i = index, #self.btnList, 1 do
			---@type CEGUIButton
			local btn = self.btnList[i]
			btn:setXPosition({ 0, startX + (i - 1) * space })
		end
	else
		local index = 2
		local startX = -30
		local space = -100
		for i = index + 1, #self.btnList, 1 do
			---@type CEGUIButton
			local btn = self.btnList[i]
			btn:setXPosition({ 0, startX + (i - 2) * space })
		end
	end
end

---@private
function WidgetPlayerBattleInfoWidget:onOpen()
	--- 隐藏自身血量
	Me:setProp("hideHp", 1)
	Me:setEditorModHideHp("true")
	self:initData()
	self:initVirtualUI()
	self:updateHp(self.curHp, true)
	self:updateStamina(self.curMp, true)
	self:updateLevel(self.curlevel, true)
	self:updateExp(self.curExp, true)
	self:updateAbility()
	self:updateAbilityLevelInfo()
	self:updateAttributeRedDot()
	self:updateAbilityRedDot()
	self:updateBookRedDot()
	self:updateBagRedDot()
	self:updateCombinationGift()
	self:updateGoldenWheel()
	self:updateAwakeBtnState()
	self:updateActivityBtnPosition()
	self:updateMissionInfo()
	self:subscribeEvents()


	self.regenTimer = LuaTimer:scheduleTicker(function()
		self:onTick()
	end, 1)
end

function WidgetPlayerBattleInfoWidget:initVirtualUI()
	self.buffInfoList = {}
	self.buffInfoList[#self.buffInfoList + 1] = { node = self.wBodyBuffLocation1, icon = self.siBodyBuffLocation1BuffIcon, time = self.stBodyBuffLocation1BuffLeftTime }
	self.buffInfoList[#self.buffInfoList + 1] = { node = self.wBodyBuffLocation2, icon = self.siBodyBuffLocation2BuffIcon, time = self.stBodyBuffLocation2BuffLeftTime }
	for _, data in pairs(self.buffInfoList) do
		data.node:setVisible(false)
	end
end

function WidgetPlayerBattleInfoWidget:initData()
	self.events = {}
	self.maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
	self.curlevel = GrowthSystem:getLevel(Me)
	self.curExp = GrowthSystem:getExp(Me)
	self.curHp = self.maxHp
	self.maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
    self.curMp = self.maxMp
	self.maxLevel = PlayerLevelConfig:getMaxLevel()

	self.activityStatus = {}
	self.btnPositions = nil
	self.btnList = nil
	--- buff 处理
	self.buffList = {}
	self.buffList[1] = {}
	self.buffList[2] = {}
	self.hpTimer = nil
	self.mpTimer = nil
	self.regenTimer = nil

	self.missionTimer = nil

	--- 单位帧
	PROGRESS_INTERVAL = 2
	TEXT_INTERVAL = 5

	self.proFrame = { hp = 0, mp = 0 }
	self.txtFrame = { hp = 0, mp = 0 }
end

function WidgetPlayerBattleInfoWidget:onTick()
	if BattleSystem:isDead(Me) then
		return
	end

	if not self.hpTimer and self.curHp < self.maxHp then
		self.proFrame.hp = self.proFrame.hp + 1
		self.txtFrame.hp = self.txtFrame.hp + 1
		if self.proFrame.hp >= PROGRESS_INTERVAL then
			self.proFrame.hp = 0
			local hpRegen = AttributeSystem:getAttributeValue(Me, Define.ATTR.HP_REGEN)
			self.curHp = math.clamp(GameLib.keepPreciseDecimal((hpRegen * self.maxHp) / (20 / PROGRESS_INTERVAL) + self.curHp, 1), 0, self.maxHp)
			local curPro = math.clamp(self.curHp / self.maxHp, 0, 1)
			self.pbBodyHpBar:setProgress(curPro)
		end
		if self.txtFrame.hp >= TEXT_INTERVAL or self.curHp >= self.maxHp then
			self.txtFrame.hp = 0
			local value = GameLib.round(self.curHp)
			if value == 0 and self.curHp > 0 then
				value = 1
			end
			self.stBodyHpBarValue:setText(GameLib.formatUINumber(value) .. "/" .. GameLib.formatUINumber(self.maxHp))
		end
	end

	if not self.mpTimer and self.curMp < self.maxMp then
		self.proFrame.mp = self.proFrame.mp + 1
		self.txtFrame.mp = self.txtFrame.mp + 1
		if self.proFrame.mp >= PROGRESS_INTERVAL then
			self.proFrame.mp = 0
			local hpRegen = AttributeSystem:getAttributeValue(Me, Define.ATTR.MP_REGEN)
			self.curMp = math.clamp(GameLib.keepPreciseDecimal((hpRegen * self.maxMp) / (20 / PROGRESS_INTERVAL) + self.curMp, 1), 0, self.maxMp)
			local curPro = math.clamp(self.curMp / self.maxMp, 0, 1)
			self.pbBodyStaminaBar:setProgress(curPro)
		end
		if self.txtFrame.mp >= TEXT_INTERVAL or self.curMp >= self.maxMp then
			self.txtFrame.mp = 0
			local value = GameLib.round(self.curMp)
			if value == 0 and self.curMp > 0 then
				value = 1
			end
			self.stBodyStaminaBarValue:setText(GameLib.formatUINumber(GameLib.round(value)) .. "/" .. GameLib.formatUINumber(self.maxMp))
		end
	end
end

--- 刷新活动按钮位置
function WidgetPlayerBattleInfoWidget:updateActivityBtnPosition()
	
	if not self.btnPositions then
		self.btnPositions = {}
		self.btnPositions[#self.btnPositions + 1] = { 
			x = self.btnBodyGoldenWheelButton:getXPosition()[2], 
			y = self.btnBodyGoldenWheelButton:getYPosition()[2] 
		}
		self.btnPositions[#self.btnPositions + 1] = { 
			x = self.btnBodyCombinationGiftButton:getXPosition()[2], 
			y = self.btnBodyCombinationGiftButton:getYPosition()[2] 
		}
	end

	local index = 0

	if self.activityStatus[Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL] then
		index = index + 1
		local position = self.btnPositions[index]
		self.btnBodyGoldenWheelButton:setXPosition({ 0, position.x })
		self.btnBodyGoldenWheelButton:setYPosition({ 0, position.y })
	end

	if self.activityStatus[Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT] then
		index = index + 1
		local position = self.btnPositions[index]
		self.btnBodyCombinationGiftButton:setXPosition({ 0, position.x })
		self.btnBodyCombinationGiftButton:setYPosition({ 0, position.y })
	end
end

--- 刷新混合礼包
---@param isOpen any
function WidgetPlayerBattleInfoWidget:updateCombinationGift(isOpen)
	if isOpen == nil then
		isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
	end
	self.activityStatus[Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT] = isOpen
	self.btnBodyCombinationGiftButton:setVisible(isOpen)
	self:updateCombinationGiftRedDot(isOpen)
end

--- 刷新混合礼包红点
function WidgetPlayerBattleInfoWidget:updateCombinationGiftRedDot(isRed)
	self.siBodyCombinationGiftButtonRedDot:setVisible(isRed)
end

--- 刷新转盘入口
---@param isOpen any
function WidgetPlayerBattleInfoWidget:updateGoldenWheel(isOpen)
	if isOpen == nil then
		isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL)
	end
	self.activityStatus[Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL] = isOpen
	self.btnBodyGoldenWheelButton:setVisible(isOpen)
	self.siBodyGoldenWheelButtonRedDot:setVisible(false)
end

--- 刷新进度条
function WidgetPlayerBattleInfoWidget:updateStamina(curMp, force)
	curMp = curMp or Me:getCurMp()
	if not force and self.curMp == curMp then
		return
	end
	if self.mpTimer then
		LuaTimer:cancel(self.mpTimer)
		self.mpTimer = nil
	end
	local preMp = self.curMp
    local pro = math.clamp(curMp / self.maxMp, 0, 1)
	if not force then
		local curPro = self.pbBodyStaminaBar:getProgress()
		if preMp > curMp and curPro > pro then
			self.curMp = curMp
			local value = GameLib.round(self.curMp)
			if value == 0 and self.curMp > 0 then
				value = 1
			end
			self.stBodyStaminaBarValue:setText(GameLib.formatUINumber(GameLib.round(value)) .. "/" .. GameLib.formatUINumber(self.maxMp))
			local frame = testSub(pro - curPro, 1)
			if frame > 0 then
				local del = (pro - curPro) / frame
				self.mpTimer = LuaTimer:scheduleTicker(function()
					frame = frame - 1
					if frame <= 0 then
						self.pbBodyStaminaBar:setProgress(pro)
						LuaTimer:cancel(self.mpTimer)
						self.mpTimer = nil
						self.proFrame.mp = -WAIT_INTERVAL
						self.txtFrame.mp = 0
					else
						curPro = curPro + del
						self.pbBodyStaminaBar:setProgress(curPro)
					end
				end, 1)
			else
				self.pbBodyStaminaBar:setProgress(pro)
			end
		end
		return
	end
	self.curMp = curMp
	local value = GameLib.round(self.curMp)
	if value == 0 and curMp > 0 then
		value = 1
	end
	self.stBodyStaminaBarValue:setText(GameLib.formatUINumber(value) .. "/" .. GameLib.formatUINumber(self.maxMp))
	self.pbBodyStaminaBar:setProgress(pro)
end

--- 更新血量
---@param curHp any
---@param force any
function WidgetPlayerBattleInfoWidget:updateHp(curHp, force)
	curHp = curHp or Me:getCurHp()
	if not force and self.curHp == curHp then
		return
	end
	if self.hpTimer then
		LuaTimer:cancel(self.hpTimer)
		self.hpTimer = nil
	end
	local preHp = self.curHp
	local pro = math.clamp(curHp / self.maxHp, 0, 1)
	if not force then
		local curPro = self.pbBodyHpBar:getProgress()
		if preHp > curHp and curPro > pro then
			self.curHp = curHp
			local value = GameLib.round(self.curHp)
			if value == 0 and self.curHp > 0 then
				value = 1
			end
			self.stBodyHpBarValue:setText(GameLib.formatUINumber(value) .. "/" .. GameLib.formatUINumber(self.maxHp))
			--- 处理扣血表现
			local frame = testSub(pro - curPro, 1)
			if frame > 0 then
				local del = (pro - curPro) / frame
				self.hpTimer = LuaTimer:scheduleTicker(function()
					frame = frame - 1
					if frame <= 0 then
						self.pbBodyHpBar:setProgress(pro)
						self.proFrame.hp = -WAIT_INTERVAL
						self.txtFrame.hp = 0
						LuaTimer:cancel(self.hpTimer)
						self.hpTimer = nil
					else
						curPro = curPro + del
						self.pbBodyHpBar:setProgress(curPro)
					end
				end, 1)
			else
				self.pbBodyHpBar:setProgress(pro)
			end
		end
		return
	end
	self.curHp = curHp
	local value = GameLib.round(self.curHp)
	if value == 0 and self.curHp > 0 then
		value = 1
	end
	self.stBodyHpBarValue:setText(GameLib.formatUINumber(value) .. "/" .. GameLib.formatUINumber(self.maxHp))
	self.pbBodyHpBar:setProgress(pro)
end

--- 属性等级红点
function WidgetPlayerBattleInfoWidget:updateAttributeRedDot()
	local remainPoint = AttributeSystem:getRemainPoint(Me)
	self.siBodyAttributeButtonRedDot:setVisible(remainPoint > 0)
	if remainPoint > 0 then
		if remainPoint > 99 then
			self.stBodyAttributeButtonRedDotNum:setText("99+")
		else
			self.stBodyAttributeButtonRedDotNum:setText(tostring(remainPoint))
		end
	end
end

local CHECK_INVENTORY_LIST = {
	Define.INVENTORY_TYPE.ABILITY,
	Define.INVENTORY_TYPE.BAG,
}

--- 刷新背包红点
function WidgetPlayerBattleInfoWidget:updateBagRedDot()
	for _, inventoryType in pairs(CHECK_INVENTORY_LIST) do
		local slots = InventorySystem:getAllSlots(Me, inventoryType)
		if slots then
			---@type number, Slot
			for _, slot in pairs(slots) do
				---@type Item
				local item = slot:getItem()
				if item 
					and slot:getAmount() > 0
					and not item:isInspected()

				then
					self.siBodyBagButtonRedDot:setVisible(true)
					return
				end
			end
		end
	end
	
	self.siBodyBagButtonRedDot:setVisible(false)
end

--- 刷新能力红点
function WidgetPlayerBattleInfoWidget:updateAbilityRedDot()
	local num = 0
	local red = 0

	local slots = InventorySystem:getAllSlots(Me, Define.INVENTORY_TYPE.ABILITY)
	if slots then
		---@type number, Slot
		for _, slot in pairs(slots) do
			---@type Ability
			local item = slot:getItem()
			--- 不需要处理数量
			if item and item:isUnlimited() then
				if not item:isUnlimitedInspected() then
					red = red + 1
				end
				num = num + 1
			end
		end
	end
	self.btnBodyAbilityButton:setVisible(num > 1)
	if num > 1 then
		if red > 0 then
			self.siBodyAbilityButtonRedDot:setVisible(true)
			if red > 99 then
				self.stBodyAbilityButtonRedDotNum:setText("99+")
			else
				self.stBodyAbilityButtonRedDotNum:setText(tostring(red))
			end
		else
			self.siBodyAbilityButtonRedDot:setVisible(false)
		end
	end
end

--- 刷新图鉴红点
function WidgetPlayerBattleInfoWidget:updateBookRedDot()
	local isShow = Me:isHaveBookRewardRed()
	self.siBodyBookButtonRedDot:setVisible(isShow)
end

--- 更新经验
---@param curExp any
---@param force any
function WidgetPlayerBattleInfoWidget:updateExp(curExp, force)
	if self.curlevel >= self.maxLevel then
		self.stBodyLevelInfoLevelValueExpValue:setVisible(false)
	else
		curExp = curExp or GrowthSystem:getExp(Me)
		if not force and self.curExp == curExp then
			return
		end

		self.curExp = curExp
		self.stBodyLevelInfoLevelValueExpValue:setVisible(true)
		local needExp = PlayerLevelConfig:getNeedExp(self.curlevel)
		local pro = math.clamp(curExp / needExp, 0, 1) * 100
		pro = GameLib.keepPreciseDecimal(pro, 2)
		self.stBodyLevelInfoLevelValueExpValue:setText("(" .. pro .. "%)")
	end
end

--- 更新等级
---@param curlevel any
---@param force any
function WidgetPlayerBattleInfoWidget:updateLevel(curlevel, force)
	curlevel = curlevel or GrowthSystem:getLevel(Me)
	if not force and self.curlevel == curlevel then
		return
	end
	self.curlevel = curlevel
	self.stBodyLevelInfoLevelValue:setText(Lang:toText("g2069_level_text") .. curlevel)
end

--- 刷新能力名称
function WidgetPlayerBattleInfoWidget:updateAbility()
	---@type Ability
	local ability = AbilitySystem:getAbility(Me)
	if ability then
		self.stBodyAbilityLevelAbilityName:setVisible(true)
		local name = ability:getName()
		self.stBodyAbilityLevelAbilityName:setText(Lang:toText(name))
	else
		self.stBodyAbilityLevelAbilityName:setVisible(false)
	end
end

--- 刷新能力等级数据
function WidgetPlayerBattleInfoWidget:updateAbilityLevelInfo()
	---@type Ability
	local ability = AbilitySystem:getAbility(Me)
	if ability then
		self.stBodyAbilityLevel:setVisible(true)
		local level = ability:getLevel()
		local maxLevel = AbilityConfig:getMaxLevel(ability:getItemId())
		if level >= maxLevel then
			self.stBodyAbilityLevel:setText("LV." .. level)
		else
			local exp = ability:getExp()
			local needExp = AbilityLevelConfig:getCfgByLevel(level).upgradePrice
			local pro = math.clamp(exp / needExp, 0, 1) * 100
			pro = GameLib.keepPreciseDecimal(pro, 2)
			self.stBodyAbilityLevel:setText("LV." .. level .. " (" .. pro .. "%)")
		end
	else
		self.stBodyAbilityLevel:setVisible(false)
	end
end

function WidgetPlayerBattleInfoWidget:subscribeEvents()
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_CURRENT_HP, function(value)
		self:updateHp(value)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA, function()
		self.maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
		self.maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
		self:updateHp(self.maxHp, true)
		self:updateStamina(self.maxMp, true)
		self:updateLevel()
		self:updateExp()
		self:updateAbility()
		self:updateAbilityLevelInfo()
		self:updateAttributeRedDot()
		self:updateAbilityRedDot()
		self:updateBagRedDot()
		self:updateBookRedDot()
		self:updateAwakeBtnState()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
		--- 等级有改变
		if addLevel ~= 0 then
			local level = GrowthSystem:getLevel(Me)
			if not self.curlevel or self.curlevel ~= level then
				self.maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
				self.maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
				self:updateHp(self.maxHp, true)
				self:updateStamina(self.maxMp, true)
			end
			self:updateLevel()
			self:updateAttributeRedDot()
			self:updateAwakeBtnState()
		end
		if addExp ~= 0 then
			self:updateExp()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_POINT, function(success, player, index, id, alevel)
		---红点处理
		if success then
			self:updateAttributeRedDot()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ATTRIBUTE_CHANGE, function(player, id)
		--- 等级有改变
		if player.objID == Me.objID then
			if id == Define.ATTR.MAX_HP then
				local maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
				if maxHp ~= self.maxHp then
					self.maxHp = maxHp
					self:updateHp(self.curHp, true)
				end
			elseif id == Define.ATTR.MAX_MP then
				local maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
				if self.maxMp ~= maxMp then
					self.maxMp = maxMp
					self:updateStamina(self.curMp, true)
				end
			end
			
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_UNLOCK, function(success, player, unlockIndex, preIndex)
		if success then
			self:updateAttributeRedDot()
		end
    end)
	
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_INDEX, function(success, player, index)
		if success then
			self:updateAttributeRedDot()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_RESET_POINT_SET, function(success, player, index)
		if success then
			self:updateAttributeRedDot()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, function(player, item, addAmount)
		if item:getItemType() == Define.ITEM_TYPE.ABILITY then
			if item:isUnlimited() then
				self:updateAbilityRedDot()
			end
		end
		if addAmount ~= 0 then
			self:updateBagRedDot()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, function(player, item, addAmount)
		if item:getItemType() == Define.ITEM_TYPE.ABILITY and item:isUnlimited() then
			if item:isUnlimited() then
				self:updateAbilityRedDot()
			end
			self:updateBookRedDot()
		end
		if addAmount ~= 0 then
			self:updateBagRedDot()
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_BOOK_REWARD_STATE, function()
		self:updateBookRedDot()
	end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_UNLIMITED, function(player, ability)
		self:updateAbilityRedDot()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_INSPECT_ABILITY, function()
		self:updateAbilityRedDot()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_INSPECT_ITEM, function()
		self:updateBagRedDot()
    end)
	
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success)
		if not success then
			return
		end
		self:updateAbility()
		self:updateAbilityLevelInfo()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_EXP, function()
		self:updateAbilityLevelInfo()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_CURRENT_MP, function(value)
        self:updateStamina(value)
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_NEW_LIMITED_TIME_ACTIVITY_UPDATE_COMBINATION_GIFT, function(isOpen)
		self:updateCombinationGift(isOpen)
		self:updateActivityBtnPosition()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_NEW_LIMITED_TIME_ACTIVITY_UPDATE_GOLDEN_WHEEL, function(isOpen)
		self:updateGoldenWheel(isOpen)
		self:updateActivityBtnPosition()
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_ENTRY_RED_DOY, function(value, activityType)
		if activityType == Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT then
			self:updateCombinationGiftRedDot(value)
		end
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_ADD_BUFF, function(id)
		self:addBuff(id)
    end)
	
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_REMOVE_BUFF, function(id)
		self:removeBuff(id)
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_BUFF, function(id)
		self:updateBuff(id)
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_REVIVE, function(player)
		self:updateHp(self.maxHp, true)
		self:updateStamina(self.maxMp, true)
    end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_UPDATE_SUBSCRIBE_RED_SHOW, function(value)
		self.siBodySubscribeButtonRedDot:setVisible(value)
	end)

	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_UPDATE_MISSION_STATE, function()
		self:updateMissionInfo()
	end)
end

--- 更新副本状态
function WidgetPlayerBattleInfoWidget:updateMissionInfo()
	if self.missionTimer then
		LuaTimer:cancel(self.missionTimer)
		self.missionTimer = nil
	end
	local data = Me:getMissionStateData()
	if data and data.state then
		local state = data.state
		--- 倒计时时间
		local endTime = nil
		if state == Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER then
			endTime = data.endTime
			if data.mode == Define.MISSION_PLAY_MODE.MULTIPLE and Me:isInMissionRoom() then
				self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_waiting_time"))
			else
				self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_waiting_time_single"))
			end
		elseif state == Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS then
			endTime = data.endTime
			self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_complete_time"))
		elseif state == Define.MISSION_ROOM_STATE.MISSION_STAGE_INIT then
			endTime = data.endTime
			self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_stages_change_time"))
		elseif state == Define.MISSION_ROOM_STATE.MISSION_STAGE_MASK then
			--- 显示黑屏
			local args = {
				fadeOutEvent = "EVENT_GAME_MISSION_STAGE_INIT_STATE_EXIT_MASK",
				fadeOutTime = 5,	--- 最长等待时间
			}
			UI:openWindow("UI/game_role_common/gui/win_fade_mask", nil, nil, args)
		elseif state == Define.MISSION_ROOM_STATE.MISSION_COMPLETE then
			endTime = data.endTime
			if data.code == Define.MISSION_COMPLETE_CODE.SUCCESS then
				--- 成功
				self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_finish_time"))
			else
				--- 失败
				self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_fail_time_end"))
			end
		elseif state == Define.MISSION_ROOM_STATE.MISSION_START then
			endTime = data.endTime
			self.stBodyMissionInfoStateText:setText(Lang:toText("g2069_mission_tips_waiting_battle_time"))
			Lib.emitEvent(Event.EVENT_GAME_MISSION_STAGE_INIT_STATE_EXIT_MASK)
		end

		--- 显示倒计时
		if endTime then
			local time = math.max(endTime - os.time(), 0)
			if time > 0 then
				self.wBodyMissionInfo:setVisible(true)
				self.stBodyMissionInfoCountDownLeftTime:setText(tostring(time))
				self.missionTimer = LuaTimer:scheduleTicker(function()
					if time <= 0 then
						LuaTimer:cancel(self.missionTimer)
						self.missionTimer = nil
						self.wBodyMissionInfo:setVisible(false)
					end
					time = math.max(endTime - os.time(), 0)
					self.stBodyMissionInfoCountDownLeftTime:setText(tostring(time))
				end, 20)
			end
			return
		end
	end
	
	self.wBodyMissionInfo:setVisible(false)
end

function WidgetPlayerBattleInfoWidget:addBuff(id)
	local buff = Me:getBuffById(id)
	local location = buff.cfg.location
	if location and location ~= 0 then
		local buffList = self.buffList[location]
		buffList[#buffList + 1] = id
		--- 刷新
		self:updateBuffInfo(location, buff)
	end
end

function WidgetPlayerBattleInfoWidget:removeBuff(id)
	local buff = Me:getBuffById(id)
	local location = buff.cfg.location
	if location and location ~= 0 then
		local buffList = self.buffList[location]
		local len = #buffList
		for i = 1, len, 1 do
			if buffList[i] == id then
				table.remove(buffList, i)
				if i == len then
					Me:showGameTopTips(Lang:toText({ "g2069_buff_disappear", buff.cfg.name }))
					--- 刷新
					local temp = nil
					if #buffList > 0 then
						temp = Me:getBuffById(buffList[#buffList])
					end
					self:updateBuffInfo(location, temp)
				end
				break
			end
		end
	end
end

function WidgetPlayerBattleInfoWidget:updateBuff(id)
	local buff = Me:getBuffById(id)
	local location = buff.cfg.location
	if location and location ~= 0 then
		local buffList = self.buffList[location]
		if buffList[#buffList] == id then
			self:updateBuffInfo(location, buff)
		end
	end
end

local hour = 60 * 60 
local min = 60

--- 格式化时间
---@param leftTime number 剩余时间，单位帧
local parseTime = function(leftTime)
	leftTime = math.ceil(leftTime / 20)
	local str = nil
	if leftTime >= hour then
		local h = math.floor(leftTime / hour)
		str = tostring(h) .. "h"
		leftTime = leftTime - h * hour
	end
	if leftTime >= min then
		local m = math.floor(leftTime / min)
		str = (str or "") .. tostring(m) .. "m"
		leftTime = leftTime - m * min
	end
	str = (str or "") .. tostring(leftTime) .. "s"
	return str
end

--- 显示buff
---@param location number 索引
---@param buff any
function WidgetPlayerBattleInfoWidget:updateBuffInfo(location, buff)
	local data = self.buffInfoList[location]
	if data then
		local ndoe = data.node
		if data.timer then
			LuaTimer:cancel(data.timer)
			data.timer = nil
		end
		if buff and buff.time and buff.time > 0 then
			---@type CEGUIStaticImage
			local iconImg = data.icon
			local id = buff.id
			ndoe:setVisible(true)
			iconImg:setImage(buff.cfg.icon)
			--- 剩余时间，单位帧
			local leftTime = buff.time
			---@type CEGUIStaticText
			local timeText = data.time

			local showRemain1Min = false
			if leftTime <= 1200 then
				showRemain1Min = true
			end
			local buffName = buff.cfg.name

			--- 显示时间
			local updateLeftTime = function(noReduce)
				if not noReduce then
					leftTime = leftTime - 20
				end
				if leftTime <= 0 then
					-- Me:showGameTopTips(Lang:toText({ "g2069_buff_disappear", buffName }))
					return false
				end
				local strTime = parseTime(leftTime)
				timeText:setText(strTime)

				if not showRemain1Min and leftTime <= 1200 then
					showRemain1Min = true
					Me:showGameTopTips(Lang:toText({ "g2069_buff_about_to_disappear", buffName }))
				end

				return true
			end
			
			updateLeftTime(true)

			data.timer = LuaTimer:scheduleTicker(function()
				if not updateLeftTime() then
					LuaTimer:cancel(data.timer)
					data.timer = nil
					ndoe:setVisible(false)
					self:removeBuff(id)
				end
			end, 20)
		else
			ndoe:setVisible(false)
		end
	end
end

function WidgetPlayerBattleInfoWidget:unsubscribeEvents()
    if self.events then
        for _, func in pairs(self.events) do
            func()
        end
        self.events = nil
    end
end

---@private
function WidgetPlayerBattleInfoWidget:onDestroy()
	if self.buffInfoList then
		for _, data in pairs(self.buffInfoList) do
			if data.timer then
				LuaTimer:cancel(data.timer)
				data.timer = nil
			end
		end
	end
	self:unsubscribeEvents()
	if self.hpTimer then
		LuaTimer:cancel(self.hpTimer)
		self.hpTimer = nil
	end
	if self.mpTimer then
		LuaTimer:cancel(self.mpTimer)
		self.mpTimer = nil
	end
	if self.regenTimer then
		LuaTimer:cancel(self.regenTimer)
		self.regenTimer = nil
	end
	if self.missionTimer then
		LuaTimer:cancel(self.missionTimer)
		self.missionTimer = nil
	end
end

WidgetPlayerBattleInfoWidget:init()
