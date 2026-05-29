---@class WinGameShopLayout : CEGUILayout
local WinGameShopLayout = M

---@type ShopConfig
local ShopConfig = T(Config, "ShopConfig")
---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type BusinessSystem
local BusinessSystem = T(Lib, "BusinessSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")

--- 定义事件
local CALL_EVENT = {
    CLOSE_WIN = "close",
    BUY_ITEM = "buy",
    SELECT_TAB = "select_tab",
    SELECT_ITEM = "select_item",
    IS_SELECTED_TAB = "selected_tab",
    IS_SELECTED_ITEM = "selected_item",
}

---@private
function WinGameShopLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
    self.mainAniWnd = self.wWindowShop
end

---@private
function WinGameShopLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wWindowShop = self.WindowShop
	---@type CEGUIStaticImage
	self.siWindowShopBg = self.WindowShop.Bg
	---@type CEGUIStaticText
	self.stWindowShopTitle = self.WindowShop.Title
	---@type CEGUIScrollableView
	self.wWindowShopSvItem = self.WindowShop.SvItem
	---@type CEGUIGridView
	self.gvWindowShopSvItemGvItem = self.WindowShop.SvItem.GvItem
	---@type CEGUIScrollableView
	self.wWindowShopSvTab = self.WindowShop.SvTab
	---@type CEGUIVerticalLayoutContainer
	self.wWindowShopSvTabLvTab = self.WindowShop.SvTab.LvTab
	---@type CEGUIButton
	self.btnWindowShopCloseButton = self.WindowShop.CloseButton
	---@type CEGUIDefaultWindow
	self.wWindowShopItemInfo = self.WindowShop.ItemInfo
	---@type CEGUIStaticImage
	self.siWindowShopItemInfoBg = self.WindowShop.ItemInfo.Bg
	---@type CEGUIStaticImage
	self.siWindowShopItemInfoBg2 = self.WindowShop.ItemInfo.Bg2
	---@type CEGUIStaticImage
	self.siWindowShopItemInfoItemQuality = self.WindowShop.ItemInfo.ItemQuality
	---@type CEGUIStaticImage
	self.siWindowShopItemInfoItemQualityItemIcon = self.WindowShop.ItemInfo.ItemQuality.ItemIcon
	---@type CEGUIStaticText
	self.stWindowShopItemInfoItemName = self.WindowShop.ItemInfo.ItemName
	---@type CEGUIStaticText
	self.stWindowShopItemInfoItemQualityName = self.WindowShop.ItemInfo.ItemQualityName
	---@type CEGUIStaticText
	self.stWindowShopItemInfoDamageName = self.WindowShop.ItemInfo.DamageName
	---@type CEGUIStaticImage
	self.siWindowShopItemInfoDamageNameDamageIcon = self.WindowShop.ItemInfo.DamageName.DamageIcon
	---@type CEGUIScrollableView
	self.wWindowShopItemInfoSvDesc = self.WindowShop.ItemInfo.SvDesc
	---@type CEGUIVerticalLayoutContainer
	self.wWindowShopItemInfoSvDescLvDesc = self.WindowShop.ItemInfo.SvDesc.LvDesc
	---@type CEGUIStaticText
	self.stWindowShopItemInfoSvDescLvDescItemDesc = self.WindowShop.ItemInfo.SvDesc.LvDesc.ItemDesc
	---@type CEGUIScrollableView
	self.wWindowShopItemInfoSvSkill = self.WindowShop.ItemInfo.SvSkill
	---@type CEGUIVerticalLayoutContainer
	self.wWindowShopItemInfoSvSkillLvSkill = self.WindowShop.ItemInfo.SvSkill.LvSkill
	---@type CEGUIStaticText
	self.stWindowShopItemInfoPurchaseNum = self.WindowShop.ItemInfo.PurchaseNum
	---@type CEGUIButton
	self.btnWindowShopItemInfoBuyButton = self.WindowShop.ItemInfo.BuyButton
end

---@private
function WinGameShopLayout:initUI()
	self.stWindowShopTitle:setText(Lang:toText("g2069_shop_title"))
    self.btnWindowShopItemInfoBuyButton:setText(Lang:toText("g2069_shop_tab_buy"))
end

