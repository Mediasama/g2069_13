---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type BuffManager
local BuffManager = require "common.manager.buff_manager"
---@type BuffSystem
local BuffSystem = T(Lib, "BuffSystem")
---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@class BuffManagerServer : BuffManager
local BuffManagerServer = class("BuffManagerServer", BuffManager)

--- 通知指定客户端
---@param entity Entity
---@param packet any
---@param includeSelf boolean
local sendPacketToTracking = function(entity, packet, includeSelf)
    if includeSelf == nil then
        includeSelf = true
    end
    entity:sendPacketToTracking(packet, entity.isPlayer and includeSelf)
end

--- 初始化
function BuffManagerServer:initialize()
    BuffManager.initialize(self)
    self.removeCache = nil
    self.lockBuffList = false
end

--- 重写监听事件
function BuffManagerServer:subscribeEvents()
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_DESTROY, function(entity)
        --- 消亡前移除所有buff
        self:removeAllBuffs(entity, true)
    end)
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_ROLE_DEAD, function(entity)
        --- 死亡时移除所有自身buff
        self:removeAllBuffs(entity)
    end)
end

--- 心跳函数
---@param deltaTime number 时间间隔，单位帧
function BuffManagerServer:tick(deltaTime)
    self.lockBuffList = true

    for _, data in pairs(self.entityList) do
        local objID = data.objID
        ---@type Entity
        local entity = data.entity
        if entity:isValid() then
            local idxList = nil
            local idList = nil
            local buffs = BuffSystem:getAllBuffs(entity)
            if buffs and #buffs > 0 then
                for i = 1, #buffs, 1 do
                    ---@type BaseBuff
                    local buff = buffs[i]
                    if not buff:checkIsEnter() then
                        buff:enter()
                    end
                    buff:tick(deltaTime)
                    if buff:getBuffLayer() <= 0 then
                        idxList = idxList or {}
                        idList = idList or {}
                        idxList[#idxList + 1] = i
                        idList[#idList + 1] = buff:getId()
                        buff:exit()
                    end
                end
                if idxList then
                    self.removeCache = self.removeCache or {}
                    self.removeCache[#self.removeCache + 1] = { idxList = idxList, idList = idList, entity = entity, objID = objID }
                end
            end
        end
    end

    self.lockBuffList = false

    --- 移除处理
    if self.removeCache then
        for _, data in pairs(self.removeCache) do
            local idxList = data.idxList
            -- local idList = data.idList
            ---@type Entity
            local entity = data.entity
            for i = #idxList, 1, -1 do
                local index = idxList[i]
                BuffSystem:removeBuffByIndex(entity, index)
            end
            -- --- 同步数据
            -- sendPacketToTracking(entity, {
            --     pid = "S2CRemoveBuff",
            --     list = idList,
            --     objID = data.objID,
            -- })
        end
        self.removeCache = nil
    end
end

--- 添加buff
---@param caster Entity
---@param holder Entity
---@param buffId number
---@param topCasterId number 顶级触发者
---@param source any 来源
---@return boolean, BaseBuff
function BuffManagerServer:addBuff(caster, holder, buffId, topCasterId, source)
    local addType = SkillBuffConfig:getCfgByBuffId(buffId).addType
    if addType == Define.BUFF_ADD_TYPE.NONE then
        --- 直接添加
        local buff = BuffSystem:createBuff(caster, holder, buffId, topCasterId, source)
        --- 添加buff
        BuffSystem:addBuff(holder, buff)
        --- 触发添加流程
        buff:added()
        return true, buff
    elseif addType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_REFRESH
        or addType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_NO_REFRESH
        or addType == Define.BUFF_ADD_TYPE.LAYER_STACK_TIME_EXTEND
        or addType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_EXTEND
        or addType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_REFRESH
    then
        local buff = BuffSystem:getBuffByCasterIdAndBuffId(holder, caster.objID, buffId)
        if buff then
            if not buff:isMaxLayer() then
                buff:addBuffLayer()
                return true, buff
            end
        else
            --- 直接添加
            local buff = BuffSystem:createBuff(caster, holder, buffId, topCasterId, source)
            --- 添加buff
            BuffSystem:addBuff(holder, buff)
            --- 触发添加流程
            buff:added()
            return true, buff
        end
    elseif addType == Define.BUFF_ADD_TYPE.LAYER_NO_STACK_TIME_NO_REFRESH then
        local buff = BuffSystem:getBuffByCasterIdAndBuffId(holder, caster.objID, buffId)
        if not buff then
            --- 直接添加
            local buff = BuffSystem:createBuff(caster, holder, buffId, topCasterId, source)
            --- 添加buff
            BuffSystem:addBuff(holder, buff)
            --- 触发添加流程
            buff:added()
            return true, buff
        end
    end
    return false
end

--- 移除所有buff
---@param entity Entity
---@param ignoreDead boolean 
function BuffManagerServer:removeAllBuffs(entity, ignoreDead)
    local buffs = BuffSystem:getAllBuffs(entity)
    if buffs and next(buffs) then
        local len = #buffs
        for i = len, 1, -1 do
            if ignoreDead or (not ignoreDead and not buffs[i]:isNotDeadRemove()) then
                buffs[i]:exit()
            end
        end
    end
end

--- 通过buffId移除
---@param holder any
---@param buffId any
---@param casterId any 触发者，可不传
function BuffManagerServer:removeBuffsByBuffId(holder, buffId, casterId)
    local buffs = BuffSystem:getAllBuffs(holder)
    if buffs then
        local len = #buffs
        for i = len, 1, -1 do
            ---@type BaseBuff
            local buff = buffs[i]
            if buff:getBuffId() == buffId and (not casterId or casterId == buff:getCasterId()) then
                buff:exit()
            end
        end
    end
end

--- 通过buff唯一id移除
---@param holder any
---@param id any
function BuffManagerServer:removeBuffById(holder, id)
    local buff = BuffSystem:getBuffById(holder, id)
    if buff then
        buff:exit()
    end
end

--- 使用buff卡
---@param player Entity
---@param itemId any
function BuffManagerServer:useBuffCard(player, itemId)
    local params = ItemConfig:getCfgByItemId(itemId).params
    local buffId = params["buff_id"]
    local buff = SkillBuffConfig:getCfgByBuffId(buffId)
    player:addBuff(buff.buffName, buff.duration, player)
end

return BuffManagerServer