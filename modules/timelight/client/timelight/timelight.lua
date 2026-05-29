local TimeLight = T(Lib, "TimeLight")
local cjson = require("cjson")
local LuaTimer = T(Lib, "LuaTimer")
local TimeLightConfig = T(Config, "TimeLightConfig")
---@type GameTimes
local GameTimes = T(Lib, "GameTimes")
local engineSceneManager = EngineSceneManager.Instance()
local gameSettings = Blockman.instance.gameSettings

local DAYSECONDS = 24 * 3600

local pointArr = {}
local spotArr = {}

local setting=nil

local function readSetting()
    local path = Root.Instance():getGamePath().."modules/timelight/setting.json"
    local file = assert(io.open(path), "File opening failure: " .. path)
    local content = file:read("*all")
    file:close()
    return assert(cjson.decode(content), "json to table error")
end

function TimeLight:Init()
	print("&&TimeLight:Init&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
	local lua_version = _VERSION:sub(-3)
	local is_luajit = (string.dump(function() end) or ""):sub(1, 3) == "\027LJ"
	print("lua_version:", lua_version)
	print("is_luajit:", is_luajit)
	if is_luajit then
		jit.on()
		jit.flush()
		print("jit.on()")
		print("jit.version:", jit.version)
		print("jit.version_num:", jit.version_num)
		print("jit.os:", jit.os)
		print("jit.arch:", jit.arch)
	end
	print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")


    setting = readSetting()

    --local root = Root.Instance()
    --root:setEnableRealtimeShadowType(0)
    --root:setRealtimeShadowTexSizeLevel(1)
    --root:setRealtimeShadowIntensityLevel(0.9)
    --root:setRealtimeShadowCullFront(true)

    --engineSceneManager:setBakeFilename("g2052MMO_map003_bake.json")
    EngineSceneManager.Instance():setLowQualityHdr(false)
    EngineSceneManager.Instance():setExposure(setting.Exposure)
    EngineSceneManager.Instance():setGamma(setting.Gamma)
    Lib.lightSubscribeEvent("error!!!!! : TimeLight event : EVENT_QUALITY_LEVEL_CHANGE", Event.EVENT_QUALITY_LEVEL_CHANGE, function(level)
        gameSettings:setEnableBloom(level >= 2)
        gameSettings:setEnableFullscreenBloom(setting.EnableFullscreenBloom)
        gameSettings:setBloomThreshold(setting.BloomThreshold)
        gameSettings:setBloomSaturation(setting.BloomSaturation)
        gameSettings:setBloomIntensity(setting.BloomIntensity)
        gameSettings:setBloomBlurDeviation(setting.BloomBlurDeviation)
        gameSettings:setBloomBlurMultiplier(setting.BloomBlurMultiplier)
        gameSettings:setBloomBlurSampler(setting.BloomBlurSampler)
        engineSceneManager:setEnableBakeDirLightShadow(level < 1)

        self.closeFog = level == 0
        self.curHour = nil
    end)

    if self.timer then
        LuaTimer:cancel(self.timer)
    end

    self.timer = LuaTimer:schedule(function()
        self:_OnTick()
    end, 0, 1000)
end

function TimeLight:GetTime()
    return Lib.timeFormatting(self.seconds)
end

function TimeLight:_OnTick()
    if self.disabled then
        return
    end
    local curTime = GameTimes:GetTime()
    self:_SetTime(curTime)
end

function TimeLight:_SetTime(curTime)
    local sec = Lib.time2Seconds(curTime.hour, curTime.min)
    local fromCfg, toCfg = TimeLightConfig:getByTime(sec)
    local lerp = self:_TimeLerp(sec, fromCfg.second, toCfg.second)
    local ambientSkyColor = self:_LerpColor(lerp, fromCfg.ambientSkyColor, toCfg.ambientSkyColor)
    local ambientEquatorColor = self:_LerpColor(lerp, fromCfg.ambientEquatorColor, toCfg.ambientEquatorColor)
    local dirLightColor = self:_LerpColor(lerp, fromCfg.dirLightColor, toCfg.dirLightColor)
    local dirLightRotation = self:_LerpVector3(lerp, fromCfg.dirLightRotation, toCfg.dirLightRotation)
    local ambientIntensity = self:_LerpNumber(lerp, fromCfg.ambientIntensity, toCfg.ambientIntensity)
    local dirLightIntensity = self:_LerpNumber(lerp, fromCfg.dirLightIntensity, toCfg.dirLightIntensity)
    local fogData, fogColor
    if not self.curHour or (self.curHour and self.curHour ~= curTime.hour) then
        fogData = self:_LerpColor(lerp, fromCfg.fogData, toCfg.fogData)
        fogColor = self:_LerpColor(lerp, fromCfg.fogColor, toCfg.fogColor)
        self.curHour = curTime.hour
    end
    self:_SetLight(ambientSkyColor, ambientEquatorColor, dirLightColor, dirLightRotation, ambientIntensity, dirLightIntensity, fogData, fogColor)
end

function TimeLight:_LerpNumber(lerp, from, to)
    return from + (to - from) * lerp
end

function TimeLight:_LerpVector3(lerp, from, to)
    return from + (to - from) * lerp
end

function TimeLight:_LerpColor(lerp, from, to)
    local ret = {}
    for i = 1, 4 do
        table.insert(ret, self:_LerpNumber(lerp, from[i], to[i]))
    end
    return ret
end

function TimeLight:_TimeLerp(sec, from, to)
    if from > to then
        if sec < to then
            sec = sec + DAYSECONDS
        end
        to = to + DAYSECONDS
    end
    return (sec - from) / (to - from)
end

local function updateFog(self, fogData, fogColor)
    if fogData and fogColor then
        local fog = {}
        fog["start"] = fogData[2] or 0
        fog["end"] = (fogData[3] or 0)
        fog["density"] = fogData[1] or 0
        fog["type"] = fogData[5] or 0
        fog["min"] = fogData[4] or 0
        fog["color"] = {
            x = fogColor[1] or 0,
            y = fogColor[2] or 0,
            z = fogColor[3] or 0
        }
        Blockman.instance.gameSettings:setCustomFog(fog.start, fog["end"], fog.density, fog.color, fog.type, fog.min)
        Blockman.instance.gameSettings.hideFog = self.closeFog
    end
end

function TimeLight:_SetLight(ambientSkyColor, ambientEquatorColor, dirLightColor, dirLightRotation, ambientIntensity, dirLightIntensity, fogData, fogColor)
    --engineSceneManager:setEnableLightMap(false)
    --engineSceneManager:setEnableBakeLight(false)
    --engineSceneManager:setEnableBakeDirLightShadow(false)
    --gameSettings:setEnableActorReceiveShadow(0.05)
    --CameraManager.Instance():getMainCamera():setFarClip(self.cameraFarClip or 140)
    engineSceneManager:setAmbientLightIntensity(ambientIntensity + (self.ambientIntensityInc or 0))
    engineSceneManager:setAmbientLightSkyColor(ambientSkyColor)
    engineSceneManager:setAmbientLightEquatorColor(ambientEquatorColor)


    engineSceneManager:setDirLightIntensity(dirLightIntensity)
    engineSceneManager:setDirLightColor(dirLightColor)
    --engineSceneManager:setDirLightDir(dirLightRotation)

    updateFog(self, fogData, fogColor)
end

function TimeLight:SetAmbientIntensityInc(inc)
    self.ambientIntensityInc = inc
end

TimeLight:Init()
