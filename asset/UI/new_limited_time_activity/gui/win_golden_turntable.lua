---@class WinGoldenTurntableLayout : CEGUILayout
local WinGoldenTurntableLayout = M

---@type LimitTimeClientHelper
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
---@type LimitedTimeGoldWheelConfig
local LimitedTimeGoldWheelConfig = T(Config, "LimitedTimeGoldWheelConfig")
---@type LimitedTimeGoldWheelAwardsConfig
local LimitedTimeGoldWheelAwardsConfig = T(Config, "LimitedTimeGoldWheelAwardsConfig")
---@type LimitedTimeGiftItemConfig
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

local rotationAngle = { 0, 60, 120, 180, 240, 300 }

---@private
function WinGoldenTurntableLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinGoldenTurntableLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIDefaultWindow
	self.wMainWindowMainBody = self.MainWindow.MainBody
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyBg = self.MainWindow.MainBody.Bg
	---@type CEGUIDefaultWindow
	self.wMainWindowMainBodyWheelWindow = self.MainWindow.MainBody.WheelWindow
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowBg = self.MainWindow.MainBody.WheelWindow.Bg
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowWheelFace = self.MainWindow.MainBody.WheelWindow.WheelFace
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowWheelFaceHighLight = self.MainWindow.MainBody.WheelWindow.WheelFace.HighLight
	---@type CEGUIButton
	self.btnMainWindowMainBodyWheelWindowPayButton = self.MainWindow.MainBody.WheelWindow.PayButton
	---@type CEGUIStaticText
	self.stMainWindowMainBodyWheelWindowPayButtonTitle = self.MainWindow.MainBody.WheelWindow.PayButton.Title
	---@type CEGUIDefaultWindow
	self.wMainWindowMainBodyWheelWindowCurrencyDiscount = self.MainWindow.MainBody.WheelWindow.CurrencyDiscount
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowCurrencyDiscountIcon = self.MainWindow.MainBody.WheelWindow.CurrencyDiscount.Icon
	---@type CEGUIStaticText
	self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum1 = self.MainWindow.MainBody.WheelWindow.CurrencyDiscount.Num1
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowCurrencyDiscountNum1Line = self.MainWindow.MainBody.WheelWindow.CurrencyDiscount.Num1.Line
	---@type CEGUIStaticText
	self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum2 = self.MainWindow.MainBody.WheelWindow.CurrencyDiscount.Num2
	---@type CEGUIDefaultWindow
	self.wMainWindowMainBodyWheelWindowCurrency = self.MainWindow.MainBody.WheelWindow.Currency
	---@type CEGUIStaticImage
	self.siMainWindowMainBodyWheelWindowCurrencyIcon = self.MainWindow.MainBody.WheelWindow.Currency.Icon
	---@type CEGUIStaticText
	self.stMainWindowMainBodyWheelWindowCurrencyNum1 = self.MainWindow.MainBody.WheelWindow.Currency.Num1
	---@type CEGUIStaticText
	self.stMainWindowMainBodyWheelWindowCountDown = self.MainWindow.MainBody.WheelWindow.CountDown
	---@type CEGUIButton
	self.btnMainWindowHelpButton = self.MainWindow.HelpButton
	---@type CEGUIStaticText
	self.stMainWindowTitle = self.MainWindow.Title
	---@type CEGUIDefaultWindow
	self.wMainWindowCoinNode = self.MainWindow.CoinNode
	---@type CEGUIButton
	self.btnMainWindowCloseButton = self.MainWindow.CloseButton
end

---@private
function WinGoldenTurntableLayout:initUI()
	self.stMainWindowTitle:setText(Lang:toText("gui.limit.time.activity.gold.wheel.title"))
	self.stMainWindowMainBodyWheelWindowPayButtonTitle:setText(Lang:toText("GO"))
	-- self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum1:setText(Lang:toText(""))
	-- self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum2:setText(Lang:toText(""))
	-- self.stMainWindowMainBodyWheelWindowCurrencyNum1:setText(Lang:toText(""))
	-- self.stMainWindowMainBodyWheelWindowCountDown:setText(Lang:toText(""))


	self.imgWheelFace = self.siMainWindowMainBodyWheelWindowWheelFace
	self.imgHighlight = self.siMainWindowMainBodyWheelWindowWheelFaceHighLight
	self.btnPay = self.btnMainWindowMainBodyWheelWindowPayButton

	self.imgCurrency1 = self.wMainWindowMainBodyWheelWindowCurrencyDiscount
	self.txtCurrencyNum1 = self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum1
	self.txtCurrencyNum2 = self.stMainWindowMainBodyWheelWindowCurrencyDiscountNum2
	self.imgCurrency = self.wMainWindowMainBodyWheelWindowCurrency
	self.txtCurrencyNum = self.stMainWindowMainBodyWheelWindowCurrencyNum1
	self.txtCountDown = self.stMainWindowMainBodyWheelWindowCountDown

