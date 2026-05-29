---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type BattleSystem
local BattleSystem = T(Lib, "BattleSystem")

---@type AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")

---@type WalletSystem
local WalletSystem = T(Lib, "WalletSystem")


---@type GameLib
local GameLib = T(Lib, "GameLib")

local ReportAttr = T(Config, "ReportAttr")

local daySec = 24 * 60 * 60
local minSec = 60

------------------- begin 公共属性 -----------------------
--- 角色等级
---@param player Entity
---@return number
function ReportAttr.role_level(player)
    local level = GrowthSystem:getLevel(player)
    return level
end

--- 角色战斗力
---@param player Entity
---@return number
function ReportAttr.role_battle_power(player)
    local cp = BattleSystem:getCombatPower(player)
    return cp
end

--- 当前装备能力别称
---@param player Entity
---@return string
function ReportAttr.ability_id_alias(player)
    ---@type Ability
    local ability = AbilitySystem:getAbility(player)
    if ability then
        return ability:getItemAlias()
    end
    return "unknown"
end

--- 当前装备能力等级
---@param player Entity
---@return number
function ReportAttr.ability_level(player)
    ---@type Ability
    local ability = AbilitySystem:getAbility(player)
    if ability then
        return ability:getLevel() or 1
    end
    return 1
end

--- 当前剩余属性点
---@param player Entity
---@return number
function ReportAttr.remain_attribute_points(player)
    local point = AttributeSystem:getRemainPoint(player)
    return point
end

--- 当前二级属性点,格式如health=100,attack=99,defence=0
---@param player Entity
---@return string
function ReportAttr.sec_attribute_points(player)
    local str = nil
    local attributes = AttributeInfoConfig:getAttributesByType(2)
    if attributes then
        for _, config in pairs(attributes) do
            local attrId = config.attr_id
            ---@type GrowthAttribute
            local attribute = AttributeSystem:getAttribute(player, attrId)
            if attribute then
                if not str then
                    str = attrId .. "=" .. tostring(attribute:getLevel() - 1)
                else
                    str = str .. "," .. (attrId .. "=" .. tostring(attribute:getLevel() - 1))
                end
            end
        end
    end
    return str or ""
end

--- 生命等级
---@param player Entity
function ReportAttr.health_level(player)
    return AttributeSystem:getLevel(player, Define.ATTR.HEALTH) or 1
end

--- 物理攻击等级
---@param player Entity
function ReportAttr.attack_level(player)
    return AttributeSystem:getLevel(player, Define.ATTR.ATTACK) or 1
end

--- 元素攻击等级
---@param player Entity
function ReportAttr.ele_attack_level(player)
    return AttributeSystem:getLevel(player, Define.ATTR.ELEMENT_ATTACK) or 1
end

--- 精力等级
---@param player Entity
function ReportAttr.energy_level(player)
    return AttributeSystem:getLevel(player, Define.ATTR.ENERGY) or 1
end

--- 当前主线任务ID
---@param player Entity
---@return number
function ReportAttr.main_task_id(player)
    local mainTask = player:getMainTask()
    for taskId, _ in pairs(mainTask) do
        return taskId
    end
    return 0
end

--- 当前支线任务ID
---@param player Entity
---@return number
function ReportAttr.side_task_id(player)
    local result = ""
    local branchTask = player:getBranchTask()
    for taskId, _ in pairs(branchTask) do
        result = result .. taskId .. ","
    end
    return result
end

--- 当前加点方案
---@param player Entity
---@return number
function ReportAttr.points_solution(player)
    ---@type AttributeData
    local attributeData = AttributeSystem:getAttributeData(player)
    if attributeData then
        return attributeData.idx or 1
    end
    return 1
end

--- 当前解锁方案数量
---@param player Entity
---@return number
function ReportAttr.points_solution_count(player)
    ---@type AttributeData
    local attributeData = AttributeSystem:getAttributeData(player)
    if attributeData then
        return attributeData.uidx or 1
    end
    return 1
end

--- 当前地图名称
---@param player Entity
---@return string
function ReportAttr.map(player)
    local map = player.map
    if map then
        return map.name or "unknown"
    end
    return World.cfg.defaultMap
end

