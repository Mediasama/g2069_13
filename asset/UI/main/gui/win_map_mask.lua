---@class WinMapMaskLayout : CEGUILayout
local WinMapMaskLayout = M

---@private
function WinMapMaskLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()

    self:setLevel(2)
end

---@private
function WinMapMaskLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siMaskIcon = self.MaskIcon
end

---@private
function WinMapMaskLayout:initUI()
end

---@private
function WinMapMaskLayout:initEvent()
    self.siMaskIcon.onMouseButtonDown = function()
        --Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "map_loading")
    end
end

---@private
function WinMapMaskLayout:onOpen()
    Me:setEntityProp("gravity", 0)
end

---@private
function WinMapMaskLayout:onDestroy()

end

---@private
function WinMapMaskLayout:onClose()
    Me:resetEntityProp("gravity")
end

WinMapMaskLayout:init()
