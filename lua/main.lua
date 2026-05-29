if World.IsClient then
require "script_client.main"
else
require "script_server.main"
end
require "script_common.main"
-- [Engine Takeover] Unlock Debug Features
if World.cfg then
    World.cfg.openGM = true
    World.cfg.localDebug = true
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