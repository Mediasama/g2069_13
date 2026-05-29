---@class WinShootDownLayout : CEGUILayout
local WinShootDownLayout = M

---@private
function WinShootDownLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
    World.Timer(math.floor(20*1.4),function ()
        UI:closeWindow(self)
    end)
end

---@private
function WinShootDownLayout:findAllWindow()
    ---@type CEGUIEffectWindow
    self.wEffectWindow = self.EffectWindow
end

---@private
function WinShootDownLayout:initUI()
end

---@private
function WinShootDownLayout:initEvent()
end

---@private
function WinShootDownLayout:onOpen()

end

---@private
function WinShootDownLayout:onDestroy()

end

---@private
function WinShootDownLayout:onClose()

end

WinShootDownLayout:init()