end

---@private
function WinGoldenTurntableLayout:initEvent()
	self.btnMainWindowHelpButton.onMouseClick = function()
        -- UI:openWnd("limitedTimeActivityCommonDialog", {title = "gui.limit.time.activity.help", dec = "gui.limit.time.activity.gold.wheel.help"})
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Me:showConfirm(Lang:toText("gui.limit.time.activity.help"), Lang:toText("gui.limit.time.activity.gold.wheel.help"))
	end
	self.btnMainWindowMainBodyWheelWindowPayButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        if Me.inPlayLimitedTimeGoldWheel then
            return
        end
        if not self.params or not self.cfg or not self.pond then
			return
		end
		if self.wheelTimer or self.highlightTimer then
			return
		end

		local params = {}
		params.id = self.params.id
		params.price = self.isDiscount and self.cfg.dailyDeals or self.cfg.price
		Me:playLimitedTimeGoldWheel(params)
	end
    self.btnMainWindowCloseButton.onMouseClick = function()
        if Me.inPlayLimitedTimeGoldWheel then
			Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
            return
        end
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
        UI:closeWindow(self)
	end
end

---@private
function WinGoldenTurntableLayout:onOpen()
    self:initData()
    self:initItemList()
    self:initView()
    self:subscribeEvents()
	
    local node = UI:openWidget("UI/game_coin/gui/widget_common_coin", nil, {
		notAutoRefreshGold = true
	})
    self.wMainWindowCoinNode:addChild(node:getWindow())
	---@type WidgetCommonCoinWidget
	self._coinNode = node
end

function WinGoldenTurntableLayout:initData()
    self.ratioItem = {}
    self.isOpen = true
	self.curRotateAngle = 0
	self.awards = LimitedTimeGiftItemConfig:getAllCfgs()

    self.wheelSize = {
        width = 0,
        height = 0,
    }
    self.itemSize = {
        width = 0,
        height = 0,
        init = false,
    }
    self.wheelSize.width = self.imgWheelFace:getWidth()[2]
    self.wheelSize.height = self.imgWheelFace:getHeight()[2]
end

function WinGoldenTurntableLayout:initItemList()
	for i = 1, 6 do
        local node = UI:openWidget("UI/new_limited_time_activity/gui/widget_golden_turntable_item")
        self.imgWheelFace:addChild(node:getWindow())
        if not self.itemSize.init then
            self.itemSize.init = true
            self.itemSize.width = node:getWidth()[2]
            self.itemSize.height = node:getHeight()[2]
        end

		local itemPos = self:getPosByAngleAndRadius(rotationAngle[i],  188)
        node:setXPosition({ 0, itemPos.x })
        node:setYPosition({ 0, itemPos.y })
        self.ratioItem[i] = node
	end
end

function WinGoldenTurntableLayout:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GET_LIMITED_TIME_GOLD_WHEEL_RESULT, function(addition)
		self.addition = addition
		self:startWheel(addition)
	end)

	self:subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_FIRST_PURCHASE_DATA, function()
		self:updatePurchaseInfo()
	end)
end

-- 获取圆中心特定角度、半径的坐标
function WinGoldenTurntableLayout:getPosByAngleAndRadius(angle, radius, offset)
	local offset = offset and offset * -1 or 0
	local yaw = angle + offset
	local value = math.rad(yaw)
	local s = math.sin(value)
	local c = math.cos(value)
    ---@type Vector3
    local pos = Lib.v3(s, c, 0) * radius * -1
    pos.x = pos.x + self.wheelSize.width * 0.5 - self.itemSize.width * 0.5
    pos.y = pos.y + self.wheelSize.height * 0.5 - self.itemSize.height * 0.5
	return pos
end

--界面数据初始化
function WinGoldenTurntableLayout:initView()
	self:updateView()
	self.imgHighlight:setVisible(false)
end

