--- 基础状态

---@class RoomStateMissionStageMask : MissionRoom
local RoomStateMissionStageMask = {}

local MASK_TIME = 1

function RoomStateMissionStageMask:enteredState()
    self.time = 0
    --- 角色黑屏
    ---@type number
    ---@type Entity
    for _, player in pairs(self.players) do
        if player and player:isValid() then
            --- 设置状态数据
            self:syncStageMaskState(player)
        end
    end
end

--- 心跳函数，间隔每秒
function RoomStateMissionStageMask:onUpdate()
    self.time = self.time + 1
    if self.time == MASK_TIME then
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_START, true)
    end
end

function RoomStateMissionStageMask:exitedState()
    self.time = 0
end

return RoomStateMissionStageMask