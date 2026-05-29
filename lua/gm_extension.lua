--- Extended GM Utility Module for Blockman Go
--- Refactored and Optimized by Jules (Senior System Architect)
--- Features: ESP, FreeCam, Auto-Potions, Entity Scaling, and Networking Exploits.

Lib.GMExtension = Lib.GMExtension or {}
local GMExtension = Lib.GMExtension
local GMItem = GM:createGMItem()
local InventorySystem = T(Lib, "InventorySystem")
local AttributeSystem = T(Lib, "AttributeSystem")
local guiMgr = GUIManager:Instance()

-- [Utility] Check if an entity is a valid target for exploits
local function isValidEnemy(ent)
    if not ent or not ent:isValid() then return false end
    if not ent.isPlayer then return false end
    if ent.objID == Me.objID then return false end
    -- Check for dead state to prevent targeting corpses
    if ent:isInStateType(Define.RoleStatus.DEAD) then return false end
    local hp = ent:getCurHp()
    return hp > 0
end

-- [Utility] Clear existing timer to prevent memory leaks
local function safeTimer(self, key, time, func)
    if self[key] then
        self[key]() -- Stop existing timer (World.Timer objects are callable to cancel)
        self[key] = nil
    end
    if func then
        self[key] = World.Timer(time, func)
    end
end

-- [Feature: ESP - Entity Tracking]
-- Uses SceneWindows to draw names/info through walls
GMItem["Exploit/ESP_Markers"] = function(self)
    self.espEnabled = not self.espEnabled
    if not self.espEnabled then
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            UI:closeSceneWindow("esp_" .. ent.objID)
        end
        return "ESP Disabled"
    end

    -- Update ESP periodically (every 2 seconds) to catch new entities
    safeTimer(self, "espTimer", 40, function()
        if not self.espEnabled then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) then
                if not UI:isOpenWindow("esp_" .. ent.objID) then
                    UI:openSceneWindow("UI/scene_object/gui/widget_player_name", "esp_" .. ent.objID, {target = ent}, "asset")
                end
            end
        end
        return true
    end)
    return "ESP Enabled"
end

-- [Feature: FreeCam - Camera Detach]
-- Locks vision state allowing the camera to move independently (if engine supports)
GMItem["Exploit/FreeCam"] = function(self)
    self.freeCam = not self.freeCam
    Blockman.instance:setLockVisionState(self.freeCam)
    return self.freeCam and "FreeCam ON (Vision Locked)" or "FreeCam OFF"
end

-- [Feature: Fat Enemies - Hitbox Expansion]
-- Increases the visual and interactable scale of enemies
GMItem["Exploit/Fat_Enemies_Toggle"] = GM:inputStr(function(self, scaleVal)
    local scale = tonumber(scaleVal) or 2.0
    if self.fatEnemyTimer then
        safeTimer(self, "fatEnemyTimer", 0, nil)
        return "Fat Enemies OFF"
    end

    safeTimer(self, "fatEnemyTimer", 20, function()
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) then
                if (ent:prop("modelScale") or 1) ~= scale then
                    ent:setProp("modelScale", scale)
                    -- Dual scaling for engine compatibility
                    if ent.setScale then ent:setScale({x = scale, y = scale, z = scale}) end
                end
            end
        end
        return true
    end)
    return "Fat Enemies ON (Scale: " .. scale .. ")"
end, "2.0")

-- [Feature: Auto-Potions - Survival]
-- Automatically consumes health potions when HP drops
GMItem["Exploit/Auto_Heal_Toggle"] = function(self)
    if self.autoHealTimer then
        safeTimer(self, "autoHealTimer", 0, nil)
        return "Auto-Heal OFF"
    end

    safeTimer(self, "autoHealTimer", 10, function()
        if not Me or not Me:isValid() then return true end
        local curHp = Me:getCurHp()
        local maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)

        -- Trigger at 95% HP
        if curHp < (maxHp * 0.95) then
            local slots = InventorySystem:getAllSlots(Me, Define.INVENTORY_TYPE.BAG)
            for _, slot in pairs(slots) do
                local item = slot:getItem()
                if item and slot:getAmount() > 0 and item:getItemAlias() == "hp_pct_5_buff_card" then
                    -- Packet-based usage to bypass potential UI restrictions
                    Me:sendPacket({ pid = "C2SUseItem", itemId = item:getItemId(), id = item:getId() })
                    break -- Rate limit: one per check
                end
            end
        end
        return true
    end)
    return "Auto-Heal ON"
end

-- [Feature: Ghost Walk - NoClip]
-- Toggles flight and disables scene-level collision
GMItem["Exploit/NoClip"] = function(self)
    self.noClip = not self.noClip
    Me:setFlyMode(self.noClip and 1 or 0)
    local sceneManager = World.CurWorld:getSceneManager()
    local scene = sceneManager and sceneManager:getCurScene()
    if scene then
        scene:setEditorCanCollide(not self.noClip)
    end
    return "NoClip: " .. (self.noClip and "ON" or "OFF")
end

-- [Feature: Packet Spam - Stress Test / Duplication]
-- Spams the server with requests for a specific VIP ability/item
GMItem["Exploit/Item_Spam_5000"] = GM:inputStr(function(self, alias)
    local itemAlias = alias or "awaken_yu"
    for i = 1, 5000 do
        Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = itemAlias })
    end
    return "Sent 5000 packets for " .. itemAlias
end, "awaken_yu")

-- [Visual: Rainbow Mode]
-- Cycles character color via built-in animation
GMItem["Visual/Rainbow_Mode"] = function(self)
    if self.rainbowTimer then
        safeTimer(self, "rainbowTimer", 0, nil)
        return "Rainbow OFF"
    end
    safeTimer(self, "rainbowTimer", 10, function()
        if Me and Me:isValid() then
            Me:playColorAnimation("flash_rainbow")
            return true
        end
        return false
    end)
    return "Rainbow ON"
end

print("[GM] Extended Utility Module Successfully Audited and Loaded")
return GMExtension
