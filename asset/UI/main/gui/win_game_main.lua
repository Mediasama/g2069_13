---@class WinGameMainLayout : CEGUILayout
local WinGameMainLayout = M
---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")

---@type GameLib
local GameLib = T(Lib, "GameLib")
---@type GameTimes
local GameTimes = T(Lib, "GameTimes")
---@type NpcSystemHelper
local NpcSystemHelper = T(Lib, "NpcSystemHelper")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

---@private
function WinGameMainLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinGameMainLayout:findAllWindow()
	---@type CEGUIButton
	self.btnSettingBtn = self.SettingBtn
	---@type CEGUIButton
	self.btnFriendBtn = self.FriendBtn
	---@type CEGUIButton
	self.btnVideoBtn = self.VideoBtn
	---@type CEGUIButton
	self.btnPkBtn = self.PkBtn
	---@type CEGUIButton
	self.btnResetBtn = self.ResetBtn
	---@type CEGUIEffectWindow
	self.wHurtEffect = self.HurtEffect
	---@type CEGUIButton
	self.btnGMBtn = self.GMBtn
	---@type CEGUIDefaultWindow
	self.wCoinNode = self.CoinNode
	---@type CEGUIStaticText
	self.stSafeText = self.SafeText
	---@type CEGUIStaticText
	self.stSafeDeadText = self.SafeDeadText
	---@type CEGUIDefaultWindow
	self.wTimePanel = self.TimePanel
	---@type CEGUIStaticImage
	self.siTimePanelTimeBg = self.TimePanel.TimeBg
	---@type CEGUIStaticText
	self.stTimePanelTimeText = self.TimePanel.TimeText
	---@type CEGUIStaticText
	self.stTimePanelDayText = self.TimePanel.DayText
end

---@private
function WinGameMainLayout:initUI()
	self.wHurtEffect:setVisible(false)
	if World.cfg.openGM then
		self.btnGMBtn:setVisible(true)
	else
		self.btnGMBtn:setVisible(false)
	end
	self.stSafeText:setText(Lang:toText("g2069_main_ui_safe_tips"))
	self.stSafeDeadText:setText(Lang:toText("g2069_safe_region_leave_pk"))
end

---@private
function WinGameMainLayout:initEvent()
	self._allEvent = {}

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_HURT_UI_EFFECT, function()
		self.wHurtEffect:setVisible(true)
		self.wHurtEffect:playEffect()
	end)

	self._allEvent[#self._allEvent + 1]  = Lib.subscribeEvent(Event.EVENT_SAFE_MODE_UPDATE, function(value)
		self:updatePKBtnShowState()
		self:updateSafeTextShow()
	end)

	self._allEvent[#self._allEvent + 1]  = Lib.subscribeEvent(Event.EVENT_SAFE_REGION_UPDATE, function()
		self:updateSafeTextShow()
	end)

	self._allEvent[#self._allEvent + 1]  = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
		if player.objID == Me.objID and addLevel > 0 then
			local curLevel = GrowthSystem:getLevel(player)
			for i = 1, addLevel do
				local text = Lang:toText({"g2069_up_level_tips", curLevel - addLevel + i })
				Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", text)
			end
		end
	end)

	self._allEvent[#self._allEvent + 1]  = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA, function()
		self:updateResetBtnState()
	end)

	self._allEvent[#self._allEvent + 1]  = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, function(player, ability, addLevel)
		if player.objID == Me.objID and addLevel > 0 then
			local quality_alias = ability:getQuality() or ""
			local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality_alias]
			local name = ability:getName()
			local showName
			if qualityColor then
				local color = string.format("[colour='%s']", qualityColor)
				local color2 = string.format("[colour='%s']", World.cfg.fly_new_tipsSetting.textColours)
				showName = color .. Lang:toText(name) .. color2
			else
				showName = Lang:toText(name)
			end
			local curLevel = ability:getLevel()
			for i = 1, addLevel do
				local text = Lang:toText({"g2069_ability_level_tips", showName, curLevel - addLevel + i })
				Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", text)
			end
		end
	end)

	self.btnSettingBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")

		local settingWnd = UI:isOpenWindow("UI/setting/gui/win_new_setting")
		if settingWnd then
			settingWnd:setVisible(not settingWnd:isVisible())
		else
			settingWnd = UI:openSystemWindow("UI/setting/gui/win_new_setting")
		end

		--local settingWnd = UI:isOpenWindow("setting")
		--if settingWnd then
		--	settingWnd:setVisible(not settingWnd:isVisible())
		--else
		--	settingWnd = UI:openSystemWindow("setting")
		--end
	end

	self.btnGMBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
	end

	self.btnPkBtn.onMouseClick = function()
		local safeModeType = Me:getSafeModeType()
		if safeModeType == Define.PKModeType.safe then
			Me:setSafeModeType(Define.PKModeType.pkWait)
		elseif safeModeType == Define.PKModeType.pk1 or safeModeType == Define.PKModeType.pk2 then
			Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "g2069_pk_state_click_tips")
		end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
	end

	self.btnFriendBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:openWindow("UI/friend/gui/win_g2060Friend")
	end

	self.btnVideoBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self.btnVideoBtn:setNormalImage("gameres|asset/imageset/common:btn_0_video2")
		Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", true)
	end

	self:subscribeEvent(Event.EVENT_CLOSE_WINDOW, function(uiName)
		if uiName == "UI/new_video/gui/win_video_mode" then
			self.btnVideoBtn:setNormalImage("gameres|asset/imageset/common:btn_0_video1")
		end
	end)

	self.btnResetBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:playerResetPosition()
	end
