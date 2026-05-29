--- 基础状态

---@class RoomStateMissionStageInit : MissionRoom
local RoomStateMissionStageInit = {}

function RoomStateMissionStageInit:enteredState()
    self.time = 0

    --- 角色切场景等待
    ---@type number
    ---@type Entity
    for _, player in pairs(self.players) do
        if player and player:isValid() then
            --- 设置状态数据
            self:syncStageInitState(player)
        end
    end
end

--- 心跳函数，间隔每秒
function RoomStateMissionStageInit:onUpdate()
    self.time = self.time + 1
    if self:getCurrentStageInitLeftTime() == 0 then
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_STAGE_MASK, true)
    end
end

function RoomStateMissionStageInit:exitedState()
    self.time = 0
end

return RoomStateMissionStageInit