---@private
function WinGameShopLayout:initEvent()
	self.btnWindowShopCloseButton.onMouseClick = function()
        self:onCallHandler("close")
	end
	self.btnWindowShopItemInfoBuyButton.onMouseClick = function()
        self:onCallHandler("buy")
	end
end

---@private
function WinGameShopLayout:onOpen(args)
    self:initData(args)
    self:initVirtualUI()
    self:selectTab(self.selectedShopTab, true)
    self:subscribeEvents()
end

--- 初始化
function WinGameShopLayout:initVirtualUI()
    local this = self

    --- 商品列表
    self.gvShopItem = widget_virtual_grid:init(
		self.wWindowShopSvItem, 
		self.gvWindowShopSvItemGvItem,
		function(self, parent)
			-- ---@type WidgetGameShopItemWidget
			local node = UI:openWidget("UI/game_business/gui/widget_game_shop_item")
			parent:addChild(node:getWindow())
			node:registerCallHandler(CALL_EVENT.SELECT_ITEM, this, this.onCallHandler)
			node:registerCallHandler(CALL_EVENT.IS_SELECTED_ITEM, this, this.onCallHandler)
			return node
		end,
		function(self, node, data)
			node:updateInfo(data)
		end,
		4
	)

    --- tab 列表
    self.lvShopTab = widget_virtual_vert_list:init(
        self.wWindowShopSvTab,
        self.wWindowShopSvTabLvTab,
		function(self, parent)
			---@type WidgetGameShopTabWidget
			local node = UI:openWidget("UI/game_business/gui/widget_game_shop_tab")
			parent:addChild(node:getWindow())
            node:registerCallHandler(CALL_EVENT.SELECT_TAB, this, this.onCallHandler)
            node:registerCallHandler(CALL_EVENT.IS_SELECTED_TAB, this, this.onCallHandler)
			return node
		end,
		function(self, node, data)
			local shopTab = data.shop_tab
			node:updateInfo(shopTab)
		end
    )

    ---@type widget_virtual_vert_list
    self.lvSkill = widget_virtual_vert_list:init(
        self.wWindowShopItemInfoSvSkill, 
        self.wWindowShopItemInfoSvSkillLvSkill,
        function(self, parent)
            local node = UI:openWidget("UI/game_business/gui/widget_game_shop_skill")
            parent:addChild(node:getWindow())
            return node
        end,
        function(self, node, data)
            local unlockLevel = data.unlock_level
            local skillId = data.skill_id
            local index = data.index
            node:updateInfo(unlockLevel, skillId, index)
        end
    )


    for _, tab in pairs(self.tabs) do
        self.lvShopTab:addVirtualChild(tab)
    end
end