function WinGoldenTurntableLayout:updatePurchaseInfo()
	if not self.params or not self.cfg then
		return
	end
	if self.discountsTimer then
		self.discountsTimer()
		self.discountsTimer = nil
	end
	self.txtCurrencyNum1:setText(self.cfg.price)
	self.txtCurrencyNum2:setText(self.cfg.dailyDeals)
	self.txtCurrencyNum:setText(self.cfg.price)
	local purchaseData = Me:getFirstPurchaseData()
	local isDiscount = false
	if purchaseData[self.cfg.pondId] then
		isDiscount = (os.time() - purchaseData[self.cfg.pondId]) > (3600 * 24)
	else
		isDiscount = true
	end
	self.imgCurrency1:setVisible(isDiscount)
	self.imgCurrency:setVisible(not isDiscount)
	-- self.txtCountDown:setVisible(not isDiscount)
	self.txtCountDown:setVisible(true)
	self.isDiscount = isDiscount
	if not isDiscount then
		local this = self

		local count_down = function()
			local surplus = purchaseData[this.cfg.pondId] + (3600 * 24) - os.time()
			local timeHour, timeMinute, timeSecond = Lib.timeFormatting(surplus)
			local time = timeHour .. ":" .. timeMinute .. ":" .. timeSecond
			if surplus > 0 then
				local text = Lang:toText("g2069_gold_wheel_tips2") .. " " .. time
				this.txtCountDown:setText(text)
			else
				this.txtCountDown:setText(Lang:toText("g2069_gold_wheel_tips1"))
			end
			-- this.txtCountDown:setText(time)
			-- if surplus > 0 then
			-- 	this.txtCountDown:setVisible(true)
			-- else
			-- 	this.imgCurrency1:setVisible(true)
			-- 	this.txtCountDown:setVisible(false)
			-- 	this.imgCurrency:setVisible(false)
			-- end
			return surplus > 0
		end
		
		count_down()
		self.discountsTimer = Me:timer(20, function()
			return count_down()
		end)
	else
		self.txtCountDown:setText(Lang:toText("g2069_gold_wheel_tips1"))
	end
end

function WinGoldenTurntableLayout:updateView()
	self.params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL)
	if self.params then
		--print("---self.params---",Lib.v2s(self.params))
		local cfg = LimitedTimeGoldWheelConfig:getCfgByActivityId(self.params.id)
		if not cfg or not cfg[1] then
			return
		end
		self.cfg = cfg[1]
		self.pond = LimitedTimeGoldWheelAwardsConfig:getCfgByPondId(self.cfg.pondId)
		--print("----pond----",Lib.v2s(self.cfg),Lib.v2s(self.pond))
		self:updatePurchaseInfo()
		for i, v in pairs(self.pond or {}) do
			local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId],  self.cfg.radius)
            local node = self.ratioItem[v.sortId]
            node:setXPosition({ 0, itemPos.x })
            node:setYPosition({ 0, itemPos.y })
			local item = self.awards[v.giftContent[1]] or {}
			item.tag = v.tag
            node:updateInfo(item)
		end
		self.imgWheelFace:setProperty("Rotate", 0)
	end
end

function WinGoldenTurntableLayout:showHighlight(callBack)
	if self.highlightTimer then
		self.highlightTimer()
		self.highlightTimer = nil
		self.imgHighlight:setVisible(false)
	end
	local count = 10
	self.imgHighlight:setVisible(true)
	self.highlightTimer = Me:timer(1, function()
		count = count - 1
		local surplus = count % 2
		self.imgHighlight:setVisible(surplus == 0)
		if count < 1 then
			if callBack then
				callBack()
			end
		end
		if count <= 0 then
			self.highlightTimer()
			self.highlightTimer = nil
		end
		return count > 0
	end)
end

local function directionalConditionJudgment(direction, obey, defy)
	local needAlter = false
	if direction > 0 then
		needAlter = obey
	else
		needAlter = defy
	end
	return needAlter
end

