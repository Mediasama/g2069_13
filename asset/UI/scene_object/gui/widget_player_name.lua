---@class WidgetPlayerNameWidget : CEGUILayout
local WidgetPlayerNameWidget = M

---@private
function WidgetPlayerNameWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetPlayerNameWidget:findAllWindow()
	---@type CEGUIStaticText
	self.stPlayerName = self.PlayerName
end

---@private
function WidgetPlayerNameWidget:initUI()
	self.stPlayerName:setText(Lang:toText(""))
end

---@private
function WidgetPlayerNameWidget:initEvent()
end

---@private
function WidgetPlayerNameWidget:onOpen()

end

function WidgetPlayerNameWidget:updateInfo(name)
    self.stPlayerName:setText(name)
end

---@private
function WidgetPlayerNameWidget:onDestroy()

end

WidgetPlayerNameWidget:init()
