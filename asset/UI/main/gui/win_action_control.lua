---@class WinActionControlLayout : CEGUILayout
local WinActionControlLayout = M

local worldCfg = World.cfg
local guiMgr = L("guiMgr", GUIManager:Instance())
local root = guiMgr:getRootWindow()
local windowWidth = root:getPixelSize().width
local windowHeight = root:getPixelSize().height
local Logic = L("Logic", {})

local BM = Blockman.instance
local dragAreaStartPoint = {100, -70}

local dragControlConfig = worldCfg.dragControlConfig or {}
local dragPointImageConfig = dragControlConfig.dragPointImageConfig or
        {
            prx = "main_ui/control_",
            asset = "main_ui",
            group = "_imagesets_"
        }

------------------------------------------------------------- Logic
function Logic.setImage(self, property, image, resourceGroup) -- image 的参数参考注释的 test code
    if property == "Image" then
        self:setImage(image.name, resourceGroup)
    elseif property == "NormalImage" then
        self:setNormalImage(image.name, resourceGroup)
    elseif property == "PushedImage" then
        self:setPushedImage(image.name, resourceGroup)
    end
end

---@private
function WinActionControlLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinActionControlLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siDragControl = self.DragControl
    ---@type CEGUIStaticImage
    self.siDragControlDragControlBg = self.DragControl.DragControlBg
    ---@type CEGUIStaticImage
    self.siDragControlDragControlBgPointNode = self.DragControl.DragControlBg.PointNode
    ---@type CEGUIStaticImage
    self.siDragControlDragControlBgDragPointCenterPoint = self.DragControl.DragControlBg.DragPointCenterPoint
    ---@type CEGUIDefaultWindow
    self.wDragControlMove = self.DragControlMove
end

---@private
function WinActionControlLayout:initUI()
    self._allEvent = {}

    self.siDragControlDragControlBgPointNode:setVisible(false)
    self.dragPoints = {}
    local size = {13,16,19,21,61}
    for i = 1, 5 do
        local radius = size[i]
        local point = UI:createStaticImage("DragPoint" .. i)
        point:setArea2({0, 0}, {0, 0}, {0, radius}, {0, radius})
        point:setProperty("WindowTouchThroughMode", "MousePassThroughOpen")
        Logic.setImage(point, "Image", {name = dragPointImageConfig.prx..i, asset = dragPointImageConfig.asset}, dragPointImageConfig.group)
        point:setProperty("HorizontalAlignment", "Centre")
        point:setProperty("VerticalAlignment", "Centre")
        point:setClippedByParent(false)
        self.siDragControlDragControlBgPointNode:addChild(point)
        table.insert(self.dragPoints, point)
    end
end

---@private
function WinActionControlLayout:initEvent()
    --点击屏幕滑杆移动位置的UI事件
    self.wDragControlMove.onWindowTouchUp = function(instance, window, x, y)
        self:cleanDragTouch()
    end
    self.wDragControlMove.onWindowTouchDown = function(instance, window, x, y)
        self:onDragTouchDown(window, x, y)
        --滑杆移动到点击位置
        self.siDragControlDragControlBg:setArea2(self.bgAreaX, self.bgAreaY, {1, 0}, {1, 0})
        self.siDragControlDragControlBg:setImage("asset/imageset/main:img_0_leftrocker_bottom_on")
    end
    self.wDragControlMove.onWindowTouchMove = function(instance, window, x, y)
        self:onDragTouchMove(window, x, y)
    end

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function()
        self:cleanDragTouch()
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_PLAYER_DEAD, function()
        self:cleanDragTouch()
    end)
end

function WinActionControlLayout:cleanDragTouch()
    self:onDragTouchUp()
    --滑杆复位
    self.siDragControlDragControlBg:setArea2({0, dragAreaStartPoint[1]}, {0, dragAreaStartPoint[2]}, {1, 0}, {1, 0})
    self.siDragControlDragControlBg:setImage("asset/imageset/main:img_0_leftrocker_bottom_normal")
end

function WinActionControlLayout:onDragTouchUp()
    self.inSide = false
    Blockman.instance.gameSettings.poleForward = 0
    Blockman.instance.gameSettings.poleStrafe = 0
    self.siDragControlDragControlBgPointNode:setVisible(false)
    self.siDragControlDragControlBgDragPointCenterPoint:setVisible(true)
