--- 等待状态

---@class ContentStateWaveWait : StageContentBase
local ContentStateWaveWait = {}

function ContentStateWaveWait:enteredState()
    self.time = 0
    if self.waitTime <= 0 then
        self:gotoState(Define.MISSION_WAVE_STATE.WAVE_SATRT, true)
    end
end

--- 心跳函数，间隔每秒
function ContentStateWaveWait:onUpdate()
    if self.waitTime > 0 then
        self.time = self.time + 1
        if self.time == self.waitTime then
            self:gotoState(Define.MISSION_WAVE_STATE.WAVE_SATRT, true)
        end
    end
end

function ContentStateWaveWait:exitedState()
    self.time = 0
end

return ContentStateWaveWait