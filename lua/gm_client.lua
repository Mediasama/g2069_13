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
    calc = { current = "0", op = nil, last = nil, win = nil },
    pro = { fov = 75 }
}
_G.CARS = CARS

-- [Core Helpers]
local function safeTimer(key, time, func)
    if CARS.timers[key] then CARS.timers[key]() CARS.timers[key] = nil end
    if func then CARS.timers[key] = World.Timer(time, func) end
end

local function safeHook(obj, name, newFunc)
    if not obj then return end
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

GMItem["[1] Combat/KillAura_AntiExploit"] = function()
    CARS.active.killAura = not CARS.active.killAura
    safeTimer("killAura", 5, function()
        if not CARS.active.killAura then return false end
        local targets = {}
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            local isVulnerable = ent:getSafeModeType() == Define.PKModeType.pk2 or ent:getPlayerIsInBattleState()
            if ent.isPlayer and isValidEnemy(ent, true) and (isVulnerable or Me:distance(ent) < 8) then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets }) end
        return true
    end)
    return "KillAura: " .. (CARS.active.killAura and "ON" or "OFF")
end

GMItem["[1] Combat/PK_God_Mode"] = function()
    CARS.active.pkGod = not CARS.active.pkGod
    if CARS.active.pkGod then
        safeHook(Skill, "Cast", function(old, name, packet)
            if CARS.active.pkGod then
                Me:setSafeModeType(Define.PKModeType.pk2)
                safeTimer("pk_ret", 6, function() Me:setSafeModeType(Define.PKModeType.safe) end)
            end
            return old(name, packet)
        end)
    end
    return "PK Juggler: " .. (CARS.active.pkGod and "ACTIVE" or "OFF")
end

-- ==========================================
-- [2] MOVEMENT - ПЕРЕМЕЩЕНИЕ
-- ==========================================

GMItem["[2] Movement/Responsive_Flight"] = function()
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
    return "Vector Flight ACTIVE"
end

-- ==========================================
-- [9] PRO-CONFIG - ТРАЙХАРД РЕЖИМ
-- ==========================================

GMItem["[9] Pro/Unlock_Camera_Limits"] = function()
    local cam = Blockman.Instance()
    cam:setCameraDistanceMax(100)
    cam:setCameraDistanceMin(0)
    -- Pitch bypass for all view modes
    for i = 0, 4 do
        local info = cam:getCameraInfo(i)
        if info and info.viewCfg then
            info.viewCfg.minPitch = -89
            info.viewCfg.maxPitch = 89
        end
    end
    return "Camera Pitch Unlocked (-89 to 89)"
end

GMItem["[9] Pro/Wide_FOV_110"] = function()
    CARS.pro.fov = (CARS.pro.fov == 110) and 75 or 110
    Blockman.Instance():setViewFovAngle(CARS.pro.fov)
    return "FOV toggled to: " .. CARS.pro.fov
end

GMItem["[9] Pro/Drone_View_Toggle"] = function()
    CARS.active.drone = not CARS.active.drone
    Blockman.Instance():setCameraDistance(CARS.active.drone and 45 or 8)
    return "Drone Mode: " .. (CARS.active.drone and "ON" or "OFF")
end

GMItem["[9] Pro/Input_Latency_Fix"] = function()
    Blockman.instance.gameSettings:setCameraSensitive(1.25)
    return "Sensitivity Boosted (Fast Response)"
end

-- ==========================================
-- [0] SYSTEM - СЕРВИС
-- ==========================================

GMItem["[0] System/Clean_All"] = function()
    for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end
    if CARS.active.terminalWin then root:removeChild(CARS.active.terminalWin:getWindow()) end
    CARS.active = {}
    return "State Purged"
end

print("[System] Tryhard Pro-Config Integrated into CARS Suite")
return GMItem
