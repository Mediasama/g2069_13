---@class WinTeammateSelectLayout : CEGUILayout
local WinTeammateSelectLayout = M

---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type widget_virtual_grid
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")

--- 定义事件
local CALL_EVENT = {
	SELECT_ITEM = "select_item",
	IS_SELECTED_ITEM = "selected_item",
}

---@private
function WinTeammateSelectLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinTeammateSelectLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wWindowPanel = self.WindowPanel
	---@type CEGUIStaticImage
	self.siWindowPanelBg = self.WindowPanel.Bg
	---@type CEGUIStaticText
	self.stWindowPanelTitle = self.WindowPanel.Title
	---@type CEGUIDefaultWindow
	self.wWindowPanelLeftPanel = self.WindowPanel.LeftPanel
	---@type CEGUIStaticImage
	self.siWindowPanelLeftPanelLeftBg = self.WindowPanel.LeftPanel.LeftBg
	---@type CEGUIStaticImage
	self.siWindowPanelLeftPanelLeftTopBg = self.WindowPanel.LeftPanel.LeftTopBg
	---@type CEGUIStaticText
	self.stWindowPanelLeftPanelText = self.WindowPanel.LeftPanel.Text
	---@type CEGUIScrollableView
	self.wWindowPanelLeftPanelLeftSv = self.WindowPanel.LeftPanel.LeftSv
	---@type CEGUIGridView
	self.gvWindowPanelLeftPanelLeftSvLeftGv = self.WindowPanel.LeftPanel.LeftSv.LeftGv

	---@type CEGUIStaticImage
	self.siWindowPanelNoItemBg = self.WindowPanel.LeftPanel.NoItemBg
	---@type CEGUIStaticText
	self.stWindowPanelNoneText = self.WindowPanel.LeftPanel.NoItemBg.Title

	---@type CEGUIDefaultWindow
	self.wWindowPanelRightPanel = self.WindowPanel.RightPanel
	---@type CEGUIStaticImage
	self.siWindowPanelRightPanelRightBg = self.WindowPanel.RightPanel.RightBg
	---@type CEGUIStaticImage
	self.siWindowPanelRightPanelRightTopBg = self.WindowPanel.RightPanel.RightTopBg
	---@type CEGUIStaticText
	self.stWindowPanelRightPanelText = self.WindowPanel.RightPanel.Text
	---@type CEGUIScrollableView
	self.wWindowPanelRightPanelRightSv = self.WindowPanel.RightPanel.RightSv
	---@type CEGUIVerticalLayoutContainer
	self.wWindowPanelRightPanelRightSvRightVc = self.WindowPanel.RightPanel.RightSv.RightVc
	---@type CEGUIButton
	self.btnWindowPanelCloseButton = self.WindowPanel.CloseButton
	---@type CEGUIButton
	self.btnWindowPanelNextBtn = self.WindowPanel.NextBtn
	---@type CEGUIButton
	self.btnWindowPanelRefreshBtn = self.WindowPanel.RefreshBtn
end

---@private
function WinTeammateSelectLayout:initUI()
	self.stWindowPanelTitle:setText(Lang:toText("g2069_select_teammate_main_title"))
	self.stWindowPanelLeftPanelText:setText(Lang:toText("g2069_select_teammate_left_title"))
	self.stWindowPanelNoneText:setText(Lang:toText("g2069_select_teammate_none_tips"))

	self.btnWindowPanelNextBtn:setText(Lang:toText("g2069_select_mission_open_text"))
	self.btnWindowPanelRefreshBtn:setText(Lang:toText("g2069_button_refresh_title"))

	self:initVirtualUI()
end

function WinTeammateSelectLayout:initVirtualUI()
	self.curSelectList = {}

	local this = self
	self.leftGv = widget_virtual_grid:init(
			self.wWindowPanelLeftPanelLeftSv,
			self.gvWindowPanelLeftPanelLeftSvLeftGv,
			function(self, parent)
				---@type WidgetTeammateSelectItemWidget
				local node = UI:openWidget("UI/game_mission/gui/widget_teammate_select_item")
				parent:addChild(node:getWindow())
				node:setIsCanClick(true)
				node:registerCallHandler(CALL_EVENT.SELECT_ITEM, this, this.onCallHandler)
				node:registerCallHandler(CALL_EVENT.IS_SELECTED_ITEM, this, this.onCallHandler)
				return node
			end,
			---@type any, WidgetMissionSelectItemWidget, table
			function(self, node, data)
				node:initData(data)
			end, 2
	)

	self.rightGv = widget_virtual_vert_list:init(
			self.wWindowPanelRightPanelRightSv,
			self.wWindowPanelRightPanelRightSvRightVc,
			function(self, parent)
				---@type WidgetTeammateSelectItemWidget
				local node = UI:openWidget("UI/game_mission/gui/widget_teammate_select_item")
				parent:addChild(node:getWindow())
				node:setIsCanClick(false)
				node:registerCallHandler(CALL_EVENT.IS_SELECTED_ITEM, this, this.onCallHandler)
				return node
			end,
			---@type any, WidgetMissionSelectItemWidget, table
			function(self, node, data)
				node:initData(data)
			end)
