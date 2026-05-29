---@class WinTaskGuideLayout : CEGUILayout
local WinTaskGuideLayout = M
---@type TaskConfig
local TaskConfig = T(Config, "TaskConfig")
---@type MapManagerClient
local MapManagerClient = require "client.manager.game_map_manager"

---@private
function WinTaskGuideLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinTaskGuideLayout:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wGuidePanel = self.guidePanel
end

---@private
function WinTaskGuideLayout:initUI()
    self.curGuideTask = 0
end

---@private
function WinTaskGuideLayout:initEvent()
    self._allEvent = {}

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TASK_UPDATE_GUIDE_SHOW, function(taskId, isShow)
        if isShow == false then
            if taskId == self.curGuideTask then
                self:stopGuideIconShow()
                self.curGuideTask = 0
            end
        else
            if self.curGuideTask == taskId then
                self:stopGuideIconShow()
                self.curGuideTask = 0
            else
                self:initTaskGuidePosInfo(taskId)
                self:startGuideIconShow()
            end
        end
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA, function()
        --- 只有在房间外才显示
        if Me:isInMissionPreState() and Me.map then
            local missionGroup = Me:getMissionRoomGroup()
            local position, mapName = MapManagerClient:instance():findMissionGatePosition(Me.map.name or "unknown", missionGroup)
            if position then
                Lib.emitEvent(Event.EVENT_MISSION_UPDATE_GUIDE_SHOW, true, mapName, position)
                return
            end
        end
        Lib.emitEvent(Event.EVENT_MISSION_UPDATE_GUIDE_SHOW, false)
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MISSION_UPDATE_GUIDE_SHOW, function(isShow, mapName, guidePos)
        if isShow then
            self:initMissionGuidePosInfo( mapName, guidePos)
            self:startGuideIconShow()
        else
            if self.curGuideTask <= 0 then
                self:stopGuideIconShow()
            end
        end
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function(mapName)
        self.needTeleportPos = nil
        if Me:isInMissionRoom() then
            self:setVisible(false)
            self:stopGuideIconShow()
        else
            self:setVisible(true)
        end
    end)
end

function WinTaskGuideLayout:stopGuideIconShow()
    if self.guideIconTimer then
        self.guideIconTimer()
        self.guideIconTimer = nil
    end
    if self.guideNode then
        self.guideNode:setVisible(false)
    end
    Me:showTaskGuideArrow(false)
end

function WinTaskGuideLayout:getCurGuideTaskId()
    return self.curGuideTask or 0
end

function WinTaskGuideLayout:initMissionGuidePosInfo(mapName, guidePos)
    self.guideMapName = mapName
    self.guidePos = guidePos
    self.curGuideTask = 0
end

function WinTaskGuideLayout:initTaskGuidePosInfo(taskId)
    self.curGuideTask = taskId
    local taskConfig = TaskConfig:getCfgById(taskId)
    self.guideMapName = taskConfig.guideMap
    self.guidePos = Lib.copyTable1(taskConfig.guidePos)

    if not self.guideNode then
        self.guideNode = UI:openWidget("UI/task/gui/widget_task_guide_item")
        self.wGuidePanel:addChild(self.guideNode:getWindow())
    end
    self.guideNode:updateTaskTypeShow(taskConfig.taskType)
    self.guideNode:setVisible(false)
end

function WinTaskGuideLayout:startGuideIconShow()
    self:stopGuideIconShow()
    self.needTeleportPos = nil

    if (not self.guideMapName) or (self.guideMapName == "") then
        return
    end
    if not self.guidePos then
        return
    end


    local time = 1
    self.guideIconTimer = World.Timer(time, function()
        self:updateItemShow()
        return true
    end)
end

function WinTaskGuideLayout:updateItemShow()
    local myPos = Me:getPosition()
    if (Me.map.name == "map_born") or Me:isInMissionRoom() then
        Me:showTaskGuideArrow(false)
        if self.guideNode then
            self.guideNode:setVisible(false)
        end
        return
    end
    local targetPos = self.guidePos
    if Me.map.name ~= self.guideMapName then
        if not self.needTeleportPos then
            local newPos = MapManagerClient:instance():findTeleportPosition(Me.map.name, self.guideMapName)
            if newPos then
                self.needTeleportPos = Lib.v3(newPos.x, newPos.y, newPos.z)
                self.needTeleportPos.y = self.needTeleportPos.y + 3.5
            end
        end
        targetPos = self.needTeleportPos
    end
    if targetPos then
        Me:showTaskGuideArrow(true, targetPos)
        if self.guideNode then
            if self.curGuideTask <= 0 then
                self.guideNode:setVisible(false)
            else
                self.guideNode:setVisible(true)
            end
        end
    else
        Me:showTaskGuideArrow(false)
        if self.guideNode then
            self.guideNode:setVisible(false)
        end
        return
    end
    self:updateGuideInfo(myPos, targetPos)
end

function WinTaskGuideLayout:updateGuideInfo(myPos, targetPos)
    local dis = Lib.getPosDistance(myPos, targetPos)
    if dis <= 4 and Me.map.name == self.guideMapName then
        if self.curGuideTask <= 0 then
            Lib.emitEvent(Event.EVENT_MISSION_UPDATE_GUIDE_SHOW, false)
        else
            Lib.emitEvent(Event.EVENT_TASK_UPDATE_GUIDE_SHOW, self.curGuideTask, false)
        end
        return
    end

    if not self.guideNode then
        return
    end
    if self.curGuideTask <= 0 then
        return
    end

    self.guideNode:updateDistanceShow(dis)
    self:showUIOnVector3Pos(self.guideNode, {
        x = targetPos.x,
        y = targetPos.y,
        z = targetPos.z
    }, {
        uiSize = {width = self.guideNode:getWidth(), height = self.guideNode:getHeight()},
        anchorX = 0,
        anchorY = 0
    })
end

function WinTaskGuideLayout:showUIOnVector3Pos(ui, pos, params)
    local result = Blockman.instance:getScreenPos(pos)

    local showPosX = result.x
    if showPosX > 0.99 then
        showPosX = 0.99
    elseif showPosX < 0.01 then
        showPosX = 0.01
    end

    local showPosY = result.y
    if showPosY > 0.92 then
        showPosY = 0.92
    elseif showPosY < 0 then
        showPosY = 0
    end

    if result.w < 0 or result.z < 0 then
        --showPosY = 0.5
        showPosX = 0.99
    end

    ui:setXPosition({showPosX, 0})
    ui:setYPosition({showPosY, 0})
end

---@private
function WinTaskGuideLayout:onOpen()

end

---@private
function WinTaskGuideLayout:onDestroy()

end

---@private
function WinTaskGuideLayout:onClose()
    self.curGuideTask = 0
    self:stopGuideIconShow()

    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = {}
    end
end

WinTaskGuideLayout:init()
