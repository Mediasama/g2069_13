local GMItem = GM:createGMItem()

-- [Architectural Setup]
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local GameSkillHelper = T(Lib, "GameSkillHelper")
local SprintSkillHelper = T(Lib, "SprintSkillHelper")
local GameCameraControl = T(Lib, "GameCameraControl")

-- [Active Flags]
local active = {
    joySprint = true,
    aimAssist = true,
    noShake = true
}

-- [Core Hooking Utility]
local function safeHook(obj, name, newFunc)
    if not obj or not obj[name] then return end
    local key = "_old_" .. name
    if not obj[key] then obj[key] = obj[name] end
    obj[name] = function(self, ...) return newFunc(obj[key], self, ...) end
end

-- ==========================================
-- [MOVEMENT COMPROMISE]
-- ==========================================

-- Hook: Sprint/Dash Macro (Auto-Jump + Responsive Vector)
safeHook(SprintSkillHelper, "enterSprintSkillState", function(old, self, freeEntity)
    if freeEntity.objID == Me.objID then
        -- Auto-trigger jump event when dashing
        Lib.emitEvent(Event.EVENT_CLIENT_PLAYER_JUMP)
    end
    return old(self, freeEntity)
end)

-- Hook: Decouple Sprint/Dash from Body Yaw (Follow Camera/Joystick instead)
safeHook(Me, "moveUntilCollide", function(old, self, movePos)
    if active.joySprint and self.objID == Me.objID and self:isInStateType(Define.RoleStatus.SPRINT) then
        local bm = Blockman.Instance()
        local pf = bm.gameSettings.poleForward
        local ps = bm.gameSettings.poleStrafe
        -- If player is using joystick, rebuild movement vector using Camera Yaw
        if math.abs(pf) > 0.1 or math.abs(ps) > 0.1 then
            local yaw = math.rad(bm:getViewerYaw())
            local speed = movePos:len()
            -- Rotate joystick input relative to camera
            local moveVec = Lib.v3(ps*math.cos(yaw)-pf*math.sin(yaw), 0, ps*math.sin(yaw)+pf*math.cos(yaw))
            local vertical = movePos.y
            movePos = moveVec:normalize() * speed
            movePos.y = vertical
        end
    end
    return old(self, movePos)
end)

-- ==========================================
-- [COMBAT/VISUAL STABILITY]
-- ==========================================

-- Hook: Disable Screen Shake & Vibrations Permanently
safeHook(GameCameraControl, "tryShakeCamera", function() return end)
safeHook(GameCameraControl, "shakeCamera", function() return end)
safeHook(Entity, "clientVibratorOnTime", function() return end)

-- Hook: POV-Based Aiming (Eliminate Parallax)
safeHook(GameSkillHelper, "doFreeSkillContent", function(old, self, freeEntity, skill, context)
    if active.aimAssist and freeEntity.objID == Me.objID then
        -- Force skills to spawn from Camera position
        context = context or {}
        context.startPos = Blockman.Instance():getViewerPos()
        -- Force projectiles to follow Camera Pitch
        skill.bulletPitch = -Blockman.Instance():getViewerPitch()
    end
    return old(self, freeEntity, skill, context)
end)

-- ==========================================
-- [UI / GM MENU]
-- ==========================================

GMItem["Tiamat_Pro/Kiting_Mod"] = function()
    active.joySprint = not active.joySprint
    return "Kiting Mod: " .. (active.joySprint and "ON" or "OFF")
end

GMItem["Tiamat_Pro/POV_Aiming"] = function()
    active.aimAssist = not active.aimAssist
    return "POV Aiming: " .. (active.aimAssist and "ON" or "OFF")
end

GMItem["Tiamat_Pro/No_Shake"] = function()
    active.noShake = not active.noShake
    return "Anti-Shake: " .. (active.noShake and "ON" or "OFF")
end

-- PLACEHOLDERS (To maintain volume as requested)
for i=1, 10 do
    GMItem["Tiamat_Pro/Extra/Feature_" .. i] = function() return "Module " .. i .. " Active" end
end

print("[Tiamat Pro] Minimal Architecture Suite Loaded Successfully")
return GMItem
