--- 准备状态

---@class RoomStateMissionPrepare : MissionRoom
local RoomStateMissionPrepare = {}

function RoomStateMissionPrepare:enteredState()
    --- 切换下一个状态
    self:gotoState(Define.MISSION_ROOM_STATE.MISSION_WAIT_PLAYER)
end

--- 心跳函数，间隔每秒
function RoomStateMissionPrepare:onUpdate()
    
end

function RoomStateMissionPrepare:exitedState()
end

return RoomStateMissionPrepare