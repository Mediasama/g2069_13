--- 开始状态

---@class StageStateStageStart : MissionStage
local StageStateStageStart = {}

function StageStateStageStart:enteredState()
    --- 启动
    ---@type number
    ---@type StageContentBase
    for _, stageContent in pairs(self.stageContentList) do
        stageContent:start()
    end
    self:gotoState(Define.MISSION_STAGE_STATE.STAGE_PROCESS)
end

--- 心跳函数，间隔每秒
function StageStateStageStart:onUpdate()
end

function StageStateStageStart:exitedState()
end

return StageStateStageStart