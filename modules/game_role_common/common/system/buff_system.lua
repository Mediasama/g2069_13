---@class BuffSystem
local BuffSystem = T(Lib, "BuffSystem")
---@type uuid
local uuid = require "common.uuid"
---@type BaseBuff
local BaseBuff = require "common.buff.base_buff"

function BuffSystem:init()

end

--- 创建buff
---@param caster Entity 触发者
---@param holder Entity 持有者
---@param buffId number 
---@param topCasterId number 顶级触发者
---@param source any 源头，待定
---@return BaseBuff
function BuffSystem:createBuff(caster, holder, buffId, topCasterId, source)
    ---@type BaseBuff
    local buff = BaseBuff:new(uuid(), buffId, caster.objID, holder.objID, topCasterId, source)
    return buff
end

--- 通过caster和buffId获取buff
---@param entity Entity
---@param casterId number caster objID
---@param buffId number
---@return BaseBuff, number BaseBuff与索引
function BuffSystem:getBuffByCasterIdAndBuffId(entity, casterId, buffId)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        return buffComponent:getBuffByCasterIdAndBuffId(casterId, buffId)
    end
    return nil, -1
end

--- 添加buff
---@param entity Entity
---@param buff BaseBuff
function BuffSystem:addBuff(entity, buff)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        buffComponent:addBuff(buff)
    end
end

--- 获取所有buffs
---@param entity Entity
function BuffSystem:getAllBuffs(entity)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        return buffComponent:getAllBuffs()
    end
    return nil
end

--- 移除buff
---@param entity Entity
---@param id any
---@return boolean 是否成功
function BuffSystem:removeBuffById(entity, id)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        return buffComponent:removeBuffById(id)
    end
    return false
end

--- 通过索引移除buff
---@param entity Entity
---@param index any
function BuffSystem:removeBuffByIndex(entity, index)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        return buffComponent:removeBuffByIndex(index)
    end
    return false
end

--- 移除所有buff
---@param entity entity
function BuffSystem:removeAllBuffs(entity)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        buffComponent:removeAllBuffs()
    end
end

--- 通过buff唯一id获取
---@param entity any
---@param id any
---@return BaseBuff 指定buff
---@return number 索引
function BuffSystem:getBuffById(entity, id)
    ---@type BuffComponent
    local buffComponent = entity:getComponent("buff")
    if buffComponent then
        return buffComponent:getBuffById(id)
    end
    return nil, -1
end

BuffSystem:init()

return BuffSystem