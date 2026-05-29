--- 基础状态

---@class RoomStateMissionComplete : MissionRoom
local RoomStateMissionComplete = {}
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")

function RoomStateMissionComplete:enteredState(completeCode)
    self.completeCode = completeCode or Define.MISSION_COMPLETE_CODE.FAIL
    self.time = 0

    local send = false

    ---@type number
    ---@type Entity
    for _, player in pairs(self.players) do
        if player and player:isValid() then
            if not send then
                send = true
                Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_COMPLETE, self , player, self.gameTime or 0, self.completeCode)
            end
            
            --- 同步状态数据
            self:syncCompleteState(player)

            --- 发放奖励
            if self.completeCode == Define.MISSION_COMPLETE_CODE.SUCCESS then
                Plugins.CallTargetPluginFunc("game_role_common", "gainMissionRewards", player, self.missionId)
                local missionCfg = MissionInfoConfig:getCfgByMissionId(self.missionId)
                if missionCfg then
                    local params = {
                        missionGroup = missionCfg.mission_group
                    }
                    player:checkUpdateTaskData(Define.TargetConditionKey.MISSION, params)
                end
            end
        end
    end

    if not send then
        ---@type Entity
        local onwer = Game.GetPlayerByUserId(self.ownerUserId)
        if onwer and onwer:isValid() then
            send = true
            Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_COMPLETE, self , onwer, self.gameTime or 0, self.completeCode)
        end
    end
    if not send then
        local players = Game.GetAllPlayers()
        if players then
            ---@type number
            ---@type Entity
            for _, player in pairs(players) do
                if player and player:isValid() then
                    send = true
                    Lib.emitEvent(Event.EVENT_GAME_MISSION_ROOM_COMPLETE, self , player, self.gameTime or 0, self.completeCode)
                    break
                end
            end
        end
    end
end

--- 心跳函数，间隔每秒
function RoomStateMissionComplete:onUpdate()
    self.time = self.time + 1
    if self:getQuitLeftTime() == 0 then
        --- 解除房间绑定
        if self.players then
            ---@type number
            ---@type Entity
            for _, player in pairs(self.players) do
                if player and player:isValid() then
                    self:unlink(player)
                end
            end
            self.players = nil
        end
    elseif self:getQuitLeftTime() + 1 == 0 then
        --- 切换至结束
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_END)
    end
end

function RoomStateMissionComplete:exitedState()
    self.time = 0
end

return RoomStateMissionComplete