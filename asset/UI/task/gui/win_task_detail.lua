---@class WinTaskDetailLayout : CEGUILayout
local WinTaskDetailLayout = M
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type TaskConfig
local TaskConfig = T(Config, "TaskConfig")

---@private
function WinTaskDetailLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.wContentPanel
end

---@private
function WinTaskDetailLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siBackBg = self.backBg
	---@type CEGUIDefaultWindow
	self.wContentPanel = self.contentPanel
	---@type CEGUIStaticImage
	self.siContentPanelContentBg = self.contentPanel.contentBg
	---@type CEGUIStaticImage
	self.siContentPanelTaskIcon = self.contentPanel.taskIcon
	---@type CEGUIButton
	self.btnContentPanelCloseBtn = self.contentPanel.CloseBtn
	---@type CEGUIButton
	self.btnContentPanelGiveBtn = self.contentPanel.GiveBtn
	---@type CEGUIButton
	self.btnContentPanelGuideBtn = self.contentPanel.GuideBtn
	---@type CEGUIStaticText
	self.stContentPanelTaskTitle = self.contentPanel.TitleBg.taskTitle
	---@type CEGUIStaticText
	self.stContentPanelTaskTypeText = self.contentPanel.taskTypeText
	---@type CEGUIStaticText
	self.stContentPanelTaskName = self.contentPanel.taskName
	---@type CEGUIStaticText
	self.stContentPanelRewardTitle = self.contentPanel.rewardTitle
	---@type CEGUIDefaultWindow
	self.wContentPanelRewardPanel = self.contentPanel.rewardPanel
	---@type CEGUIScrollableView
	self.wContentPanelRewardScrollable = self.contentPanel.rewardPanel.rewardScrollable
	---@type CEGUIVerticalLayoutContainer
	self.wContentPanelRewardScrollableRewardVertical = self.contentPanel.rewardPanel.rewardScrollable.rewardVertical
end

---@private
function WinTaskDetailLayout:initUI()
	self._allEvent = {}

	self.stContentPanelTaskTitle:setText(Lang:toText("g2069_task_detail_title_text"))
	self.stContentPanelRewardTitle:setText(Lang:toText("g2069_task_detail_reward_text"))

	self.btnContentPanelGiveBtn:setText(Lang:toText("g2069_task_detail_give_up"))
	self.btnContentPanelGuideBtn:setText(Lang:toText("g2069_task_detail_guide"))

	self.taskView = widget_virtual_vert_list:init(self.wContentPanelRewardScrollable, self.wContentPanelRewardScrollableRewardVertical,
			function(self, parentWindow)
				local item = UI:openWidget("UI/task/gui/widget_task_detail_item")
				parentWindow:addChild(item:getWindow())
				item:setWidth({ 1, 0 })
				return item
			end,
			function(self, childWindow, data)
				childWindow:initData(data)
			end
	)
end

---@private
function WinTaskDetailLayout:initEvent()
	self.btnContentPanelCloseBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		UI:closeWindow("UI/task/gui/win_task_detail")
		--UI:closeWindow(self)
	end
	self.btnContentPanelGiveBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Me:sendPacket({
			pid = "RequestGiveUpTask",
			taskId = self.data.taskId
		})
		Lib.emitEvent(Event.EVENT_TASK_UPDATE_GUIDE_SHOW, self.data.taskId, false)
		UI:closeWindow("UI/task/gui/win_task_detail")
	end
	self.btnContentPanelGuideBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Lib.emitEvent(Event.EVENT_TASK_UPDATE_GUIDE_SHOW, self.data.taskId)
		self:updateGuideBtnState()
		UI:closeWindow("UI/task/gui/win_task_detail")
	end

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
		if addLevel and addLevel ~= 0 then
			self:updateTaskProgressShow()
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, function(player, ability, addLevel)
		if addLevel and addLevel ~= 0 then
			self:updateTaskProgressShow()
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_ITEM, function(player, item, addAmount)
		if player and player.objID == Me.objID then
			self:updateTaskProgressShow()
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ITEM, function(player, item, addAmount)
		if player and player.objID == Me.objID then
			self:updateTaskProgressShow()
		end
	end)
end

function WinTaskDetailLayout:updateTaskProgressShow()
	local taskConfig = TaskConfig:getCfgById(self.data.taskId)
	local showStr = Lang:toText(taskConfig.taskName)
	local progressText = Me:getTaskProgressShow(self.data)
	if progressText and progressText ~= "" then
		showStr = showStr .. "(" .. progressText .. ")"
	end
	self.stContentPanelTaskName:setText(showStr)
end

function WinTaskDetailLayout:updateViewShow(data)
	self.data = data

	self:updateTaskProgressShow()

	local taskConfig = TaskConfig:getCfgById(data.taskId)
	if taskConfig.guideMap == "" then
		self.btnContentPanelGuideBtn:setVisible(false)
	else
		self.btnContentPanelGuideBtn:setVisible(true)
	end

	if taskConfig.taskType == Define.TaskType.Main then
		--self.stContentPanelTaskName:setProperty("TextColours", "FFFFFF00")
		self.siContentPanelTaskIcon:setImage("asset/imageset/main:img_0_main")
		self.stContentPanelTaskTypeText:setText(Lang:toText("g2069_task_main_title_text"))
	else
		--self.stContentPanelTaskName:setProperty("TextColours", "FFFF00FF")
		self.siContentPanelTaskIcon:setImage("asset/imageset/main:img_0_branch")
		self.stContentPanelTaskTypeText:setText(Lang:toText("g2069_task_branch_title_text"))
	end

	if taskConfig.canGiveUp then
		self.btnContentPanelGiveBtn:setVisible(true)
	else
		self.btnContentPanelGiveBtn:setVisible(false)
	end
	self:updateBtnPosShow()


	for _, val in pairs(taskConfig.rewards or {}) do
		self.taskView:addVirtualChild(val)
	end
	self:updateGuideBtnState()
end

function WinTaskDetailLayout:updateGuideBtnState()
	local guideWnd = UI:getWindow("UI/task/gui/win_task_guide")
	if guideWnd:getCurGuideTaskId() == self.data.taskId then
		self.btnContentPanelGuideBtn:setText(Lang:toText("g2069_task_close_guide"))
	else
		self.btnContentPanelGuideBtn:setText(Lang:toText("g2069_task_detail_guide"))
	end
end

function WinTaskDetailLayout:updateBtnPosShow()
	if self.btnContentPanelGiveBtn:isVisible() and self.btnContentPanelGuideBtn:isVisible() then
		self.btnContentPanelGiveBtn:setXPosition({0, -214})
		self.btnContentPanelGuideBtn:setXPosition({0, 214})
	elseif self.btnContentPanelGiveBtn:isVisible() then
		self.btnContentPanelGiveBtn:setXPosition({0, 0})
	elseif self.btnContentPanelGuideBtn:isVisible() then
		self.btnContentPanelGuideBtn:setXPosition({0, 0})
	end
end

---@private
function WinTaskDetailLayout:onOpen(data)
	self.taskView:clearVirtualChild()
	self:updateViewShow(data)
end

---@private
function WinTaskDetailLayout:onDestroy()

end

---@private
function WinTaskDetailLayout:onClose()
	self.taskView:clearVirtualChild()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WinTaskDetailLayout:init()
