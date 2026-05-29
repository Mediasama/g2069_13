local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local InventorySystem = T(Lib, "InventorySystem")
local guiMgr = GUIManager:Instance()
local root = guiMgr:getRootWindow()

-- [CARS Lifecycle & State Management]
local CARS = {
    timers = {},
    hooks = {},
    active = {},
    calc = { current = "0", op = nil, last = nil, win = nil }
}

-- [Core Utilities]
local function isValidEnemy(ent, ignoreSafe)
    if not ent or not ent:isValid() or ent.objID == Me.objID then return false end
    if ent:isInStateType(Define.RoleStatus.DEAD) or (ent.curHp and ent.curHp <= 0) then return false end

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
    local hookKey = tostring(obj) .. name
    if CARS.hooks[hookKey] then return end
    CARS.hooks[hookKey] = obj[name]
    obj[name] = function(self, ...)
        return newFunc(CARS.hooks[hookKey], self, ...)
    end
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
            -- [PUNISHER] If enemy is attacking or in PK mode, they are vulnerable regardless of 'safe' status
            local isVulnerable = ent:getSafeModeType() == Define.PKModeType.pk2 or ent:getPlayerIsInBattleState()
            if ent.isPlayer and isValidEnemy(ent, true) and (isVulnerable or Me:distance(ent) < 8) then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then
            Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets })
        end
        return true
    end)
    return "KillAura (PK Punisher): " .. (CARS.active.killAura and "ON" or "OFF")
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

GMItem["[1] Combat/Turbo_Combo"] = function()
    Me.turboCombo = not Me.turboCombo
    return "Turbo Combo: " .. (Me.turboCombo and "ON" or "OFF")
end

GMItem["[1] Combat/Instant_Finisher"] = function()
    Me.alwaysFinisher = not Me.alwaysFinisher
    return "Instant Finisher: " .. (Me.alwaysFinisher and "ON" or "OFF")
end

-- ==========================================
-- [2] MOVEMENT - ПЕРЕМЕЩЕНИЕ
-- ==========================================

GMItem["[2] Movement/Ultra_Flight_v2"] = function()
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
        local speed = 0.8
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
    return "Vector Flight ACTIVE"
end

GMItem["[2] Movement/Voxel_Ghost"] = function()
    CARS.active.ghost = not CARS.active.ghost
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not CARS.active.ghost)
    return "Ghost Mode: " .. (CARS.active.ghost and "ON" or "OFF")
end

-- ==========================================
-- [3] RAIDS - РЕЙДЫ И МИССИИ
-- ==========================================

GMItem["[3] Raids/Reset_Daily_Limits"] = function()
    Me:sendPacket({ pid = "C2SGMResetMissionCounts" })
    return "Limits Restored (10/10)"
end

GMItem["[3] Raids/Force_Join_Room"] = GM:inputStr(function(_, roomId)
    Me:sendPacket({ pid = "C2SEnterMission", roomId = roomId })
    return "Breaching room ID: " .. roomId
end, "RoomID")

GMItem["[3] Raids/Instant_Win_Stage"] = function()
    local count = 0
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if ent:isMonster() then
            Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = {ent.objID} })
            count = count + 1
        end
    end
    return "Stage Cleared (" .. count .. " kills)"
end

GMItem["[3] Raids/Bypass_Level_Req"] = function()
    UI:openWindow("UI/game_mission/gui/win_mission_select")
    return "Mission Menu Opened (Bypassing Checks)"
end

-- ==========================================
-- [4] VISUALS - ВИЗУАЛ
-- ==========================================

GMItem["[4] Visuals/Full_Bright"] = function()
    local timelight = T(Lib, "TimeLight")
    if timelight then timelight:SetAmbientIntensityInc(100) end
    return "Brightness MAX"
end

GMItem["[4] Visuals/Entity_ESP"] = function()
    CARS.active.esp = not CARS.active.esp
    safeTimer("esp", 40, function()
        if not CARS.active.esp then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if ent.isPlayer and ent.objID ~= Me.objID and ent.curHp > 0 then
                if not UI:isOpenWindow("esp_"..ent.objID) then
                    UI:openSceneWindow("UI/scene_object/gui/widget_player_name", "esp_"..ent.objID, {target = ent}, "asset")
                end
            end
        end
        return true
    end)
end

-- ==========================================
-- [5] APPS - ПРИЛОЖЕНИЯ
-- ==========================================

local function updateCalcDisplay(val)
    if not CARS.calc.win then return end
    local display = CARS.calc.win:child("Display")
    if val == "C" then CARS.calc.current = "0" CARS.calc.op = nil CARS.calc.last = nil
    elseif tonumber(val) then
        if CARS.calc.current == "0" then CARS.calc.current = val else CARS.calc.current = CARS.calc.current .. val end
    elseif val == "=" then
        if CARS.calc.op and CARS.calc.last then
            local f, err = pcall(loadstring("return "..CARS.calc.last..CARS.calc.op..CARS.calc.current))
            CARS.calc.current = f and tostring(err) or "Error"
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
    win:setProperty("ImageColours", "tl:FF333333 tr:FF333333 bl:FF333333 br:FF333333")
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
        btn.onMouseClick = function() updateCalcDisplay(b) end
        win:addChild(btn:getWindow())
    end
    CARS.calc.win = win
end

local BA_DATA = { "      ####      \n    ########    \n   ##########   \n   ##########   \n    ########    \n      ####      ", "                \n      ####      \n     ######     \n     ######     \n      ####      \n                " }
GMItem["[5] Apps/BadApple_Doom_PoC"] = function()
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
        win:setText(BA_DATA[f])
        f = (f % #BA_DATA) + 1
        return true
    end)
end

-- ==========================================
-- [6] SYSTEM - СИСТЕМА
-- ==========================================

GMItem["[6] System/Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF")
end

GMItem["[6] System/Clean_All_State"] = function()
    for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end
    if CARS.calc.win then root:removeChild(CARS.calc.win:getWindow()) CARS.calc.win = nil end
    if CARS.baWin then root:removeChild(CARS.baWin:getWindow()) CARS.baWin = nil end
    return "Cleanup Complete"
end

print("[Core] Master Modding Suite 1.2 Deployed with Raid Exploits")
return GMItem
