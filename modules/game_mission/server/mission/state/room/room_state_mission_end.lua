--- 基础状态

---@class RoomStateMissionEnd : MissionRoom
local RoomStateMissionEnd = {}

function RoomStateMissionEnd:enteredState()
end

--- 心跳函数，间隔每秒
function RoomStateMissionEnd:onUpdate()
end

function RoomStateMissionEnd:exitedState()
end

return RoomStateMissionEnd