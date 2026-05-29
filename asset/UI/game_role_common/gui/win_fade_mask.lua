---@class WinFadeMaskLayout : CEGUILayout
local WinFadeMaskLayout = M
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@private
function WinFadeMaskLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
    self:setLevel(49)
end

---@private
function WinFadeMaskLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siMask = self.Mask
end

---@private
function WinFadeMaskLayout:initUI()
end

---@private
function WinFadeMaskLayout:initEvent()
end

function WinFadeMaskLayout:maskFadeIn()
    self.siMask:setVisible(true)
    self.siMask:setAlpha(0)
    local alpha = 0
    local time = 0.5
    local tick = math.ceil(20 * time)
    local step = 1 / tick
    self.maskTimer = LuaTimer:scheduleTicker(function()
        alpha = math.min(alpha + step, 1)
        self.siMask:setAlpha(alpha)
        tick = tick - 1
        if tick <= 0 then
            self:stopMaskTimer()
            self.fadeInFinish = true
            if self.data.fadeInCb then
                self.data.fadeInCb()
            end
            --- 进行下一步
            if self.fadeOutForce then
                self:maskFadeOut()
            elseif self.data.fadeOutTime then
                local waitTicker = math.ceil(self.data.fadeOutTime * 20)
                self.waitTimer = LuaTimer:scheduleTicker(function()
                    waitTicker = waitTicker - 1
                    if waitTicker <= 0 then
                        self:stopWaitTimer()
                        self:maskFadeOut()
                    end
                end, 1)
            end
        end
    end, 1)
end

function WinFadeMaskLayout:maskFadeOut()
    local alpha = 1
    local time = 0.5
    local tick = math.ceil(20 * time)
    local step = 1 / tick
    self.siMask:setVisible(true)
    self.siMask:setAlpha(1)
    self.fadeOutState = true

    self.maskTimer = LuaTimer:scheduleTicker(function()
        alpha = math.max(alpha - step, 0)
        self.siMask:setAlpha(alpha)
        tick = tick - 1
        if tick <= 0 then
            self:stopMaskTimer()
            if self.data.fadeOutCb then
                self.data.fadeOutCb()
            end
            UI:closeWindow(self)
        end
    end, 1)
end

function WinFadeMaskLayout:stopMaskTimer()
    if self.maskTimer then
        LuaTimer:cancel(self.maskTimer)
        self.maskTimer = nil
    end
end

function WinFadeMaskLayout:stopWaitTimer()
    if self.waitTimer then
        LuaTimer:cancel(self.waitTimer)
        self.waitTimer = nil
    end
end

---@private
function WinFadeMaskLayout:onOpen(data)
    self.data = data
    self.fadeInFinish = false
    self.fadeOutState = false
    --- 强制黑屏标记
    self.fadeOutForce = false
    self:maskFadeIn()
    if self.data.fadeOutEvent then
        self:subscribeEvent(Event[self.data.fadeOutEvent], function()
            self.fadeOutForce = true
            if self.fadeInFinish and not self.fadeOutState then
                self:stopWaitTimer()
                self:stopMaskTimer()
                self:maskFadeOut()
            end
        end)
    end
end

---@private
function WinFadeMaskLayout:onDestroy()
    self:stopWaitTimer()
    self:stopMaskTimer()
end

---@private
function WinFadeMaskLayout:onClose()
    self:stopWaitTimer()
    self:stopMaskTimer()
end

WinFadeMaskLayout:init()
