---@class WinMissionInfoLayout : CEGUILayout
local WinMissionInfoLayout = M

---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

---@private
function WinMissionInfoLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinMissionInfoLayout:findAllWindow()
	---@type CEGUIScrollableView
	self.wSvPlayerName = self.SvPlayerName
	---@type CEGUIVerticalLayoutContainer
	self.wSvPlayerNameLvPlayerName = self.SvPlayerName.LvPlayerName
end

---@private
function WinMissionInfoLayout:initUI()
end

---@private
function WinMissionInfoLayout:initEvent()
end

function WinMissionInfoLayout:initData()
    self.missionGroup = nil
end

---@private
function WinMissionInfoLayout:onOpen()
    self:initData()
    self:initVirtualUI()
    self:subscribeEvents()

    self.infoTimer = LuaTimer:scheduleTicker(function()
        local sceneUIId = self.__sceneUIID
        local sceneUIObj = Instance.getByRuntimeId(sceneUIId)
        if not sceneUIObj or not sceneUIObj:isValid() then
            return
        end
        ---@type Instance
        local instance = sceneUIObj:getParent()
        if not instance or not instance:isValid() then
            return
        end
        LuaTimer:cancel(self.infoTimer)
        self.infoTimer = nil
        self.missionGroup = instance:getMissionGroup()
        self:updateInfo()
    end, 10)
end

function WinMissionInfoLayout:initVirtualUI()
    ---@type widget_virtual_vert_list
	self.lvPlayerName = widget_virtual_vert_list:init(
		self.wSvPlayerName,
		self.wSvPlayerNameLvPlayerName,
		function(_, parent)
			---@type WidgetPlayerNameWidget
			local node = UI:openWidget("UI/scene_object/gui/widget_player_name")
			parent:addChild(node:getWindow())
			return node
		end,
		function(_, node, data)
			node:updateInfo(data)
		end
	)
end

function WinMissionInfoLayout:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA, function()
        if not self.missionGroup then
            return
        end
        self:updateInfo()
    end)
end

--- 刷新信息
function WinMissionInfoLayout:updateInfo()
    if Me:isInMissionPreState() then
        --- 获取任务组
        local missionGroup = Me:getMissionRoomGroup()
        if missionGroup == self.missionGroup then
            local data = Me:getMissionRoomData()
            --- 清空名字
            self.lvPlayerName:clearVirtualChild()
            local userIds = data.userIds
            if userIds then
                for _, userId in pairs(userIds) do
                    local playerInfo = Game.GetPlayerByUserId(userId)
                    if playerInfo then
                        self.lvPlayerName:addVirtualChild(playerInfo.name or "")
                    end
                end
                self.lvPlayerName:addVirtualChild(Lang:toText("g2069_mission_tips_teleport"))
            end
            return
        end
    end
    --- 清空名字
    self.lvPlayerName:clearVirtualChild()
end

---@private
function WinMissionInfoLayout:onDestroy()
    self.missionGroup = nil
    if self.infoTimer then
        LuaTimer:cancel(self.infoTimer)
        self.infoTimer = nil
    end
end

---@private
function WinMissionInfoLayout:onClose()

end

WinMissionInfoLayout:init()
