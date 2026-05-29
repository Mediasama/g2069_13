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
-- [1] COMBAT - БОЕВАЯ СИСТЕМА
-- ==========================================

GMItem["[1] Combat/KillAura_360"] = function()
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

GMItem["[1] Combat/Turbo_Combo"] = function()
    Me.turboCombo = not Me.turboCombo
    return "Turbo Combo (No Delay): " .. (Me.turboCombo and "ON" or "OFF")
end

GMItem["[1] Combat/Instant_Finisher"] = function()
    Me.alwaysFinisher = not Me.alwaysFinisher
    return "Instant Finisher: " .. (Me.alwaysFinisher and "ON" or "OFF")
end

GMItem["[1] Combat/No_Recovery_Frames"] = function()
    safeHook(Entity, "playAction", function(old, self, name, time)
        return old(self, name, 0.01)
    end)
    return "Action Frame Skip ACTIVE"
end

GMItem["[1] Combat/Infinite_Channeling"] = function()
    Me.infiniteMP = not Me.infiniteMP
    return "Infinite Channeling: " .. (Me.infiniteMP and "ON" or "OFF")
end

-- ==========================================
-- [2] MOVEMENT - ПЕРЕМЕЩЕНИЕ
-- ==========================================

-- Optimized Flight Logic (High Responsiveness)
GMItem["[2] Movement/Ultra_Flight_v2"] = function()
    CARS.active.flight = not CARS.active.flight
    if not CARS.active.flight then
        Me:setProp("gravity", 0.08)
        safeTimer("flight", 0, nil)
        return "Flight OFF"
    end

    -- Manipulating Me.motion directly every tick creates a much more
    -- responsive feel than changing moveSpeed, as it bypasses built-in
    -- physics dampening and acceleration.
    safeTimer("flight", 1, function()
        if not CARS.active.flight then return false end
        Me:setProp("gravity", 0)
        local bm = Blockman.Instance()
        local move = Lib.v3(0, 0, 0)
        local speed = 0.7

        if bm:isKeyPressing("key.forward") then move.z = 1 end
        if bm:isKeyPressing("key.back") then move.z = -1 end
        if bm:isKeyPressing("key.left") then move.x = 1 end
        if bm:isKeyPressing("key.right") then move.x = -1 end
        if bm:isKeyPressing("key.jump") then move.y = 1 end
        if bm:isKeyPressing("key.sneak") then move.y = -1 end

        if move:len() > 0 then
            local yaw = math.rad(bm:getViewerYaw())
            local rotatedMove = Lib.v3(
                move.x * math.cos(yaw) - move.z * math.sin(yaw),
                move.y,
                move.x * math.sin(yaw) + move.z * math.cos(yaw)
            )
            Me.motion = rotatedMove * speed
        else
            Me.motion = Lib.v3(0, 0, 0)
        end
        return true
    end)
    return "Responsive Vector Flight ACTIVE"
end

GMItem["[2] Movement/Voxel_Ghost_Mode"] = function()
    CARS.active.ghost = not CARS.active.ghost
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not CARS.active.ghost)
    return "Noclip: " .. (CARS.active.ghost and "ON" or "OFF")
end

-- ==========================================
-- [3] VISUALS - ВИЗУАЛ
-- ==========================================

GMItem["[3] Visuals/Entity_ESP"] = function()
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

-- ==========================================
-- [4] APPS - ПРИЛОЖЕНИЯ
-- ==========================================

-- Functional Calculator with GUI
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

GMItem["[4] Apps/Calculator_GUI"] = function()
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
        btn.onMouseClick = function() updateCalc(b) end
        win:addChild(btn:getWindow())
    end
    CARS.calc.win = win
    return "Calculator Deployed"
end

-- Bad Apple ASCII Visualizer
local BA_DATA = {
    "  . . . . .  \n . # # # . \n . # . # . \n . # # # . \n  . . . . .  ",
    "  . . . . .  \n . . . . . \n . . # . . \n . . . . . \n  . . . . .  "
}

GMItem["[4] Apps/Bad_Apple_ASCII"] = function()
    CARS.active.ba = not CARS.active.ba
    if not CARS.active.ba then
        if CARS.baWin then root:removeChild(CARS.baWin:getWindow()) CARS.baWin = nil end
        return "Bad Apple STOPPED"
    end

    local win = UI:createStaticText("BARoot")
    win:setSize(UDim2.new(0, 400, 0, 400))
    win:setPosition(UDim2.new(0.5, -200, 0.5, -200))
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
    return "Bad Apple Playing..."
end

-- ==========================================
-- [5] SYSTEM - СЕРВИС
-- ==========================================

GMItem["[5] System/Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield: " .. (Me.lagShield and "ON" or "OFF")
end

GMItem["[5] System/Clean_All_State"] = function()
    for k, _ in pairs(CARS.timers) do safeTimer(k, 0, nil) end
    if CARS.calc.win then root:removeChild(CARS.calc.win:getWindow()) CARS.calc.win = nil end
    if CARS.baWin then root:removeChild(CARS.baWin:getWindow()) CARS.baWin = nil end
    return "Cleanup Complete"
end

print("[Core] Categorized Engine Suite with Apps Deployed Successfully")
return GMItem
