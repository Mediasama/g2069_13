---@class WidgetAbilityAwakeItemWidget : CEGUILayout
local WidgetAbilityAwakeItemWidget = M

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
function WidgetAbilityAwakeItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetAbilityAwakeItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticImage
	self.siAwakeBg = self.AwakeBg
	---@type CEGUIStaticImage
	self.siAwakeComplete = self.AwakeComplete
	---@type CEGUIStaticText
	self.stAwakeDesc = self.AwakeDesc
	---@type CEGUIStaticImage
	self.siLockBg = self.LockBg
	---@type CEGUIStaticImage
	self.siLockBgLockIcon = self.LockBg.LockIcon
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetAbilityAwakeItemWidget:initUI()
end

---@private
function WidgetAbilityAwakeItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function()
		if not self.abilityId then
			return
		end
		self:callHandler("select_awake", self.abilityId, self.abilityAwake)
	end
end

---@private
function WidgetAbilityAwakeItemWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetAbilityAwakeItemWidget:initData()
	self.abilityId = nil
	self.abilityAwake = nil
    self.callHandlers = {}
end

function WidgetAbilityAwakeItemWidget:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_SELECT_ABILITY_AWAKE, function(abilityId)
        if not self.abilityId then
            return
        end
		local selected = abilityId == self.abilityId
        self.siSelectedBg:setVisible(selected)
    end)

	self:subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_AWAKE, function(success, player, ability)
        if not self.abilityId or not success then
            return
        end
		local unlock = self:callHandler("unlock", self.abilityId, self.abilityAwake) or false
		local isAwake = self:callHandler("is_awake", self.abilityId, self.abilityAwake) or false
		self.siLockBg:setVisible(not unlock)
		self.siAwakeComplete:setVisible(isAwake)
    end)
end

--- 注册回调
---@param context any
---@param func any
function WidgetAbilityAwakeItemWidget:registerCallHandler(key, context, func)
    self.callHandlers[key] = { this = context, func = func }
end

--- 回调
function WidgetAbilityAwakeItemWidget:callHandler(key, ...)
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
function WidgetAbilityAwakeItemWidget:updateInfo(data)
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
	local unlock = self:callHandler("unlock", abilityId, awake) or false
	local isAwake = self:callHandler("is_awake", abilityId, awake) or false

	self.siSelectedBg:setVisible(selected)
	self.siLockBg:setVisible(not unlock)
	self.siAwakeComplete:setVisible(isAwake)
end

---@private
function WidgetAbilityAwakeItemWidget:onDestroy()

end

WidgetAbilityAwakeItemWidget:init()
