--- buff_component.lua
--- 属性组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@class BuffComponent : middleclass
local BuffComponent = class("BuffComponent")

--- 初始化
---@param owner any
function BuffComponent:initialize(owner)
    self.owner = owner
    self.buffs = {}  --- 使用数组，保证tick顺序
end

--- 添加buff
---@param buff BaseBuff
function BuffComponent:addBuff(buff)
    self.buffs[#self.buffs + 1] = buff
end

--- 通过casterId和buffId获取buff
---@param casterId number
---@param buffId number
---@return BaseBuff, number
function BuffComponent:getBuffByCasterIdAndBuffId(casterId, buffId)
    for index, buff in pairs(self.buffs) do
        if buff:getCasterId() == casterId and buff:getBuffId() == buffId then
            return buff, index
        end
    end
    return nil, -1
end

--- 获取buff
---@param id any
---@return BaseBuff, number
function BuffComponent:getBuffById(id)
    for index, buff in pairs(self.buffs) do
        if buff:getId() == id then
            return buff, index
        end
    end
    return nil, -1
end

--- 移除buff
---@param id any
---@return boolean 是否成功
function BuffComponent:removeBuffById(id)
    local buff, index = self:getBuffById(id)
    if buff then
        table.remove(self.buffs, index)
        return true
    end
    return false
end

--- 通过索引移除
---@param index number
---@return boolean 是否成功
function BuffComponent:removeBuffByIndex(index)
    if self.buffs[index] then
        table.remove(self.buffs, index)
        return true
    end
    return false
end

--- 获取所有buff
function BuffComponent:getAllBuffs()
    return self.buffs
end

--- 移除所有buff
function BuffComponent:removeAllBuffs()
    self.buffs = {}
end

--- 反序列化
---@param data any
function BuffComponent:deserialize(data)

end

--- 序列化数据
function BuffComponent:serialize()

end

return BuffComponent