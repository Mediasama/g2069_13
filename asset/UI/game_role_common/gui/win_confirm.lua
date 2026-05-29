---@class WinConfirmLayout : CEGUILayout
local WinConfirmLayout = M

---@private
function WinConfirmLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.Bg
end

---@private
function WinConfirmLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMask = self.Mask
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticText
	self.stBgTitle = self.Bg.Title
	---@type CEGUIStaticText
	self.stBgContent = self.Bg.Content
	---@type CEGUIButton
	self.btnBgConfirm = self.Bg.Confirm
	---@type CEGUIButton
	self.btnBgCancel = self.Bg.Cancel
	---@type CEGUIButton
	self.btnBgClose = self.Bg.Close
end

---@private
function WinConfirmLayout:initUI()
	-- self.stBgTitle:setText(Lang:toText(""))
	-- self.stBgContent:setText(Lang:toText(""))
	self.btnBgConfirm:setText(Lang:toText("g2069_ok_button"))
	self.btnBgCancel:setText(Lang:toText("g2069_cancel_button"))
end

---@private
function WinConfirmLayout:initEvent()
	self.btnBgConfirm.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		if self.confirmCallback then
			self.confirmCallback()
		end
		UI:closeWindow(self)
	end
	self.btnBgCancel.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		if self.cancelCallback then
			self.cancelCallback()
		end
		UI:closeWindow(self)
	end
	self.btnBgClose.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		if self.closeCallback then
			self.closeCallback()
		end
		UI:closeWindow(self)
	end
end

function WinConfirmLayout:initData(args)
	self.confirmCallback = args.confirmCallback or nil
	self.cancelCallback = args.cancelCallback or nil
	self.closeCallback = args.closeCallback or nil
	self.winTitle = args.title or ""
	self.winContent = args.content or ""
end

---@private
function WinConfirmLayout:onOpen(args)
	self:initData(args)
	self:updateWinInfo()
end

function WinConfirmLayout:updateWinInfo()
	self.stBgTitle:setText(self.winTitle)
	self.stBgContent:setText(self.winContent)
end

---@private
function WinConfirmLayout:onDestroy()
	self.confirmCallback = nil
	self.cancelCallback = nil
	self.closeCallback = nil
end

---@private
function WinConfirmLayout:onClose()

end

WinConfirmLayout:init()
