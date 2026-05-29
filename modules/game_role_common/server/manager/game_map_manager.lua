---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type WorldServer
local CW = World.CurWorld
---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")

---@type Vector3
local forward = Vector3.new(0, 0, 1)
---@type GameMapManager
local GameMapManager = require "common.manager.game_map_manager"

---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")

---@class MapManagerServer : GameMapManager
local MapManagerServer = class("MapManagerServer", GameMapManager)

--- 初始化
---@param player any
function MapManagerServer:onPlayerLogin(player)
    --- 跳转地图
    local bornMap = player:getBornMap()
    local curMap = player:getCurMap()

    local defaultBornMap = World.cfg.defaultBornMap

    local mapName = nil
    if curMap and curMap ~= "" and curMap ~= "map_born" then
        mapName = curMap
    elseif bornMap and bornMap ~= "" then
        mapName = bornMap
    elseif defaultBornMap and defaultBornMap ~= "" then
        --- 强行设置出生地图
        player:setBornMap(defaultBornMap)
        mapName = defaultBornMap
    else
        -- mapName = World.cfg.defaultMap
    end
    
    if mapName then
        self:gotoMap(player, mapName)
    end
end

--- 跳转地图
---@param player Entity
---@param mapName any
---@param position Vector3
---@return boolean success
function MapManagerServer:gotoMap(player, mapName, position)
    --- 创建静态地图
    local config = PlayerBornConfig:getCfgByMapName(mapName)
    if not config then
        return false
    end
    local map = CW:getOrCreateStaticMap(mapName)
    if position then
        player:setMapPos(map, position)
    else
        player:setMapPos(map, config.bornPosition)
    end
    if mapName ~= "map_born" then
        player:setCurMap(mapName)
        Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_GO_TO_MAP, player, mapName)
    end
    return true
end

--- 跳转至对应地图传送门
---@param player Entity
---@param mapName string
---@param toTeleportId string 可为空
---@return boolean success
function MapManagerServer:gotoMapTeleport(player, mapName, toTeleportId)
    local position = nil
    if toTeleportId and toTeleportId ~= "" then
        local initPos = self:getMapTeleportPosition(mapName, toTeleportId)
        if initPos then
            position = Lib.v3(initPos.x,initPos.y + 1, initPos.z)
            --- 随机位置
            local angle = math.random(0, 359)
            local q = Quaternion.fromEulerAngle(0, angle, 0)

            local radius = World.cfg.teleportSetting and World.cfg.teleportSetting.randomRadius or 2
            position = position + q * (forward * radius)
        end
    end
    return self:gotoMap(player, mapName, position)
end

--- 复活点
---@param player Entity
---@return boolean success
function MapManagerServer:backRebornPosition(player)
    if player.map then
        local bornMap = player:getBornMap()
        local level = GrowthSystem:getLevel(player)
        local list = PlayerBornConfig:getAllCfgs()
        for name, cfg in pairs(list) do
            local born_level = cfg.born_level
            if born_level and #born_level > 0 then
                if level >= born_level[1] and level <= born_level[2] then
                    if cfg.selectableMap == 0 or (cfg.selectableMap == 1 and bornMap == name) then
                        return self:gotoMap(player, name)
                    end
                end
            end
        end

        local mapName = player.map.name
        local config = PlayerBornConfig:getCfgByMapName(mapName)
        --- 复活地图
        local rebornMap = config.rebornMap
        local rebornPositions = config.rebornPositions
        local rand = math.random(1, #rebornPositions)
        ---@type Vector3
        local rebornPosition = rebornPositions[rand]

        return self:gotoMap(player, rebornMap, rebornPosition)
    end
    return false
end

--- 出生点
---@param player any
---@return boolean success
function MapManagerServer:backBornPosition(player)
    if player.map then
        local mapName = player.map.name
        return self:gotoMap(player, mapName)
    end
    return false
end

return MapManagerServer