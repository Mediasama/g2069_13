---@type Map
local Map = T(World, "Map")

local engine_init = Map.init
--- 重载
---@param isCache any
function Map:init(isCache)
    engine_init(self, isCache)
    Lib.emitEvent(Event.EVENT_SCENE_OBJECT_INIT_MAP, self)
end