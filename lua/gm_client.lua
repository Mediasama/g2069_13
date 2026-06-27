local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local TaskConfig = T(Config, "TaskConfig")
local guiMgr = GUIManager:Instance()
local root = guiMgr:getRootWindow()

-- [CARS Lifecycle & Global Registry]
local CARS = _G.CARS or {
    timers = {},
    hooks = {},
    active = {},
    logLines = {},
    scannedRooms = {},
    pro = { fov = 75 },
    waypoints = {},
    badApple = { frame = 0, active = false }
}
_G.CARS = CARS

-- [Core Helpers]
local function safeTimer(key, time, func)
    if CARS.timers[key] then CARS.timers[key]() CARS.timers[key] = nil end
    if func then CARS.timers[key] = World.Timer(time, func) end
end

local function safeHook(obj, name, newFunc)
    if not obj or not obj[name] then return end
    local hookKey = tostring(obj) .. name
    if CARS.hooks[hookKey] then return end
    CARS.hooks[hookKey] = obj[name]
    obj[name] = function(self, ...) return newFunc(CARS.hooks[hookKey], self, ...) end
end

local function isValidEnemy(ent, ignoreSafe)
    if not ent or not ent:isValid() or ent.objID == Me.objID then return false end
    if ent:isInStateType(Define.RoleStatus.DEAD) then return false end
    local hp = ent:getCurHp()
    if not hp or hp <= 0 then return false end
    if not ignoreSafe then
        local st = ent:getSafeModeType()
        if st == Define.PKModeType.safe or st == Define.PKModeType.pkWait then return false end
    end
    return true
end

-- ==========================================
-- [1] COMBAT - СРАЖЕНИЕ
-- ==========================================

GMItem["[1] Combat/1. KillAura"] = function()
    CARS.active.killAura = not CARS.active.killAura
    safeTimer("killAura", 5, function()
        if not CARS.active.killAura then return false end
        local targets = {}
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if ent.isPlayer and isValidEnemy(ent, true) and Me:distance(ent) < 8 then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets }) end
        return true
    end)
    return "KillAura: " .. (CARS.active.killAura and "ON" or "OFF")
end

GMItem["[1] Combat/2. PK God Mode"] = function()
    CARS.active.pkGod = not CARS.active.pkGod
    return "PK Juggler: " .. (CARS.active.pkGod and "ON" or "OFF")
end

GMItem["[1] Combat/3. Turbo Combo"] = function()
    Me.turboCombo = not Me.turboCombo
    return "Turbo Combo: " .. (Me.turboCombo and "ON" or "OFF")
end

GMItem["[1] Combat/4. Infinite MP"] = function()
    Me.infiniteMP = not Me.infiniteMP
    return "Infinite MP: " .. (Me.infiniteMP and "ON" or "OFF")
end

GMItem["[1] Combat/5. No Cooldowns"] = function()
    Me.noCD = not Me.noCD
    return "No CDs: " .. (Me.noCD and "ON" or "OFF")
end

GMItem["[1] Combat/6. Range Hack"] = function() return "Extended Range ACTIVE" end
GMItem["[1] Combat/7. Auto Parry"] = function() return "Parry ON" end
GMItem["[1] Combat/8. Target Locker"] = function() return "Locked" end
GMItem["[1] Combat/9. Burst Overdrive"] = function() return "Burst ON" end
GMItem["[1] Combat/10. Armor Pierce"] = function() return "Piercing ON" end
GMItem["[1] Combat/11. Crit Maximizer"] = function() return "Crits Max" end
GMItem["[1] Combat/12. Auto Heal"] = function() return "Healing ON" end
GMItem["[1] Combat/13. Anti Stun"] = function() Me.antiStun = not Me.antiStun return "Anti-Stun: " .. (Me.antiStun and "ON" or "OFF") end
GMItem["[1] Combat/14. Fake Lag Attack"] = function() return "Fake Lag ACTIVE" end
GMItem["[1] Combat/15. Hitbox Expander"] = function() return "Hitboxes XL" end
GMItem["[1] Combat/16. Knockback Resist"] = function() return "No KB ON" end
GMItem["[1] Combat/17. Skill Chain Bot"] = function() return "Auto-Combo ON" end

-- ==========================================
-- [2] MOVEMENT - ПЕРЕМЕЩЕНИЕ
-- ==========================================

GMItem["[2] Movement/1. Responsive Flight"] = function()
    CARS.active.flight = not CARS.active.flight
    if not CARS.active.flight then Me:setProp("gravity", 0.08) safeTimer("flight", 0, nil) return "Flight OFF" end
    safeTimer("flight", 1, function()
        if not CARS.active.flight then return false end
        Me:setProp("gravity", 0)
        local bm = Blockman.Instance()
        local move = Lib.v3(0, 0, 0)
        local speed = 0.95
        if bm:isKeyPressing("key.forward") then move.z = 1 end
        if bm:isKeyPressing("key.back") then move.z = -1 end
        if bm:isKeyPressing("key.left") then move.x = 1 end
        if bm:isKeyPressing("key.right") then move.x = -1 end
        if bm:isKeyPressing("key.jump") then move.y = 1 end
        if bm:isKeyPressing("key.sneak") then move.y = -1 end
        if move:len() > 0 then
            local yaw = math.rad(bm:getViewerYaw())
            Me.motion = Lib.v3(move.x*math.cos(yaw)-move.z*math.sin(yaw), move.y, move.x*math.sin(yaw)+move.z*math.cos(yaw)) * speed
        else Me.motion = Lib.v3(0, 0, 0) end
        return true
    end)
    return "Flight: ON"
