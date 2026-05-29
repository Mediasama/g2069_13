---@class WinNpcTaskTipLayout : CEGUILayout
local WinNpcTaskTipLayout = M


---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type NpcConfig
local NpcConfig = T(Config, "NpcConfig")

---@private
function WinNpcTaskTipLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinNpcTaskTipLayout:findAllWindow()
	---@type CEGUIEffectWindow
	self.wEffectWindow = self.EffectWindow
end

---@private
function WinNpcTaskTipLayout:initUI()
end

---@private
function WinNpcTaskTipLayout:initEvent()
end

---@private
function WinNpcTaskTipLayout:onOpen()

end

---@private
function WinNpcTaskTipLayout:onDestroy()
end

---@private
function WinNpcTaskTipLayout:onClose()

end

WinNpcTaskTipLayout:init()