function WinGameShopLayout:initData(args)
    self.tabs = {}
    self.selectedShopTab = args and args.shopTab or Define.SHOP_TAB.PROPS

    local tabs = {
        Define.SHOP_TAB.PROPS,
        Define.SHOP_TAB.PRIVILEGE,
        Define.SHOP_TAB.RESOURCES
    }

    for k, v in pairs(tabs) do
        local items = ShopConfig:getShopItemsByShopTab(v, true)
        if items and #items > 0 then
            self.tabs[#self.tabs + 1] = { shop_tab = v, items = items }
        elseif self.selectedShopTab == v then
            self.selectedShopTab = nil
        end
    end

    if not self.selectedShopTab then
        self.selectedShopTab = self.tabs[1].shop_tab
    end

    -- self.tabs[#self.tabs + 1] = { shop_tab = Define.SHOP_TAB.PROPS, items = nil }
    -- self.tabs[#self.tabs + 1] = { shop_tab = Define.SHOP_TAB.PRIVILEGE, items = nil }
    -- self.tabs[#self.tabs + 1] = { shop_tab = Define.SHOP_TAB.RESOURCES, items = nil }
    --- 选中

    self.selectedShopId = nil

    self.skills = {}

    self.onBuy = false

    ---@type widget_virtual_grid
    self.gvShopItem = nil
    ---@type widget_virtual_vert_list
    self.lvShopTab = nil
end

function WinGameShopLayout:checkInterupt(event)
    if event == CALL_EVENT.SELECT_TAB then
    elseif event == CALL_EVENT.SELECT_ITEM then
    elseif event == CALL_EVENT.BUY_ITEM then
        return self.onBuy
    elseif event == CALL_EVENT.IS_SELECTED_TAB then
    elseif event == CALL_EVENT.IS_SELECTED_ITEM then
    elseif event == CALL_EVENT.CLOSE_WIN then
        return self.onBuy
    end
    return false
end

--- 音效
---@param event any
function WinGameShopLayout:checkSound(event)
    if event == CALL_EVENT.CLOSE_WIN then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    elseif event == CALL_EVENT.BUY_ITEM 
        or event == CALL_EVENT.SELECT_TAB
        or event == CALL_EVENT.SELECT_ITEM
    then
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    end
end

--- 回调
---@param event any
function WinGameShopLayout:onCallHandler(event, ...)
    self:checkSound(event)
    
    if self:checkInterupt(event) then
        return
    end
    if event == CALL_EVENT.SELECT_TAB then
        local shopTab = table.unpack({...})
        self:selectTab(shopTab)
    elseif event == CALL_EVENT.SELECT_ITEM then
        local shopId = table.unpack({...})
        self:updateItemInfo(shopId)
    elseif event == CALL_EVENT.BUY_ITEM then
        self:buyItem(self.selectedShopId)
    elseif event == CALL_EVENT.IS_SELECTED_TAB then
        local shopTab = table.unpack({...})
        return shopTab == self.selectedShopTab
    elseif event == CALL_EVENT.IS_SELECTED_ITEM then
        local shopId = table.unpack({...})
        return self.selectedShopId == shopId
    elseif event == CALL_EVENT.CLOSE_WIN then
        UI:closeWindow(self)
    end
end

--- 选中tab
---@param shopTab any
---@param force any
function WinGameShopLayout:selectTab(shopTab, force)
    if not force and self.selectedShopTab == shopTab then
        return
    end
    self.selectedShopTab = shopTab
    Lib.emitEvent(Event.EVENT_GAME_BUSINESS_UI_SELECT_SHOP_TAB, shopTab)
    local tab = self:getTab(shopTab)
    local items = tab.items
    if not items then
        items = ShopConfig:getShopItemsByShopTab(tab.shop_tab, true)
        tab.items = items
    end
    --- 刷新数据
    self.gvShopItem:setVirtualVertBarPosition(0)
    self.gvShopItem:clearVirtualChild()
    --- 添加数据
    if #items > 0 then
        self.selectedShopId = items[1].shop_id
        self.gvShopItem:addVirtualChildList(items)
    else
        self.selectedShopId = nil
    end
    --- 刷新物品信息
    self:updateItemInfo(self.selectedShopId, true)
end

function WinGameShopLayout:getTab(shopTab)
    for _, tab in pairs(self.tabs) do
        if tab.shop_tab == shopTab then
            return tab
        end
    end
    return nil
end

--- 刷新信息
---@param shopId any
---@param force boolean
function WinGameShopLayout:updateItemInfo(shopId, force)
    if not force and shopId and self.selectedShopId == shopId then
        return
    end
    self.selectedShopId = shopId
    if not shopId or shopId == "" then
        self.wWindowShopItemInfo:setVisible(false)
        return
    end
    self.wWindowShopItemInfo:setVisible(true)

    local config = ShopConfig:getCfgByShopId(shopId)
    self.stWindowShopItemInfoItemName:setText(Lang:toText(config.shop_name))

    local text = Lang:toText(config.shop_desc)
    self.stWindowShopItemInfoSvDescLvDescItemDesc:setText(text)
    --- 品质
    local item = config.item
    local itemAlias = item.item_alias
    
    local itemConfig = ItemConfig:getCfgByItemAlias(itemAlias)
    local itemId = itemConfig.item_id
    local itemType = itemConfig.type_alias
    local quality = itemConfig.quality_alias
    local purchaseLimit = config.purchase_limit
    local qualityBg = Define.ITEM_QUALITY_BG[quality]
    local qualityName = Define.ITEM_QUALITY_LANG[quality]
    local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality]
    self.siWindowShopItemInfoItemQuality:setImage(qualityBg)
    self.stWindowShopItemInfoItemQualityName:setText(Lang:toText(qualityName))
    if qualityColor then
		self.stWindowShopItemInfoItemQualityName:setProperty("TextColours", qualityColor)
	end

    if itemType == Define.ITEM_TYPE.ABILITY or itemType == Define.ITEM_TYPE.ABILITY_BOOK then
        self.stWindowShopItemInfoDamageName:setVisible(true)
        local abilityId
        if itemType == Define.ITEM_TYPE.ABILITY then
            abilityId = itemConfig.item_id
        else
            abilityId = itemConfig.params["ability_id"]
        end
            
        local abilityConfig = AbilityConfig:getCfgByAbilityId(abilityId)
        local damageType = abilityConfig.damageType
        local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
        local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
	    local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]
        self.siWindowShopItemInfoDamageNameDamageIcon:setImage(dmgBg)
        self.stWindowShopItemInfoDamageName:setText(Lang:toText(dmgName))
        if dmgColor then
            self.stWindowShopItemInfoDamageName:setProperty("TextColours", dmgColor)
        end

        --- 获取技能数据
        local askills = self.skills[abilityId]
        if not askills then
			askills = AbilityConfig:getActiveSkillList(abilityId)
			for index, data in pairs(askills) do
				data.index = index
			end
			self.skills[abilityId] = askills
		end

        self.wWindowShopItemInfoSvSkill:setVisible(true)

        self.lvSkill:setVirtualBarPosition(0)
		self.lvSkill:clearVirtualChild()
		if #askills > 0 then
			self.lvSkill:addVirtualChildList(askills)
		end

        self.wWindowShopItemInfoSvDescLvDesc:setHeight({ 0, 96 })
        self.siWindowShopItemInfoBg2:setHeight({ 0, 125 })
    else
        self.wWindowShopItemInfoSvSkill:setVisible(false)
        self.wWindowShopItemInfoSvDescLvDesc:setHeight({ 0, 235 })
        self.siWindowShopItemInfoBg2:setHeight({ 0, 262 })

        self.stWindowShopItemInfoDamageName:setVisible(false)
    end

    --- 图标
    self.siWindowShopItemInfoItemQualityItemIcon:setImage(itemConfig.icon)

    if purchaseLimit > 0 then
        self.stWindowShopItemInfoPurchaseNum:setVisible(true)
        local purchaseNum = BusinessSystem:getPurchaseData(Me, shopId)
        self.btnWindowShopItemInfoBuyButton:setVisible(purchaseNum < purchaseLimit)
        self.stWindowShopItemInfoPurchaseNum:setText(Lang:toText({ "g2069_remain_purchase_num", tostring(purchaseLimit - purchaseNum) .. "/" .. tostring(purchaseLimit) }))
    else
        self.stWindowShopItemInfoPurchaseNum:setVisible(false)
        self.btnWindowShopItemInfoBuyButton:setVisible(true)
    end

    Lib.emitEvent(Event.EVENT_GAME_BUSINESS_UI_SELECT_SHOP_ITEM, shopId)
end

--- 购买商品
---@param shopId any
function WinGameShopLayout:buyItem(shopId)
    if not BusinessSystem:checkCanPurchase(Me, shopId) then
        --- 购买次数达到上限
        return
    end

    if Me:clientBuyShopByShopId(shopId) then
        self.onBuy = true
    end
end

function WinGameShopLayout:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GAME_BUSINESS_SHOP_BUY, function(player, shopId, success)
        if success and self.selectedShopId == shopId then
            local config = ShopConfig:getCfgByShopId(shopId)
            local purchaseLimit = config.purchase_limit
            if purchaseLimit > 0 then
                self.stWindowShopItemInfoPurchaseNum:setVisible(true)
                local purchaseNum = BusinessSystem:getPurchaseData(Me, shopId)
                self.btnWindowShopItemInfoBuyButton:setVisible(purchaseNum < purchaseLimit)
                self.stWindowShopItemInfoPurchaseNum:setText(Lang:toText({ "g2069_remain_purchase_num", tostring(purchaseLimit - purchaseNum) .. "/" .. tostring(purchaseLimit) }))
            else
                self.stWindowShopItemInfoPurchaseNum:setVisible(false)
                self.btnWindowShopItemInfoBuyButton:setVisible(true)
            end
        end
        self.onBuy = false
    end)
end

---@private
function WinGameShopLayout:onDestroy()

end

---@private
function WinGameShopLayout:onClose()

end

WinGameShopLayout:init()
