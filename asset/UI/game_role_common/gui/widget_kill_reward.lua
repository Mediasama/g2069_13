---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
local POP_TICK = 24 * 1
local POP_STAY_TICK = 6 * 1
local POP_HEIGHT = 70

---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type GameLib
local GameLib = T(Lib, "GameLib")

---@class WidgetKillRewardWidget : CEGUILayout
local WidgetKillRewardWidget = M

---@private
function WidgetKillRewardWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetKillRewardWidget:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wMoveBody = self.MoveBody
	---@type CEGUIDefaultWindow
	self.wMoveBodyExpReward = self.MoveBody.ExpReward
	---@type CEGUIStaticImage
	self.siMoveBodyExpRewardExpIcon = self.MoveBody.ExpReward.ExpIcon
	---@type CEGUIStaticText
	self.stMoveBodyExpRewardExpValue = self.MoveBody.ExpReward.ExpValue
	---@type CEGUIStaticText
	self.stMoveBodyExpRewardExpValueExRate = self.MoveBody.ExpReward.ExpValue.ExRate
	---@type CEGUIDefaultWindow
	self.wMoveBodyAexpReward = self.MoveBody.AexpReward
	---@type CEGUIStaticImage
	self.siMoveBodyAexpRewardAexpIcon = self.MoveBody.AexpReward.AexpIcon
	---@type CEGUIStaticText
	self.stMoveBodyAexpRewardAexpValue = self.MoveBody.AexpReward.AexpValue
	---@type CEGUIStaticText
	self.stMoveBodyAexpRewardAexpValueExRate = self.MoveBody.AexpReward.AexpValue.ExRate
	---@type CEGUIDefaultWindow
	self.wMoveBodyCoinReward = self.MoveBody.CoinReward
	---@type CEGUIStaticImage
	self.siMoveBodyCoinRewardCoinIcon = self.MoveBody.CoinReward.CoinIcon
	---@type CEGUIStaticText
	self.stMoveBodyCoinRewardCoinValue = self.MoveBody.CoinReward.CoinValue
	---@type CEGUIStaticText
	self.stMoveBodyCoinRewardCoinValueExRate = self.MoveBody.CoinReward.CoinValue.ExRate
end

---@private
function WidgetKillRewardWidget:initUI()

end

---@private
function WidgetKillRewardWidget:initEvent()
end

---@private
function WidgetKillRewardWidget:onOpen()
	self:initData()
	self:subscribeEvents()
end

function WidgetKillRewardWidget:initData()
	self.events = {}
	self.timer = nil
	self.remainTicker = 0
	self.deltaHeight = POP_HEIGHT / POP_TICK
	self.deltaAlpha = 1 / POP_STAY_TICK
end

function WidgetKillRewardWidget:subscribeEvents()
    --- entity onCreate
    ---@param entity Entity
    ---@param isPlayer boolean
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UI_KILL_REWARD, function(exp, coinNum, aexp, limit)
		self.remainTicker = POP_TICK + POP_STAY_TICK
		self:resetRewardPosition()
		self:updateInfo(exp, coinNum, aexp, limit)
		self:startTimer()
		self:setVisible(true)
		self:setAlpha(1)
    end)
end

--- 重置位置
function WidgetKillRewardWidget:resetRewardPosition()
	self.wMoveBody:setYPosition({ 0, 0 })
end

function WidgetKillRewardWidget:startTimer()
	if self.timer then
		return
	end
	self.timer = LuaTimer:scheduleTicker(function()
		self.remainTicker = self.remainTicker - 1

		if self.remainTicker < POP_STAY_TICK then
			local alpha = math.clamp(self:getAlpha() - self.deltaAlpha, 0, 1)
			self:setAlpha(alpha)
		else
			--- 设置位置
			local posY = self.wMoveBody:getYPosition()[2] - self.deltaHeight
			self.wMoveBody:setYPosition({ 0, posY })
		end

		if self.remainTicker <= 0 then
			self:stopTimer()
			self:setVisible(false)
		end
	end, 1)
end

function WidgetKillRewardWidget:stopTimer()
	if self.timer then
		LuaTimer:cancel(self.timer)
		self.timer = nil
	end
end

--- 刷新
---@param exp number 角色经验
---@param coinNum number 金币
---@param aexp number 能力经验
function WidgetKillRewardWidget:updateInfo(exp, coinNum, aexp, limit)
	local index = 0
	local space = 45
	if exp then
		self.wMoveBodyExpReward:setVisible(true)
		self.stMoveBodyExpRewardExpValueExRate:setVisible(false)
		local text = "+" .. exp
		if limit and limit[Define.ITEM_ALIAS.ROLE_EXP] then
			text = text .. Lang:toText("g2069_daily_exp_limit")
		else
			local rate = AttributeSystem:getAttributeValue(Me, Define.ATTR.EXP_RATE)
			if rate > 1 then
				self.stMoveBodyExpRewardExpValueExRate:setVisible(true)
				self.stMoveBodyExpRewardExpValueExRate:setText(" x" .. GameLib.formatUINumber(rate))
			end
		end
		self.stMoveBodyExpRewardExpValue:setText(text)
		self.wMoveBodyExpReward:setYPosition({ 0, 0 })
		index = index + 1
	else
		self.wMoveBodyExpReward:setVisible(false)
	end
	if aexp then
		self.wMoveBodyAexpReward:setVisible(true)
		self.stMoveBodyAexpRewardAexpValueExRate:setVisible(false)
		local text = "+" .. aexp
		if limit and limit[Define.ITEM_ALIAS.ABILITY_EXP] then
			text = text .. Lang:toText("g2069_daily_aexp_limit")
		else
			local rate = AttributeSystem:getAttributeValue(Me, Define.ATTR.AP_RATE)		
			if rate > 1 then
				self.stMoveBodyAexpRewardAexpValueExRate:setVisible(true)
				self.stMoveBodyAexpRewardAexpValueExRate:setText(" x" .. GameLib.formatUINumber(rate))
			end
		end
		self.stMoveBodyAexpRewardAexpValue:setText(text)
		self.wMoveBodyAexpReward:setYPosition({ 0, -index * space })
		index = index + 1
	else
		self.wMoveBodyAexpReward:setVisible(false)
	end
	if coinNum then
		self.wMoveBodyCoinReward:setVisible(true)
		self.stMoveBodyCoinRewardCoinValueExRate:setVisible(false)
		local text = "+" .. coinNum
		if limit and limit[Define.ITEM_ALIAS.GOLD_COIN] then
			text = text .. Lang:toText("g2069_daily_coin_limit")
		else
			local rate = AttributeSystem:getAttributeValue(Me, Define.ATTR.COIN_RATE)
			if rate > 1 then
				self.stMoveBodyCoinRewardCoinValueExRate:setVisible(true)
				self.stMoveBodyCoinRewardCoinValueExRate:setText(" x" .. GameLib.formatUINumber(rate))
			end
		end
		self.stMoveBodyCoinRewardCoinValue:setText(text)
		self.wMoveBodyCoinReward:setYPosition({ 0, -index * space })
		index = index + 1
	else
		self.wMoveBodyCoinReward:setVisible(false)
	end
end

function WidgetKillRewardWidget:unsubscribeEvents()
	if self.events then
		for _, func in pairs(self.events) do
			func()
		end
		self.events = nil
	end
end

---@private
function WidgetKillRewardWidget:onDestroy()
	self:stopTimer()
	self:unsubscribeEvents()
end

WidgetKillRewardWidget:init()