--- 当前坐标
---@param player Entity
---@return string
function ReportAttr.coordiantes(player)
    ---@type Vector3
    local position = player:getPosition()
    local x = GameLib.keepPreciseDecimal(position.x, 1)
    local y = GameLib.keepPreciseDecimal(position.y, 1)
    local z = GameLib.keepPreciseDecimal(position.z, 1)
    local str = "x:" .. x .. " y:" .. y .. " z:" .. z
    return str
end

--- 今天游玩时间
---@param player Entity
---@return number 单位秒
function ReportAttr.today_play_time(player)
    local curTime = os.time()
    local lastLoginTime = player:getLastLoginTime()
    if lastLoginTime == 0 then
        lastLoginTime = player:getRegisterTime()
    end
    local addPlayTime = math.max(curTime - lastLoginTime, 0)
    return math.ceil(addPlayTime / minSec)
end

--- 总计游玩时间
---@param player Entity
---@return number 单位秒
function ReportAttr.total_play_time(player)
    local curTime = os.time()
    local lastLoginTime = player:getLastLoginTime()
    if lastLoginTime == 0 then
        lastLoginTime = player:getRegisterTime()
    end
    local addPlayTime = math.max(curTime - lastLoginTime, 0)
    local totalPlayTime = player:getTotalPlayTime() + addPlayTime
    return math.ceil(totalPlayTime / minSec)
end

--- 玩家活跃自然日
---@param player Entity
---@return number 单位天
function ReportAttr.activity_day(player)
    local curTime = os.time()
    local data = player:getActiveDayData()
    local day = 1
    if data and data.time then
        local time = data.time
        if Lib.isSameDay(time, curTime) then
            day = math.max(1, data.day)
        else
            local addDay = 0
            for i = 1, 100, 1 do
                curTime = curTime - daySec
                addDay = addDay + 1
                if curTime < time or Lib.isSameDay(time, curTime) then
                    break
                end
            end
            day = math.max(data.day + addDay, 1)
        end
    end
    return day
end

------------------- end 公共属性 -----------------------


--- 总游戏时长(hour)
---@param player Entity
---@return int
function ReportAttr.int_play_time(player)
    local loginTs = player:getLoginTs()
    local curPlayTime = os.time() - loginTs
    local curPlayHour =  math.floor(curPlayTime/60/60*10)/10 or 0
    local curTotalTime = player:getNewAllPlayTime()
    return math.floor((curTotalTime + curPlayHour)*10)
end

--- 总游戏时长(hour)
---@param player Entity
---@return string
function ReportAttr.string_play_time(player)
    local loginTs = player:getLoginTs()
    local curPlayTime = os.time() - loginTs
    local curPlayHour =  math.floor(curPlayTime/60/60*10)/10 or 0
    local curTotalTime = player:getNewAllPlayTime() or 0
    return tostring(curTotalTime + curPlayHour)
end

--- 本局击杀怪物次数
---@param player Entity
---@return int
function ReportAttr.count_kill_monster(player)
    return player:getCountKillMonster()
end

--- 本局击杀boss次数
---@param player Entity
---@return int
function ReportAttr.count_kill_boss(player)
    return player:getCountKillBoss()
end

--- 本局被怪物击杀次数
---@param player Entity
---@return int
function ReportAttr.count_killed_monster(player)
    return player:getCountKilledMonster()
end

--- 本局击杀玩家次数
---@param player Entity
---@return int
function ReportAttr.count_kill_other(player)
    return player:getCountKillOther()
end

--- 本局被玩家击杀次数
---@param player Entity
---@return int
function ReportAttr.count_killed_other(player)
    return player:getCountKilledOther()
end

--- 总危险指数
---@param player Entity
---@return int
function ReportAttr.total_danger_exp(player)
    return player:getDangerValue()
end

--- 总危险指数-string
---@param player Entity
---@return string
function ReportAttr.string_danger_exp(player)
    local dangerVal = player:getDangerValue()
    return tostring(dangerVal)
end

--- 当前金币数量
---@param player Entity
---@return number
function ReportAttr.role_gold_coin(player)
    local coin = WalletSystem:getCoin(player, Define.ITEM_ALIAS.GOLD_COIN) or 0
    return coin
end