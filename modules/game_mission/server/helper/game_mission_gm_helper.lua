---@class GameMissionGMHelperServer
local GameMissionGMHelperServer = T(Lib, "GameMissionGMHelperServer")

---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")

--- gm处理
---@param player Entity
---@param packet any
function GameMissionGMHelperServer:onCommandHandle(player, packet)
    if not World.openGM then
        return
    end

    ---@type MissionManagerServer
    local MissionManagerServer = require "server.manager.mission_manager"
    ---@type MissionManagerServer
    local manager = MissionManagerServer:instance()
    local command = packet.command
    if command == Define.GAME_MISSION_GM_COMMAND.OPEN_MISSION then
        if player:isInMissionRoom() then
            Lib.logError("Error:Player is in mission room, room id:", player:getMissionRoomId())
            return
        end
        --- 开启副本
        local missionId = packet.missionId
        manager:createRoom(player, Define.MISSION_PLAY_MODE.SINGLE, missionId)
    elseif command == Define.GAME_MISSION_GM_COMMAND.QUIT_MISSION then
        if not player:isInMissionRoom() then
            Lib.logError("Error:Player is not in mission room.")
            return
        end
        local roomId = player:getMissionRoomId()
        local room = manager:getRoom(roomId)
        if room then
            room:quit(player)
        else
            Lib.logError("Error:Mission room is not exist, room id:", roomId)
        end
    end
end

return GameMissionGMHelperServer