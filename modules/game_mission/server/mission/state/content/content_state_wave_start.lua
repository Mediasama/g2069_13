--- 开始状态

---@class ContentStateWaveStart : StageContentBase
local ContentStateWaveStart = {}

function ContentStateWaveStart:enteredState(isRepeat)
    self:onWaveStart()
    self:gotoState(Define.MISSION_WAVE_STATE.WAVE_PROCESS)
end

--- 心跳函数，间隔每秒
function ContentStateWaveStart:onUpdate()
end

function ContentStateWaveStart:exitedState()
end

return ContentStateWaveStart