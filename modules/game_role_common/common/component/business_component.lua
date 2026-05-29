--- buff_component.lua
--- 属性组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@class BusinessComponent : middleclass
local BusinessComponent = class("BusinessComponent")

--- 初始化
---@param owner any
function BusinessComponent:initialize(owner)
    self.owner = owner
    self.purchaseData = {}
end

function BusinessComponent:addPurchaseData(shopId)
    self.purchaseData[shopId] = (self.purchaseData[shopId] or 0) + 1
end

function BusinessComponent:setPurchaseData(shopId, value)
    self.purchaseData[shopId] = value
end

function BusinessComponent:getPurchaseData(shopId)
    return self.purchaseData[shopId] or 0
end

--- 序列化
function BusinessComponent:serialize()
    local data = {}
    for shopId, num in pairs(self.purchaseData) do
        if num > 0 then
            data[shopId] = num
        end
    end
    return data
end

--- 反序列化
---@param data any
function BusinessComponent:deserialize(data)
    self.purchaseData = {}
    if data then
        for shopId, num in pairs(data) do
            self.purchaseData[shopId] = num
        end
    end
end

return BusinessComponent