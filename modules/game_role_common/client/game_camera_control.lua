
---@class GameCameraControl
local GameCameraControl = T(Lib, "GameCameraControl")

---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
local Instance = Blockman.instance

local WINDOW_WIDTH = math.max(
        GUISystem.instance:GetRootWindow():GetPixelSize().x,
        GUISystem.instance:GetRootWindow():GetPixelSize().y
)
Lib.subscribeEvent(Event.EVENT_TOUCH_SCREEN_ZOOM, function(delta)
    if not Me.touchSkillBtn then
        local sensitive = World.cfg.cameraZoomSensitive or (80 / WINDOW_WIDTH)
        Blockman.instance:addCameraDistance(-delta * sensitive)
    end
end)

function GameCameraControl:initCamera()
    local followSpeed=World.cfg.game_role_commonSetting.HorizontalFollowSpeed and World.cfg.game_role_commonSetting.HorizontalFollowSpeed or  0.2
    GlobalProperty.Instance():setFloatProperty("HorizontalFollowSpeed", followSpeed)
end

function GameCameraControl:setRoleYawToTarget(target)
    if not target or not target:isValid() then
        return
    end
    local targetYaw = math.deg(math.atan(target:getPosition().z - Me:getPosition().z, target:getPosition().x - Me:getPosition().x)) - 90
    Me:setProp("calcYawBySpeedDir", 0)
    --Blockman.instance.gameSettings:setLockBodyRotation(true)
    local oldYaw=Me:getBodyYaw()
    local diff=(targetYaw-oldYaw)%360
    if math.abs(diff)>180 then
        diff=diff<0 and (360+diff) or -(360-diff)
    end
    local smoothTime= World.cfg.game_role_commonSetting.setFaceToTargetTime and World.cfg.game_role_commonSetting.setFaceToTargetTime or  0.25
    local smoothCount=smoothTime*20
    local smoothStep=diff/smoothCount
    --print("+++++++++++++++++++++++++ setRoleYawToTarget ",oldYaw,targetYaw,smoothCount,smoothStep)
    if self.setRoleYawToTargetTimer then
        LuaTimer:cancel(self.setRoleYawToTargetTimer)
        self.setRoleYawToTargetTimer=nil
    end
    self.setRoleYawToTargetTimer = LuaTimer:scheduleTickerWithEnd(function()
        if Me:isValid() then
            local curYaw=Me:getBodyYaw()
            local newYaw=curYaw+smoothStep
            Me:setBodyYaw(newYaw)
            Me:setRotationYaw(newYaw)
            --print("---------------------------scheduleTicker ",newYaw)
        end
    end,function()
        if Me:isValid() then
            Me:setProp("calcYawBySpeedDir", 1)
        end
    end, 1,smoothCount)
end

function GameCameraControl:tryShakeCamera(shakeCameraCfg)
    if not shakeCameraCfg or not shakeCameraCfg.delay then
        return
    end
    self:cancelDelayShakeCamera()
    if shakeCameraCfg.delay>0 then
        self.delayShakeCameraTimer=World.Timer(shakeCameraCfg.delay*20,function()
            self:shakeCamera(shakeCameraCfg.duration,shakeCameraCfg.onceDuration,
                    shakeCameraCfg.amplitude,shakeCameraCfg.reduce)
        end)
    else
        self:shakeCamera(shakeCameraCfg.duration,shakeCameraCfg.onceDuration,
                shakeCameraCfg.amplitude,shakeCameraCfg.reduce)
    end
end

function GameCameraControl:shakeCamera(duration,onceDuration,amplitude,reduce)
    if not duration or not onceDuration or not amplitude or not reduce then
        Lib.logError("GameCameraControl:shakeCamera(),param is nil!")
        return
    end
    if duration<=0 or duration<onceDuration or onceDuration<=0 or amplitude<=0 or reduce<0  then
        Lib.logError("GameCameraControl:shakeCamera(),param is wrong!")
        return
    end

    self:cancelShakeCamera()
    local startCounter=0
    local onceNum=math.ceil(onceDuration*20)
    local step=((amplitude/onceDuration)*2)/20
    local shakeNum=math.ceil(duration/onceDuration)
    local shakeCounter=0
    local curStep=step
    local angle=math.random(1,360)
    local revertAngleRange=0
    local revertAngle=0
    local lastAngle=angle
    local function nextShake()
        shakeCounter=shakeCounter+1
        if shakeCounter > shakeNum then
            return true
        end
        if shakeCounter > 1 then
            curStep=curStep*reduce
            angle=(lastAngle+180+math.random(-30,30))%360
            lastAngle=angle
        end
        revertAngleRange=math.random(-45,45)
        revertAngle=(angle+180+revertAngleRange)%360
        startCounter=0
    end
    nextShake()
    self.shakeCameraTimer=World.Timer(1,function ()
        startCounter=startCounter+1
        local curAngle=math.rad( startCounter<=math.ceil(onceNum/2) and angle or revertAngle)
        local curYaw=Instance:viewerRenderYaw()
        local curPitch=Instance:viewerRenderPitch()
        --print(">>>>>>>>>>>>>>>shakeCamera  ",shakeCounter,shakeNum,curStep,startCounter,curAngle)
        Me:changeCameraView(nil, curYaw+math.cos(curAngle)*curStep,curPitch+math.sin(curAngle)*curStep )
        if startCounter>=onceNum then
            --print("-------------------------------------shakeCamera")
            if nextShake() then
                --print("-------------------------------------shakeCamera end")
                return false
            end
        end
        return true
    end)
end

function GameCameraControl:cancelShakeCamera()
    if self.shakeCameraTimer then
        self.shakeCameraTimer()
        self.shakeCameraTimer=nil
    end
end

function GameCameraControl:cancelDelayShakeCamera()
    if self.delayShakeCameraTimer then
        self.delayShakeCameraTimer()
        self.delayShakeCameraTimer=nil
    end
end

