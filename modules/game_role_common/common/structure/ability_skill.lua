---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@class AbilitySkill : middleclass
---@field attack number 攻击技能
---@field sprint number 冲刺技能
---@field fly number   飞行技能
---@field AddFly number   额外飞行技能
---@field passives table 被动buff，数组
---@field skills table 主动技能，数组
local AbilitySkill = class("AbilitySkill")

--- 初始化
---@param data AbilitySkill
function AbilitySkill:initialize(data)
    self.attack = data and data.attack or 0
    self.sprint = data and data.sprint or 0
    self.passives = (data and data.passives) and Lib.copy(data.passives) or {}
    self.skills = (data and data.skills) and Lib.copy(data.skills) or {}
end

return AbilitySkill