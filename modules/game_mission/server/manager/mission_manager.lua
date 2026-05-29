---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"
---@type uuid
local uuid = require "common.uuid"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@type MissionRoom
local MissionRoom = require "server.mission.mission_room"

---@class MissionManagerServer : singleton
local MissionManagerServer = class("MissionManagerServer")
MissionManagerServer:include(singleton)

function MissionManagerServer:initialize()
    self.isInited = false
    self.rooms = {}
    self.removeList = nil
end

function MissionManagerServer:init()
    if self.isInited then
        return
    end
    self.isInited = true

    LuaTimer:scheduleTicker(function()
        self:update()
        self:lateUpdate()
    end, 20)
end

--- 心跳函数，间隔每秒
function MissionManagerServer:update()
    ---@type string, MissionRoom
    for roomId, room in pairs(self.rooms) do
        room:update()
        if room:completed() then
            self.removeList = self.removeList or {}
            self.removeList[#self.removeList + 1] = roomId
        end
    end
end

--- 后处理
function MissionManagerServer:lateUpdate()
    if self.removeList then
        for _, roomId in pairs(self.removeList) do
            ---@type MissionRoom
            local room = self.rooms[roomId]
            if room then
                self.rooms[roomId] = nil
                room:destroy()
            end
        end
        self.removeList = nil
    end
end

--- 创建房间
---@param player Entity 房主
---@param missionId number 关卡id
---@param mode number 模式
---@param multipleUserIds table 多人副本被邀请玩家
---@return MissionRoom 房间
function MissionManagerServer:createRoom(player, missionId, mode, multipleUserIds)
    local id = uuid()
    if self.rooms[id] then
        return nil
    end
    ---@type MissionRoom
    local room = MissionRoom:new({
        id = id,
        missionId = missionId,
        multipleUserIds = multipleUserIds,
        owner = player,
        mode = mode,
    })
    self.rooms[id] = room
    --- 设置房间数据
    room:link(player)
    --- 同步房间等待状态
    room:syncWaitPlayerState(player)

    if multipleUserIds then
        for _, userId in pairs(multipleUserIds) do
            ---@type Entity
            local invitee = Game.GetPlayerByUserId(userId)
            if invitee and invitee:isValid() and not invitee:getMissionRoomId() then
                --- 设置房间数据
                room:link(invitee)
                --- 同步房间等待状态
                room:syncWaitPlayerState(invitee)
            end
        end
    end

    --- 派发事件
    Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_OPEN, room, player)
    return room
end

--- 获取房间
---@param roomId any
---@return MissionRoom
function MissionManagerServer:getRoom(roomId)
    return self.rooms[roomId]
end

--- 加入房间
---@param player Entity
---@param roomId string
---@return boolean 是否成功
---@return MissionRoom 房间
function MissionManagerServer:joinRoom(player, roomId)
    ---@type MissionRoom
    local room = self.rooms[roomId]
    if room and room:join(player) then
        return true
    end
    return false
end

--- entity进入时间
---@param entity Entity
function MissionManagerServer:onEntityEnter(entity)
    if entity.isPlayer then
        --- 还原房间数据
        ---@type string
        ---@type MissionRoom
        for _, room in pairs(self.rooms) do
            if room:link(entity) then
                --- 同步房间等待状态
                room:syncWaitPlayerState(entity)
                break
            end
        end
    end
end

--- entity离开时机
---@param entity Entity
function MissionManagerServer:onEntityLeave(entity)
    local roomId = entity:getMissionRoomId()
    if roomId and self.rooms[roomId] then
        ---@type MissionRoom
        local room = self.rooms[roomId]
        room:onEntityLeave(entity)
    end
end

--- 玩家主动退出
---@param player Entity
function MissionManagerServer:onPlayerQuit(player)
    if player:isInMissionRoom() then
        local roomId = player:getMissionRoomId()
        if roomId and self.rooms[roomId] then
            ---@type MissionRoom
            local room = self.rooms[roomId]
            return room:quit(player)
        end
    end
    return false
end

return MissionManagerServer