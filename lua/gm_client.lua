local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local TaskConfig = T(Config, "TaskConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
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

GMItem["[1] Combat/18. Aim Assist (Camera Lock)"] = function()
    CARS.active.aimAssist = not CARS.active.aimAssist
    return "Aim Assist: " .. (CARS.active.aimAssist and "ON" or "OFF")
end

GMItem["[1] Combat/19. 360-Sweep Exploit"] = function()
    CARS.active.sweep = not CARS.active.sweep
    return "Sweep Exploit: " .. (CARS.active.sweep and "ON" or "OFF")
end

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

GMItem["[2] Movement/20. Enhanced Sprint (Joy-Aligned)"] = function()
    CARS.active.joySprint = not CARS.active.joySprint
    return "Joy Sprint: " .. (CARS.active.joySprint and "ON" or "OFF")
end

-- ==========================================
-- [Engine Hooks]
-- ==========================================

-- [Hook] Engine Core Rotation Interface
local GameSkillHelper = T(Lib, "GameSkillHelper")
safeHook(GameSkillHelper, "doGameSkillResult", function(old, self, freeEntity, skill, startPos, hitPos)
    if freeEntity.objID == Me.objID and (CARS.active.aimAssist or CARS.active.sweep) then
        local bm = Blockman.Instance()
        local camYaw = bm:getViewerYaw()
        safeHook(freeEntity, "getRotationYaw", function() return camYaw end)
        local res = old(self, freeEntity, skill, startPos, hitPos)
        freeEntity.getRotationYaw = CARS.hooks[tostring(freeEntity).."getRotationYaw"]
        CARS.hooks[tostring(freeEntity).."getRotationYaw"] = nil
        return res
    end
    return old(self, freeEntity, skill, startPos, hitPos)
end)

-- [Hook] Camera-Decoupled Origin & Pitch Aiming
safeHook(GameSkillHelper, "doFreeSkillContent", function(old, self, freeEntity, skill, context)
    if freeEntity.objID == Me.objID and CARS.active.aimAssist then
        skill.bulletPitch = -Blockman.Instance():getViewerPitch()
        context = context or {}
        context.startPos = Blockman.Instance():getViewerPos()
    end
    return old(self, freeEntity, skill, context)
end)

-- [Hook] Sprint/Dash Joystick Compromise
local SprintSkillHelper = T(Lib, "SprintSkillHelper")
safeHook(Me, "moveUntilCollide", function(old, self, movePos)
    if CARS.active.joySprint and self.objID == Me.objID and self:isInStateType(Define.RoleStatus.SPRINT) then
        local bm = Blockman.Instance()
        local pf = bm.gameSettings.poleForward
        local ps = bm.gameSettings.poleStrafe
        if math.abs(pf) > 0.1 or math.abs(ps) > 0.1 then
            local yaw = math.rad(bm:getViewerYaw())
            local speed = movePos:len()
            local moveVec = Lib.v3(ps*math.cos(yaw)-pf*math.sin(yaw), 0, ps*math.sin(yaw)+pf*math.cos(yaw))
            movePos = moveVec:normalize() * speed
            movePos.y = 0 -- Keep it horizontal
        end
    end
    return old(self, movePos)
end)

-- [Hook] Disable Camera Shake & Vibrations
local GameCameraControl = T(Lib, "GameCameraControl")
safeHook(GameCameraControl, "tryShakeCamera", function() return end)
safeHook(GameCameraControl, "shakeCamera", function() return end)
safeHook(Entity, "clientVibratorOnTime", function() return end)

-- [Hook] Skill Casting Vector Logic
safeHook(Lib, "rotate", function(old, pos, rotation)
    if CARS.active.aimAssist and rotation and rotation.y then
        rotation.y = -Blockman.Instance():getViewerYaw()
    end
    return old(pos, rotation)
end)

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

-- [Hook] Global LockBodyRotation Override
safeHook(Player, "setPlayerBodyRotation", function(old, self, value, priority)
    if self.objID == Me.objID then
        -- Force lockBodyRotation to FALSE always for responsive kiting
        Blockman.instance.gameSettings:setLockBodyRotation(false)
        return
    end
    return old(self, value, priority)
end)

-- Initialize other placeholder items
for i=1, 20 do
    local cat = (i % 3 == 0) and "[1] Combat/" or ((i % 3 == 1) and "[2] Movement/" or "[3] Utility/")
    if not GMItem[cat .. "Feature_" .. i] then
        GMItem[cat .. "Feature_" .. i] = function() return "Module " .. i .. " OK" end
    end
end

print("[CARS 2.2] Architecture Compromise: Joy-Sprint, No-Shake, No-Collision")
return GMItem
