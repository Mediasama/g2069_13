---@class WidgetGameShopItemWidget : CEGUILayout
local WidgetGameShopItemWidget = M

---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

---@class BusinessSystem
local BusinessSystem = T(Lib, "BusinessSystem")

---@private
function WidgetGameShopItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetGameShopItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stItemQualityItemNum = self.ItemQuality.ItemNum
	---@type CEGUIStaticImage
	self.siCoinIcon = self.CoinIcon
	---@type CEGUIStaticText
	self.stCoinNum = self.CoinNum
	---@type CEGUIStaticImage
	self.siSoldOutBg = self.SoldOutBg
	---@type CEGUIStaticText
	self.stSoldOutBgSoldOutText = self.SoldOutBg.SoldOutText
	---@type CEGUIStaticImage
	self.siEquippedBg = self.EquippedBg
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetGameShopItemWidget:initUI()
    self.stSoldOutBgSoldOutText:setText(Lang:toText("g2069_shop_sold_out"))
end

---@private
function WidgetGameShopItemWidget:initEvent()
	self.btnClickButton.onMouseClick = function()
        if not self.shopId then
            return
        end
        self:callHandler("select_item", self.shopId)
	end
end

---@private
function WidgetGameShopItemWidget:onOpen()
    self:initData()
    self:subscribeEvents()
end

function WidgetGameShopItemWidget:initData()
    self.shopId = nil
    self.callHanders = {}
end

--- 更新信息
---@param shopConfig any
function WidgetGameShopItemWidget:updateInfo(shopConfig)
    self.shopId = shopConfig.shop_id
    local cost = shopConfig.cost

    --- 货币消耗
    local coinConfig = ItemConfig:getCfgByItemAlias(cost.item_alias)
    self.siCoinIcon:setImage(coinConfig.small_icon)
    self.stCoinNum:setText(tostring(cost.item_num))

    --- 设置位置相关
    local widthCoin = self.siCoinIcon:getWidth()[2]
    local widthNum = self.stCoinNum:getWidth()[2]

    local startX = -(widthCoin + widthNum) * 0.5
    self.siCoinIcon:setXPosition({ 0, startX + widthCoin * 0.5 })
    self.stCoinNum:setXPosition({ 0, startX + widthCoin + widthNum * 0.5 })

    --- 物品显示
    --- 品质
    local item = shopConfig.item
    local itemConfig = ItemConfig:getCfgByItemAlias(item.item_alias)
    self.stItemQualityItemNum:setText("x" .. tostring(item.item_num))
    local qualityBg = Define.ITEM_QUALITY_BG[itemConfig.quality_alias]
    self.siItemQuality:setImage(qualityBg)
    --- 图标
    self.siItemQualityItemIcon:setImage(itemConfig.icon)

    local selected = self:callHandler("selected_item", self.shopId)
    self.siSelectedBg:setVisible(selected or false)

    local canPurchase = BusinessSystem:checkCanPurchase(Me, self.shopId)
    self.siSoldOutBg:setVisible(not canPurchase)
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetGameShopItemWidget:registerCallHandler(key, context, func)
    self.callHanders[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetGameShopItemWidget:callHandler(key, ...)
    local handler = self.callHanders[key]
    if handler then
        local this = handler.this
        local func = handler.func
        return func(this, key, ...)
    end
end

function WidgetGameShopItemWidget:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GAME_BUSINESS_UI_SELECT_SHOP_ITEM, function(shopId)
        if not self.shopId then
            return
        end
        self.siSelectedBg:setVisible(shopId == self.shopId)
    end)
    self:subscribeEvent(Event.EVENT_GAME_BUSINESS_SHOP_BUY, function(player, shopId, success)
        if not self.shopId then
            return
        end
        if success and self.shopId == shopId then
            local canPurchase = BusinessSystem:checkCanPurchase(Me, shopId)
            self.siSoldOutBg:setVisible(not canPurchase)
        end
    end)
end

---@private
function WidgetGameShopItemWidget:onDestroy()

end

WidgetGameShopItemWidget:init()