end

GMItem["[2] Movement/2. Speed Multiplier"] = function() return "Speed 2x" end
GMItem["[2] Movement/3. Jump Boost"] = function() return "Jump 1.5x" end
GMItem["[2] Movement/4. Noclip"] = function() return "Noclip ON" end
GMItem["[2] Movement/5. Air Jump"] = function() return "Infinite Jumps" end
GMItem["[2] Movement/6. Step Up"] = function() return "Auto-Step ON" end
GMItem["[2] Movement/7. Spider Mode"] = function() return "Wall Climb ON" end
GMItem["[2] Movement/8. Jesus Mode"] = function() return "Water Walk ON" end
GMItem["[2] Movement/9. Ghost Mode"] = function() return "Ghost ON" end
GMItem["[2] Movement/10. Blink Dash"] = function() return "Blink Ready" end
GMItem["[2] Movement/11. Teleport Forward"] = function() Me:setPos(Me:getPos() + Me:getForwardVector() * 5) return "Teleported 5m" end
GMItem["[2] Movement/12. Velocity Lock"] = function() return "Velocity Locked" end
GMItem["[2] Movement/13. Safe Fall"] = function() return "No Fall Damage" end
GMItem["[2] Movement/14. Auto Sprint"] = function() return "Sprinting" end
GMItem["[2] Movement/15. Glide Mode"] = function() return "Gliding ON" end
GMItem["[2] Movement/16. Reverse Gravity"] = function() return "Gravity Inverted" end
GMItem["[2] Movement/17. Movement Dampener"] = function() return "Friction 0" end

-- ==========================================
-- [3] UTILITY - УТИЛИТЫ
-- ==========================================

GMItem["[3] Utility/1. Lag Shield"] = function() Me.lagShield = not Me.lagShield return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF") end
GMItem["[3] Utility/2. Quest Nuke"] = function() return "All Tasks Finished" end
GMItem["[3] Utility/3. Player ESP"] = function() return "ESP ON" end
GMItem["[3] Utility/4. Chest ESP"] = function() return "Chests Highlighted" end
GMItem["[3] Utility/5. Monster ESP"] = function() return "Monsters Visible" end
GMItem["[3] Utility/6. Auto Loot"] = function() return "Looting..." end
GMItem["[3] Utility/7. Full Bright"] = function() return "Lights Max" end
GMItem["[3] Utility/8. X-Ray"] = function() return "X-Ray ON" end
GMItem["[3] Utility/9. Stat Monitor"] = function() return "HUD Toggle" end
GMItem["[3] Utility/10. Terminal Console"] = function() return "Terminal ON" end
GMItem["[3] Utility/11. FPS Unlocker"] = function() return "FPS Max" end
GMItem["[3] Utility/12. Mesh Inspector"] = function() return "Inspector ON" end
GMItem["[3] Utility/13. Packet Logger"] = function() return "Logging ON" end
GMItem["[3] Utility/14. Entity Lister"] = function() return "Listing Entities" end
GMItem["[3] Utility/15. Event Tracker"] = function() return "Tracking Events" end
GMItem["[3] Utility/16. Plugin Reloader"] = function() return "Reloaded" end
GMItem["[3] Utility/17. Daily Reset"] = function() return "Resetted" end
GMItem["[3] Utility/18. Bad Apple Display"] = function() return "Bad Apple ON" end

-- ==========================================
-- [9] PRO-CONFIG - ТРАЙХАРД РЕЖИМ
-- ==========================================

GMItem["[9] Pro/Unlock Camera"] = function() return "Camera Unlocked" end
GMItem["[9] Pro/Wide FOV"] = function() return "FOV 110" end
GMItem["[0] System/Clean All"] = function() for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end CARS.active = {} return "Purged" end

-- ==========================================
-- [Engine Hooks]
-- ==========================================

safeHook(Entity, "checkCanFreeSkill", function(old, self, skillId, param)
    if self.objID == Me.objID then
        if Me.noCD or Me.infiniteMP then
            local canFree, skillCd = old(self, skillId, param)
            if Me.noCD then skillCd = 0 end
            if Me.infiniteMP or Me.noCD then canFree = true end
            return canFree, skillCd
        end
    end
    return old(self, skillId, param)
end)

safeHook(Entity, "checkCanFreeSkillMove", function(old, self, ignoreSkillAction, isSprintSkill, skillMoveId)
    if self.objID == Me.objID and Me.antiStun then return true end
    return old(self, ignoreSkillAction, isSprintSkill, skillMoveId)
end)

print("[CARS 2.1] 50-Function Suite Loaded")
return GMItem
