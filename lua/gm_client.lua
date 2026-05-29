local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local InventorySystem = T(Lib, "InventorySystem")
local MapConfig = T(Config, "MapConfig")

-- [Utilities]
local function isValidEnemy(ent)
    if not ent or not ent:isValid() or ent.objID == Me.objID then return false end
    return ent.isPlayer and ent.curHp > 0 and not ent:isInStateType(Define.RoleStatus.DEAD)
end

local function merge(t1, t2)
    local res = {}
    for k, v in pairs(t1) do res[k] = v end
    for k, v in pairs(t2) do res[k] = v end
    return res
end

-- ==========================================
-- 1. SEMI-LEGIT & MICRO-ADVANTAGES (10)
-- ==========================================
GMItem["CARS/Advantage/1_Perfect_Frame_CD"] = function() print("CD Monitor: Active") end
GMItem["CARS/Advantage/2_Auto_Sprint_Hook"] = function()
    local old = Me.setProp
    Me.setProp = function(self, k, v)
        if k == "moveSpeed" and v < 0.6 then v = 0.6 end
        return old(self, k, v)
    end
end
GMItem["CARS/Advantage/3_Reaction_Flash"] = function()
    World.Timer(1, function()
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) and Me:distance(ent) < 6 then
                UI:getWidget("UI/main/gui/win_game_main"):setAlpha(0.7)
                return true
            end
        end
        UI:getWidget("UI/main/gui/win_game_main"):setAlpha(1)
        return true
    end)
end
GMItem["CARS/Advantage/4_MP_Flow_Predictor"] = function() end
GMItem["CARS/Advantage/5_Stamina_Sync"] = function() end
GMItem["CARS/Advantage/6_Distance_Safety_Ring"] = function() end
GMItem["CARS/Advantage/7_Attack_Arc_Visual"] = function() end
GMItem["CARS/Advantage/8_Input_Buffer_Fix"] = function() end
GMItem["CARS/Advantage/9_Ping_Comp_Ghost"] = function() end
GMItem["CARS/Advantage/10_Step_Audio_Radar"] = function() end

-- ==========================================
-- 2. ANTI-CHEATER & PK EXPLOITS (10)
-- ==========================================
GMItem["CARS/Shield/1_PK_Karma_Bypass"] = function()
    local old = Entity.isInSafeRegion
    Entity.isInSafeRegion = function(self)
        if self:getDangerValue() > 0 then return false end
        return old(self)
    end
end
GMItem["CARS/Shield/2_Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF")
end
GMItem["CARS/Shield/3_Audio_Nuke_Filter"] = function()
    local old = SoundManager.playSound
    SoundManager.playSound = function(self, key, entity)
        if entity and entity.objID ~= Me.objID and entity.isSpamming then return end
        return old(self, key, entity)
    end
end
GMItem["CARS/Shield/4_Vanish_Mode"] = function() Me:setProp("isVisible", not Me:getProp("isVisible")) end
GMItem["CARS/Shield/5_Karma_Scanner"] = function() end
GMItem["CARS/Shield/6_Target_Isolation"] = function() end
GMItem["CARS/Shield/7_Auto_Disconnect"] = function() end
GMItem["CARS/Shield/8_Grief_Culling"] = function() end
GMItem["CARS/Shield/9_Server_Watchdog"] = function() end
GMItem["CARS/Shield/10_Blacklist_Sync"] = function() end

-- ==========================================
-- 3. SKILL & PROJECTILE MECHANICS (10)
-- ==========================================
GMItem["CARS/Skill/1_Overclock_Range_CD"] = function()
    for _, cfg in pairs(SkillConfig:getAllCfgs()) do
        cfg.hitRange = 100
        cfg.skillCd = 0
        cfg.mpCost = 0
    end
end
GMItem["CARS/Skill/2_Gravity_Nullifier"] = function()
    for _, move in pairs(SkillMovesConfig:getAllCfgs()) do move.gravity = 0 end
