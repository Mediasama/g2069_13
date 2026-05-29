---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type GameMapManager
local GameMapManager = require "common.manager.game_map_manager"

---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")

---@class MapManagerClient : GameMapManager
local MapManagerClient = class("MapManagerClient", GameMapManager)

function MapManagerClient:initialize()
    GameMapManager.initialize(self)
    self.events = {}
end

--- 初始化
function MapManagerClient:init()
    if self.isInited then
        return
    end
    GameMapManager.init(self)
end

--- 寻路
---@param curMap any
---@param targetMap any
---@param recursion any
---@param layer any
---@param path any
---@param pathNo any
---@param checkMap any
function MapManagerClient:innerFindTeleportPosition(curMap, targetMap, path, layer, checkMap)
    --- 过滤检测路线
    checkMap = checkMap or {}
    if checkMap[curMap] then
        return false
    end
    checkMap[curMap] = true

    layer = (layer or 0) + 1
    local list = nil

    local teleports = self:getMapTeleports(curMap) or {}
    for _, teleportCfg in pairs(teleports) do
        local teleport_map = teleportCfg.teleport_map
        if teleport_map == targetMap then
            --- 新增路线
            local pathNo = #path + 1
            local newPath = {}
            path[pathNo] = newPath

            newPath[#newPath + 1] = { layer = layer, position = teleportCfg.position, map = teleport_map }

            list = list or {}
            list[#list + 1] = pathNo

        elseif not checkMap[teleport_map] then
            local success, _list = self:innerFindTeleportPosition(teleport_map, targetMap, path, layer, checkMap)
            if success then
                for _, pathNo in pairs(_list) do
                    local newPath = path[pathNo]
                    --- 插入当前值
                    table.insert(newPath, 1, { layer = layer, position = teleportCfg.position, map = teleport_map })
                    list = list or {}
                    list[#list + 1] = pathNo
                end
            end
        end
    end
    if list then
        return true, list
    end
    return false
end

--- 寻找路线
---@param curMap string 当前地图
---@param targetMap string 目标地图
---@param recursion boolean 是否递归
---@return Vector3 传送点位置
function MapManagerClient:findTeleportPosition(curMap, targetMap)
    local path = {}
    self:innerFindTeleportPosition(curMap, targetMap, path)
    --- 判断是否有路线
    local len = #path
    if len > 0 then
        local minLayer = nil
        local index = nil
        for i = 1, len, 1 do
            local l = #path[i]
            if l > 0 and path[i][1].layer == 1 then
                if not minLayer or minLayer > #path[i] then
                    index = i
                    minLayer = #path[i]
                end
            end
        end
        if index then
            return path[index][1].position
        end
    end

    return nil
end

--- 查找副本入口
---@param curMap any
---@param missionGroup any
---@return Vector3 入口位置
---@return string 地图名称
function MapManagerClient:findMissionGatePosition(curMap, missionGroup)
    --- 优先返回当前地图
    local position = self:getMapMissionGatePosition(curMap, missionGroup)
    if position then
        return position, curMap
    end
    local cfgs = PlayerBornConfig:getAllCfgs()
    for mapName, cfg in pairs(cfgs) do
        if curMap ~= mapName then
            local pos = self:getMapMissionGatePosition(mapName, missionGroup)
            if pos then
                return pos, mapName
            end
        end
    end
    return nil, nil
end

return MapManagerClient