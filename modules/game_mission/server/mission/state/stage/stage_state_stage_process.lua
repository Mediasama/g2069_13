--- 经行状态

---@class StageStateStageProcess : MissionStage
local StageStateStageProcess = {}

function StageStateStageProcess:enteredState()
end

--- 心跳函数，间隔每秒
function StageStateStageProcess:onUpdate()
    local allCompleted = true
    ---@type number, StageContentBase
    for _, stageContent in pairs(self.stageContentList) do
        stageContent:update()
        if not stageContent:completed() then
            allCompleted = false
        end
    end
    if allCompleted then
        self.completeCode = Define.MISSION_COMPLETE_CODE.SUCCESS
        --- 进入下个状态
        self:gotoState(Define.MISSION_STAGE_STATE.STAGE_WAIT)
    end
end

function StageStateStageProcess:exitedState()
end

return StageStateStageProcess