end

function WinActionControlLayout:getUIPixelSize(window)
    if not window then
        return {width = windowWidth, height = windowHeight}
    end

    local width = window:getWidth()
    local height = window:getHeight()

    if width[1] ~= 0 or height[1] ~= 0 then
        local parentSize = self:getUIPixelSize(window:getParent())
        local w = parentSize.width * width[1] + width[2]
        local h = parentSize.height * height[1] + height[2]
        return {width = w, height = h}
    else
        return {width = width[2], height = height[2]}
    end
end

function WinActionControlLayout:onDragTouchDown(window, x, y)
    self.inSide = true

    self.dragOriginX = x --screenToWindowX(points:getWindow(), x)
    self.dragOriginY = y --screenToWindowY(points:getWindow(), y)
    self.dragScreenX = x
    self.dragScreenY = y

    for _, point in ipairs(self.dragPoints) do
        point:setXPosition({0, 0})
        point:setYPosition({0, 0})
    end
    self.siDragControlDragControlBgPointNode:setVisible(true)
    local size = self:getUIPixelSize(self.siDragControlDragControlBg)
    self.bgAreaX = {0, x - (size.width * 0.5)}
    self.bgAreaY = {0, y - windowHeight + (size.height * 0.5)}
    self.siDragControlDragControlBgDragPointCenterPoint:setVisible(false)
end

function WinActionControlLayout:onDragTouchMove(window, x, y)
    if not self.inSide then
        return
    end

    local offX = x - self.dragScreenX
    local offY = y - self.dragScreenY
    local disSqr = offX * offX + offY * offY
    disSqr = disSqr ~= 0 and math.sqrt(disSqr) or 1
    local poleForward = -offY / disSqr
    local poleStrafe = -offX / disSqr

    local count = #self.dragPoints
    for i = 1, count do
        local point = self.dragPoints[i]
        local posX = offX / (count - 1) * (i - 1)
        local posY = offY / (count - 1) * (i - 1)
        point:setXPosition({0, posX})
        point:setYPosition({0, posY})
    end

    if not self:canControlPlayer() then
        Blockman.instance.gameSettings.poleForward = 0
        Blockman.instance.gameSettings.poleStrafe = 0
        return
    end
    if not Me:checkPlayerCanMove() then
        Blockman.instance.gameSettings.poleForward = 0
        Blockman.instance.gameSettings.poleStrafe = 0
        return
    end
    if not Me:getCtrlLimitByFlyState() then
        Blockman.instance.gameSettings.poleForward = poleForward
        Blockman.instance.gameSettings.poleStrafe = poleStrafe
    end
end

function WinActionControlLayout:canControlPlayer()
    return Me:checkCanControlPlayer()
end

function WinActionControlLayout:handleStandingTurnAround(window, x, y)
    if not self.inSide then
        return
    end
    local offX = x - self.dragScreenX
    local offY = y - self.dragScreenY
    local disSqr = offX * offX + offY * offY
    disSqr = disSqr ~= 0 and math.sqrt(disSqr) or 1
    local poleForward = offY / disSqr
    local yaw=math.deg(math.asin(poleForward))
    if offX<0 then
       yaw=180-yaw
    end
    yaw=yaw+90-Blockman.instance:viewerRenderYaw()
    Me:setBodyYaw(yaw)
    Me:setRotationYaw(yaw)
    --print("********************** handleStandingTurnAround",math.floor(offX),math.floor(offY),yaw,Blockman.instance:viewerRenderYaw())

    local count = #self.dragPoints
    for i = 1, count do
        local point = self.dragPoints[i]
        local posX = offX / (count - 1) * (i - 1)
        local posY = offY / (count - 1) * (i - 1)
        point:setXPosition({0, posX})
        point:setYPosition({0, posY})
    end
    self.siDragControlDragControlBgDragPointCenterPoint:setXPosition({0, offX})
    self.siDragControlDragControlBgDragPointCenterPoint:setYPosition({0, offY})
end

---@private
function WinActionControlLayout:onOpen()

end

---@private
function WinActionControlLayout:onDestroy()

end

---@private
function WinActionControlLayout:onClose()
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent = {}
    end
end

WinActionControlLayout:init()
