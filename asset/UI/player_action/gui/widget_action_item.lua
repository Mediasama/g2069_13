---@class WidgetActionItemWidget : CEGUILayout
local WidgetActionItemWidget = M

---@private
function WidgetActionItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetActionItemWidget:findAllWindow()
    ---@type CEGUIStaticImage
    self.siImage = self.Image
end

---@private
function WidgetActionItemWidget:initUI()
end

---@param cfg PlayerActionItem
function WidgetActionItemWidget:updateInfo(cfg)
    self.cfg=cfg
    self.siImage:setImage(cfg.icon)
end

---@private
function WidgetActionItemWidget:initEvent()
    self.siImage.onWindowClick=function()
        if self.cfg and self.cfg.anim then
            Me:playPlayerAction(self.cfg.anim)
            UI:closeWindow("UI/player_action/gui/win_player_action")
        end
    end
end

---@private
function WidgetActionItemWidget:onOpen()

end

---@private
function WidgetActionItemWidget:onDestroy()

end

WidgetActionItemWidget:init()
