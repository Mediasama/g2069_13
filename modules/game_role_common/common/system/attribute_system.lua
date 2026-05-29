---@class AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")

function AttributeSystem:init()
    local attributeData = World.cfg.attributeData
    self.maxIndex = attributeData.maxIndex
    self.unlockCostCube = attributeData.unlockCostCube
    self.resetCostCube = attributeData.resetCostCube
    self.freeResetTimes = attributeData.freeResetTimes


    self.ATTRIBUTE_CACHE_POINT = nil
end

--- 获取属性值
---@param entity Entity
---@param id any 属性key，参考Define.ATTR
function AttributeSystem:getAttributeValue(entity, id)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getAttributeValue(id)
    end
    return AttributeInfoConfig:getBaseValue(id)
end

--- 获取属性
---@param entity Entity
---@param id any 属性key，参考Define.ATTR
---@return BaseAttribute
function AttributeSystem:getAttribute(entity, id)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getAttribute(id)
    end
    return nil
end

--- 添加属性修饰
---@param entity Entity
---@param id any 属性id
---@param bonus number 额外加成
---@param modType number 修饰器类型
---@param source any 源标记
function AttributeSystem:addBonus(entity, id, bonus, modType, source)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        attributeComponent:addBonus(id, bonus, modType, source)
    end
end

--- 移除源属性修饰
---@param entity Entity
---@param source any
function AttributeSystem:removeAllModifiersFromSource(entity, source)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        attributeComponent:removeAllModifiersFromSource(source)
    end
end

--- 获取剩余属性点
---@param entity Entity
---@param index number 方案索引
---@return number 属性点
function AttributeSystem:getRemainPointByIndex(entity, index)
    ---@type GrowthComponent
    local growthComponent = entity:getComponent("growth")
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent and growthComponent then
        local point = growthComponent:getAttributePoint()
        local data = attributeComponent:getLevelDataByIndex(index)
        if data then
            for id, level in pairs(data) do
                if level > 1 then
                    local needPoint = 1
                    point = point - needPoint * (level - 1)
                end
            end
        end
        return point
    end
    return 0
end


--- 获取当前方案剩余属性点
---@param entity Entity
---@return number 属性点
function AttributeSystem:getRemainPoint(entity)
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local index = attributeComponent:getIndex()
        return self:getRemainPointByIndex(entity, index)
    end
    return 0
end

--- 获取当前方案属性等级
---@param entity Entity
---@param id string
function AttributeSystem:getLevel(entity, id)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getLevel(id)
    end
    return 1
end

--- 获取方案属性等级
---@param entity Entity
---@param id string
---@param index string 方案索引
function AttributeSystem:getLevelByIndex(entity, id, index)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        local data = attributeComponent:getLevelDataByIndex(index)
        if data then
            return data[id] or 1
        end
    end
    return 1
end

--- 设置当前方案属性等级
---@param entity Entity 目标
---@param id string 属性id
---@param level number 等级
---@return boolean 是否成功
function AttributeSystem:setLevel(entity, id, level)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:setLevel(id, level)
    end
    return false
end

--- 设置指定方案属性等级
---@param entity Entity 目标
---@param id string 属性id
---@param level number 等级
---@param index number 方案索引
---@return boolean 是否成功
function AttributeSystem:setLevelByIndex(entity, id, level, index)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:setLevelByIndex(id, level, index)
    end
    return false
end

--- 获取属性数据
---@param entity any
---@return AttributeData
function AttributeSystem:getAttributeData(entity)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getAttributeData()
    end
    return nil
end

--- 清空属性数据
---@param entity any
---@param index any
function AttributeSystem:clearAttributeData(entity, index)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:clearAttributeData(index)
    end
    return false
end

--- 获取属性数据
---@param entity any
---@return AttributeData
function AttributeSystem:getUnlockIndex(entity)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getUnlockIndex()
    end
    return nil
end

--- 设置加点方案索引
---@param entity any
---@param index number 方案索引
---@return boolean 是否成功
function AttributeSystem:setIndex(entity, index)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:setIndex(index)
    end
    return false
end

--- 获取属性方案
---@param entity any
---@return number 方案索引
function AttributeSystem:getIndex(entity)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:getIndex()
    end
    return 1
end

--- 设置加点方案索引
---@param entity any
---@param unlockIndex number 解锁索引
---@return boolean 是否成功
function AttributeSystem:setUnlockIndex(entity, unlockIndex)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        return attributeComponent:setUnlockIndex(unlockIndex)
    end
    return false
end

--- 获取重置次数
---@param entity any
function AttributeSystem:getResetTimes(entity)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        ---@type AttributeData
        local attributeData = attributeComponent:getAttributeData()
        return attributeData.rtimes or 0
    end
    return 0
end

--- 设置重置次数
---@param entity any
---@param times any
function AttributeSystem:setResetTimes(entity, times)
    ---@type AttributeComponent
    local attributeComponent = entity:getComponent("attribute")
    if attributeComponent then
        ---@type AttributeData
        local attributeData = attributeComponent:getAttributeData()
        attributeData.rtimes = times
    end
end

--- 获取方案最大索引
function AttributeSystem:getAttributeMaxIndex()
    return self.maxIndex
end

--- 获取解锁消耗金魔方
function AttributeSystem:getUnlockCostCube()
    return self.unlockCostCube
end

function AttributeSystem:getResetCostCube()
    return self.resetCostCube
end

--- 获取免费重置次数
function AttributeSystem:getFreeResetTimes()
    return self.freeResetTimes
end


AttributeSystem:init()

return AttributeSystem