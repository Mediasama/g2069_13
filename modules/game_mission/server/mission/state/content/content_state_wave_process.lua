--- 经行状态

---@class ContentStateWaveProcess : StageContentBase
local ContentStateWaveProcess = {}

function ContentStateWaveProcess:enteredState(isRepeat)
end

--- 心跳函数，间隔每秒
function ContentStateWaveProcess:onUpdate()
    --- 当前波数结束
    if self:checkCurrentWaveCompleted() then
        --- 判断是否进行下一波
        if self:checkWaveContinue() then
            self:gotoState(Define.MISSION_WAVE_STATE.WAVE_WAIT)
        else
            self:gotoState(Define.MISSION_WAVE_STATE.WAVE_END)
        end
    end
end

function ContentStateWaveProcess:exitedState()
end

return ContentStateWaveProcess