end

function WinGameMainLayout:updateResetBtnState()
	if Me:isInMissionRoom() then
		self.btnResetBtn:setVisible(false)
	else
		self.btnResetBtn:setVisible(true)
	end
end

function WinGameMainLayout:playerResetPosition()
	if Me:getPlayerIsInBattleState() then
		Me:showGameTopTips(Lang:toText("g2069_reset_location_battle"))
		return
	end
	if Me:isInStateType(Define.RoleStatus.IN_TELEPORT) or Me:isInMissionRoom() then
		return
	end

	local curTime = os.time()
	local resetPosTime = Me:getResetPosTime()
	if resetPosTime > 0 then
		local delta = math.clamp(World.cfg.resetPosTime - (curTime - resetPosTime), 0, World.cfg.resetPosTime)
		if delta > 0 then
			--- 弹出提示
			Me:showGameTopTips(Lang:toText({ "g2069_reset_location_cdtips", GameLib.formatLeftTime(delta) }))
			return
		end
	end

	Me:showConfirm(
		"",
		Lang:toText("g2069_reset_location_confirm"),
		function()
			if Me:getPlayerIsInBattleState() then
				Me:showGameTopTips(Lang:toText("g2069_reset_location_battle"))
				return
			end
			if Me:isInStateType(Define.RoleStatus.IN_TELEPORT) or Me:isInMissionRoom() then
				return
			end
			local map = Me.map
			if map and map.name ~= "map_born" then
				local mapName = map.name
				local config = PlayerBornConfig:getCfgByMapName(mapName)
				local position = nil
				local rebornPositions = config.rebornPositions
				local len = #rebornPositions
				if len > 0 then
					local index = 1
					if len > 1 then
						index = math.random(1, len)
					end
					position = rebornPositions[index]
				end
				if not position then
					position = config.bornPosition
				end
				Me:teleportToMapPosition(mapName, position, function(success)
					if success then
						Me:setResetPosTime(os.time())
					end
				end)
			end
		end
	)
end

