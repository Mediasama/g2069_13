---@type middleclass
local class = require "common.3rd.middleclass.middleclass"

---@type BaseBuffAction
local BaseBuffAction = require "common.buff.action.base_buff_action"
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")
---@class ChangeAttribute : BaseBuffAction
local ChangeAttribute = class("ChangeAttribute", BaseBuffAction)

function ChangeAttribute:onAdded()
    self.attributes = nil
    self.attributePcts = nil
    self.curFrame = 0
    self.interval = 0
    ---@type BattleManagerServer
    local BattleManagerServer = require "server.manager.battle_manager"
    ---@type BattleManagerServer
    self.mgr = BattleManagerServer:instance()

    if self.holder and self.holder:isValid() then
        self.bonusSource = "buff-" .. self.id .. "-" .. self.buffActionId
        local config = self.cfg

        self.attributes = config.attribute
        self.attributePcts = config.attribute_pct
        self.interval = config.interval or 0

        if config.addHpPct or config.addHp then
            if self.interval == 0 then
                --- 立刻恢复
                self:changeCurHp({ pct = config.addHpPct, value = config.addHp })
            else
                self.addHp = { pct = config.addHpPct, value = config.addHp }
            end
        end

        if config.addMpPct or config.addMp then
            if self.interval == 0 then
                --- 立刻恢复
                self:changeCurMp({ pct = config.addMpPct, value = config.addMp }    )
            else
                self.addMp = { pct = config.addMpPct, value = config.addMp }        
            end
        end        

        if self.attributes then
            for id, value in pairs(self.attributes) do
                AttributeSystem:addBonus(self.holder, id, value, Define.ATTR_MOD_TYPE.RAW, self.bonusSource)
            end
        end

        if self.attributePcts then
            for id, value in pairs(self.attributePcts) do
                AttributeSystem:addBonus(self.holder, id, value, Define.ATTR_MOD_TYPE.PERCENTADD, self.bonusSource)
            end
        end
    end
end

--- 改变当前血量
---@param addHp any
function ChangeAttribute:changeCurHp(addHp)
    if self.holder and self.holder:isValid() and self.caster and self.caster:isValid() then
        local maxHp = AttributeSystem:getAttributeValue(self.holder, Define.ATTR.MAX_HP)
        local hp = 0
        if addHp.pct and addHp.pct ~= 0 then
            if addHp.pct > 0 then
                hp = hp + math.abs(maxHp * addHp.pct)
            else
                hp = hp - math.abs(maxHp * addHp.pct)
            end
        end
        if addHp.value and addHp.value ~= 0 then
            hp = hp + addHp.value
        end
        if hp > 0 then
            BattleSystem:changeHp(self.holder, hp)
        elseif hp < 0 then
            self.mgr:directAttack(self.caster, self.holder, -hp)
        end
    end
end

--- 改变当前mp
---@param addMp any
function ChangeAttribute:changeCurMp(addMp)
    if self.holder and self.holder:isValid() then
        local maxMp = AttributeSystem:getAttributeValue(self.holder, Define.ATTR.MAX_MP)
        local mp = 0
        if addMp.pct and addMp.pct ~= 0 then
            if addMp.pct > 0 then
                mp = mp + math.abs(maxMp * addMp.pct)
            else
                mp = mp - math.abs(maxMp * addMp.pct)
            end
        end

        if addMp.value and addMp.value ~= 0 then
            mp = mp + addMp.value
        end

        if mp ~= 0 then
            BattleSystem:changeMp(self.holder, mp)
        end
    end
end

function ChangeAttribute:onEnter()
    
end

---@param deltaTime any 时间间隔，单位秒
function ChangeAttribute:onTick(deltaTime)
    self.curFrame = self.curFrame + 1
    if self.addMp then
        if self.interval ~= 0 and self.curFrame % self.interval == 0 then
            --- 添加当前血量
            self:changeCurHp(self.addHp)
        end
    end
    if self.addMp then
        if self.interval ~= 0 and self.curFrame % self.interval == 0 then
            self:changeCurMp(self.addMp)
        end
    end
end

function ChangeAttribute:onExit()
    if self.holder and self.holder:isValid() then
        if self.attributes or self.attributePcts then
            AttributeSystem:removeAllModifiersFromSource(self.holder, self.bonusSource)
        end
        
    end
    self.holder = nil
    self.attributes = nil
    self.attributePcts = nil
    self.addMp = nil
    self.addHp = nil
    self.mgr = nil
end

return ChangeAttribute



