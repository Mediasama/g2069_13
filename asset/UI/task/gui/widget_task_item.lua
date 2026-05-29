---@class WidgetTaskItemWidget : CEGUILayout
local WidgetTaskItemWidget = M
---@type TaskConfig
local TaskConfig = T(Config, "TaskConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@private
function WidgetTaskItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetTaskItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemBg = self.itemBg
	---@type CEGUIEffectWindow
	self.wItemBgTaskEffect = self.itemBg.taskEffect
	---@type CEGUIStaticText
	self.stTaskTitle = self.taskTitle
	---@type CEGUIStaticText
	self.stProgressContent = self.progressContent
	---@type CEGUIStaticImage
	self.siTaskIcon = self.taskIcon
	---@type CEGUIStaticImage
	self.siAddIcon = self.addIcon
end

---@private
function WidgetTaskItemWidget:initUI()
	self._allEvent = {}
	self.wItemBgTaskEffect:setVisible(false)
end

---@private
function WidgetTaskItemWidget:initEvent()
	self.onMouseClick=function()
		if self.data then
			UI:openWindow("UI/task/gui/win_task_detail", nil, nil, self.data)
		end
	end

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA, function()
		self:updateTaskProgressShow()
	end)

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

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TASK_UI_UPDATE_TASK, function(taskId)
		if self.data and self.data.taskId == taskId then
			self:playTaskEffect()
		end
	end)
	
end

function WidgetTaskItemWidget:updateTaskProgressShow()
	if not self.data then
		return
	end
	local progressText = Me:getTaskProgressShow(self.data)
	self.stProgressContent:setText(progressText)
end

function WidgetTaskItemWidget:initData(data, play)

	if self.data and data and self.data.taskId ~= data.taskId then
		self:stopPlayTaskEffect()
	end

	self.data = data

	local taskConfig = TaskConfig:getCfgById(self.data.taskId)
	local taskTitle = Lang:toText(taskConfig.taskName)
	self.stTaskTitle:setText(taskTitle)

	self:updateTaskProgressShow()

	if taskConfig.taskType == Define.TaskType.Main then
		--self.stTaskTitle:setProperty("TextColours", "FFFFFF00")
		self.siTaskIcon:setImage("asset/imageset/main:img_0_main")
	else
		--self.stTaskTitle:setProperty("TextColours", "FFFF00FF")
		self.siTaskIcon:setImage("asset/imageset/main:img_0_branch")
	end

	--local taskReward = ""
	--for _, data in pairs(taskConfig.rewards or {}) do
	--	local item_alias = data.item_alias
	--	local item_num = data.item_num
	--	local name = ItemConfig:getCfgByItemAlias(item_alias).name
	--
	--	if taskReward ~= "" then
	--		taskReward = taskReward .. ","
	--	end
	--	taskReward = taskReward .. Lang:toText(name) .. item_num
	--end
	--
	--local showStr = self:getShortContentShow(taskReward)
	--self.stRewardContent:setText(showStr)
	if play then
		self:playTaskEffect()
	end
end

function WidgetTaskItemWidget:getShortContentShow(textStr)
	local endIndex = Lib.subStringGetTotalIndex(textStr)
	local maxLen = World.cfg.task_systemSetting.taskItemMaxLen  or 20
	if endIndex > maxLen then
		local content = Lib.subStringUTF8(textStr, 1, maxLen)
		local result = content .. "..."
		return result
	else
		return textStr
	end
end

---@private
function WidgetTaskItemWidget:onOpen()
end

function WidgetTaskItemWidget:playTaskEffect()
	self.wItemBgTaskEffect:setVisible(true)
	self.wItemBgTaskEffect:playEffect()
end

function WidgetTaskItemWidget:stopPlayTaskEffect()
	self.wItemBgTaskEffect:setVisible(false)
	self.wItemBgTaskEffect:stopEffect()
end

---@private
function WidgetTaskItemWidget:onDestroy()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WidgetTaskItemWidget:init()
