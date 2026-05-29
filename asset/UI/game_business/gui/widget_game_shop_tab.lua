---@class WidgetGameShopTabWidget : CEGUILayout
local WidgetGameShopTabWidget = M

---@private
function WidgetGameShopTabWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetGameShopTabWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticText
	self.stTabName = self.TabName
	---@type CEGUIStaticImage
	self.siSelectedBg = self.SelectedBg
	---@type CEGUIStaticText
	self.stSelectedBgTabName = self.SelectedBg.TabName
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
end

---@private
function WidgetGameShopTabWidget:initUI()
	-- self.stTabName:setText(Lang:toText(""))
end

---@private
function WidgetGameShopTabWidget:initEvent()
	self.btnClickButton.onMouseClick = function()
        if not self.shopTab then
            return
        end
        self:callHandler("select_tab", self.shopTab)
	end
end

---@private
function WidgetGameShopTabWidget:onOpen()
    self:initData()
    self:subscribeEvents()
end

function WidgetGameShopTabWidget:initData()
    self.shopTab = nil
    self.callHanders = {}
end

--- 刷新信息
---@param shopTab any
function WidgetGameShopTabWidget:updateInfo(shopTab)
    self.shopTab = shopTab
    local tabName = Define.SHOP_TAB_NAME[shopTab] or "nil"
    self.stTabName:setText(Lang:toText(tabName))
    self.stSelectedBgTabName:setText(Lang:toText(tabName))
    local selected = self:callHandler("selected_tab", shopTab)
    self.siSelectedBg:setVisible(selected or false)
end

--- 注册回调
---@param key any
---@param context any
---@param func any
function WidgetGameShopTabWidget:registerCallHandler(key, context, func)
    self.callHanders[key] = { this = context, func = func }
end

--- 调用回调
---@param key any
function WidgetGameShopTabWidget:callHandler(key, ...)
    local handler = self.callHanders[key]
    if handler then
        local this = handler.this
        local func = handler.func
        return func(this, key, ...)
    end
end

function WidgetGameShopTabWidget:subscribeEvents()
    self:subscribeEvent(Event.EVENT_GAME_BUSINESS_UI_SELECT_SHOP_TAB, function(shopTab)
        if not self.shopTab then
            return
        end
        self.siSelectedBg:setVisible(shopTab == self.shopTab)
    end)
end

---@private
function WidgetGameShopTabWidget:onDestroy()

end

WidgetGameShopTabWidget:init()
