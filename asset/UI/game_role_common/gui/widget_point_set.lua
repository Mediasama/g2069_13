---@class WidgetPointSetWidget : CEGUILayout
local WidgetPointSetWidget = M

---@private
function WidgetPointSetWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetPointSetWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticText
	self.stName = self.Name
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIStaticText
	self.stSelectedBgName = self.SelectedBg.Name
	---@type CEGUIButton
	self.btnAddSetButton = self.AddSetButton
	---@type CEGUIButton
	self.btnPointSetButton = self.PointSetButton
end

---@private
function WidgetPointSetWidget:initUI()
	-- self.stName:setText(Lang:toText(""))
	-- self.stSelectedBgName:setText(Lang:toText(""))
end

---@private
function WidgetPointSetWidget:initEvent()
	self.btnAddSetButton.onMouseClick = function()
		self:callHandler("unlock", self.levelIndex)
	end
	self.btnPointSetButton.onMouseClick = function()
		self:callHandler("select", self.levelIndex)
	end
end

---@private
function WidgetPointSetWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetPointSetWidget:initData()
	self.levelIndex = nil
    self.unlockIndex = nil
    self.callHandlers = {}
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetPointSetWidget:registerCallHandler(key, context, func)
	self.callHandlers[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetPointSetWidget:callHandler(key, ...)
	local handler = self.callHandlers[key]
    if handler then
        local this = handler.this
        local func = handler.func
        return func(this, key, ...)
    end
end

function WidgetPointSetWidget:updateInfo(levelIndex, unlockIndex)
	self.levelIndex = levelIndex
	self.unlockIndex = unlockIndex

	local name = Lang:toText({ "g2069_attribute_point_set", levelIndex })
	self.stName:setText(name)
	self.stSelectedBgName:setText(name)

	local unlock = levelIndex <= unlockIndex

	self.AddSetButton:setVisible(not unlock)
	self.btnPointSetButton:setVisible(unlock)

	local selected = self:callHandler("selected", self.levelIndex)

	self.siSelectedBg:setVisible(selected or false)
end

function WidgetPointSetWidget:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_POINT_SET, function(levelIndex)
		if not self.levelIndex then
			return
		end
		local selected = levelIndex == self.levelIndex
		self.siSelectedBg:setVisible(selected or false)
	end)

	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_POINT_SET_UNLOCK, function(success, player, unlockIndex, preIndex)
		if not self.levelIndex then
			return
		end
		if success then
			self:updateInfo(self.levelIndex, unlockIndex)
		end
	end)
end

---@private
function WidgetPointSetWidget:onDestroy()

end

WidgetPointSetWidget:init()
