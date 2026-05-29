---@class WidgetAbilityBookItemWidget : CEGUILayout
local WidgetAbilityBookItemWidget = M
---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")

local AWAKE_ICON = {
	[1] = "gameres|asset/imageset/wake:img_0_1",
	[2] = "gameres|asset/imageset/wake:img_0_2",
	[3] = "gameres|asset/imageset/wake:img_0_3",
	[4] = "gameres|asset/imageset/wake:img_0_4",
	[5] = "gameres|asset/imageset/wake:img_0_5",
	[6] = "gameres|asset/imageset/wake:img_0_6",
	[7] = "gameres|asset/imageset/wake:img_0_7",
	[8] = "gameres|asset/imageset/wake:img_0_8",
	[9] = "gameres|asset/imageset/wake:img_0_9",
	[10] = "gameres|asset/imageset/wake:img_0_10",
}

---@private
function WidgetAbilityBookItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetAbilityBookItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticImage
	self.siAwakeBg = self.AwakeBg
	---@type CEGUIStaticText
	self.stAwakeDesc = self.AwakeDesc
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetAbilityBookItemWidget:initUI()

end

---@private
function WidgetAbilityBookItemWidget:initEvent()
	self._allEvent = {}
	self._allEvent[#self._allEvent + 1] = self:subscribeEvent(Event.EVENT_GAME_BOOK_ABILITY_SELECT, function(abilityId)
		if not self.abilityId then
			return
		end
		local selected = abilityId == self.abilityId
		self.siSelectedBg:setVisible(selected)
	end)

	self.btnClickButton.onMouseClick = function()
		if not self.abilityId then
			return
		end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:callHandler("select_awake", self.abilityId, self.abilityAwake)
	end
end

---@private
function WidgetAbilityBookItemWidget:onOpen()
	self:initData()
end

function WidgetAbilityBookItemWidget:initData()
	self.abilityId = nil
	self.abilityAwake = nil
	self.callHandlers = {}
end

--- 注册回调
---@param context any
---@param func any
function WidgetAbilityBookItemWidget:registerCallHandler(key, context, func)
	self.callHandlers[key] = { this = context, func = func }
end

--- 回调
function WidgetAbilityBookItemWidget:callHandler(key, ...)
	local data = self.callHandlers[key]
	if data then
		local this = data.this
		local func = data.func
		return func(this, key, ...)
	end
end

--- 刷新信息
---@param abilityId number
---@param awake number
function WidgetAbilityBookItemWidget:updateInfo(data)
	local abilityId = data.abilityId
	local awake = data.awake
	local origin = data.origin

	self.abilityId = abilityId
	self.abilityAwake = awake

	local config = AbilityAwakeConfig:getCfgByAbilityId(origin)
	local desc = config.awake_tips[awake] or "unknown"

	self.stAwakeDesc:setText(Lang:toText(desc))
	self.siAwakeBg:setImage(AWAKE_ICON[awake])

	local selected = self:callHandler("selected", abilityId, awake) or false
	self.siSelectedBg:setVisible(selected)
end

---@private
function WidgetAbilityBookItemWidget:onDestroy()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WidgetAbilityBookItemWidget:init()
