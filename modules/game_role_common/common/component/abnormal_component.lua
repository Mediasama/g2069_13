---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@class AbnormalComponent : middleclass
local AbnormalComponent = class("AbnormalComponent")

--- 初始化
---@param owner any
function AbnormalComponent:initialize(owner)
    self.owner = owner
    self.abnStatus = {}
end

--- 添加状态
---@param status any
function AbnormalComponent:addStatus(status)
    if self.abnStatus[status] then
        self.abnStatus[status] = self.abnStatus[status] + 1
    else
        self.abnStatus[status] = 1
    end
end

--- 移除状态
---@param status any
function AbnormalComponent:removeStatus(status)
    if self.abnStatus[status] then
        self.abnStatus[status] = self.abnStatus[status] - 1
        if self.abnStatus[status] <= 0 then
            self.abnStatus[status] = nil
        end
    end
end

--- 判断状态
---@param status any
---@return boolean
function AbnormalComponent:getStatus(status)
    if self.abnStatus[status] then
        return self.abnStatus[status] > 0
    end
    return false
end

--- 清除状态
---@param status any
function AbnormalComponent:clearStatus(status)
    self.abnStatus[status] = nil
end

return AbnormalComponent