end

--- 回调
---@param event any
function WinTeammateSelectLayout:onCallHandler(event, ...)
	if event == CALL_EVENT.SELECT_ITEM then
		local userId = table.unpack({...})
		self:updateCurClickPlayer(userId)
	elseif event == CALL_EVENT.IS_SELECTED_ITEM then
		return self.curSelectList or {}
	end
end

---@private
function WinTeammateSelectLayout:initEvent()
	self._allEvent = {}

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_SELECT_TEAMMATE, function(missionId, playerList)
		if missionId == self.curMissionId then
			self:updateViewShow(playerList)
		end
	end)

	self.btnWindowPanelCloseButton.onMouseClick = function()
		UI:closeWindow("UI/game_mission/gui/win_teammate_select")
	end

	self.btnWindowPanelNextBtn.onMouseClick = function()
		local selectUserList = {}
		for userId, state in pairs(self.curSelectList) do
			if state then
				table.insert(selectUserList, userId)
			end
		end
		Me:requestOpenMissionTeleport(Define.MISSION_PLAY_MODE.MULTIPLE, self.curMissionId, selectUserList)
		UI:closeWindow("UI/game_mission/gui/win_teammate_select")
	end

	self.btnWindowPanelRefreshBtn.onMouseClick = function()
		Me:requestMissionTeammateCanSelect(self.curMissionId)
	end
end

function WinTeammateSelectLayout:initView(missionId)
	self.curMissionId = missionId
	self.curSelectList = {}
	self.selectNum = 0
	Me:requestMissionTeammateCanSelect(self.curMissionId)
end

function WinTeammateSelectLayout:updateViewShow(playerList)
	self.missionCfg = MissionInfoConfig:getCfgByMissionId(self.curMissionId)

	self.stWindowPanelRightPanelText:setText(Lang:toText({ "g2069_select_teammate_right_title", "0/" .. (self.missionCfg.join_player_max - 1) }))

	local curPlayerList = Lib.copyTable1(playerList)
	self.allPlayerList = {}
	local userIdList = {}
	self.siWindowPanelNoItemBg:setVisible(true)
	for key, val in pairs(curPlayerList) do
		if val.isInMission or (val.remainCounts <= 0) then
			curPlayerList[key].selectState = 0
		elseif (val.level < (self.missionCfg.join_level_range[1] or 0)) or (val.level > (self.missionCfg.join_level_range[2] or 9999999)) then
			curPlayerList[key].selectState = 0
		else
			curPlayerList[key].selectState = 1
		end
		curPlayerList[key].curMissionId = self.curMissionId
		self.allPlayerList[val.userId] = curPlayerList[key]
		table.insert(userIdList, val.userId)
		self.siWindowPanelNoItemBg:setVisible(false)
	end

	UserInfoCache.LoadCacheByUserIds(userIdList, function()
		Lib.emitEvent(Event.EVENT_GAME_MISSION_TEAMMATE_HEAD)
	end)

	table.sort(curPlayerList, function(e1, e2)
		return e1.selectState > e2.selectState
	end)
	self.leftGv:setVirtualVertBarPosition(0)
	self.leftGv:clearVirtualChild()
	self.leftGv:addVirtualChildList(curPlayerList)

	for userId, state in pairs(self.curSelectList) do
		if state and self.allPlayerList[userId] then
			self.curSelectList[userId] = true
		else
			self.curSelectList[userId] = nil
		end
	end
	self:updateCurSelectShow()
end

function WinTeammateSelectLayout:updateCurClickPlayer(userId)
	if not self.curSelectList[userId] then
		if self.selectNum >= (self.missionCfg.join_player_max - 1) then
			return
		end
	end
	self.curSelectList[userId] = not self.curSelectList[userId]
	Lib.emitEvent(Event.EVENT_GAME_MISSION_TEAMMATE_USERID, self.curSelectList)
	self:updateCurSelectShow()
end

function WinTeammateSelectLayout:updateCurSelectShow()
	local selectList = {}
	self.selectNum = 0
	for userId, state in pairs(self.curSelectList) do
		if state then
			table.insert(selectList, self.allPlayerList[userId])
			self.selectNum = self.selectNum + 1
		end
	end
	self.rightGv:clearVirtualChild()
	self.rightGv:addVirtualChildList(selectList)
	self.stWindowPanelRightPanelText:setText(Lang:toText({ "g2069_select_teammate_right_title", self.selectNum .. "/" .. (self.missionCfg.join_player_max - 1) }))
end

---@private
function WinTeammateSelectLayout:onOpen(missionId)
	self:initView( missionId)
end

---@private
function WinTeammateSelectLayout:onDestroy()

end

---@private
function WinTeammateSelectLayout:onClose()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WinTeammateSelectLayout:init()
