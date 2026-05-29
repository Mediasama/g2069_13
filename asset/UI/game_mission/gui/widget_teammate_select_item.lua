---@class WidgetTeammateSelectItemWidget : CEGUILayout
local WidgetTeammateSelectItemWidget = M
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")

---@private
function WidgetTeammateSelectItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetTeammateSelectItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIDefaultWindow
	self.wPanelHead = self.PanelHead
	---@type CEGUIStaticImage
	self.siPanelHeadImageHead = self.PanelHead.ImageHead
	---@type CEGUIStaticImage
	self.siPanelHeadImageFrame = self.PanelHead.ImageFrame
	---@type CEGUIStaticText
	self.stPanelHeadLevelText = self.PanelHead.LevelText
	---@type CEGUIStaticText
	self.stNameText = self.NameText
	---@type CEGUIStaticText
	self.stCountText = self.CountText
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
	---@type CEGUIStaticImage
	self.siMaskPanel = self.MaskPanel
	---@type CEGUIStaticImage
	self.siReasonIcon = self.ReasonIcon
end

---@private
function WidgetTeammateSelectItemWidget:initUI()
	self.callHandlers = {}
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetTeammateSelectItemWidget:registerCallHandler(key, context, func)
	self.callHandlers[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetTeammateSelectItemWidget:callHandler(key, ...)
	local handler = self.callHandlers[key]
	if handler then
		local this = handler.this
		local func = handler.func
		return func(this, key, ...)
	end
end

---@private
function WidgetTeammateSelectItemWidget:initEvent()
	self._allEvent = {}
	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_MISSION_TEAMMATE_USERID, function(curSelectList)
		self:updateSelectShow(curSelectList)
	end)

	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_MISSION_TEAMMATE_HEAD, function()
		self:updatePlayerHeadInfo()
	end)

	self.btnClickButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:callHandler("select_item", self.data.userId)
	end
end

function WidgetTeammateSelectItemWidget:setIsCanClick(canClick)
	self.canClick = canClick
end

function WidgetTeammateSelectItemWidget:initData(data)
	self.data = data
	self.curMissionId = data.curMissionId
	if self.curMissionId then
		self.missionCfg = MissionInfoConfig:getCfgByMissionId(self.curMissionId)
	end

	self.stPanelHeadLevelText:setText(Lang:toText("Lv." .. data.level))
	self.stNameText:setText(data.playerName)
	self.stCountText:setText(Lang:toText({"g2069_select_teammate_remain_tips", data.remainCounts }))

	local curSelectList = self:callHandler("selected_item")
	self:updateSelectShow(curSelectList)

	self:updatePlayerHeadInfo()
end

function WidgetTeammateSelectItemWidget:updatePlayerHeadInfo()
	if not self.data then
		return
	end
	local picUrl = ""
	local sex = 1
	local cache = UserInfoCache.GetCache(self.data.userId)
	if cache then
		picUrl = cache.picUrl or ""
		sex = cache.sex or 1
		if cache.name and cache.name ~= "" then
			self.stNameText:setText(cache.name)
		end
	end
	if picUrl == "" then
		picUrl = World.cfg.defaultAvatar
	end
	self.siPanelHeadImageHead:setImage(picUrl)
	if sex == 1 then
		self.siPanelHeadImageFrame:setImage("gameres|asset/imageset/chat2:img_9_headframe_players")
	else
		self.siPanelHeadImageFrame:setImage("gameres|asset/imageset/chat2:img_9_headframe_captain")
	end
end

function WidgetTeammateSelectItemWidget:updateSelectShow(curSelectList)
	local isFull = false
	if self.missionCfg then
		local selectNum = 0
		for userId, state in pairs(curSelectList or {}) do
			if state then
				selectNum = selectNum + 1
			end
		end
		isFull = selectNum >= (self.missionCfg.join_player_max - 1)
	end
	if not self.canClick then
		self.siSelectedBg:setVisible(false)
		self.siReasonIcon:setVisible(false)
		self.btnClickButton:setVisible(false)
		self.siMaskPanel:setVisible(false)
	elseif self.data.selectState == 0 then
		self.siSelectedBg:setVisible(false)
		self.siReasonIcon:setVisible(self.data.isInMission)
		self.btnClickButton:setVisible(false)
		self.siMaskPanel:setVisible(true)
	else
		local isSelect = false
		for userId, state in pairs(curSelectList or {}) do
			if state and (userId == self.data.userId) then
				isSelect = true
			end
		end
		self.siSelectedBg:setVisible(isSelect)

		self.siReasonIcon:setVisible(false)
		if isFull then
			if isSelect then
				self.btnClickButton:setVisible(true)
				self.siMaskPanel:setVisible(false)
			else
				self.btnClickButton:setVisible(false)
				self.siMaskPanel:setVisible(true)
			end
		else
			self.btnClickButton:setVisible(true)
			self.siMaskPanel:setVisible(false)
		end
	end
end

---@private
function WidgetTeammateSelectItemWidget:onOpen()

end

---@private
function WidgetTeammateSelectItemWidget:onDestroy()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WidgetTeammateSelectItemWidget:init()