function WinGameMainLayout:initView()
	self.wTimePanel:setVisible(false)
	local preHour = -1
	self._timer[#self._timer + 1] = Me:timer(10, function()
		local tbTime = GameTimes:GetTime()
		local min = tbTime.min >= 10 and tostring(tbTime.min) or ("0" .. tbTime.min)
		local time = tbTime.hour .. ":" .. min
		self.stTimePanelTimeText:setText(time)
		self.stTimePanelDayText:setText(Lang:toText(Define.GameTimeDay[tbTime.day]))
		if preHour ~= tbTime.hour then
			preHour = tbTime.hour
		end
		NpcSystemHelper:updateNpcTimeShow()
		return true
	end)
end

---@private
function WinGameMainLayout:onOpen()
	self._timer = {}
	self:initView()
	self:showBattleInfo()
	self:showCommonCoin()
	self:updatePKBtnShowState()
	self:updateSafeTextShow()
	self:updateResetBtnState()
end

function WinGameMainLayout:updatePKBtnShowState()
	local safeModeType = Me:getSafeModeType()
	if safeModeType == Define.PKModeType.safe
			or safeModeType == Define.PKModeType.pkWait then
		self.btnPkBtn:setNormalImage("gameres|asset/imageset/common:btn_0_pk1")
		self.btnPkBtn:setPushedImage("gameres|asset/imageset/common:btn_0_pk1")
	else
		self.btnPkBtn:setNormalImage("gameres|asset/imageset/common:btn_0_pk2")
		self.btnPkBtn:setPushedImage("gameres|asset/imageset/common:btn_0_pk2")
	end

	if self.safePkTimer then
		self.safePkTimer()
		self.safePkTimer = nil
	end
	if safeModeType == Define.PKModeType.safe then
		local totalTime = World.cfg.pkWaitEnter.autoCloseSafe
		self.safePkTimer = Me:timer(20, function()
			totalTime = totalTime - 1
			if totalTime <= 0 then
				Me:setSafeModeType(Define.PKModeType.pkWait)
				self.safePkTimer()
				self.safePkTimer = nil
				return false
			end
			return true
		end)
	end
end

function WinGameMainLayout:updateSafeTextShow()
	if Me:isInMissionSafe() or Me:isInMissionRoom() then
		self.stSafeText:setText(Lang:toText("g2069_mission_safe_tips"))
		self.stSafeText:setVisible(true)
		self.stSafeDeadText:setVisible(false)
		return
	else
		self.stSafeText:setText(Lang:toText("g2069_main_ui_safe_tips"))
	end

	local safeModeType = Me:getSafeModeType()
	if safeModeType == Define.PKModeType.safe
			or safeModeType == Define.PKModeType.pkWait
			or safeModeType == Define.PKModeType.pk1 then
		if Me:isInSafeRegion() then
			self.stSafeText:setVisible(true)
		else
			self.stSafeText:setVisible(false)
		end
	else
		self.stSafeText:setVisible(false)
	end

	if safeModeType == Define.PKModeType.safe
			or safeModeType == Define.PKModeType.pkWait then
		if Me:isInSafeRegion() then
			self.stSafeDeadText:setVisible(false)
		else
			self.stSafeDeadText:setVisible(true)
		end
	else
		self.stSafeDeadText:setVisible(false)
	end
end

function WinGameMainLayout:showBattleInfo()
	if not self.battleInfoNode then
		local node = UI:openWidget("UI/main/gui/widget_player_battle_info")
		self:addChild(node:getWindow())
		self.battleInfoNode = node
	end
end

function WinGameMainLayout:showCommonCoin()
	if not self.commonCoin then
		local node = UI:openWidget("UI/game_coin/gui/widget_common_coin")
		self.wCoinNode:addChild(node:getWindow())
		self.commonCoin = node
	end
end

---@private
function WinGameMainLayout:onDestroy()

end

---@private
function WinGameMainLayout:onClose()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end

	if self._timer then
		for k, fun in pairs(self._timer) do
			fun()
		end
	end

	if self.safePkTimer then
		self.safePkTimer()
		self.safePkTimer = nil
	end
end

WinGameMainLayout:init()
