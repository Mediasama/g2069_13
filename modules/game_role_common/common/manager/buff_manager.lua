---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type BuffSystem
local BuffSystem = T(Lib, "BuffSystem")

---@class BuffManager : singleton
local BuffManager = class("BuffManager")
BuffManager:include(singleton)

--- 初始化
function BuffManager:initialize()
    self.timer = nil
    self.isInited = false
    self.events = {}
    self.entityList = {}
end

function BuffManager:init()
    if self.isInited then
        return
    end
    self.isInited = true
    self:subscribeEvents()
    --- 按帧处理
    self.timer = LuaTimer:scheduleTicker(function()
        self:tick(0.05)
    end, 1)
end

function BuffManager:subscribeEvents()

end

--- 添加entity
---@param entity Entity
function BuffManager:addEntity(entity)
    local objID = entity.objID
    for _, data in pairs(self.entityList) do
        if data.objID == objID then
            data.entity = entity
            return
        end
    end
    self.entityList[#self.entityList + 1] = { objID = objID, entity = entity }
end

--- 移除entity
---@param entity Entity
function BuffManager:removeEntity(entity)
    local objID = entity.objID
    for i = 1, #self.entityList, 1 do
        local data = self.entityList[i]
        if data.objID == objID then
            table.remove(self.entityList, i)
            break
        end
    end
end

--- 心跳函数
---@param deltaTime number 时间间隔，单位帧
function BuffManager:tick(deltaTime)
    
end

--- 移除所有buff
---@param entity Entity
---@param ignoreDead boolean
function BuffManager:removeAllBuffs(entity, ignoreDead)

end

--- 添加buff
---@param caster Entity
---@param holder Entity
---@param buffId number
---@param topCasterId number 顶级触发者
---@param source any 来源
---@return boolean, BaseBuff
function BuffManager:addBuff(caster, holder, buffId, topCasterId, source)
    return false, nil
end

--- 通过buffId移除
---@param holder any
---@param buffId any
---@param casterId any 触发者，可nil
function BuffManager:removeBuffsByBuffId(holder, buffId, casterId)
    
end

--- 通过buff唯一id移除
---@param holder any
---@param id any
function BuffManager:removeBuffById(holder, id)
    
end

return BuffManager

