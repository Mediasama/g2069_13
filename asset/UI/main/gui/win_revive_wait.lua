---@class WinReviveWaitLayout : CEGUILayout
local WinReviveWaitLayout = M

---@private
function WinReviveWaitLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinReviveWaitLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.bg
	---@type CEGUIStaticText
	self.stTipsText = self.tipsText
end

---@private
function WinReviveWaitLayout:initUI()
end

---@private
function WinReviveWaitLayout:initEvent()
end

---@private
function WinReviveWaitLayout:onOpen(attackerName)
	local name = Lang:toText(attackerName or "")
	self.stTipsText:setText(Lang:toText({ "g2069_wait_revive_tips", name }))
	if self.delayTimer then
		self.delayTimer()
		self.delayTimer = nil
	end
end

---@private
function WinReviveWaitLayout:onDestroy()
end

---@private
function WinReviveWaitLayout:onClose()
	self.delayTimer = World.Timer(5, function()
		if Me and Me:isValid() then
			Me:setAlwaysAction("")
		end
		self.delayTimer()
		self.delayTimer = nil
	end)
end

WinReviveWaitLayout:init()
