---@class WinTaskContentLayout : CEGUILayout
local WinTaskContentLayout = M
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
local cjson = require("cjson")

---@private
function WinTaskContentLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinTaskContentLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siContentBg = self.contentBg
	---@type CEGUIScrollableView
	self.wTaskContent = self.taskContent
	---@type CEGUIVerticalLayoutContainer
	self.wTaskVertical = self.taskContent.taskVertical
end

---@private
function WinTaskContentLayout:initUI()
	self._allEvent = {}
	local this = self
	self.taskView = widget_virtual_vert_list:init(self.wTaskContent, self.wTaskVertical,
			function(self, parentWindow)
				local item = UI:openWidget("UI/task/gui/widget_task_item")
				parentWindow:addChild(item:getWindow())
				item:setWidth({ 1, 0 })
				return item
			end,
			function(self, childWindow, data)
				local taskId = data.taskId
				local play = nil
				local playData = this.taskPlayList[taskId] or this.subTaskPlayList[taskId] or nil
				if playData and playData.play and playData.has then
					play = true
				end
				childWindow:initData(data, play)
			end
	)
end

---@private
function WinTaskContentLayout:initEvent()
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TASK_UPDATE_MY_TASK, function(taskType)
		self:updateTaskInfoView(taskType)
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function(mapName)
		if Me:isInMissionRoom() then
			self:setVisible(false)
		else
			self:setVisible(true)
		end
	end)
end

---@private
function WinTaskContentLayout:onOpen()
	self:initData()
	-- self:updateTaskInfoView()
end

function WinTaskContentLayout:initData()
	self.taskPlayList = {}
	self.subTaskPlayList = {}

	self.syncTaskTypeList = {}
end

function WinTaskContentLayout:updateTaskInfoView(taskType)
	local mainTask = Me:getMainTask()
	local branchTask = Me:getBranchTask()
	
	if taskType then
		self.syncTaskTypeList[taskType] = true
	end
	--- 是否数据初始化完毕
	local isInit = false
	if self.syncTaskTypeList[Define.TaskType.Main] and self.syncTaskTypeList[Define.TaskType.Branch] then
		isInit = true
	end

	self.taskView:clearVirtualChild()
	local taskList = {}

	if mainTask then
		for taskId, val in pairs(mainTask) do
			table.insert(taskList, val)
			local code = cjson.encode(val.taskCompleteCondition or {})
			if not self.taskPlayList[taskId] or self.taskPlayList[taskId].code == nil or self.taskPlayList[taskId].code ~= code then
				self.taskPlayList[taskId] = self.taskPlayList[taskId] or {}
				self.taskPlayList[taskId].code = code
				self.taskPlayList[taskId].play = true
			end
			self.taskPlayList[taskId].has = true
		end
	end
	
	if branchTask then
		for taskId, val in pairs(branchTask) do
			table.insert(taskList, val)
			local code = cjson.encode(val.taskCompleteCondition or {})
			if not self.subTaskPlayList[taskId] or self.subTaskPlayList[taskId].code == nil or self.subTaskPlayList[taskId].code ~= code then
				self.subTaskPlayList[taskId] = self.subTaskPlayList[taskId] or {}
				self.subTaskPlayList[taskId].code = code
				self.subTaskPlayList[taskId].play = true
			end
			self.subTaskPlayList[taskId].has = true
		end
	end

	self.taskView:addVirtualChildList(taskList)

	if isInit then
		for taskId, data in pairs(self.taskPlayList) do
			if not data.has then
				data.code = nil
			end
			data.play = false
			data.has = false
		end
	end

	if isInit then
		for taskId, data in pairs(self.subTaskPlayList) do
			if not data.has then
				data.code = nil
			end
			data.play = false
			data.has = false
		end
	end
end

---@private
function WinTaskContentLayout:onDestroy()

end

---@private
function WinTaskContentLayout:onClose()
	self.taskView:clearVirtualChild()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WinTaskContentLayout:init()
