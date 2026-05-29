---@class WidgetHitdownTipsWidget : CEGUILayout
local WidgetHitdownTipsWidget = M

---@private
function WidgetHitdownTipsWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetHitdownTipsWidget:findAllWindow()
    ---@type CEGUIStaticImage
    self.siRock = self.rock
    ---@type CEGUIStaticImage
    self.siRockStr = self.rock.str
end

---@private
function WidgetHitdownTipsWidget:initUI()
    local lock1 = true
    local lock2 = true

    local offsetX = math.random(1,5)-3
    local offsetY = math.random(1,5)-3
    local downOffset = 300
    local downDurTime = 0.6
    local initPos = self.siRock:getPosition()
    --local initScale = self.siRockStr:getScale()
    initPos[1][2] = initPos[1][2]-offsetX*50
    initPos[2][2] = initPos[2][2]-offsetY*50

    self.siRock:setPosition(UDim2.new(initPos[1][1], initPos[1][2], initPos[2][1], initPos[2][2]))


    self.aniOver = World.LightTimer("aniOver", 21, function()
        self:destroy()
    end)
    --
    --
    --self.siRockStr:setAlpha(0)
    ----self.siRockStr:setVisible(false)
    ----self.siRockStr:setScale(initScale)
    --local downAni = UI.doTrans(self.siRock,{x=initPos[1], y=initPos[2] },downDurTime)
    --downAni:setEase(EaseType.outBack)
    --downAni:onFinish(function(...)
    --    --local alphaAni = UI.doFade(self.siRockStr,1,downDurTime/2)
    --    lock1 = false
    --    if not lock2 then
    --        self:destroy()
    --    end
    --end)
    --
    --local alphaAniAni = UI.doFade(self.siRockStr,1,downDurTime*3/4)
    --alphaAniAni:onFinish(function()
    --    --self.siRockStr:setVisible(true)
    --    local scaleAni = UI.doScale(self.siRockStr,0.5,downDurTime/2)
    --    scaleAni:setEase(EaseType.outBack)
    --    --scaleAni:delay(downDurTime/2)
    --    scaleAni:onFinish(function(...)
    --        self.aniOver = World.LightTimer("aniOver", 5, function()
    --            lock2 = false
    --            if not lock1 then
    --                self:destroy()
    --            end
    --        end)
    --
    --    end)
    --end)
    --




end

---@private
function WidgetHitdownTipsWidget:initEvent()
end

---@private
function WidgetHitdownTipsWidget:onOpen()

end

---@private
function WidgetHitdownTipsWidget:onDestroy()

end

WidgetHitdownTipsWidget:init()
