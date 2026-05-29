--- 基础状态

---@class RoomStateMissionStart : MissionRoom
local RoomStateMissionStart = {}

function RoomStateMissionStart:enteredState(isRepeat)
    self.time = 0
    if isRepeat then
        --- 切换地图
        local stage = self:getCurrentStage()
        local map = self:getMap(stage:getMapName())
        local bornPositions = stage:getBornPositions()
        ---@type number
        ---@type Entity
        for _, player in pairs(self.players) do
            if player and player:isValid() then
                local pos = nil
                if #bornPositions == 1 then
                    pos = bornPositions[1]
                else
                    local rand = math.random(1, #bornPositions)
                    pos = bornPositions[rand] or bornPositions[1]
                end
                player:setMapPos(map, pos)
            end
        end
    end
    if self:getStartLeftTime() == 0 then
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS)
    else
        ---@type number
        ---@type Entity
        for _, player in pairs(self.players) do
            if player and player:isValid() then
                --- 设置状态数据
                self:syncStartState(player)
            end
        end        
    end
end

--- 心跳函数，间隔每秒
function RoomStateMissionStart:onUpdate()
    self.time = self.time + 1
    if self:getStartLeftTime() == 0 then
        self:gotoState(Define.MISSION_ROOM_STATE.MISSION_STAGE_PROCESS)
    end
end

function RoomStateMissionStart:exitedState()
    self.time = 0
end

return RoomStateMissionStart