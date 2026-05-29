---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")

---@class BaseBuff : middleclass
local BaseBuff = class("BaseBuff")

--- 初始化
---@param id string 唯一id
---@param buffId number 配置表id
---@param casterId number 触发者objID
---@param holderId number 持有者objID
---@param topCasterId number entity objID，顶级触发者
---@param source any 来源
function BaseBuff:initialize(id, buffId, casterId, holderId, topCasterId, source)
    self.id = id
    self.buffId = buffId
    self.topCasterId = topCasterId or casterId
    self.source = source
    self.casterId = casterId
    self.holderId = holderId
    self.isExit = false
    self.isEnter = false
    self.isAdded = false
    --- 单位帧
    self.buffTimers = {}
    self.buffActions = {}
    local config = SkillBuffConfig:getCfgByBuffId(buffId)
    self.buffAddType = config.addType
    self.maxLayer = config.maxLayer
    self.notDeadRemove = not config.deadRemove
end

--- 真正添加时机
function BaseBuff:added()
    if self.isAdded then
        return
    end
    self.isAdded = true
    --- 添加时间
    self:addBuffLayer()
    --- 添加action
    --- 暂时buffID即为buffActionId
    local buffActionId = self.buffId
    local config = SkillBuffConfig:getCfgByBuffId(self.buffId)
    --- @type BaseBuffAction
    local actionClass = Define.BUFF_ACTION_CLASS[config.actionClass]
    --- @type BaseBuffAction
    local action = actionClass:new(buffActionId, self)
    self.buffActions[#self.buffActions + 1] = action
    --- 调用接口
    for _, buffAction in pairs(self.buffActions) do
        buffAction:onAdded()
    end
end

--- 判断是否走了added逻辑
function BaseBuff:checkIsAdded()
    return self.isAdded
end

--- 是否enter
function BaseBuff:checkIsEnter()
    return self.isEnter
end

--- 判断是否exit
function BaseBuff:checkIsExit()
    return self.isExit
end

function BaseBuff:enter()
    if not self.isAdded or self.isEnter then
        return
    end
    self.isEnter = true
    for _, buffAction in pairs(self.buffActions) do
        buffAction:onEnter()
    end
end

function BaseBuff:exit()
    if not self.isAdded or self.isExit then
        return 
    end
    self.isExit = true
    for _, buffAction in pairs(self.buffActions) do
        buffAction:onExit()
    end
    self.buffTimers = {}
end

--- 心跳函数
---@param deltaTime number 时间间隔，单位秒
function BaseBuff:tick(deltaTime)
    if not self.isAdded or not self.isEnter or self.isExit then
        return
    end
    --- 先处理tick再处理时间，保证action中获取的剩余时间正确

    for _, buffAction in pairs(self.buffActions) do
        buffAction:onTick(deltaTime)
    end

    local len = #self.buffTimers
    for i = len, 1, -1 do
        local leftTime = self.buffTimers[i]
        if leftTime ~= -1 then
            leftTime = leftTime - deltaTime
            if leftTime <= 0 then
                table.remove(self.buffTimers, i)
            else
                self.buffTimers[i] = leftTime
            end
        end
    end
end

function BaseBuff:getCasterId()
    return self.casterId
end

function BaseBuff:getHolderId()
    return self.holderId
end

function BaseBuff:getTopCasterId()
    return self.topCasterId
end

function BaseBuff:getBuffId()
    return self.buffId
end

--- 获取源头
function BaseBuff:getSource()
    return self.source
end

function BaseBuff:getId()
    return self.id
end

function BaseBuff:isClient()
    return false
end

--- 是否死亡跟随移除
function BaseBuff:isNotDeadRemove()
    return self.notDeadRemove
end

--- 是否满层级
function BaseBuff:isMaxLayer()
    if self.maxLayer > 0 and self:getBuffLayer() >= self.maxLayer then
        return true
    end
    return false
end

--- 添加层级
function BaseBuff:addBuffLayer()
    local duration = SkillBuffConfig:getCfgByBuffId(self.buffId).duration
    local len = #self.buffTimers
    if self.buffAddType == Define.BUFF_ADD_TYPE.NONE then
        --- 无限制
        self.buffTimers[1] = duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_REFRESH then
        --- 堆叠，且时间刷新
        self.buffTimers[len + 1] = duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_NO_REFRESH then
        --- 堆叠，但时间不刷新
        self.buffTimers[len + 1] = self.buffTimers[len] or duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_EXTEND then
        --- 堆叠，且时间延长
        self.buffTimers[len + 1] = (self.buffTimers[len] or 0) + duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_EXTEND then
        --- 不堆叠，且时间延长
        self.buffTimers[1] = (self.buffTimers[1] or 0) + duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_REFRESH then
        --- 不堆叠，且时间刷新
        self.buffTimers[1] = duration
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_NOT_REFRESH then
        --- 不堆叠，且时间不刷新

    end
end

--- 获取剩余时间，单位帧
function BaseBuff:getLeftTime()
    if self.buffAddType == Define.BUFF_ADD_TYPE.NONE then
        return self.buffTimers[1] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_REFRESH then
        return self.buffTimers[#self.buffTimers] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_NO_REFRESH then
        return self.buffTimers[1] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_EXTEND then
        return self.buffTimers[#self.buffTimers] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_EXTEND then
        return self.buffTimers[1] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_REFRESH then
        return self.buffTimers[1] or 0
    elseif self.buffAddType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_NO_REFRESH then
        return self.buffTimers[1] or 0
    end
    return 0
end

--- 获取buff层级
function BaseBuff:getBuffLayer()
    return #self.buffTimers
end

return BaseBuff



