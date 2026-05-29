--- widget_stamina_panel.lua
--- 体力槽


---@class WidgetStaminaPanel : CEGUILayout
local WidgetStaminaPanel = M

---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
local desktop = GUISystem.instance:GetRootWindow()
---@type Blockman
local BM = Blockman.instance
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")

---@private
function WidgetStaminaPanel:init()
    self:initData()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetStaminaPanel:initData()

end

---@private
function WidgetStaminaPanel:initUI()

end

---@private
function WidgetStaminaPanel:initEvent()
    
end

function WidgetStaminaPanel:initData()
    self.events = {}
    self.timer = nil
    self.maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP) or 100
    self.curMp = self.maxMp
    self.passTime = 0
    self.isShow = true
end

---@private
function WidgetStaminaPanel:onOpen()
    self:initData()
    self:subscribeEvents()
    self:startTimer()
    self:updateStamina()
end

--- 刷新进度条
function WidgetStaminaPanel:updateStamina()
    local progress = math.clamp(self.curMp / self.maxMp, 0, 1)
    self.Front:setProperty("FillArea", tostring(progress))
end

--- 刷新位置
function WidgetStaminaPanel:updatePosition()
    local pos = Me:getRenderPosition() + Lib.posAroundYaw(Lib.v3(-0.7, 1.2, 0), BM:getViewerYaw())
    local result = BM:getScreenPos(pos)
    local x = math.floor(result.x * desktop:GetPixelSize().x)
    local y = math.floor(result.y * desktop:GetPixelSize().y)
    self:setXPosition({0, x})
    self:setYPosition({0, y})
end

function WidgetStaminaPanel:onTick(deltaTime)
    if self.curMp >= self.maxMp then
        self.passTime = self.passTime + deltaTime
    end
    if self.passTime >= 1 then
        self.passTime = 0
        self:setStaminaVisible(false)
        self:stopTimer()
    end
end

function WidgetStaminaPanel:setStaminaVisible(visible)
    if self.isShow == visible then
        return
    end
    self.isShow = visible
    self:setVisible(visible)
end

function WidgetStaminaPanel:subscribeEvents()
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_CURRENT_MP, function(value)
        if value == self.curMp then
            return
        end
        self.curMp = value
        self:updateStamina()

        self.passTime = 0
        self:setStaminaVisible(true)

        --- 判断
        if self.curMp >= self.maxMp then
            self:startTimer()
        end
    end)
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA, function()
        local maxMp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_MP)
        if maxMp == self.maxMp then
            return
        end
        self.maxMp = maxMp
        self:updateStamina()
    end)
    
end

function WidgetStaminaPanel:unsubscribeEvents()
    if self.events then
        for _, func in pairs(self.events) do
            func()
        end
        self.events = nil
    end
end

function WidgetStaminaPanel:startTimer()
    if self.timer then
        return
    end
    self.timer = LuaTimer:scheduleTicker(function()
        self:onTick(0.05)
    end, 1)
end

function WidgetStaminaPanel:stopTimer()
    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
end

---@private
function WidgetStaminaPanel:onClose()
    self:unsubscribeEvents()
    self:stopTimer()
end

---@private
function WidgetStaminaPanel:onDestroy()
    self:unsubscribeEvents()
    self:stopTimer()
end

WidgetStaminaPanel:init()
