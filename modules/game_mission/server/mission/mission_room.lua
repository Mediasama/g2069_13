---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type Stateful
local stateful = require "common.3rd.stateful.stateful"
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")
---@type MissionStage
local MissionStage = require "server.mission.mission_stage"

--- 状态机
---@type RoomStateMissionStart
local RoomStateMissionStart = require "server.mission.state.room.room_state_mission_start"
---@type RoomStateMissionEnd
local RoomStateMissionEnd = require "server.mission.state.room.room_state_mission_end"
---@type RoomStateMissionComplete
local RoomStateMissionComplete = require "server.mission.state.room.room_state_mission_complete"
---@type RoomStateMissionProcess
local RoomStateMissionProcess = require "server.mission.state.room.room_state_mission_process"
---@type RoomStateMissionStageInit
local RoomStateMissionStageInit = require "server.mission.state.room.room_state_mission_stage_init"
---@type RoomStateMissionStageMask
local RoomStateMissionStageMask = require "server.mission.state.room.room_state_mission_stage_mask"
---@type RoomStateMissionWaitPlayer
local RoomStateMissionWaitPlayer = require "server.mission.state.room.room_state_mission_wait_player"
---@type RoomStateMissionPrepare
local RoomStateMissionPrepare = require "server.mission.state.room.room_state_mission_prepare"



---@class MissionRoom : middleclass
local MissionRoom = class("MissionRoom")
MissionRoom:include(stateful)

MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_PREPARE, RoomStateMissionPrepare)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER, RoomStateMissionWaitPlayer)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_START, RoomStateMissionStart)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_STAGE_INIT, RoomStateMissionStageInit)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_STAGE_MASK, RoomStateMissionStageMask)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS, RoomStateMissionProcess)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, RoomStateMissionComplete)
MissionRoom:addState(Define.MISSION_ROOM_STATE.MISSION_END, RoomStateMissionEnd)



