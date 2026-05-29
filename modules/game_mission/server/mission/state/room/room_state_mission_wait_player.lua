--- 基础状态

---@class RoomStateMissionWaitPlayer : MissionRoom
local RoomStateMissionWaitPlayer = {}

function RoomStateMissionWaitPlayer:enteredState()
    self.time = 0

    self.flag = false
end

--- 心跳函数，间隔每秒
function RoomStateMissionWaitPlayer:onUpdate()
    self.time = self.time + 1
    if self:getWaitPlayerLeftTime() == 5 then
        --- 再次同步时间
        if self.players then
            ---@type number
            ---@type Entity
            for _, player in pairs(self.players) do
                if player and player:isValid() then
                    self:syncWaitPlayerState(player)
                end
            end
        end
    end

    if self.missionPlayMode == Define.MISSION_PLAY_MODE.SINGLE then
        if self:isPlayerEnter(self.ownerUserId) then
            self.flag = true
            self.enterPlayerCount = self:getPlayerCount(true)
            self:gotoState(Define.MISSION_ROOM_STATE.MISSION_START)
        elseif self:getWaitPlayerLeftTime() <= 0 then
            --- 解除房间绑定
            for userId, _ in pairs(self.multipleUserIds) do
                ---@type Entity
                local player = Game.GetPlayerByUserId(userId)
                if player and player:isValid() then
                    self:unlink(player)
                end
            end
            --- 直接结束
            self:gotoState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, Define.MISSION_COMPLETE_CODE.NO_PLAYER)
        end
    elseif self.missionPlayMode == Define.MISSION_PLAY_MODE.MULTIPLE then
        local wait = true
        if self:getWaitPlayerLeftTime() <= 0 then
            wait = false
        else
            local count = 0
            for userId, _ in pairs(self.multipleUserIds) do
                count = count + 1
                if self:isPlayerEnter(userId) then
                    count = count - 1
                end
            end
            wait = count > 0
        end
        if not wait then
            --- 解除房间绑定
            for userId, _ in pairs(self.multipleUserIds) do
                if not self:isPlayerEnter(userId) then
                    ---@type Entity
                    local player = Game.GetPlayerByUserId(userId)
                    if player and player:isValid() then
                        self:unlink(player)
                    end
                end
            end

            self.enterPlayerCount = self:getPlayerCount(true)

            --- 若存在玩家，则可以开始，否则房间结算
            if self.enterPlayerCount ~= 0 then
                self.flag = true
                self:gotoState(Define.MISSION_ROOM_STATE.MISSION_START)
            else
                self:gotoState(Define.MISSION_ROOM_STATE.MISSION_COMPLETE, Define.MISSION_COMPLETE_CODE.NO_PLAYER)
            end
        end
    end
end

function RoomStateMissionWaitPlayer:exitedState()
    if self.flag then
        ---@type number
        ---@type Entity
        for _, player in pairs(self.players) do
            if player and player:isValid() then
                Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_WAIT_PLAYER_END, self, player, self.time)
            end
        end
    end
    self.time = 0
    self.flag = false
end

return RoomStateMissionWaitPlayer