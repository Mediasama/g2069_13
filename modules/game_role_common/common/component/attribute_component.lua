--- attribute_component.lua
--- 属性组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type AttributeModifier
local AttributeModifier = require "common.attribute.attribute_modifier"
---@type AttributeData
local AttributeData = require "common.structure.attribute_data"
---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")
---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")
---@type GrowthAttribute
local GrowthAttribute = require "common.attribute.growth_attribute"
---@type CompositeAttribute
local CompositeAttribute = require "common.attribute.composite_attribute"

---@class AttributeComponent : middleclass
local AttributeComponent = class("AttributeComponent")

--- 初始化
---@param owner Entity 持有者
function AttributeComponent:initialize(owner)
    self.attributes = {}
    self.owner = owner

    if owner.isPlayer then
        ---@type AttributeData
        self.attributeData = AttributeData:new()
        --- 初始化二级属性,不直接参与战斗计算
        local attributes_2nd = AttributeInfoConfig:getAttributesByType(2)
        for _, config in pairs(attributes_2nd) do
            local id = config.attr_id
            ---@type GrowthAttribute
            local cls = Define.ATTR_CLASS[id]
            if not cls then
                Lib.logError("error:Not found the attribute class, attribute id:", id)
                cls = GrowthAttribute
            end
            ---@type GrowthAttribute
            local attribute = cls:new(id, config.base_value, self:getLevel(id))
            self.attributes[id] = attribute
        end

        local attributes = AttributeInfoConfig:getAttributesByType(1)

        --- 初始化一级属性,直接参与战斗计算
        for _, config in pairs(attributes) do
            local id = config.attr_id
            ---@type CompositeAttribute
            local cls = Define.ATTR_CLASS[id]
            if not cls then
                Lib.logError("error:Not found the attribute class, attribute id:", id)
                cls = CompositeAttribute
            end
            ---@type CompositeAttribute
            local attribute = cls:new(id, config.base_value)

            --- 判断是否有二级属性
            local ids = config.comp_attr_ids
            if ids and next(ids) then
                for __, _id in pairs(ids) do
                    ---@type GrowthAttribute
                    local growthAttribute = self.attributes[_id]
                    attribute:addAttribute(growthAttribute)
                end
            end

            self.attributes[id] = attribute
        end
    elseif owner:isMonster() then
        --- 只需要初始化一级属性
        local attributes = MonsterConfig:getMonsterAttributes(owner:getMonsterId())
        for id, baseValue in pairs(attributes) do
            ---@type CompositeAttribute
            local cls = Define.ATTR_CLASS[id]
            if not cls then
                Lib.logError("error:Not found the attribute class, attribute id:", id)
                cls = CompositeAttribute
            end
            ---@type CompositeAttribute
            local attribute = cls:new(id, baseValue)
            self.attributes[id] = attribute
        end
    end

    --- 派发属性改变事件
    for id, attribute in pairs(self.attributes) do
        self:onAttributeChange(id, true)
    end
end

--- 添加属性修饰
---@param id any 属性id
---@param bonus number 额外加成
---@param modType number 修饰器类型
---@param source any 源标记
function AttributeComponent:addBonus(id, bonus, modType, source)
    ---@type BaseAttribute
    local attribute = self.attributes[id]
    if attribute then
        attribute:addModifier(AttributeModifier:new(bonus, modType, modType, source))
        self:onAttributeChange(id)
        return true
    end
    return false
end

--- 移除源属性修饰
---@param source any
function AttributeComponent:removeAllModifiersFromSource(source)
    local success = false
    for id, attribute in pairs(self.attributes) do
        if attribute:removeAllModifiersFromSource(source) then
            self:onAttributeChange(id)
            success = true
        end
    end
    return success
end

--- 获取属性值
---@param id any
function AttributeComponent:getAttributeValue(id)
    ---@type BaseAttribute
    local attribute = self.attributes[id]
    if attribute then
        local value = attribute:getValue()
        local maxValue = AttributeInfoConfig:getMaxValue(id)
        local minValue = AttributeInfoConfig:getMinValue(id)
        if maxValue and minValue then
            return math.clamp(value, minValue, maxValue)
        elseif maxValue then
            return math.min(value, maxValue)
        elseif minValue then
            return math.max(value, minValue)
        end
        return value
    end
    return nil
