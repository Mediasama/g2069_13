---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class AttackParam : middleclass
---@field attacker number
---@field defender number
---@field dodge number
---@field crit number
---@field dead number
---@field damage number
---@field skillId number
---@field monster number monsterId
---@field exParam table
local AttackParam = class("AttackParam")

--- 初始化
---@param data AttackParam
function AttackParam:initialize(data)
    self.attacker = data and data.attacker or 0
    self.defender = data and data.defender or 0
    self.dodge = data and data.dodge or false
    self.crit = data and data.crit or false
    self.dead = data and data.dead or false
    self.damage = data and data.damage or 0
    self.skillId = data and data.skillId or 0
    self.monster = data and data.monster or 0
    self.exParam= data and data.exParam or nil
end

return AttackParam