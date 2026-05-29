---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type Stateful
local stateful = require "common.3rd.stateful.stateful"
---@type MissionStageWaveInfoConfig
local MissionStageWaveInfoConfig = T(Config, "MissionStageWaveInfoConfig")
---@type ContentStateWavePrepare
local ContentStateWavePrepare = require "server.mission.state.content.content_state_wave_prepare"
---@type ContentStateWaveStart
local ContentStateWaveStart = require "server.mission.state.content.content_state_wave_start"
---@type ContentStateWaveProcess
local ContentStateWaveProcess = require "server.mission.state.content.content_state_wave_process"
---@type ContentStateWaveWait
local ContentStateWaveWait = require "server.mission.state.content.content_state_wave_wait"
---@type ContentStateWaveEnd
local ContentStateWaveEnd = require "server.mission.state.content.content_state_wave_end"
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")

---@class StageContentMonster : StageContentBase
local StageContentMonster = class("StageContentMonster")
StageContentMonster:include(stateful)

StageContentMonster:addState(Define.MISSION_WAVE_STATE.WAVE_PREPARE, ContentStateWavePrepare)
StageContentMonster:addState(Define.MISSION_WAVE_STATE.WAVE_SATRT, ContentStateWaveStart)
StageContentMonster:addState(Define.MISSION_WAVE_STATE.WAVE_PROCESS, ContentStateWaveProcess)
StageContentMonster:addState(Define.MISSION_WAVE_STATE.WAVE_WAIT, ContentStateWaveWait)
StageContentMonster:addState(Define.MISSION_WAVE_STATE.WAVE_END, ContentStateWaveEnd)

--- 初始化数据
---@param roomId any
---@param mapName any
---@param waves any
---@param waitTime any
function StageContentMonster:initialize(data)
    self.waveIndex = 1
    --- 波数间隔时间
    self.waitTime = data.waitTime or 0
    --- 波数数据
    self.waveList = {}
    for _, waveId in pairs(data.waves) do
        self.waveList[#self.waveList + 1] = MissionStageWaveInfoConfig:getCfgsByWaveId(waveId)
    end
    ---@type MissionRoom
    self.room = data.room
    ---@type MissionStage
    self.stage = data.stage
    --- 怪物列表
    self.monsters = {}

    --- 进入准备状态
    self:gotoState(Define.MISSION_WAVE_STATE.WAVE_PREPARE)
end

--- 开启
function StageContentMonster:start()
    if self:getCurrentState() == Define.MISSION_WAVE_STATE.WAVE_PREPARE then
        --- 切换下一个状态
        self:gotoState(Define.MISSION_WAVE_STATE.WAVE_SATRT)
    end
end

--- 心跳函数，间隔每秒
function StageContentMonster:update()
    self:onUpdate()
end

--- 怪物消亡
---@param entity Entity
function StageContentMonster:onMonsterLeave(entity)
    local objId = entity.objID
    if self.monsters and self.monsters[objId] then
        self.monsters[objId] = nil
    end
end

--- 波数开始
function StageContentMonster:onWaveStart()
    local map = self.room:getMap(self.stage:getMapName())
    --- 生成怪物
    local curWaves = self:getCurrentWave()
    local playerCount = self.room:getPlayerCount(true)
    local ownerInfo = self.room:getOwnerInfo()
    for _, cfg in pairs(curWaves) do
        local monsterId = cfg.monster_id
        ---@type Vector3
        local bornPosition = cfg.born_position
        ---@type EntityServer
        local entity = Plugins.CallTargetPluginFunc("monster_manager", "doCreateMonster", map, monsterId, bornPosition)
        local useOwnerInfo = cfg.use_player_skin == 1
        if useOwnerInfo then
            entity:changeActor(ownerInfo.actorName, true)
            entity:changeSkin(ownerInfo.skin)
        end
        entity:setMissionMonsterData({
            roomId = self.room:getId(),
            enter = true,
            wid = cfg.id,
            ownerName = useOwnerInfo and ownerInfo.name or nil
        })
        if playerCount > 1 then
            --- 属性处理
            local attribute = cfg.attribute
            local attribute_pct = cfg.attribute_pct
            for _, id in pairs(Define.ATTR) do
                local origin = nil
                local add = false

                if attribute and attribute[id] then
                    add = true
                    origin = AttributeSystem:getAttributeValue(entity, id)
                    local value = attribute[id][playerCount - 1] or attribute[id][#attribute[id]]
                    
                    AttributeSystem:addBonus(entity, id, value, Define.ATTR_MOD_TYPE.RAW, "mission_player_num")
                end
                if attribute_pct and attribute_pct[id] then
                    add = true
                    origin = AttributeSystem:getAttributeValue(entity, id)
                    local value = attribute_pct[id][playerCount - 1] or attribute_pct[id][#attribute_pct[id]]
                    AttributeSystem:addBonus(entity, id, value, Define.ATTR_MOD_TYPE.PERCENTADD, "mission_player_num")
                end
                
                --- 设置当前血量
                if add and id == Define.ATTR.MAX_HP then
                    entity:setCurHp(AttributeSystem:getAttributeValue(entity, id))
                end
            end
        end
        self.monsters[entity.objID] = entity
    end
end

--- 判断是否有存活怪物
function StageContentMonster:checkCurrentWaveCompleted()
    if self.monsters then
        ---@type number, Entity
        for _, entity in pairs(self.monsters) do
            if entity and entity:isValid() then
                return false
            end
        end
    end
    return true
end

--- 是否结束
function StageContentMonster:completed()
    local curState = self:getCurrentState()
    if curState and curState == Define.MISSION_WAVE_STATE.WAVE_END then
        return true
    end
    return false
end

--- 强制结束
function StageContentMonster:complete()
    if self:completed() then
        return
    end
    if self.monsters then
        local monsters = self.monsters
        self.monsters = nil
        for objId, entity in pairs(monsters) do
            --- 消亡
            Plugins.CallTargetPluginFunc("monster_manager", "doDestroyMonster", objId)
        end
    end
    self:gotoState(Define.MISSION_WAVE_STATE.WAVE_END)
end

--- 判断是否继续
function StageContentMonster:checkWaveContinue()
    local waveIndex = self.waveIndex + 1
    if waveIndex <= #self.waveList then
        self.waveIndex = waveIndex
        return true
    end
    return false
end

--- 获取当前波数数据
function StageContentMonster:getCurrentWave()
    return self.waveList[self.waveIndex]
end

--- 消亡
function StageContentMonster:destroy()
    if self.monsters then
        local monsters = self.monsters
        self.monsters = nil
        for objId, entity in pairs(monsters) do
            --- 消亡
            Plugins.CallTargetPluginFunc("monster_manager", "doDestroyMonster", objId)
        end
    end
    self.waveIndex = nil
    self.waitTime = nil
    self.waveList = nil
    self.stage = nil
    self.room = nil
end

return StageContentMonster