function WinGoldenTurntableLayout:startWheel(addition)
	local target = addition and addition.item and addition.item.sortId
	if not target or not rotationAngle[target] then
		Me.inPlayLimitedTimeGoldWheel = false
		return
	end
	if self.wheelTimer then
		self.wheelTimer()
		self.wheelTimer = nil
	end
	local aSpeed = self.cfg and self.cfg.aSpeed or 1
	local direction = aSpeed / math.abs(aSpeed)
	local carSpeed = 0
	local maxSpeed = self.cfg and self.cfg.maxSpeed or 30
	local minSpeed = self.cfg and self.cfg.minSpeed or 10
	local timeInOneLap = math.abs(math.floor(360 / maxSpeed))
	local highSpeedRotateCount = timeInOneLap * (self.cfg and self.cfg.highSpeedWhirl or 5)
	local curAngle, slowDownAngle
	local startSlowDown = false
	local condition = false
	self.imgHighlight:setVisible(false)
	self.wheelTimer = Me:timer(1, function()
		if highSpeedRotateCount > 0 then
			if directionalConditionJudgment(direction, carSpeed < maxSpeed, carSpeed > maxSpeed) then
				carSpeed = carSpeed + aSpeed
			else
				carSpeed = maxSpeed
				highSpeedRotateCount = highSpeedRotateCount - 1
			end
		else
			if directionalConditionJudgment(direction, carSpeed > minSpeed, carSpeed < minSpeed) then
				carSpeed = carSpeed - aSpeed
			else
				if not startSlowDown then
					carSpeed = minSpeed
				else
					if directionalConditionJudgment(direction, carSpeed <= 0, carSpeed >= 0) then
						carSpeed = direction
					end
				end
			end
		end
		--print("----carSpeed----",carSpeed)
		self.curRotateAngle = self.curRotateAngle + carSpeed
		if highSpeedRotateCount <= 0 then
			local num = math.floor(self.curRotateAngle / 360)
			if not curAngle then
				local rotationA = direction > 0 and rotationAngle[target] or 360 - rotationAngle[target]
				curAngle = rotationA * direction + ((num + 1 * direction) * 360)
			end
			--print('------',curAngle,curRotateAngle)
			if not slowDownAngle then
				local dis = (minSpeed*minSpeed / 2) * direction
				slowDownAngle = curAngle - dis
			end
			if aSpeed > 0 then
				condition = curAngle < self.curRotateAngle
				startSlowDown = slowDownAngle < self.curRotateAngle
			else
				condition = curAngle > self.curRotateAngle
				startSlowDown = slowDownAngle > self.curRotateAngle
			end
			--print("----startSlowDown---",curAngle, slowDownAngle, self.curRotateAngle ,startSlowDown)
			if condition then
				for _, v in pairs(self.pond or {}) do
					local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId], self.cfg.radius, self.curRotateAngle)
                    local node = self.ratioItem[v.sortId]
                    node:setXPosition({ 0, itemPos.x })
                    node:setYPosition({ 0, itemPos.y })
				end
				self.imgWheelFace:setProperty("Rotate", self.curRotateAngle)
				self:showHighlight(function()
					--- 主动刷新货币
					if self._coinNode then
						self._coinNode:updateGoldCoin()
					end
                    Me:showAwardPopup(addition)

					self.addition = nil
					Me.inPlayLimitedTimeGoldWheel = false
				end)
				--self.curRotateAngle = rotationAngle[target]
				self.wheelTimer()
				self.wheelTimer = nil
				return false
			elseif startSlowDown then
				carSpeed = carSpeed - direction
			end
		end
		for i, v in pairs(self.pond or {}) do
			local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId],  self.cfg.radius, self.curRotateAngle)
            local node = self.ratioItem[i]
            node:setXPosition({ 0, itemPos.x })
            node:setYPosition({ 0, itemPos.y })
		end
		self.imgWheelFace:setProperty("Rotate", self.curRotateAngle)
		return true
	end)
end

---@private
function WinGoldenTurntableLayout:onDestroy()

end

---@private
function WinGoldenTurntableLayout:onClose()
    self.params = nil
	self.cfg = nil
	self.pond = nil
	self.isOpen = false
	if self.wheelTimer then
		self.wheelTimer()
		self.wheelTimer = nil
		if self.addition then
			Me:showAwardPopup(self.addition)
			self.addition = nil
		end
		Me.inPlayLimitedTimeGoldWheel = false
	end
	if self.highlightTimer then
		self.highlightTimer()
		self.highlightTimer = nil
		self.imgHighlight:setVisible(false)
		if self.addition then
			Me:showAwardPopup(self.addition)
			self.addition = nil
		end
		Me.inPlayLimitedTimeGoldWheel = false
	end
	if self.discountsTimer then
		self.discountsTimer()
		self.discountsTimer = nil
	end
end

WinGoldenTurntableLayout:init()
