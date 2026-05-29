---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"

---@type Map
local Map = T(World, "Map")

--- 获取坐标
---@param cfg any
local function getCfgPosition(cfg)
    local position = cfg.properties.position
    local list = Lib.splitString(position, " ")
    local x = tonumber(Lib.splitString(list[1], ":")[2])
    local y = tonumber(Lib.splitString(list[2], ":")[2])
    local z = tonumber(Lib.splitString(list[3], ":")[2])
    return Vector3.new(x, y, z)
end

--- 寻找子节点
---@param cfg any
---@param name any
---@param recursion any
local function findCfgNode(cfg, name, recursion)
    local children = cfg.scene or cfg.children or (#cfg > 0 and cfg)
    if children then
        for index, node in pairs(children) do
            if node.properties.name == name then
                return node, index
            elseif recursion then
                local childCfg, childIndex = self:findInstanceCfg(node, name, recursion)
                if childCfg then
                    return childCfg, childIndex
                end
            end
        end
    end
    return nil, -1
end

---@class GameMapManager : singleton
local GameMapManager = class("GameMapManager")
GameMapManager:include(singleton)

function GameMapManager:initialize()
    self.isInited = false
    self.teleports = {}
    self.missionGates = {}
end

--- 初始化
function GameMapManager:init()
    if self.isInited then
        return
    end
    self.isInited = true
end

--- 获取指定地图传送点
---@param mapName any
---@param teleportId any
---@return Vector3
function GameMapManager:getMapTeleportPosition(mapName, teleportId)
    local teleports = self:getMapTeleports(mapName)
    if teleports and teleports[teleportId] then
        return teleports[teleportId].position
    end
    Lib.logWarning("Warning:Not found the target teleport in map, map name:", mapName, " teleport id:", teleportId)
    return nil
end

--- 获取所有传送点
---@param mapName any
function GameMapManager:getMapTeleports(mapName)
    if not self.teleports[mapName] then
        local teleports = {}
        self.teleports[mapName] = teleports
        Lib.XPcall(function()
            local cfg = Map.GetCfg(mapName)
            local gameContent = findCfgNode(cfg, "gameContent")
            if not gameContent then
                Lib.logError("Error:Not found the node in map, map name:", mapName, " node name:gameContent")
            end
            local path = Root.Instance():getGamePath() .. "map/" .. mapName .. "/DataSet/" .. gameContent.properties.id .. ".json"
            gameContent = Lib.read_json_file(path)
            if not gameContent then
                Lib.logError("Error:Not found the json, path:", path)
            end
            local parent = findCfgNode(gameContent, "teleport_parent")
            if parent and parent.children and #parent.children > 0 then
                --- 获取所有传送门
                for _, teleportCfg in pairs(parent.children) do
                    local teleport_id = teleportCfg.attributes["teleport_id"]
                    teleports[teleport_id] = { 
                        teleport_id = teleport_id, 
                        position = getCfgPosition(teleportCfg), 
                        teleport_map = teleportCfg.attributes["teleport_map"],
                        to_teleport_id = teleportCfg.attributes["to_teleport_id"],
                    }
                end
            end    
        end)
    end
    return self.teleports[mapName] or {}
end

--- 获取副本传送门入口
---@param mapName any
---@param missionGroup any
function GameMapManager:getMapMissionGatePosition(mapName, missionGroup)
    local missionGates = self:getMapMissionGates(mapName)
    if missionGates then
        for _, v in pairs(missionGates) do
            if v.mission_group == missionGroup then
                return v.position
            end
        end
    end
    return nil
end

--- 获取地图所有副本入口
---@param mapName any
function GameMapManager:getMapMissionGates(mapName)
    if not self.missionGates[mapName] then
        local missionGates = {}
        self.missionGates[mapName] = missionGates
        Lib.XPcall(function()
            local cfg = Map.GetCfg(mapName)
            local gameContent = findCfgNode(cfg, "gameContent")
            if not gameContent then
                Lib.logError("Error:Not found the node in map, map name:", mapName, " node name:gameContent")
            end
            local path = Root.Instance():getGamePath() .. "map/" .. mapName .. "/DataSet/" .. gameContent.properties.id .. ".json"
            gameContent = Lib.read_json_file(path)
            if not gameContent then
                Lib.logError("Error:Not found the json, path:", path)
            end
            local parent = findCfgNode(gameContent, "mission")
            if parent and parent.children and #parent.children > 0 then
                --- 获取所有传送门
                for _, gateCfg in pairs(parent.children) do
                    local mission_group = tonumber(gateCfg.attributes["mission_group"])
                    missionGates[#missionGates + 1] = { 
                        mission_group = mission_group, 
                        position = getCfgPosition(gateCfg), 
                        map = mapName,
                    }
                end
            end    
        end)
    end
    return self.missionGates[mapName]
end

return GameMapManager