--- 初始化
---@param data table 初始化数据
function MissionRoom:initialize(data)
    ---@type Entity
    local owner = data.owner

    self.enterPlayerCount = 0
    --- 房间id
    self.id = data.id
    --- 副本id
    self.missionId = data.missionId
    --- 房主
    self.ownerUserId = owner.platformUserId
    --- 游玩模式
    self.missionPlayMode = data.mode
    --- 配置
    self.config = MissionInfoConfig:getCfgByMissionId(self.missionId)
    --- 地图数据
    self.maps = {}
    --- 玩家列表
    self.players = {}
    --- 初始化索引
    self.stageIndex = 1
    --- 关卡列表
    self.stageList = {}
    --- 关卡结果
    self.stageResultList = {}
    --- 创建时间
    self.createTime = os.time()
    --- 结果
    self.completeCode = Define.MISSION_COMPLETE_CODE.NONE
    --- 通用倒计时
    self.time = 0
    --- 房主信息
    self.ownerInfo = {
        skin = Lib.copy(owner:data("skin") or {}),
        actorName = owner:cfg().actorName,
        platformUserId = self.ownerUserId,
        name = owner.name,
    }

    --- 多人局玩家
    self.multipleUserIds = {}
    self.multipleUserIds[self.ownerUserId] = true

    if self.missionPlayMode == Define.MISSION_PLAY_MODE.MULTIPLE and data.multipleUserIds then
        --- 邀请列表
        local multipleUserIds = data.multipleUserIds
        for _, platformUserId in pairs(multipleUserIds) do
            self.multipleUserIds[platformUserId] = true
        end
    end

    --- 初始化stage
    local mission_stages = self.config.mission_stages
    local stage_wait_times = self.config.stage_wait_times
    for index, stageId in pairs(mission_stages) do
        ---@type MissionStage
        local stage = MissionStage:new({
            room = self,
            stageId = stageId, 
            waitTime = stage_wait_times and stage_wait_times[index] or 0,
        })
        self.stageList[#self.stageList + 1] = stage
    end

    --- 进入起始状态
    self:gotoState(Define.MISSION_ROOM_STATE.MISSION_PREPARE)
end

--- 获取玩家信息
function MissionRoom:getOwnerInfo()
    return self.ownerInfo
end

--- 心跳函数，间隔每秒
function MissionRoom:update()
    self:onUpdate()
end

--- 是否关卡完成
function MissionRoom:completed()
    local curState = self:getCurrentState()
    if curState and curState == Define.MISSION_ROOM_STATE.MISSION_END then
        return true
    end
    return false
end

--- 获取玩家数量
---@param isValid boolean 判断是否存活玩家
---@param isCheck boolean 检测模式，isValid为true剩下，数量只返回0或1
function MissionRoom:getPlayerCount(isValid, isCheck)
    local count = 0
    if isValid and self.players then
        ---@type number
        ---@type Entity
        for _, player in pairs(self.players) do
            if player and player:isValid() then
                if isCheck then
                    return 1
                end
                count = count + 1
            end
        end
    elseif not isValid and self.multipleUserIds then
        for k, v in pairs(self.multipleUserIds) do
            count = count + 1
        end
    end
    return count
end

--- 加入玩家
---@param player Entity
---@return boolean 是否加入成功
function MissionRoom:join(player)
    --- 判断阶段
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER then
        local platformUserId = player.platformUserId
        if self.multipleUserIds[platformUserId] then
            --- 扣除副本次数
            if platformUserId ~= self.ownerUserId then
                player:doCostMissionCounts(self.missionId, 1)
            end
            self:link(player, true)
            self.players[player.platformUserId] = player
            --- 设置状态数据
            self:syncWaitPlayerState(player)
            --- 传送
            local curStage = self:getCurrentStage()
            local map = self:getMap(curStage:getMapName())
            local posList = curStage:getBornPositions()
            local position = nil
            if #posList == 1 then
                position = posList[1]
            else
                local rand = math.random(1, #posList)
                position = posList[rand] or posList[1]
            end
            player:setMapPos(map, position)
            return true
        end
    end
    return false
end

--- 获取地图对象
---@param mapName any
function MissionRoom:getMap(mapName)
    if not self.maps[mapName] then
        --- 创建地图
        ---@type WorldServer
        local CW = World.CurWorld
        self.maps[mapName] = CW:createDynamicMap(mapName, false)
    end
    return self.maps[mapName]
end

----entity离开时机
---@param entity Entity
function MissionRoom:onEntityLeave(entity)
    if entity.isPlayer then
        local platformUserId = entity.platformUserId
        if self.players then
            self.players[platformUserId] = nil
        end
    elseif entity:isMonster() then
        ---@type number
        ---@type MissionStage
        for _, stage in pairs(self.stageList) do
            stage:onMonsterLeave(entity)
        end
    end
end

--- 获取当前stage
---@return MissionStage
function MissionRoom:getCurrentStage()
    return self.stageList[self.stageIndex]
end

--- 获取房间id
function MissionRoom:getId()
    return self.id
end

--- 获取副本别称
function MissionRoom:getMissionAlias()
    return self.config and self.config.mission_alias or "unknown"
end

--- 获取结果
function MissionRoom:getCompleteCode()
    return self.completeCode
end

--- 获取房主id
function MissionRoom:getOwnerUserId()
    return self.ownerUserId
end

--- 获取剩余时间
function MissionRoom:getWaitPlayerLeftTime()
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER and self.config then
        return self.config.waitting_time - (self.time or 0)
    end
    return 0
end

--- 获取剩余时间
function MissionRoom:getGameLeftTime()
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS and self.config then
        return self.config.complete_time - (self.gameTime or 0)
    end
    return 0
end

--- 获取剩余时间
function MissionRoom:getQuitLeftTime()
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_COMPLETE and self.config then
        return self.config.quit_time - (self.time or 0)
    end
    return 0
end

--- 获取当前stage初始化剩余时间
function MissionRoom:getCurrentStageInitLeftTime()
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_STAGE_INIT and self.config then
        return (self.config.stage_wait_times[self.stageIndex] or 0) - (self.time or 0)
    end
    return 0
end

--- 获取开始状态剩余时间
function MissionRoom:getStartLeftTime()
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_START and self.config then
        return (self.config.stage_waitting_battle_times[self.stageIndex] or 0) - (self.time or 0)
    end
    return 0
end

--- 判断玩家是否进入
---@param platformUserId any
function MissionRoom:isPlayerEnter(platformUserId)
    ---@type Entity
    local player = self.players[platformUserId]
    if player and player:isValid() then
        return true
    end
    return false
end

--- 获取游玩模式
function MissionRoom:getMissionPlayMode()
    return self.missionPlayMode
end

--- 获取理论进入玩家数量
function MissionRoom:getMultiplePlayerCount()
    return Lib.getTableSize(self.multipleUserIds)
end

--- 实际进入人数
function MissionRoom:getEnterPlayerCount()
    return self.enterPlayerCount
end

--- 玩家主动退出，暂时只有死亡状态下
---@param player Entity
function MissionRoom:quit(player)
    local platformUserId = player.platformUserId
    if self.players and self.players[platformUserId] then
        self.players[platformUserId] = nil
        self:unlink(player)
        Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_PLAYER_DEAD, self, player)
        --- 弹出提示
        Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "g2069_mission_tips_die", player)
        return true
    end
    return false
