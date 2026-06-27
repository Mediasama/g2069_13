if World.IsClient then
require "script_client.main"
else
require "script_server.main"
end
require "script_common.main"
-- [Engine Takeover] Unlock Debug Features
-- [Engine Takeover] Unlock Debug Features & Hybrid Pro Camera Injection
if World.cfg then
    World.cfg.openGM = true
    World.cfg.localDebug = true
    -- Force "Hybrid Pro" parameters onto all camera modes
    if World.cfg.cameraCfg and World.cfg.cameraCfg.viewModeConfig then
        for _, cfg in ipairs(World.cfg.cameraCfg.viewModeConfig) do
            cfg.distance = 8
            cfg.viewFovAngle = 65
            cfg.minPitch = -50
            cfg.maxPitch = 89
            cfg.cameraHorizontalFollowWaitTime = 0
            cfg.enableCollisionDetect = false
            cfg.lockBodyRotation = false
        end
    end
end

-- [Hook] UI/Logic Level-Gate Bypass
local oldReq = require
_G.require = function(path)
    local module = oldReq(path)
    if path == "UI/game_mission/gui/win_mission_select" then
        -- Force level requirements to always pass
        if type(module) == "table" then
            module.checkLevelLimit = function() return true end
        end
    end
    return module
end