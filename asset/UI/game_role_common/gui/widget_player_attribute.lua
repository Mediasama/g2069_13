---@class WidgetPlayerAttributeWidget : CEGUILayout
local WidgetPlayerAttributeWidget = M

---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")
---@type AttributeLevelConfig
local AttributeLevelConfig = T(Config, "AttributeLevelConfig")


local TEXT_COLOR = {
	grey = "ff9b8f85",
	orange = "fff57129",
	black = "100E0D",
}

---@private
function WidgetPlayerAttributeWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetPlayerAttributeWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siAttributeIcon = self.AttributeIcon
	---@type CEGUIStaticText
	self.stAttributeName = self.AttributeName
	---@type CEGUIStaticText
	self.stAttributeLevel = self.AttributeLevel
	---@type CEGUIStaticText
	self.stMaxLevel = self.MaxLevel
	---@type CEGUIButton
	self.btnAddButton = self.AddButton
end

---@private
function WidgetPlayerAttributeWidget:initUI()
	self.stMaxLevel:setText(Lang:toText("g2069_attribute_is_max_level"))
	-- self.btnAddButton:setText(Lang:toText("g2069_upgrade_button"))
	self.stAttributeName:setProperty("TextColours", TEXT_COLOR.black)
	self.stMaxLevel:setProperty("TextColours", TEXT_COLOR.black)
end

---@private
function WidgetPlayerAttributeWidget:initEvent()
	self.btnAddButton.onMouseClick = function()
		if not self.attributeId then
			return
		end
		self:callHandler("add", self.levelIndex, self.attributeId)
	end
end

---@private
function WidgetPlayerAttributeWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetPlayerAttributeWidget:initData()
	self.levelIndex = nil
	self.attributeId = nil
    self.callHandlers = {}
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetPlayerAttributeWidget:registerCallHandler(key, context, func)
	self.callHandlers[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetPlayerAttributeWidget:callHandler(key, ...)
	local handler = self.callHandlers[key]
    if handler then
        local this = handler.this
        local func = handler.func
        return func(this, key, ...)
    end
end

function WidgetPlayerAttributeWidget:updateInfo(levelIndex, attributeId, attributeLevel)
	self.levelIndex = levelIndex
	self.attributeId = attributeId
	local config = AttributeInfoConfig:getCfgByAttributeId(attributeId)
    local name = config.name or attributeId
	self.stAttributeName:setText(Lang:toText(name))
	self.stAttributeLevel:setText("LV." .. attributeLevel)
	self.siAttributeIcon:setImage(config.icon)
	local max_level = AttributeLevelConfig:getMaxLevel(attributeId)
	if attributeLevel >= max_level then
		self.stMaxLevel:setVisible(true)
		self.btnAddButton:setVisible(false)
		self.stAttributeLevel:setProperty("TextColours", TEXT_COLOR.black)
	else
		self.stMaxLevel:setVisible(false)
		self.btnAddButton:setVisible(true)
		self.stAttributeLevel:setProperty("TextColours", TEXT_COLOR.orange)
	end
end

function WidgetPlayerAttributeWidget:subscribeEvents()
	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ADD_POINT, function(success, player, levelIndex, attributeId, attributeLevel)
		if not success then
			return
		end
		if not self.levelIndex or self.levelIndex ~= levelIndex or not self.attributeId or self.attributeId ~= attributeId then
			return
		end
		self:updateInfo(levelIndex, attributeId, attributeLevel)
	end)

	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_UPDATE_POINT_SET_ATTRIBUTE, function(levelIndex, attributeId, attributeLevel)
		if not self.attributeId or self.attributeId ~= attributeId then
			return
		end
		self:updateInfo(levelIndex, attributeId, attributeLevel)
	end)
	
end

---@private
function WidgetPlayerAttributeWidget:onDestroy()

end

WidgetPlayerAttributeWidget:init()
