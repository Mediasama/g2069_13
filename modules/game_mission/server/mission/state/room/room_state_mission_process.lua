--- 基础状态

---@class RoomStateMissionProcess : MissionRoom
local RoomStateMissionProcess = {}

function RoomStateMissionProcess:enteredState(isRepeat)
    self.gameTime = self.gameTime or 0
    --- 初始化当前stage
    ---@type MissionStage
    local stage = self:getCurrentStage()
    stage:start()
    ---@type number
    ---@type Entity
    for _, player in pairs(self.players) do
        if player and player:isValid() then
            --- 同步状态数据
            self:syncGameProcessState(player)
        end
    end
end

--- 心跳函数，间隔每秒
function RoomStateMissionProcess:onUpdate()
    self.gameTime = self.gameTime + 1
    --- 没有玩家存活
    if self:getPlayerCount(true, true) == 0 then
        --- 关卡结算
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, Define.MISSION_COMPLETE_CODE.ALL_PLAYER_DEAD)
        return
    end
    local stage = self:getCurrentStage()
    stage:update()
    --- 关卡完成
    if stage:completed() then
        --- 记录结果
        self.stageResultList[#self.stageResultList + 1] = stage:getCompleteCode()
        --- 判断是否结束
        local completeCode = self:checkMissionCompleted()
        if completeCode ~= Define.MISSION_COMPLETE_CODE.NONE then
            --- 进入结算阶段
            self:gotoState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, completeCode)
            return
        end
        --- 下一阶段
        self.stageIndex = self.stageIndex + 1
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_STAGE_INIT)
        return
    end
    --- 判断是否超时，超时则失败
    if self:getGameLeftTime() <= 0 then
        ---@type number
        ---@type MissionStage
        for _, stage in pairs(self.stageList) do
            stage:complete(Define.MISSION_COMPLETE_CODE.FAIL)
        end
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, Define.MISSION_COMPLETE_CODE.GAME_TIME_OUT)
    end
end

--- 检查是否关卡完成
function RoomStateMissionProcess:checkMissionCompleted()
    for _, code in pairs(self.stageResultList) do
        if code ~= Define.MISSION_COMPLETE_CODE.SUCCESS then
            return Define.MISSION_COMPLETE_CODE.FAIL
        end
    end
    --- 所有关卡已结算
    if #self.stageResultList == #self.stageList then
        return Define.MISSION_COMPLETE_CODE.SUCCESS
    end
    return Define.MISSION_COMPLETE_CODE.NONE
end

function RoomStateMissionProcess:exitedState()
end

return RoomStateMissionProcess