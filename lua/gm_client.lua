local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local SkillConfig = T(Config, "SkillConfig")
local TaskConfig = T(Config, "TaskConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local guiMgr = GUIManager:Instance()
local root = guiMgr:getRootWindow()

-- [CARS Lifecycle & Global Registry]
local CARS = _G.CARS or {
    timers = {},
    hooks = {},
    active = {},
    logLines = {},
    scannedRooms = {},
    calc = { current = "0", op = nil, last = nil, win = nil }
}
_G.CARS = CARS

-- [Utility] Terminal Redirection
local MAX_LOG_LINES = 14
if not CARS.hooks.print then
    local old_print = _G.print
    CARS.hooks.print = old_print
    _G.print = function(...)
        local args = {...}
        local str = ""
        for i, v in ipairs(args) do str = str .. tostring(v) .. "  " end
        table.insert(CARS.logLines, 1, "[" .. os.date("%H:%M:%S") .. "] " .. str)
        if #CARS.logLines > MAX_LOG_LINES then table.remove(CARS.logLines) end
        if CARS.active.terminalWin then CARS:updateTerminalUI() end
        old_print(unpack(args))
    end
end

function CARS:updateTerminalUI()
    if not self.active.terminalText then return end
    self.active.terminalText:setText(table.concat(self.logLines, "\n"))
end

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
-- [1] COMBAT - БОЕВАЯ СИСТЕМА
-- ==========================================

GMItem["[1] Combat/KillAura_AntiPK"] = function()
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

GMItem["[1] Combat/Turbo_Combo"] = function() Me.turboCombo = not Me.turboCombo return "Turbo Combo: "..(Me.turboCombo and "ON" or "OFF") end
GMItem["[1] Combat/Always_Finisher"] = function() Me.alwaysFinisher = not Me.alwaysFinisher return "Always Finisher: "..(Me.alwaysFinisher and "ON" or "OFF") end

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
-- [3] PROGRESS - ПРОКАЧКА И РЕЙДЫ
-- ==========================================

GMItem["[3] Progress/Quest_Nuke"] = function()
    for id, _ in pairs(TaskConfig:getAllCfgs()) do Me:sendPacket({ pid = "C2SCompleteTask", taskId = id }) end
    return "All Quests Nuked"
end

GMItem["[3] Progress/Exp_Storm"] = function()
    CARS.active.expSpam = not CARS.active.expSpam
    local sent = 0
    safeTimer("exp_storm", 1, function()
        if not CARS.active.expSpam then return false end
        for i = 1, 40 do
            if sent >= 5000 then CARS.active.expSpam = false return false end
            Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = "role_exp" })
            sent = sent + 1
        end
        return true
    end)
end

GMItem["[3] Progress/Raid_ID_Scanner"] = function()
    CARS.active.scanner = not CARS.active.scanner
    if CARS.active.scanner then
        safeHook(Player.PackageHandlers, "S2CMissionTeammateCanSelect", function(old, self, packet)
            print("[Raid] Intercepted ID:", packet.missionId)
            CARS.scannedRooms[packet.missionId] = true
            return old(self, packet)
        end)
    end
    return "Raid Scanner: " .. (CARS.active.scanner and "ON" or "OFF")
end

-- ==========================================
-- [4] VISUALS - ВИЗУАЛ
-- ==========================================

GMItem["[4] Visuals/Full_Bright"] = function()
    local timelight = T(Lib, "TimeLight")
    if timelight then timelight:SetAmbientIntensityInc(100) end
    return "Luminance MAX"
end

GMItem["[4] Visuals/Tactical_Crosshair"] = function()
    CARS.active.cross = not CARS.active.cross
    if not CARS.active.cross then if CARS.crossWin then root:removeChild(CARS.crossWin:getWindow()) end return "Crosshair OFF" end
    local win = UI:createStaticImage("Crosshair")
    win:setSize(UDim2.new(0, 10, 0, 10))
    win:setPosition(UDim2.new(0.5, -5, 0.5, -5))
    win:setProperty("ImageColours", "tl:FFFF0000 tr:FFFF0000 bl:FFFF0000 br:FFFF0000")
    win:setImage("set:common.json image:img_0_item_white")
    root:addChild(win:getWindow())
    CARS.crossWin = win
end

-- ==========================================
-- [5] APPS - ПРИЛОЖЕНИЯ
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
        local x, y = ((i-1) % 4) * 50 + 10, math.floor((i-1) / 4) * 50 + 60
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

-- ==========================================
-- [8] TERMINAL - ЛОГ И ИНСПЕКТОР
-- ==========================================

GMItem["[8] Terminal/Object_Inspector"] = function()
    CARS.active.inspector = not CARS.active.inspector
    return "Inspector: " .. (CARS.active.inspector and "ACTIVE (Click Parts)" or "OFF")
end

GMItem["[8] Terminal/Show_Console"] = function()
    CARS.active.terminal = not CARS.active.terminal
    if not CARS.active.terminal then if CARS.active.terminalWin then root:removeChild(CARS.active.terminalWin:getWindow()) end return "Console Hidden" end
    local win = UI:createStaticImage("Terminal")
    win:setSize(UDim2.new(0, 500, 0, 250))
    win:setPosition(UDim2.new(0, 10, 1, -260))
    win:setProperty("ImageColours", "tl:CC000000 tr:CC000000 bl:CC000000 br:CC000000")
    root:addChild(win:getWindow())
    local txt = UI:createStaticText("Logs")
    txt:setSize(UDim2.new(1, -10, 1, -10))
    txt:setPosition(UDim2.new(0, 5, 0, 5))
    txt:setProperty("TextColours", "tl:FF00FF00 tr:FF00FF00 bl:FF00FF00 br:FF00FF00")
    txt:setProperty("VertFormatting", "TopAligned")
    txt:setProperty("WordWrap", "True")
    win:addChild(txt:getWindow())
    CARS.active.terminalWin = win
    CARS.active.terminalText = txt
    CARS:updateTerminalUI()
end

-- ==========================================
-- [0] SYSTEM - СЕРВИС
-- ==========================================

GMItem["[0] System/Clean_All"] = function()
    for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end
    if CARS.active.terminalWin then root:removeChild(CARS.active.terminalWin:getWindow()) end
    if CARS.calc.win then root:removeChild(CARS.calc.win:getWindow()) end
    if CARS.crossWin then root:removeChild(CARS.crossWin:getWindow()) end
    CARS.active = {}
    return "State Purged"
end

print("[System] CARS Tactical HUD 2.0 Fully Integrated")
return GMItem
