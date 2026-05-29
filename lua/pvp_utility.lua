--- PvP Utility Module for Blockman Go
--- Designed for educational research and architectural exploration.
--- Features: Enemy Cooldown Tracker & Airborne Landing Predictor.

-- Robust Module Initialization
Lib.PvPUtility = Lib.PvPUtility or {}
local PvPUtility = Lib.PvPUtility
local SkillConfig = T(Config, "SkillConfig")
local guiMgr = GUIManager:Instance()
local root = guiMgr:getRootWindow()

-- Coordinate Projection Wrapper
-- Uses the engine's built-in projection to map 3D world coordinates to 2D screen space.
function PvPUtility.worldToScreen(worldPos)
    if not Blockman.instance or not Blockman.instance.getScreenPos then return nil end
    local screenPos = Blockman.instance:getScreenPos(worldPos)
    -- screenPos is {x, y, z}. z > 0 indicates the point is in front of the camera.
    if screenPos.z > 0 then
        return screenPos.x, screenPos.y
    end
    return nil
end

-- Minimalist UI Component Factory
-- Dynamically creates UI elements using the engine's GUIManager.
function PvPUtility.createMarker(name, color)
    local marker = UI:createStaticImage(name)
    -- Using a basic white texture which we can tint via ImageColours property.
    marker:setImage("set:common.json image:img_0_item_white")
    marker:setProperty("ImageColours", color or "tl:FFFF0000 tr:FFFF0000 bl:FFFF0000 br:FFFF0000")
    marker:setSize(UDim2.new(0, 10, 0, 10))
    root:addChild(marker:getWindow())
    return marker
end

-- [Feature A: Enemy Cooldown Tracker]
-- Hooks into the networking layer to intercept skill cast packets from other players.
PvPUtility.activeTrackers = {}

function PvPUtility:initCooldownTracker()
    -- Wrap the Packet Handlers immediately and also hook future registrations
    local handles = T(Player, "PackageHandlers")
    if handles then
        self:hookPackageHandlers(handles)
    end

    -- Hook the global 'T' to catch any other late-loading packet systems
    local oldT = _G.T
    _G.T = function(ns, name)
        local res = oldT(ns, name)
        if ns == Player and name == "PackageHandlers" then
            self:hookPackageHandlers(res)
        end
        return res
    end
end

function PvPUtility:hookPackageHandlers(handles)
    if handles.__pvp_hooked then return end
    handles.__pvp_hooked = true

    -- 1. Wrap existing handler if it's already there
    if handles.onEntityFreeGameSkill then
        local original = handles.onEntityFreeGameSkill
        handles.onEntityFreeGameSkill = function(player, packet)
            original(player, packet)
            self:onSkillPacketIntercepted(packet)
        end
    end

    -- 2. Hook __newindex to catch future registration of the handler
    local mt = getmetatable(handles) or {}
    local old_newindex = mt.__newindex or rawset

    mt.__newindex = function(t, k, v)
        if k == "onEntityFreeGameSkill" then
            local original = v
            v = function(player, packet)
                original(player, packet)
                self:onSkillPacketIntercepted(packet)
            end
        end
        old_newindex(t, k, v)
    end
    setmetatable(handles, mt)
end

function PvPUtility:onSkillPacketIntercepted(packet)
    local entity = World.CurWorld:getEntity(packet.freeObjID)
    if entity and entity.isPlayer and entity.objID ~= Me.objID then
        self:trackEnemySkill(entity, packet.skillId)
    end
end

function PvPUtility:trackEnemySkill(entity, skillId)
    local cfg = SkillConfig:getSkillConfig(skillId)
    if not cfg or not cfg.skillCd or cfg.skillCd <= 0 then return end

    local enemyId = entity.objID
    self.activeTrackers[enemyId] = self.activeTrackers[enemyId] or {}

    -- Cleanup previous tracker for the same skill
    if self.activeTrackers[enemyId][skillId] then
        self.activeTrackers[enemyId][skillId].timer()
    end

    local cdSeconds = cfg.skillCd / 1000
    print(string.format("[PvP] Enemy %s casted %s (CD: %ds)", entity.name, cfg.name or skillId, cdSeconds))

    -- Store state for potential UI dashboard rendering
    self.activeTrackers[enemyId][skillId] = {
        startTime = World.Now(),
        duration = cfg.skillCd / 50, -- Assuming 20 TPS
        timer = World.Timer(cfg.skillCd / 50, function()
            self.activeTrackers[enemyId][skillId] = nil
        end)
    }
end

-- [Feature B: Airborne Landing Predictor]
-- Calculates the landing spot of jumping/falling enemies based on their current velocity and gravity.
PvPUtility.predictionMarker = nil

function PvPUtility:updateLandingPrediction()
    if not self.predictionMarker then
        -- Create a green marker for landing prediction
        self.predictionMarker = self.createMarker("LandingPredictor", "tl:FF00FF00 tr:FF00FF00 bl:FF00FF00 br:FF00FF00")
    end

    local target = self:getNearestEnemy(30)
    if not target or target.onGround then
        self.predictionMarker:setVisible(false)
        return
    end

    local p0 = target:getPosition()
    local v0 = target.motion -- 3D velocity vector
    local grav = target:getEntityProp("gravity") or 0.08

    local landingPos = self:simulateLanding(p0, v0, grav)
    if landingPos then
        local sx, sy = self.worldToScreen(landingPos)
        if sx and sy then
            self.predictionMarker:setVisible(true)
            self.predictionMarker:setPosition(UDim2.new(0, sx - 5, 0, sy - 5))
        else
            self.predictionMarker:setVisible(false)
        end
    else
        self.predictionMarker:setVisible(false)
    end
end

-- Physics Simulation Loop
-- Simulates the trajectory until it hits the ground.
function PvPUtility:simulateLanding(p0, v0, grav)
    local curPos = Lib.v3(p0.x, p0.y, p0.z)
    local curVel = Lib.v3(v0.x, v0.y, v0.z)

    -- Simulate for up to 60 ticks (3 seconds)
    for i = 1, 60 do
        curPos = curPos + curVel
        curVel.y = curVel.y - grav

        -- Simplified ground check: assuming Y=2.2 (typical for this map)
        -- In a production mod, this would use engine raycasting (World.CurWorld:raycast).
        if curPos.y <= 2.2 then
            curPos.y = 2.2
            return curPos
        end
    end
    return nil
end

-- Utility: Find target for prediction
function PvPUtility:getNearestEnemy(radius)
    if not World.CurWorld then return nil end
    local entities = World.CurWorld:getAllEntity()
    local nearest = nil
    local minDis = radius
    for _, entity in pairs(entities) do
        if entity.isPlayer and entity.objID ~= Me.objID and entity.curHp > 0 then
            local dis = Me:distance(entity)
            if dis < minDis then
                minDis = dis
                nearest = entity
            end
        end
    end
    return nearest
end

-- Module Start
function PvPUtility:start()
    self:initCooldownTracker()

    -- Main Update Loop (1 tick = 50ms)
    World.Timer(1, function()
        if Me and Me:isValid() then
            self:updateLandingPrediction()
        end
        return true
    end)

    print("[PvP] Utility Module Successfully Injected")
end

-- Auto-bootstrap
if World.isClient then
    Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
        PvPUtility:start()
    end)
end

return PvPUtility
