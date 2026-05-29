---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type WorldServer
local CW = World.CurWorld

---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

---@class SceneObjectManagerClient : singleton
local SceneObjectManagerClient = class("SceneObjectManagerClient")
SceneObjectManagerClient:include(singleton)

--- 初始化
function SceneObjectManagerClient:initialize()
    self.isInited = false
    self.teleportGates = {}
    self.missionGates = {}
    self.events = {}
    self.timer = nil
end

function SceneObjectManagerClient:init()
    if self.isInited then
        return
    end
    self.isInited = true

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_TRIGGER_TELEPORT, function(entity, mapName, toTeleportId)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_TRIGGER_TELEPORT, entity, mapName, toTeleportId)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_CLIENT_CREATE_INSTANCE, function(instance)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_CLIENT_CREATE_INSTANCE, instance)
    end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_CLOSE_NOVICE_TELEPORT, function()
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_CLOSE_NOVICE_TELEPORT)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_TRIGGER_MISSION_TELEPORT, function(entity, instance)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_TRIGGER_MISSION_TELEPORT, entity, instance)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA, function()
        --- 获取当前数据
        self:onEventHandler(Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_LEVEL, function(player, addLevel)
        if player.objID ~= Me.objID then
            return
        end
        --- 获取当前数据
        self:onEventHandler(Event.EVENT_GAME_ROLE_COMMON_UPDATE_LEVEL)
    end)
    

    self.timer = LuaTimer:scheduleTicker(function()
        self:tick(0.05)
    end, 1)
end

---事件处理
---@param event any
function SceneObjectManagerClient:onEventHandler(event, ...)
    if event == Event.EVENT_SCENE_OBJECT_TRIGGER_TELEPORT then
        local args = { ... }
        ---@type Entity
        local entity = args[1]
        local mapName = args[2]
        local toTeleportId = args[3]
        if entity.objID ~= Me.objID then
            return
        end
        entity:teleportToMapTeleportGate(mapName, toTeleportId)
    elseif event == Event.EVENT_SCENE_OBJECT_CLIENT_CREATE_INSTANCE then
        local args = { ... }
        ---@type Instance
        local instance = args[1]
        --- 处理宝箱物品和场景破坏物
        --- 是否宝箱
        if instance:isTreasureBox() and instance:isOpen() then
            --- 隐藏
            instance.isVisible = false
        elseif instance:isBrokenObject() and instance:isBroken() then
            instance.isVisible = false
        elseif instance:isTeleport() then
            local map = World.CurMap
            local mapName = map and map.name or "unknown"
            self.teleportGates[mapName] = self.teleportGates[mapName] or {}
            self.teleportGates[mapName][instance:getTeleportId()] = instance
            --- 特殊处理，满足条件要隐藏
            instance:showTeleportInfo()
            self:checkCloseTeleport(instance)
        elseif instance:isMissionGate() then
            local group = instance:getMissionGroup()
            self.missionGates[group] = self.missionGates[group] or {}
            self.missionGates[group][instance:getInstanceID()] = instance
            local open = Me:isMissionGateOpen(group)
            instance:setMissionGateClose(not open)
            instance:showMissionInfo()
        end
    elseif event == Event.EVENT_SCENE_OBJECT_CLOSE_NOVICE_TELEPORT then
        local map = World.CurMap
        if map and map.name then
            local teleportGates = self.teleportGates[map.name]
            if teleportGates then
                ---@type string, Instance
                for _, instance in pairs(teleportGates) do
                    if instance:isValid() then
                        local teleportMap = instance:getTeleportMap()
                        local config = PlayerBornConfig:getCfgByMapName(teleportMap)
                        if config.selectableMap == 1 then
                            instance:setTeleportClose(true)
                        end
                    end
                end
            end
        end
    elseif event == Event.EVENT_SCENE_OBJECT_TRIGGER_MISSION_TELEPORT then
        ---@type Entity
        ---@type Instance
        local entity, instance = table.unpack({ ... })
        if entity.objID ~= Me.objID then
            return
        end
        local group = instance:getMissionGroup()
        if not Me:isMissionGateOpen(group) then
            return
        end
        instance:setMissionGateClose(true)
        local missionRoomId = entity:getMissionRoomId()
        entity:enterMission(missionRoomId)
    elseif event == Event.EVENT_GAME_MISSION_UPDATE_MISSION_DATA then
        ---@type number
        ---@type table
        for group, list in pairs(self.missionGates) do
            local open = Me:isMissionGateOpen(group)
            ---@type number
            ---@type Instance
            for _, instance in pairs(list) do
                if instance and instance:isValid() then
                    instance:setMissionGateClose(not open)
                end    
            end
        end
    elseif event == Event.EVENT_GAME_ROLE_COMMON_UPDATE_LEVEL then
        local map = Me.map
        if map and map.name then
            local teleportGates = self.teleportGates[map.name]
            if teleportGates then
                ---@type number
                ---@type Instance
                for _, instance in pairs(teleportGates) do
                    if instance and instance:isValid() then
                        self:checkCloseTeleport(instance)
                    end
                end
            end
        end
    end
end

--- 心跳函数
---@param deltaTime number 时间间隔，单位秒
function SceneObjectManagerClient:tick(deltaTime)
    
end

--- 判断是否关闭传送门
---@param instance any
function SceneObjectManagerClient:checkCloseTeleport(instance)
    if instance:isNoviceMapTeleport() and Me:isNeedCloseNoviceMapTeleport() then
        instance:setTeleportClose(true)
        return
    end
    --- 判断是否通过等级关闭
    local openLevel = instance:getTeleportOpenLevel()
    if openLevel then
        local open = GrowthSystem:getLevel(Me) >= openLevel
        instance:setTeleportClose(not open)
    end
end

--- 查找传送门
---@param teleportMap any
---@return Instance
function SceneObjectManagerClient:findTeleportGateByMapName(teleportMap)
    local map = World.CurMap
    if map then
        local scene = CW:getScene(map.obj)
        if scene then
            --- @type Instance
            local root = scene:getRoot()
            local childCount = root:getChildrenCount()
            for index = 0, childCount - 1, 1 do
                --- @type Instance
                local child = root:getChildAt(index)
                if child and child:isValid() and child:isTeleport() then
                    local toMapName = child:getTeleportMap()
                    if toMapName and toMapName == teleportMap then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

return SceneObjectManagerClient