local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local InventorySystem = T(Lib, "InventorySystem")

-- [CARS State & Lifecycle Management]
local CARS = {
    timers = {},
    hooks = {},
    active = {}
}

-- [Core Utilities]
local function isValidEnemy(ent)
    if not ent or not ent:isValid() or ent.objID == Me.objID then return false end
    return ent.isPlayer and ent.curHp > 0 and not ent:isInStateType(Define.RoleStatus.DEAD)
end

local function safeTimer(key, time, func)
    if CARS.timers[key] then CARS.timers[key]() CARS.timers[key] = nil end
    if func then CARS.timers[key] = World.Timer(time, func) end
end

local function safeHook(obj, name, newFunc)
    local hookKey = tostring(obj) .. name
    if CARS.hooks[hookKey] then return end
    CARS.hooks[hookKey] = obj[name]
    obj[name] = function(self, ...)
        return newFunc(CARS.hooks[hookKey], self, ...)
    end
end

-- ==========================================
-- 1. COMBAT & HITBOX MANIPULATION
-- ==========================================

GMItem["CARS/Combat/KillAura_360"] = function()
    CARS.active.killAura = not CARS.active.killAura
    safeTimer("killAura", 5, function()
        if not CARS.active.killAura then return false end
        local targets = {}
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) and Me:distance(ent) < 10 then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then
            Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets })
        end
        return true
    end)
    return "KillAura: " .. (CARS.active.killAura and "ON" or "OFF")
end

GMItem["CARS/Combat/No_Recovery_Frames"] = function()
    safeHook(Entity, "playAction", function(old, self, name, time)
        return old(self, name, 0.01) -- Force all actions to finish in 1 tick
    end)
    return "Recovery Frames Nuked"
end

GMItem["CARS/Combat/Anti_Knockback"] = function()
    safeHook(Entity, "enterStateType", function(old, self, state, ...)
        if state == Define.RoleStatus.BLOW_AWAY then return end
        return old(self, state, ...)
    end)
    return "Knockback Immune"
end

GMItem["CARS/Combat/Hitbox_Expander"] = GM:inputStr(function(_, val)
    local scale = tonumber(val) or 3.0
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if ent.isPlayer and ent.objID ~= Me.objID then
            ent:setProp("modelScale", scale)
        end
    end
    return "Hitboxes set to " .. scale
end, "3.0")

GMItem["CARS/Combat/Overclock_Skills"] = function()
    for _, cfg in pairs(SkillConfig:getAllCfgs()) do
        cfg.hitRange = 100
        cfg.skillCd = 0
        cfg.mpCost = 0
    end
    return "All Skills: 100m, 0 CD, 0 MP"
end

-- ==========================================
-- 2. MOVEMENT & MAP EXPLOITS
-- ==========================================

GMItem["CARS/Map/Voxel_Ghost_Mode"] = function()
    CARS.active.ghost = not CARS.active.ghost
    Me:setFlyMode(CARS.active.ghost and 1 or 0)
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not CARS.active.ghost)
    return "Ghost Mode: " .. (CARS.active.ghost and "ACTIVE" or "OFF")
end

GMItem["CARS/Map/Teleport_Treasure"] = function()
    for _, part in pairs(World.CurWorld:getAllStaticPart()) do
        if part.name:find("treasure") or part.name:find("chest") then
            Me:setPosition(part:getPosition())
            return "Teleported to " .. part.name
        end
    end
    return "No treasure found"
end

GMItem["CARS/Map/Speed_Overdrive"] = GM:inputStr(function(_, val)
    Me:setProp("moveSpeed", tonumber(val) or 1.2)
    return "Speed set to " .. val
end, "1.2")

GMItem["CARS/Map/Air_Walk"] = function()
    CARS.active.airWalk = not CARS.active.airWalk
    safeTimer("airWalk", 1, function()
        if not CARS.active.airWalk then return false end
        Me:setProp("gravity", 0)
        Me.motion.y = 0
        return true
    end)
end

GMItem["CARS/Map/Bypass_Distance"] = function()
    World.cfg.interactDistance = 9999
    return "Interact Distance: INFINITE"
end

-- ==========================================
-- 3. UI, VISUALS & ECONOMY
-- ==========================================

GMItem["CARS/Visual/Full_Bright"] = function()
    local timelight = T(Lib, "TimeLight")
    if timelight then timelight:SetAmbientIntensityInc(100) end
    return "Full Bright Active"
end

GMItem["CARS/Visual/Entity_ESP"] = function()
    CARS.active.esp = not CARS.active.esp
    safeTimer("esp", 40, function()
        if not CARS.active.esp then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) and not UI:isOpenWindow("esp_"..ent.objID) then
                UI:openSceneWindow("UI/scene_object/gui/widget_player_name", "esp_"..ent.objID, {target = ent}, "asset")
            end
        end
        return true
    end)
end

GMItem["CARS/Economy/Unlock_Shops"] = function()
    for i = 1, 30 do
        pcall(function() UI:openWindow("UI/game_business/gui/win_game_shop", "shop_"..i, nil, {shopId = i}) end)
    end
end

GMItem["CARS/Visual/Skin_Stealer"] = function()
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if ent.isPlayer and ent.objID ~= Me.objID then
            Me:setProp("actorName", ent:getProp("actorName"))
            return "Stolen appearance from " .. ent.name
        end
    end
end

-- ==========================================
-- 4. AUTOMATION & MACROS
-- ==========================================

GMItem["CARS/Auto/Vacuum_Loot"] = function()
    CARS.active.vacuum = not CARS.active.vacuum
    safeTimer("vacuum", 20, function()
        if not CARS.active.vacuum then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if ent.type == "drop_item" then
                Me:sendPacket({ pid = "C2SPickupItem", objID = ent.objID })
            end
        end
        return true
    end)
end

GMItem["CARS/Auto/Infinite_Potions"] = function()
    local sent = 0
    safeTimer("potions", 1, function()
        for i = 1, 20 do
            if sent >= 1000 then return false end
            Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = "hp_pct_5_buff_card" })
            sent = sent + 1
        end
        return true
    end)
end

GMItem["CARS/Auto/Auto_Heal_99"] = function()
    CARS.active.autoHeal = not CARS.active.autoHeal
    safeTimer("autoHeal", 10, function()
        if not CARS.active.autoHeal then return false end
        if Me:getCurHp() < Me:getMaxHp() then
            Me:sendPacket({ pid = "C2SUseItem", itemId = 13100001, id = 0 })
        end
        return true
    end)
end

-- ==========================================
-- 5. SHIELD & COMBO (CORE HOOKS)
-- ==========================================

GMItem["CARS/Shield/Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF")
end

GMItem["CARS/Combo/Turbo_Combo"] = function()
    Me.turboCombo = not Me.turboCombo
    return "Turbo Combo: " .. (Me.turboCombo and "ON" or "OFF")
end

GMItem["CARS/Combo/Always_Finisher"] = function()
    Me.alwaysFinisher = not Me.alwaysFinisher
    return "Instant Finisher: " .. (Me.alwaysFinisher and "ON" or "OFF")
end

GMItem["CARS/Skill/Infinite_Channeling"] = function()
    Me.infiniteMP = not Me.infiniteMP
    return "Infinite Channeling (No MP Stop): " .. (Me.infiniteMP and "ON" or "OFF")
end

print("[System] CARS Core Framework 1.1 Successfully Deployed")
return GMItem
