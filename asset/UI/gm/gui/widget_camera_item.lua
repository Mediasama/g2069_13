---@class WidgetCameraItemWidget : CEGUILayout
local WidgetCameraItemWidget = M

---@private
function WidgetCameraItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetCameraItemWidget:findAllWindow()
    ---@type CEGUIButton
    self.btnNode = self.node
end

---@private
function WidgetCameraItemWidget:initUI()
end

---@private
function WidgetCameraItemWidget:initEvent()
    self.btnNode.onMouseClick = function()
        if not self.aid then
            return
        end
        print("WidgetCameraItemWidget select",self.aid)
        self:callHandler("select", self.aid)
    end
end

---@private
function WidgetCameraItemWidget:onOpen()
    self:initData()
    self:subscribeEvents()
end
function WidgetCameraItemWidget:initData()
    self.aid = nil
    self.regFuncs = {}
    self.events = {}
end
function WidgetCameraItemWidget:subscribeEvents()
    self.events[#self.events + 1] = Lib.subscribeEvent("select_now", function(aid)
        if not self.aid then
            return
        end
        print("WidgetCameraItemWidget:subscribeEvents()",aid,self.aid)
        self.btnNode:setNormalImage(aid == self.aid and "asset/Texture/Gui/button_yellow_hover.png" or "asset/Texture/Gui/button_green_nor.png")
    end)
end
function WidgetCameraItemWidget:unsubscribeEvents()
    if self.events then
        for _, func in pairs(self.events) do
            func()
        end
        self.events = nil
    end
end

---@private
function WidgetCameraItemWidget:onDestroy()
    self:unsubscribeEvents()
    self.regFuncs = nil
end
--- 注册回调
---@param context any
---@param func any
function WidgetCameraItemWidget:registerCallHandler(key, context, func)
    self.regFuncs[key] = { this = context, func = func }
end

--- 回调
function WidgetCameraItemWidget:callHandler(key, ...)
    local data = self.regFuncs[key]
    if data then
        local this = data.this
        local func = data.func
        return func(this, key, ...)
    end
end

function WidgetCameraItemWidget:updateInfo(info)
    self.aid =info.index
    self.btnNode:setText("pos:"..info.x..","..info.y..","..info.z.."\npitch:"..info.pitch.." yaw:"..info.yaw.." smooth:"..info.smooth)
    local selected = self:callHandler("selected", self.aid)
    self.btnNode:setNormalImage(selected and "asset/Texture/Gui/button_yellow_hover.png" or "asset/Texture/Gui/button_green_nor.png")
end

WidgetCameraItemWidget:init()
