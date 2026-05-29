--- 结束状态

---@class StageStateStageEnd : MissionStage
local StageStateStageEnd = {}

function StageStateStageEnd:enteredState()
end

--- 心跳函数，间隔每秒
function StageStateStageEnd:onUpdate()
end

function StageStateStageEnd:exitedState()
end

return StageStateStageEnd