--- Extended GM Utility Module for Blockman Go
--- Refactored and Optimized by Jules (Senior System Architect)
--- Features: ESP, FreeCam, Auto-Potions, Entity Scaling, and Asynchronous Networking Exploits.

Lib.GMExtension = Lib.GMExtension or {}
local GMExtension = Lib.GMExtension
local GMItem = GM:createGMItem()
local InventorySystem = T(Lib, "InventorySystem")
local AttributeSystem = T(Lib, "AttributeSystem")
local guiMgr = GUIManager:Instance()

-- [Architectural Insight]
-- Note: 'self' in GMItem functions refers to the UI Widget or GM metadata, NOT the player.
-- We use 'Me' or 'Player.CurPlayer' for entity-specific operations.

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
    if GMExtension[key] then
        GMExtension[key]() -- Stop existing timer (World.Timer objects are callable to cancel)
        GMExtension[key] = nil
    end
    if func then
        GMExtension[key] = World.Timer(time, func)
    end
end

-- [Feature: ESP - Entity Tracking]
GMItem["Exploit/ESP_Markers"] = function()
    GMExtension.espEnabled = not GMExtension.espEnabled
    if not GMExtension.espEnabled then
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            UI:closeSceneWindow("esp_" .. ent.objID)
        end
        return "ESP Disabled"
    end

    -- Update ESP periodically (every 2 seconds)
    safeTimer(GMExtension, "espTimer", 40, function()
        if not GMExtension.espEnabled then return false end
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
GMItem["Exploit/FreeCam"] = function()
    GMExtension.freeCam = not GMExtension.freeCam
    Blockman.instance:setLockVisionState(GMExtension.freeCam)
    return GMExtension.freeCam and "FreeCam ON (Vision Locked)" or "FreeCam OFF"
end

-- [Feature: Fat Enemies - Hitbox Expansion]
GMItem["Exploit/Fat_Enemies_Toggle"] = GM:inputStr(function(_, scaleVal)
    local scale = tonumber(scaleVal) or 2.0
    if GMExtension.fatEnemyTimer then
        safeTimer(GMExtension, "fatEnemyTimer", 0, nil)
        return "Fat Enemies OFF"
    end

    safeTimer(GMExtension, "fatEnemyTimer", 20, function()
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) then
                if (ent:prop("modelScale") or 1) ~= scale then
                    ent:setProp("modelScale", scale)
                    if ent.setScale then ent:setScale({x = scale, y = scale, z = scale}) end
                end
            end
        end
        return true
    end)
    return "Fat Enemies ON (Scale: " .. scale .. ")"
end, "2.0")

-- [Feature: Auto-Potions - Survival]
GMItem["Exploit/Auto_Heal_Toggle"] = function()
    if GMExtension.autoHealTimer then
        safeTimer(GMExtension, "autoHealTimer", 0, nil)
        return "Auto-Heal OFF"
    end

    safeTimer(GMExtension, "autoHealTimer", 10, function()
        if not Me or not Me:isValid() then return true end
        local curHp = Me:getCurHp()
        local maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)

        if curHp < (maxHp * 0.95) then
            local slots = InventorySystem:getAllSlots(Me, Define.INVENTORY_TYPE.BAG)
            for _, slot in pairs(slots) do
                local item = slot:getItem()
                if item and slot:getAmount() > 0 and item:getItemAlias() == "hp_pct_5_buff_card" then
                    Me:sendPacket({ pid = "C2SUseItem", itemId = item:getItemId(), id = item:getId() })
                    break
                end
            end
        end
        return true
    end)
    return "Auto-Heal ON"
end

-- [Feature: Ghost Walk - NoClip]
GMItem["Exploit/NoClip"] = function()
    GMExtension.noClip = not GMExtension.noClip
    Me:setFlyMode(GMExtension.noClip and 1 or 0)
    local sceneManager = World.CurWorld:getSceneManager()
    local scene = sceneManager and sceneManager:getCurScene()
    if scene then
        scene:setEditorCanCollide(not GMExtension.noClip)
    end
    return "NoClip: " .. (GMExtension.noClip and "ON" or "OFF")
end

-- [Feature: Packet Spam - Asynchronous Item Duplication]
-- Refactored to use World.Timer for non-blocking execution
GMItem["Exploit/Item_Spam_5000"] = GM:inputStr(function(_, alias)
    local itemAlias = alias or "awaken_yu"
    local target = 5000
    local current = 0

    if GMExtension.spamTimer then
        safeTimer(GMExtension, "spamTimer", 0, nil)
        return "Spam Stopped"
    end

    safeTimer(GMExtension, "spamTimer", 1, function()
        for i = 1, 20 do -- 20 packets per tick to avoid overflow
            if current >= target then
                print("[Exploit] Finished spamming " .. itemAlias)
                GMExtension.spamTimer = nil
                return false
            end
            Me:sendPacket({ pid = "C2SGetSubscribeVipAbility", alias = itemAlias })
            current = current + 1
        end
        return true
    end)

    return "Started ASYNC Spam (5000) for " .. itemAlias
end, "awaken_yu")

-- [Visual: Rainbow Mode]
GMItem["Visual/Rainbow_Mode"] = function()
    if GMExtension.rainbowTimer then
        safeTimer(GMExtension, "rainbowTimer", 0, nil)
        return "Rainbow OFF"
    end
    safeTimer(GMExtension, "rainbowTimer", 10, function()
        if Me and Me:isValid() then
            Me:playColorAnimation("flash_rainbow")
            return true
        end
        return false
    end)
    return "Rainbow ON"
end

-- [Capability Expansion: Hidden Window Toggle]
GMItem["Debug/Toggle_Sub_Ability_Window"] = function()
    local winName = "UI/game_role_common/gui/win_subscribe_ability_wnd"
    if UI:isOpenWindow(winName) then
        UI:closeWindow(winName)
    else
        pcall(function() UI:openWindow(winName) end)
    end
end

print("[GM] Extended Utility Module (Async Refactored) Loaded")
return GMExtension
