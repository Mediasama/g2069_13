local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local InventorySystem = T(Lib, "InventorySystem")
local TaskConfig = T(Config, "TaskConfig")
local guiMgr = GUIManager:Instance()
local root = guiMgr:getRootWindow()

-- [CARS Lifecycle & State Management]
local CARS = {
    timers = {},
    hooks = {},
    active = {},
    scannedRooms = {}, -- Store room IDs and leaders
    calc = { current = "0", op = nil, last = nil, win = nil }
}

-- [Core Utilities]
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

local function safeTimer(key, time, func)
    if CARS.timers[key] then CARS.timers[key]() CARS.timers[key] = nil end
    if func then CARS.timers[key] = World.Timer(time, func) end
end

local function safeHook(obj, name, newFunc)
    if not obj then return end
    local hookKey = tostring(obj) .. name
    if CARS.hooks[hookKey] then return end
    CARS.hooks[hookKey] = obj[name]
    obj[name] = function(self, ...)
        return newFunc(CARS.hooks[hookKey], self, ...)
    end
end

-- ==========================================
-- [1] COMBAT - БОЕВАЯ СИСТЕМА
-- ==========================================

GMItem["[1] Combat/KillAura_PK_Punisher"] = function()
    CARS.active.killAura = not CARS.active.killAura
    safeTimer("killAura", 5, function()
        if not CARS.active.killAura then return false end
        local targets = {}
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            -- Target if vulnerable (PK mode/Battling) OR within tight range regardless of status
            local isVulnerable = ent:getSafeModeType() == Define.PKModeType.pk2 or ent:getPlayerIsInBattleState()
            if ent.isPlayer and isValidEnemy(ent, true) and (isVulnerable or Me:distance(ent) < 7) then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then
            Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets })
        end
        return true
    end)
    return "KillAura (Anti-Cheat): " .. (CARS.active.killAura and "ON" or "OFF")
end

GMItem["[1] Combat/PK_God_Mode"] = function()
    CARS.active.pkGod = not CARS.active.pkGod
    if CARS.active.pkGod then
        safeHook(Skill, "Cast", function(old, name, packet)
            if CARS.active.pkGod then
                Me:setSafeModeType(Define.PKModeType.pk2) -- Vulnerability window opens
                safeTimer("pk_ret", 6, function() Me:setSafeModeType(Define.PKModeType.safe) end) -- Closes after 300ms
            end
            return old(name, packet)
        end)
    end
    return "PK State Juggler: " .. (CARS.active.pkGod and "ACTIVE" or "OFF")
end

GMItem["[1] Combat/Turbo_Combo"] = function()
    Me.turboCombo = not Me.turboCombo
    return "Combo Cooldown Bypass: " .. (Me.turboCombo and "ON" or "OFF")
end

GMItem["[1] Combat/Always_Finisher"] = function()
    Me.alwaysFinisher = not Me.alwaysFinisher
    return "Forced Final Stage: " .. (Me.alwaysFinisher and "ON" or "OFF")
end

GMItem["[1] Combat/Infinite_Channeling"] = function()
    Me.infiniteMP = not Me.infiniteMP
    return "Skill MP Exhaustion Bypass: " .. (Me.infiniteMP and "ON" or "OFF")
end

-- ==========================================
-- [2] MOVEMENT - ПЕРЕМЕЩЕНИЕ
-- ==========================================

GMItem["[2] Movement/Responsive_Flight"] = function()
    CARS.active.flight = not CARS.active.flight
    if not CARS.active.flight then
        Me:setProp("gravity", 0.08)
        safeTimer("flight", 0, nil)
        return "Flight OFF"
    end
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
            local rotatedMove = Lib.v3(move.x*math.cos(yaw)-move.z*math.sin(yaw), move.y, move.x*math.sin(yaw)+move.z*math.cos(yaw))
            Me.motion = rotatedMove * speed
        else
            Me.motion = Lib.v3(0, 0, 0)
        end
        return true
    end)
    return "Direct Vector Flight ACTIVE"
end

-- ==========================================
-- [3] RAIDS - РЕЙДЫ И МИССИИ
-- ==========================================

GMItem["[3] Raids/Reset_Daily_Limits"] = function()
    Me:sendPacket({ pid = "C2SGMResetMissionCounts" })
    return "Daily limit (10/10) reset to 0."
end

GMItem["[3] Raids/Room_ID_Scanner"] = function()
    CARS.active.scanner = not CARS.active.scanner
    if CARS.active.scanner then
        safeHook(Player.PackageHandlers, "S2CMissionTeammateCanSelect", function(old, self, packet)
            local lead = packet.playerList[1] and packet.playerList[1].name or "Unknown"
            print("[SCANNER] Found Raid! RoomID:", packet.missionId, "Host:", lead)
            CARS.scannedRooms[packet.missionId] = lead
            return old(self, packet)
        end)
        return "Scanner: ON (Check console for IDs)"
    end
    return "Scanner: OFF"
end

GMItem["[3] Raids/Show_Scanned_Rooms"] = function()
    local list = "Active Raid Rooms:\n"
    for id, lead in pairs(CARS.scannedRooms) do
        list = list .. string.format("- ID: %s (Host: %s)\n", id, lead)
    end
    print(list)
    return "Logged room list to console."
end