end

--- 销毁
function MissionRoom:destroy()
    if self.stageList then
        ---@type number, MissionStage
        for _, stage in pairs(self.stageList) do
            stage:destroy()
        end
        self.stageList = nil
    end
    --- 销毁动态地图
    if self.maps then
        ---@type any
        ---@type MapServer
        for _, map in pairs(self.maps) do
            map:close()
        end
        self.maps = nil
    end

    self.id = nil
    self.missionId = nil
    self.config = nil
    self.players = nil
    self.stageIndex = nil
    self.stageResultList = nil
    self.ownerUserId = nil
    self.ownerInfo = nil
    self.multipleUserIds = nil
end

----------------------------- 处理房间状态同步数据 ----------------------------
--- 同步房间等待状态
---@param player Entity
function MissionRoom:syncWaitPlayerState(player)
    local leftTime = self:getWaitPlayerLeftTime()
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER,
        mode = self.missionPlayMode,
        endTime = leftTime + os.time(),
    })
end

--- 同步房间结算状态
---@param player Entity
function MissionRoom:syncCompleteState(player)
    local leftTime = self:getQuitLeftTime()
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_COMPLETE,
        endTime = leftTime + os.time(),
        code = self.completeCode,
    })
end

--- 同步房间游玩状态
---@param player Entity
function MissionRoom:syncGameProcessState(player)
    local leftTime = self:getGameLeftTime()
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS,
        endTime = leftTime + os.time(),
    })
end

--- 同步房间准备跳转场景状态
---@param player Entity
function MissionRoom:syncStageInitState(player)
    local leftTime = self:getCurrentStageInitLeftTime()
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_STAGE_INIT,
        endTime = leftTime + os.time(),
    })
end

--- 同步房间跳场景黑屏状态
---@param player Entity
function MissionRoom:syncStageMaskState(player)
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_STAGE_MASK,
    })
end

--- 同步房间准备战斗状态
---@param player any
function MissionRoom:syncStartState(player)
    local leftTime = self:getStartLeftTime()
    --- 设置状态数据
    player:setMissionStateData({
        state = Define.MISSION_ROOM_STATE.MISSION_START,
        endTime = leftTime + os.time(),
    })
end

--- 链接房间
---@param player Entity
---@param enter boolean 是否进入房间
function MissionRoom:link(player, enter)
    if self:getCurrentState() == Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER then
        local data = nil
        local platformUserId = player.platformUserId
        if self.multipleUserIds and self.multipleUserIds[platformUserId] then
            data = {
                roomId = self.id,
                missionId = self.missionId,
                owner = self.ownerUserId,
            }
        end
        if enter and data then
            local position = player:getPosition()
            data.x = position.x
            data.y = position.y
            data.z = position.z
            data.map = player:getCurMap()
            data.enter = true
        elseif not enter and data then
            local userIds = {}
            data.userIds = userIds
            for userId, _ in pairs(self.multipleUserIds) do
                userIds[#userIds + 1] = userId
            end
        end

        if data then
            player:setMissionRoomData(data)
            return true
        end
    end
    return false
end

--- 解除链接
---@param player Entity
function MissionRoom:unlink(player)
    --- 清空数据
    local data = player:getMissionRoomData()
    if self.id and data and data.roomId == self.id then
        player:clearMissionRoomData()
        local enter = data.enter
        if enter then
            local position = nil
            local mapName = data.map or player:getCurMap()
            if data.x and data.y and data.z then
                position = Vector3.new(data.x, data.y, data.z)
            end
            Plugins.CallTargetPluginFunc("game_role_common", "gotoMap", player, mapName, position)
        end
        return true
    end
    return false
end

-----------------------------------------------------------------------------

return MissionRoom