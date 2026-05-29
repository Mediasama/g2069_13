---@class WinPlayerActionLayout : CEGUILayout
local WinPlayerActionLayout = M

---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type PlayerActionConfig
local PlayerActionConfig = T(Config, "PlayerActionConfig")

---@private
function WinPlayerActionLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinPlayerActionLayout:findAllWindow()
    ---@type CEGUIScrollableView
    self.wScrollableView = self.ScrollableView
    ---@type CEGUIGridView
    self.gvScrollableViewGridView = self.ScrollableView.GridView
    ---@type CEGUIButton
    self.btnButtonClose = self.ButtonClose
end

---@private
function WinPlayerActionLayout:initUI()
    self.gvAction = widget_virtual_grid:init(
            self.wScrollableView,
            self.gvScrollableViewGridView,
    ---@type any, CEGUIWindow
            function(self, parent)
                local node = UI:openWidget("UI/player_action/gui/widget_action_item")
                parent:addChild(node:getWindow())
                return node
            end,
    ---@type any, WidgetAbilityItemWidget, table
            function(self, node, data)
                node:updateInfo(data)
            end,
            6
    )
    self.gvAction:addVirtualChildList(PlayerActionConfig:getSortedList())
end

---@private
function WinPlayerActionLayout:initEvent()
    self.btnButtonClose.onMouseClick = function()
        UI:closeWindow(self)
    end
end

---@private
function WinPlayerActionLayout:onOpen()
    UI:closeWindow("UI/game_role_common/gui/win_simple_ability_bag")
end

---@private
function WinPlayerActionLayout:onDestroy()

end

---@private
function WinPlayerActionLayout:onClose()

end

WinPlayerActionLayout:init()