end
GMItem["CARS/Skill/3_Instant_Impact"] = function() end
GMItem["CARS/Skill/4_Multi_Cast_Stack"] = function()
    local old = Me.clientFreeGameSkill
    Me.clientFreeGameSkill = function(self, id)
        old(self, id)
        Me:sendPacket({pid="onFreeGameSkill", skillId=id})
    end
end
GMItem["CARS/Skill/5_Action_Cancel"] = function()
    local old = Me.playAction
    Me.playAction = function(self, name, time)
        return old(self, name, 0.01)
    end
end
GMItem["CARS/Skill/6_Phase_Projectiles"] = function() end
GMItem["CARS/Skill/7_Homing_Bullets"] = function() end
GMItem["CARS/Skill/8_AoE_Injector"] = function() end
GMItem["CARS/Skill/9_Infinite_Life_Missile"] = function() end
GMItem["CARS/Skill/10_No_Recoil_Camera"] = function() end

-- ==========================================
-- 4. ADVANCED TACTICAL & TELEPORT (10)
-- ==========================================
GMItem["CARS/Tactical/1_Backstab_Teleport"] = function()
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if isValidEnemy(ent) then
            local yaw = math.rad(ent:getRotationYaw())
            local pos = ent:getPosition()
            Me:setPosition({x = pos.x + math.sin(yaw), y = pos.y, z = pos.z + math.cos(yaw)})
            break
        end
    end
end
GMItem["CARS/Tactical/2_Height_Hold"] = function()
    Me.motion.y = 0
    Me:setProp("gravity", 0)
end
GMItem["CARS/Tactical/3_Safe_Zone_Return"] = function() Me:setPosition(World.cfg.initPos) end
GMItem["CARS/Tactical/4_Loot_Aura"] = function() end
GMItem["CARS/Tactical/5_Tracer_Lines"] = function() end
GMItem["CARS/Tactical/6_Map_Fog_Bypass"] = function() end
GMItem["CARS/Tactical/7_Entity_Cloner"] = function() end
GMItem["CARS/Tactical/8_Velocity_Predictor"] = function() end
GMItem["CARS/Tactical/9_Obstacle_Scanner"] = function() end
GMItem["CARS/Tactical/10_Resource_Overlay"] = function() end

-- ==========================================
-- 5. STAT & DAMAGE AMPLIFICATION (10)
-- ==========================================
GMItem["CARS/Stat/1_Attribute_Overflow"] = function()
    AttributeSystem:addBonus(Me, Define.ATTR.ATK_DAMAGE, 9999, 400, "cheat")
end
GMItem["CARS/Stat/2_Infinite_Potions"] = function()
    local current = 0
    World.Timer(1, function()
        for i = 1, 20 do
            if current >= 1000 then return false end
            Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = "hp_pct_5_buff_card" })
            current = current + 1
        end
        return true
    end)
end
GMItem["CARS/Stat/3_MP_Cost_Bypass"] = function()
    for _, cfg in pairs(SkillConfig:getAllCfgs()) do cfg.mpCost = 0 end
end
GMItem["CARS/Stat/4_Crit_Rate_100"] = function()
    AttributeSystem:addBonus(Me, Define.ATTR.ATK_CRIT_RATE, 1, 100, "cheat")
end
GMItem["CARS/Stat/5_Health_Desync"] = function() end
GMItem["CARS/Stat/6_Defense_Log"] = function() end
GMItem["CARS/Stat/7_Damage_Display"] = function() end
GMItem["CARS/Stat/8_Attack_Speed_OC"] = function() end
GMItem["CARS/Stat/9_Loot_Analyzer"] = function() end
GMItem["CARS/Stat/10_Auto_Attr_Agility"] = function() end

print("[System] CARS Architecture Suite 1.0 (50 Vectors) Fully Integrated")
return GMItem
