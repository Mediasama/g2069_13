---@class WidgetBookRoleWidget : CEGUILayout
local WidgetBookRoleWidget = M
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@private
function WidgetBookRoleWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetBookRoleWidget:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wBg = self.Bg
    ---@type CEGUIDefaultWindow
    self.wPanel = self.Bg.Panel
    ---@type CEGUIStaticImage
    self.siPanelTopBg = self.Bg.Panel.TopBg
    ---@type CEGUIStaticImage
    self.siPanelTopBgAbilityIcon = self.Bg.Panel.TopBg.AbilityIcon
    ---@type CEGUIStaticImage
    self.siPanelRoleIcon = self.Bg.Panel.RoleIcon
    ---@type CEGUIButton
    self.btnPanelClickBtn = self.Bg.Panel.ClickBtn
end

---@private
function WidgetBookRoleWidget:initUI()
end

---@private
function WidgetBookRoleWidget:initEvent()
    self.btnPanelClickBtn.onMouseClick = function()
        UI:openWindow("UI/game_book/gui/win_ability_book_wnd", nil, nil, self.data.abilityId)
    end
end

function WidgetBookRoleWidget:initData(data)
    self.data = data

    self.siPanelRoleIcon:setImage(data.abilityRole)
    local abilityCfg = AbilityConfig:getCfgByAbilityId(data.abilityId)
    self.siPanelTopBgAbilityIcon:setImage(abilityCfg.unlimited_icon)
    self.wBg:setYPosition({0, data.showPosY})

    local inventoryType = Define.ITEM_INVENTORY_TYPE[Define.ITEM_TYPE.ABILITY]
    local ability = InventorySystem:getItemByItemId(Me, inventoryType, data.abilityId)
    if ability then
        self.siPanelRoleIcon:setProperty("ImageColours","FFFFFFFF")
        self.siPanelTopBgAbilityIcon:setProperty("ImageColours","FFFFFFFF")
    else
        self.siPanelRoleIcon:setProperty("ImageColours","FF000000")
        self.siPanelTopBgAbilityIcon:setProperty("ImageColours","FF000000")
    end
end

---@private
function WidgetBookRoleWidget:onOpen()

end

---@private
function WidgetBookRoleWidget:onDestroy()

end

WidgetBookRoleWidget:init()