GMItem["[3] Raids/Join_Room_BY_ID"] = GM:inputStr(function(_, roomId)
    Me:sendPacket({ pid = "C2SEnterMission", roomId = roomId })
    return "Attempting to breach instance: " .. roomId
end, "RoomID")

-- ==========================================
-- [4] LEVELING - ПРОКАЧКА
-- ==========================================

GMItem["[4] Leveling/Quest_Nuke_All"] = function()
    local allTasks = TaskConfig:getAllCfgs()
    for id, _ in pairs(allTasks) do
        Me:sendPacket({ pid = "C2SCompleteTask", taskId = id })
    end
    return "Sent completion for all game quests."
end

GMItem["[4] Leveling/Exp_Packet_Storm"] = function()
    CARS.active.expSpam = not CARS.active.expSpam
    if not CARS.active.expSpam then return "Storm Stopped" end
    local sent = 0
    safeTimer("exp_storm", 1, function()
        if not CARS.active.expSpam then return false end
        for i = 1, 40 do
            if sent >= 10000 then CARS.active.expSpam = false return false end
            Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = "role_exp" })
            sent = sent + 1
        end
        return true
    end)
    return "EXP Storm: ACTIVE"
end

-- ==========================================
-- [5] APPS & TOOLS - ПРИЛОЖЕНИЯ
-- ==========================================

local function updateCalc(val)
    if not CARS.calc.win then return end
    local display = CARS.calc.win:child("Display")
    if val == "C" then CARS.calc.current = "0" CARS.calc.op = nil CARS.calc.last = nil
    elseif tonumber(val) then
        if CARS.calc.current == "0" then CARS.calc.current = val else CARS.calc.current = CARS.calc.current .. val end
    elseif val == "=" then
        if CARS.calc.op and CARS.calc.last then
            local res, err = pcall(loadstring("return "..CARS.calc.last..CARS.calc.op..CARS.calc.current))
            CARS.calc.current = res and tostring(err) or "Error"
            CARS.calc.op = nil CARS.calc.last = nil
        end
    else
        CARS.calc.op = val CARS.calc.last = CARS.calc.current CARS.calc.current = "0"
    end
    display:setText(CARS.calc.current)
end

GMItem["[5] Apps/Calculator_GUI"] = function()
    if CARS.calc.win then root:removeChild(CARS.calc.win:getWindow()) CARS.calc.win = nil return end
    local win = UI:createStaticImage("CalcRoot")
    win:setSize(UDim2.new(0, 220, 0, 300))
    win:setPosition(UDim2.new(0.5, -110, 0.5, -150))
    win:setProperty("ImageColours", "tl:FF222222 tr:FF222222 bl:FF222222 br:FF222222")
    root:addChild(win:getWindow())
    local display = UI:createStaticText("Display")
    display:setSize(UDim2.new(1, -20, 0, 40))
    display:setPosition(UDim2.new(0, 10, 0, 10))
    display:setText("0")
    win:addChild(display:getWindow())
    local buttons = {"7","8","9","/", "4","5","6","*", "1","2","3","-", "0","C","=","+"}
    for i, b in ipairs(buttons) do
        local btn = UI:createStaticText("Btn"..i)
        btn:setSize(UDim2.new(0, 45, 0, 45))
        local x = ((i-1) % 4) * 50 + 10
        local y = math.floor((i-1) / 4) * 50 + 60
        btn:setPosition(UDim2.new(0, x, 0, y))
        btn:setText(b)
        btn:setProperty("HorzFormatting", "CentreAligned")
        btn:setProperty("VertFormatting", "CentreAligned")
        btn:setProperty("BackgroundEnabled", "True")
        btn.onMouseClick = function() updateCalc(b) end
        win:addChild(btn:getWindow())
    end
    CARS.calc.win = win
end

local BAD_APPLE = { "  .###.  \n .#...#. \n .#...#. \n .#...#. \n  .###.  ", "  .....  \n  .###.  \n  .#.#.  \n  .###.  \n  .....  " }
GMItem["[5] Apps/Bad_Apple_ASCII"] = function()
    CARS.active.ba = not CARS.active.ba
    if not CARS.active.ba then
        if CARS.baWin then root:removeChild(CARS.baWin:getWindow()) CARS.baWin = nil end
        return "Video Stopped"
    end
    local win = UI:createStaticText("VideoRoot")
    win:setSize(UDim2.new(0, 300, 0, 300))
    win:setPosition(UDim2.new(0.5, -150, 0.5, -150))
    win:setProperty("HorzFormatting", "CentreAligned")
    win:setProperty("VertFormatting", "CentreAligned")
    root:addChild(win:getWindow())
    CARS.baWin = win
    local f = 1
    safeTimer("ba", 2, function()
        if not CARS.active.ba then return false end
        win:setText(BAD_APPLE[f])
        f = (f % #BAD_APPLE) + 1
        return true
    end)
end

-- ==========================================
-- [6] SYSTEM - СЕРВИС
-- ==========================================

GMItem["[6] System/Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF")
end

GMItem["[6] System/Clean_All_State"] = function()
    for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end
    if CARS.calc.win then root:removeChild(CARS.calc.win:getWindow()) CARS.calc.win = nil end
    if CARS.baWin then root:removeChild(CARS.baWin:getWindow()) CARS.baWin = nil end
    return "Cleanup Complete."
end

print("[System] CARS 1.3 Master Suite Deployed - Full Takeover Active")
return GMItem
