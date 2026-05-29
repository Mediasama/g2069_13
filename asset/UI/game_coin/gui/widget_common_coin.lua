---@class WidgetCommonCoinWidget : CEGUILayout
local WidgetCommonCoinWidget = M

---@type WalletSystem
local WalletSystem = T(Lib, "WalletSystem")

local mn = math.pow(10, 6)
--- 浮点数精度既定常数
local e = 1e-9

local formatCoin = function(num)
	local text = nil
	local em = nil
	for i = 1, 1000, 1 do
		if num <= 0 then
			break
		end
		if num >= mn then
			num = math.floor(num / 1000000 + e)
			em = (em or "") .. "M"
		else
			local n = num % 1000
			local str = num == n and tostring(n) or string.format("%03d", tostring(n))
			if text then
				text = str .. "," .. text
			else
				text = str
			end
			num = math.floor((num - n) / 1000 + e)
		end
	end
	if em then
		return (text or tostring(num)) .. em
	end
	return text or tostring(num)
end

---@private
function WidgetCommonCoinWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetCommonCoinWidget:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wCube = self.Cube
	---@type CEGUIStaticImage
	self.siCubeCoinBg = self.Cube.CoinBg
	---@type CEGUIStaticImage
	self.siCubeCoinIcon = self.Cube.CoinIcon
	---@type CEGUIStaticText
	self.stCubeCoinNum = self.Cube.CoinNum
	---@type CEGUIButton
	self.btnCubeAddButton = self.Cube.AddButton
	---@type CEGUIDefaultWindow
	self.wGoldCoin = self.GoldCoin
	---@type CEGUIStaticImage
	self.siGoldCoinCoinBg = self.GoldCoin.CoinBg
	---@type CEGUIStaticImage
	self.siGoldCoinCoinIcon = self.GoldCoin.CoinIcon
	---@type CEGUIStaticText
	self.stGoldCoinCoinNum = self.GoldCoin.CoinNum
	---@type CEGUIButton
	self.btnGoldCoinAddButton = self.GoldCoin.AddButton
    ---@type CEGUIButton
	self.btnShopButton = self.ShopButton
end

---@private
function WidgetCommonCoinWidget:initUI()

end

---@private
function WidgetCommonCoinWidget:initEvent()
    self.btnCubeAddButton.onMouseClick = function()
        if self.hideCube then
            return
        end
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        Interface.onRecharge(1)
	end
	self.btnGoldCoinAddButton.onMouseClick = function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
        UI:openWindow("UI/game_business/gui/win_game_shop", nil, nil, {
            shopTab = Define.SHOP_TAB.RESOURCES
        })
	end
    self.btnShopButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		UI:openWindow("UI/game_business/gui/win_game_shop")
	end
end

---@private
function WidgetCommonCoinWidget:onOpen(args)
    self:initData(args)
    self:coinShowHandle()
    self:updateCube()
    self:updateGoldCoin()
    self:subscribeEvents()
end

function WidgetCommonCoinWidget:initData(args)
    self.hideCube = args and args.hideCube or false
    self.notAutoRefreshGold = args and args.notAutoRefreshGold or false
end

function WidgetCommonCoinWidget:coinShowHandle()
    if self.hideCube then
        local posX = self.wCube:getXPosition()[2]
        self.wCube:setVisible(false)
        self.wGoldCoin:setXPosition({ 0, posX })
    end
end

--- 刷新金魔方
function WidgetCommonCoinWidget:updateCube()
    if not self.hideCube then
        local cube = WalletSystem:getCube(Me)
        self.stCubeCoinNum:setText(formatCoin(cube))
    end
end

--- 刷新绿宝石
function WidgetCommonCoinWidget:updateGoldCoin()
    local gold = WalletSystem:getCoin(Me, Define.ITEM_ALIAS.GOLD_COIN)
    self.stGoldCoinCoinNum:setText(formatCoin(gold))
end

function WidgetCommonCoinWidget:subscribeEvents()
    self.events = {}
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_RECHARGE_GOLD_COIN, function()
        self:updateCube()
    end)
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
        self:updateCube()
        if not self.notAutoRefreshGold then
            self:updateGoldCoin()
        end
    end)
end

function WidgetCommonCoinWidget:unsubscribeEvents()
    if self.events then
        for _, func in pairs(self.events) do
            func()
        end
        self.events = nil
    end
end

---@private
function WidgetCommonCoinWidget:onDestroy()
    self:unsubscribeEvents()
end

WidgetCommonCoinWidget:init()
