---@class WidgetGameShopSkillWidget : CEGUILayout
local WidgetGameShopSkillWidget = M

---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")

local FONT_COLOR = {
    "ff1aab45",
    "ffe12d68",
    "ff9b26e5",
    "ff3365e2",
    "fff05316",
}


---@private
function WidgetGameShopSkillWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetGameShopSkillWidget:findAllWindow()
	---@type CEGUIStaticText
	self.stName = self.Name
	---@type CEGUIStaticText
	self.stLevel = self.Level
	---@type CEGUIStaticImage
	self.siLineBg = self.LineBg
end

---@private
function WidgetGameShopSkillWidget:initUI()

end

---@private
function WidgetGameShopSkillWidget:initEvent()
end

---@private
function WidgetGameShopSkillWidget:onOpen()
	self:initData()
end

function WidgetGameShopSkillWidget:initData()
    self.callHandlers = {}
end

--- 注册回调
---@param context any
---@param func any
function WidgetGameShopSkillWidget:registerCallHandler(key, context, func)
    self.callHandlers[key] = { this = context, func = func }
end

--- 回调
function WidgetGameShopSkillWidget:callHandler(key, ...)
    local data = self.callHandlers[key]
    if data then
        local this = data.this
        local func = data.func
        return func(this, key, ...)
    end
end

function WidgetGameShopSkillWidget:updateInfo(unlockLevel, skillId, index)
    self.stLevel:setText("LV." .. unlockLevel)
    local skillConfig = SkillConfig:getSkillConfig(skillId)
    local name = tostring(skillId)
    if skillConfig.name and skillConfig.name ~= "" then
        name = skillConfig.name
    end
    
    self.stName:setText(Lang:toText(name))
    self.siLineBg:setVisible(index ~= 1)

    local color = FONT_COLOR[index]
    if color then
        self.stName:setProperty("TextColours", color)
        self.stLevel:setProperty("TextColours", color)
    end
end

---@private
function WidgetGameShopSkillWidget:onDestroy()

end

WidgetGameShopSkillWidget:init()
