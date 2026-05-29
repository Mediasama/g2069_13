--- attribute_component.lua
--- 战斗组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type AttributeComponent
local AttributeComponent = require "common.component.attribute_component"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@class AttributeComponentServer : AttributeComponent
local AttributeComponentServer = class("AttributeComponentServer", AttributeComponent)

function AttributeComponentServer:initialize(owner)
    self.isInitedValue = false
    AttributeComponent.initialize(self, owner)
    --- 同步数据
    self.bonus = {}
    self.bonusTimer = nil
    self.isInitedValue = true
end

--- 同步数据
---@param id any
---@param bonus any
---@param modType any
---@param source any
function AttributeComponentServer:syncBonus(add, source, id, bonus, modType)
    --- 如果不是玩家则不需要同步
    if not self.owner or not self.owner.isPlayer then
        return
    end

    if add then
        self.bonus[#self.bonus + 1] = { add = 1, source = source, id = id, bonus = bonus, modType = modType }
    else
        local len = #self.bonus
        if len > 0 then
            for i = len, 1, -1 do
                local data = self.bonus[i]
                if data.source == source then
                    if data.add == 1 then
                        table.remove(self.bonus, i)
                    else
                        return
                    end
                end
            end
        end
        self.bonus[#self.bonus + 1] = { add = 0, source = source }
    end

    if not self.bonusTimer then
        self.bonusTimer = LuaTimer:scheduleTicker(function()
            LuaTimer:cancel(self.bonusTimer)
            self.bonusTimer = nil
            if self.owner and self.owner:isValid() and #self.bonus > 0 then
                --- 同步数据
                self.owner:sendPacket({
                    pid = "S2CSyncAttributeBonus",
                    bonus = self.bonus,
                })
                self.bonus = {}
            end
        end, 1)
    end
end

--- 特殊属性处理
---@param id any
---@param value any
function AttributeComponentServer:onAttributeChange(id, notRecursion)
    --- 特殊属性处理
    if id == Define.ATTR.MOVE_SPEED then
        local moveSpeed = self:getAttributeValue(Define.ATTR.MOVE_SPEED)
        if moveSpeed ~= self.owner:prop("moveSpeed") then
            self.owner:setProp("moveSpeed", moveSpeed)
        end
    elseif id == Define.ATTR.JUMP_SPEED then
        local jumpSpeed = self:getAttributeValue(Define.ATTR.JUMP_SPEED)
        if jumpSpeed ~= self.owner:prop("jumpSpeed") then
            self.owner:setProp("jumpSpeed", jumpSpeed)
        end
    elseif id == Define.ATTR.MAX_HP then
        local maxHp = self:getAttributeValue(Define.ATTR.MAX_HP)
        if maxHp ~= self.owner:prop("maxHp") then
            self.owner:setProp("maxHp", maxHp)
        end
        if not self.isInitedValue or self.owner:getCurHp() > maxHp then
            self.owner:setCurHp(maxHp)
        end
    elseif id == Define.ATTR.MAX_MP then
        local maxMp = self:getAttributeValue(Define.ATTR.MAX_MP)
        if not self.isInitedValue or self.owner:getCurMp() > maxMp then
            self.owner:setCurMp(maxMp)
        end
    end

    AttributeComponent.onAttributeChange(self, id, notRecursion)
end

--- 添加属性修饰
---@param id any 属性id
---@param bonus number 额外加成
---@param modType number 修饰器类型
---@param source any 源标记
function AttributeComponentServer:addBonus(id, bonus, modType, source)
    local success = AttributeComponent.addBonus(self, id, bonus, modType, source)
    --- 同步数据
    self:syncBonus(true, source, id, bonus, modType)
    return success
end

--- 移除源属性修饰
---@param source any
function AttributeComponentServer:removeAllModifiersFromSource(source)
    local success = AttributeComponent.removeAllModifiersFromSource(self, source)
    self:syncBonus(false, source)
    return success
end

--- 反序列化
---@param data AttributeData
function AttributeComponentServer:deserialize(data)
    self.isInitedValue = false
    AttributeComponent.deserialize(self, data)
    self.isInitedValue = true
end

return AttributeComponentServer