---@type SoundConfig
local SoundConfig = T(Config, "SoundConfig")
---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
--- @class SoundManager
local SoundManager = T(Lib, "SoundManager")

function SoundManager:init()
    if self.isInited then
        return
    end
    self.isInited = true
    self.isInPause = false
    self.bgmTimer = nil
    self.curBgmSound = nil
    self.curBgmSoundId = nil

    Lib.lightSubscribeEvent("", Event.EVENT_GAME_PAUSE, function()
        SoundManager.isInPause = true

        if SoundManager.curBgmSoundId then
            TdAudioEngine.Instance():pauseSound(SoundManager.curBgmSoundId)
        end
    end)

    Lib.lightSubscribeEvent("", Event.EVENT_GAME_RESUME, function()
        SoundManager.isInPause = false

        if SoundManager.curBgmSoundId then
            TdAudioEngine.Instance():resumeSound(SoundManager.curBgmSoundId)
        end
    end)

    Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
        local map = World.CurMap
        if map then
            local mapName = map.name
            local config = PlayerBornConfig:getCfgByMapName(mapName)
            if config and config.bgm then
                SoundManager:playBgm(config.bgm)
            end
        end
    end)

    -- Lib.subscribeEvent(Event.EVENT_PLAYER_MOVE_STATUS_CHANGE, function(newState, oldState)
    --     SoundManager:playPlayStateSound(newState)
    -- end)

    Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_EXP, function(player, addLevel, addExp)
        if player.objID == Me.objID and addLevel > 0 then
            SoundManager:playSound("player_level")
        end
    end)

    Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_DEAD, function(entity)
        if entity and entity:isValid() then
            SoundManager:playSound("entity_dead", entity)
        end
    end)

    Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_REVIVE, function(entity)
        if entity.isPlayer and entity.objID == Me.objID then
            SoundManager:playSound("entity_revival")
        end
    end)

    Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, function(player, ability, addLevel)
        if player.objID == Me.objID then
            SoundManager:playSound("ability_level")
        end
    end)
    
    Lib.subscribeEvent(Event.EVENT_PLAY_SOUND, function(soundKey)
        SoundManager:playSound(soundKey)
    end)
end

function SoundManager:playPlayStateSound(newState)
    if self.playState ~= newState then
        if self.runSoundId then
            self:stopSound(self.runSoundId)
            self.runSoundId = nil
        end
        self.playState = newState
        if newState == 3 then
            --run
            self.runSoundId = self:playSound("g2066_run")
        elseif newState == 8 then
            --jump
            self:playSound("g2066_jump")
        end
    end
end

function SoundManager:playBgm(soundKey)
    self:stopBgm()
    local config = SoundConfig:getSound(soundKey)
    self.curBgmSoundId = TdAudioEngine.Instance():play2dSound(config.sound, config.loop, 0)
    --- 是否间隔循环
    local bgm_interval = config.bgm_interval
    local bgm_duration = config.bgm_duration
    if bgm_duration and bgm_interval and bgm_duration > 0 and bgm_interval > 0 then
        self.bgmTimer = LuaTimer:scheduleTicker(function()
            if SoundManager.isInPause then
                return
            end
            bgm_duration = bgm_duration - 0.05
            if bgm_duration <= 0 then
                SoundManager:stopBgm()
                SoundManager.bgmTimer = LuaTimer:scheduleTicker(function()
                    if SoundManager.isInPause then
                        return
                    end
                    bgm_interval = bgm_interval - 0.05
                    if bgm_interval <= 0 then
                        LuaTimer:cancel(SoundManager.bgmTimer)
                        SoundManager.bgmTimer = nil
                        SoundManager:playBgm(soundKey)
                    end
                end, 1)
            end
        end, 1)
    end
end

function SoundManager:stopBgm()
    if self.curBgmSoundId then
        TdAudioEngine.Instance():stopSound(self.curBgmSoundId)
        self.curBgmSoundId = nil
    end
    if self.bgmTimer then
        LuaTimer:cancel(self.bgmTimer)
        self.bgmTimer = nil
    end
end

function SoundManager:playSound(soundKey, entity)
    local config = SoundConfig:getSound(soundKey)
    if not config then
        return
    end
    if entity and entity:isValid() and config.is3dSound then
        return entity:playSound(config)
    else
        return TdAudioEngine.Instance():play2dSound(config.sound, config.loop, 1)
    end
end

function SoundManager:stopSound(soundId)
    if soundId then
        TdAudioEngine.Instance():stopSound(soundId)
    end
end

SoundManager:init()

return SoundManager