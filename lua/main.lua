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