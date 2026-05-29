---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type Stateful
local stateful = require "common.3rd.stateful.stateful"
---@type MissionStageInfoConfig
local MissionStageInfoConfig = T(Config, "MissionStageInfoConfig")
---@type StageStateStageStart
local StageStateStageStart = require "server.mission.state.stage.stage_state_stage_start"
---@type StageStateStageEnd
local StageStateStageEnd = require "server.mission.state.stage.stage_state_stage_end"
---@type StageStateStageWait
local StageStateStageWait = require "server.mission.state.stage.stage_state_stage_wait"
---@type StageStateStageProcess
local StageStateStageProcess = require "server.mission.state.stage.stage_state_stage_process"
---@type StageStateStagePrepare
local StageStateStagePrepare = require "server.mission.state.stage.stage_state_stage_prepare"

---@class MissionStage : middleclass
local MissionStage = class("MissionStage")
MissionStage:include(stateful)

MissionStage:addState(Define.MISSION_STAGE_STATE.STAGE_PREPARE, StageStateStagePrepare)
MissionStage:addState(Define.MISSION_STAGE_STATE.STAGE_SATRT, StageStateStageStart)
MissionStage:addState(Define.MISSION_STAGE_STATE.STAGE_PROCESS, StageStateStageProcess)
MissionStage:addState(Define.MISSION_STAGE_STATE.STAGE_WAIT, StageStateStageWait)
MissionStage:addState(Define.MISSION_STAGE_STATE.STAGE_END, StageStateStageEnd)

--- 初始化数据
---@param data table
function MissionStage:initialize(data)
    self.completeCode = Define.MISSION_COMPLETE_CODE.NONE
    self.stageId = data.stageId
    self.config = MissionStageInfoConfig:getCfgByStageId(self.stageId)
    ---@type MissionRoom
    self.room = data.room
    --- 初始化数据
    -------------------- 关卡内容 -----------------
    self.stageContentList = {}
    --- boss
    local boss_waves = self.config.boss_waves
    if boss_waves and next(boss_waves) then
        ---@type StageContentMonster
        local StageContentMonster = Define.STAGE_CONTENT_CLASS[Define.STAGE_CONTENT_TYPE.BOSS]
        ---@type StageContentMonster
        local stageContent = StageContentMonster:new({
            room = self.room, 
            stage = self, 
            waves = boss_waves, 
            waitTime = self.config.boss_wave_time or 0
        })
        self.stageContentList[#self.stageContentList + 1] = stageContent
    end
    --- 小怪
    local monster_waves = self.config.monster_waves
    if monster_waves and next(monster_waves) then
        ---@type StageContentMonster
        local StageContentMonster = Define.STAGE_CONTENT_CLASS[Define.STAGE_CONTENT_TYPE.MONSTER]
        ---@type StageContentMonster
        local stageContent = StageContentMonster:new({
            room = self.room, 
            stage = self, 
            waves = monster_waves, 
            waitTime = self.config.monster_wave_time or 0
        })
        self.stageContentList[#self.stageContentList + 1] = stageContent
    end
    -------------------------------------
    --- 进入准备状态
    self:gotoState(Define.MISSION_STAGE_STATE.STAGE_PREPARE)
end

--- 获取stage id
function MissionStage:getStageId()
    return self.stageId
end

function MissionStage:start()
    if self:getCurrentState() == Define.MISSION_STAGE_STATE.STAGE_PREPARE then
        --- 切换下一个状态
        self:gotoState(Define.MISSION_STAGE_STATE.STAGE_SATRT)
    end
end

--- 心跳函数，间隔每秒
function MissionStage:update()
    self:onUpdate()
end

--- 判断是否完成
function MissionStage:completed()
    local curState = self:getCurrentState()
    if curState and curState == Define.MISSION_STAGE_STATE.STAGE_END then
        return true
    end
    return false
end

--- 获取结果
function MissionStage:getCompleteCode()
    return self.completeCode
end

--- 获取地图名称
function MissionStage:getMapName()
    return self.config.stage_map
end

--- 获取出生点列表
function MissionStage:getBornPositions()
    return self.config.born_position
end

--- 怪物消亡
---@param entity Entity
function MissionStage:onMonsterLeave(entity)
    ---@type number
    ---@type StageContentBase
    for _, stageContent in pairs(self.stageContentList) do
        stageContent:onMonsterLeave(entity)
    end
end

--- 结束
function MissionStage:complete(completeCode)
    if self:completed() then
        return
    end
    self.completeCode = completeCode or Define.MISSION_COMPLETE_CODE.FAIL
    if self.stageContentList then
        ---@type number
        ---@type StageContentBase
        for _, stageContent in pairs(self.stageContentList) do
            stageContent:complete()
        end
    end
    self:gotoState(Define.MISSION_STAGE_STATE.STAGE_END)
end

function MissionStage:destroy()
    if self.stageContentList then
        ---@type number
        ---@type StageContentBase
        for _, stageContent in pairs(self.stageContentList) do
            stageContent:destroy()
        end
        self.stageContentList = nil
    end
    self.completeCode = nil
    self.stageId = nil
    self.config = nil
    self.room = nil
end

return MissionStage