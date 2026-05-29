--- 等待状态

---@class StageStateStageWait : MissionStage
local StageStateStageWait = {}

function StageStateStageWait:enteredState()
    self:gotoState(Define.MISSION_STAGE_STATE.STAGE_END)
end

--- 心跳函数，间隔每秒
function StageStateStageWait:onUpdate()

end

function StageStateStageWait:exitedState()
end

return StageStateStageWait