end

--- 获取属性
---@param id any
---@return BaseAttribute
function AttributeComponent:getAttribute(id)
    return self.attributes[id] 
end

--- 设置当前属性等级
---@param id any
---@param level any
function AttributeComponent:setLevel(id, level)
    ---@type GrowthAttribute
    local attribute = self.attributes[id]
    if attribute and attribute:isGrowth() then
        if self.attributeData then
            self.attributeData:setLevel(id, level)
        end
        attribute:setLevel(level)
        self:onAttributeChange(id)
        return true
    end
    return false
end

--- 设置指定方案属性等级
---@param id any
---@param level any
---@param index any
function AttributeComponent:setLevelByIndex(id, level, index)
    if self.attributeData then
        self.attributeData:setLevelByIndex(id, level, index)
        if self.attributeData.idx == index then
            return self:setLevel(id, level)
        end
        return true
    end
    return false
end

--- 切换属性加成方案
---@param index any
function AttributeComponent:setIndex(index)
    if not self.attributeData then
        return false
    end
    self.attributeData.idx = index
    --- 设置属性等级
    for id, attribute in pairs(self.attributes) do
        if attribute:isGrowth() then
            attribute:setLevel(self:getLevel(id))
            self:onAttributeChange(id)
        end
    end
    return true
end

--- 设置加点方案解锁索引
---@return number 解锁索引
function AttributeComponent:setUnlockIndex(unlockIndex)
    if self.attributeData then
        self.attributeData.uidx = unlockIndex
        return true
    end
    return false
end

--- 获取加点方案索引
---@return number 方案索引
function AttributeComponent:getIndex()
    if self.attributeData then
        return self.attributeData.idx
    end
    return 1
end

--- 获取加点方案解锁索引
---@return number 解锁索引
function AttributeComponent:getUnlockIndex()
    if self.attributeData then
        return self.attributeData.uidx
    end
    return 1
end

--- 获取加点方案
---@return table 加点方案
function AttributeComponent:getLevelDataByIndex(index)
    if self.attributeData then
        return self.attributeData.data[index]
    end
    return nil
end

--- 获取当前方案属性等级
---@param id string 属性id
---@return number 等级
function AttributeComponent:getLevel(id)
    if self.attributeData then
        return self.attributeData:getLevel(id)
    end
    return 1
end

--- 反序列化
---@param data AttributeData
function AttributeComponent:deserialize(data)
    if self.attributeData then
        self.attributeData:deserialize(data)
        --- 设置属性等级
        for id, attribute in pairs(self.attributes) do
            if attribute:isGrowth() then
                attribute:setLevel(self:getLevel(id))
                self:onAttributeChange(id)
            end
        end
    end
end

--- 序列化数据
---@return AttributeData
function AttributeComponent:serialize()
    if self.attributeData then
        return self.attributeData:serialize()
    end
    return {}
end

--- 获取属性数据
---@return AttributeData
function AttributeComponent:getAttributeData()
    return self.attributeData
end

--- 清空属性数据
---@param index any
function AttributeComponent:clearAttributeData(index)
    local data = self.attributeData.data
    if data[index] then
        data[index] = {}
        if self.attributeData.idx == index then
            --- 设置属性等级
            for id, attribute in pairs(self.attributes) do
                if attribute:isGrowth() then
                    attribute:setLevel(self:getLevel(id))
                    self:onAttributeChange(id)
                end
            end
        end
        return true
    end
    return false
end

--- 属性改变
---@param id any
---@param notRecursion boolean 是否递归，防止死循环
function AttributeComponent:onAttributeChange(id, notRecursion)
    if not self.attributes[id] then
        return
    end
    Lib.emitEvent(Event.EVENT_GAME_ROLE_COMMON_ATTRIBUTE_CHANGE, self.owner, id)
    ---@type BaseAttribute
    local target = self.attributes[id]
    if target:isGrowth() and not notRecursion then
        ---@type string, CompositeAttribute
        for attrId, attribute in pairs(self.attributes) do
            if attribute:isComposite() and attribute:retrieveAttribute(target) then
                self:onAttributeChange(attrId, true)
            end
        end
    end
end

return AttributeComponent