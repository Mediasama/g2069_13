---@class WidgetDialogReplyWidget : CEGUILayout
local WidgetDialogReplyWidget = M
---@type NpcDialogueReplyConfig
local NpcDialogueReplyConfig = T(Config, "NpcDialogueReplyConfig")

---@private
function WidgetDialogReplyWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetDialogReplyWidget:findAllWindow()
	---@type CEGUIButton
	self.btnReplyBtn = self.replyBtn
end

---@private
function WidgetDialogReplyWidget:initUI()
end

---@private
function WidgetDialogReplyWidget:initEvent()
	self.btnReplyBtn.onMouseClick = function()
		if not self.replyId then
			return
		end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		if not self.replyConfig then
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		else
			Lib.emitEvent(Event.EVENT_UPDATE_NPC_DIALOG_REPLY, self.replyId, self.replyConfig.replyType)
		end
	end
end

function WidgetDialogReplyWidget:initData(replyId)
	self.replyId = replyId
	self.replyConfig = NpcDialogueReplyConfig:getCfgById(replyId)
	if self.replyConfig and self.replyConfig.replyText then
		self.btnReplyBtn:setText(Lang:toText(self.replyConfig.replyText))
	end
end

---@private
function WidgetDialogReplyWidget:onOpen()

end

---@private
function WidgetDialogReplyWidget:onDestroy()

end

WidgetDialogReplyWidget:init()
