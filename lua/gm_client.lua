local GMItem = GM:createGMItem()

-- [Architectural Dependencies]
local ItemConfig = T(Config, "ItemConfig")
local SkillConfig = T(Config, "SkillConfig")
local SkillMovesConfig = T(Config, "SkillMovesConfig")
local MapConfig = T(Config, "MapConfig")
local AttributeSystem = T(Lib, "AttributeSystem")
local InventorySystem = T(Lib, "InventorySystem")
local guiMgr = GUIManager:Instance()

-- [Utility] Valid Enemy Check
local function isValidEnemy(ent)
    if not ent or not ent:isValid() then return false end
    if not ent.isPlayer then return false end
    if ent.objID == Me.objID then return false end
    if ent:isInStateType(Define.RoleStatus.DEAD) then return false end
    local hp = ent:getCurHp()
    return hp and hp > 0
end

-- [Utility] Simple Table Merge
local function merge(t1, t2)
    local res = {}
    for k, v in pairs(t1) do res[k] = v end
    for k, v in pairs(t2) do res[k] = v end
    return res
end

-- [Utility] Async Packet Loop
local function asyncSpam(total, batch, pid, dataFactory)
    local current = 0
    World.Timer(1, function()
        for i = 1, batch do
            if current >= total then return false end
            local data = dataFactory(current)
            Me:sendPacket(merge({pid = pid}, data))
            current = current + 1
        end
        return true
    end)
end

-- ==========================================
-- 1. COMBAT & HITBOX MANIPULATION
-- ==========================================

GMItem["Combat/KillAura"] = function()
    Me.killAura = not Me.killAura
    World.Timer(5, function()
        if not Me.killAura then return false end
        local targets = {}
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) and Me:distance(ent) < 12 then
                table.insert(targets, ent.objID)
            end
        end
        if #targets > 0 then
            Me:sendPacket({ pid = "doGameSkillResult", skillId = 1000004, targets = targets })
        end
        return true
    end)
    return "KillAura: " .. (Me.killAura and "ON" or "OFF")
end

GMItem["Combat/Anti_Knockback"] = function()
    Me.antiKB = not Me.antiKB
    local old_enter = Me.enterStateType
    Me.enterStateType = function(self, state, ...)
        if Me.antiKB and state == Define.RoleStatus.BLOW_AWAY then
            return
        end
        return old_enter(self, state, ...)
    end
    return "Anti-Knockback: " .. (Me.antiKB and "ACTIVE" or "OFF")
end

GMItem["Combat/Hitbox_Expander"] = GM:inputStr(function(_, val)
    local scale = tonumber(val) or 5.0
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if ent.isPlayer and ent.objID ~= Me.objID then
            ent:setProp("modelScale", scale)
        end
    end
    return "Hitboxes expanded to " .. scale
end, "5.0")

GMItem["Combat/Infinite_Skill_Range"] = function()
    local cfgs = SkillConfig:getAllCfgs()
    for _, cfg in pairs(cfgs) do
        cfg.hitRange = 100
    end
    return "All Skill Ranges set to 100m"
end

GMItem["Combat/No_CD_Bypass"] = function()
    Me.noCD = not Me.noCD
    local old_check = Me.checkCanFreeSkill
    Me.checkCanFreeSkill = function(self, skillId, ...)
        if Me.noCD then
            return true, 0
        end
        return old_check(self, skillId, ...)
    end
    return "No-CD Bypass: " .. (Me.noCD and "ON" or "OFF")
end

-- ==========================================
-- 2. MOVEMENT & MAP EXPLOITS
-- ==========================================

GMItem["Map/Noclip_Voxel"] = function()
    Me.noClip = not Me.noClip
    Me:setFlyMode(Me.noClip and 1 or 0)
    local scene = World.CurWorld:getSceneManager():getCurScene()
    if scene then scene:setEditorCanCollide(not Me.noClip) end
    return "Noclip: " .. (Me.noClip and "ON" or "OFF")
end

GMItem["Map/Teleport_to_Loot"] = function()
    local found = false
    for _, part in pairs(World.CurWorld:getAllStaticPart()) do
        if part.name:find("treasure") or part.name:find("chest") then
            Me:setPosition(part:getPosition())
            found = true
            break
        end
    end
    return found and "Teleported to loot" or "No loot found"
end

GMItem["Map/Speed_Bypass"] = GM:inputStr(function(_, val)
    Me:setProp("moveSpeed", tonumber(val) or 1.0)
    return "Speed set to " .. val
end, "1.0")

GMItem["Map/Air_Walk"] = function()
    Me.airWalk = not Me.airWalk
    World.Timer(1, function()
        if not Me.airWalk then return false end
        Me:setProp("gravity", 0)
        Me.motion.y = 0
        return true
    end)
    return "AirWalk: " .. (Me.airWalk and "ON" or "OFF")
end

GMItem["Map/Insta_Interact"] = function()
    World.cfg.interactDistance = 9999
    return "Interact Distance set to Infinite"
end

-- ==========================================
-- 3. UI, VISUALS & ECONOMY
-- ==========================================

GMItem["Visual/Full_Bright"] = function()
    local timelight = T(Lib, "TimeLight")
    if timelight then
        timelight:SetAmbientIntensityInc(100)
    end
    return "World Brightness Maximized"
end

GMItem["Visual/Entity_ESP"] = function()
    Me.esp = not Me.esp
    World.Timer(40, function()
        if not Me.esp then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if isValidEnemy(ent) then
                if not UI:isOpenWindow("esp_"..ent.objID) then
                    UI:openSceneWindow("UI/scene_object/gui/widget_player_name", "esp_"..ent.objID, {target = ent}, "asset")
                end
            end
        end
        return true
    end)
    return "ESP: " .. (Me.esp and "ON" or "OFF")
end

GMItem["Economy/Unlock_All_Shops"] = function()
    for i = 1, 50 do
        pcall(function() UI:openWindow("UI/game_business/gui/win_game_shop", "shop_"..i, nil, {shopId = i}) end)
    end
    return "Attempted to open all shop IDs"
end

GMItem["Visual/Skin_Stealer"] = function()
    for _, ent in pairs(World.CurWorld:getAllEntity()) do
        if ent.isPlayer and ent.objID ~= Me.objID then
            Me:setProp("actorName", ent:getProp("actorName"))
            return "Skin stolen from " .. ent.name
        end
    end
end

GMItem["Economy/Free_VIP_Interface"] = function()
    UI:openWindow("UI/game_role_common/gui/win_subscribe_ability_wnd")
    return "VIP Menu Opened"
end

-- ==========================================
-- 4. AUTOMATION & MACROS
-- ==========================================

GMItem["Auto/Vacuum_Loot"] = function()
    Me.vacuum = not Me.vacuum
    World.Timer(20, function()
        if not Me.vacuum then return false end
        for _, ent in pairs(World.CurWorld:getAllEntity()) do
            if ent.type == "drop_item" then
                Me:sendPacket({ pid = "C2SPickupItem", objID = ent.objID })
            end
        end
        return true
    end)
    return "Auto-Loot: " .. (Me.vacuum and "ON" or "OFF")
end

GMItem["Auto/Infinite_Potions"] = function()
    asyncSpam(1000, 10, "C2SGetSubscribeVipAbility", function()
        return { alias = "hp_pct_5_buff_card" }
    end)
    return "Duplicating 1000 Potions..."
end

GMItem["Auto/Auto_Heal_99"] = function()
    Me.autoHeal = not Me.autoHeal
    World.Timer(10, function()
        if not Me.autoHeal then return false end
        local maxHp = AttributeSystem:getAttributeValue(Me, Define.ATTR.MAX_HP)
        if Me:getCurHp() < maxHp then
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
    return "Auto-Heal: " .. (Me.autoHeal and "ON" or "OFF")
end

GMItem["Auto/Fast_Dialogue"] = function()
    Lib.subscribeEvent("EVENT_NPC_TALK", function(packet)
        Me:sendPacket({ pid = "C2SNpcDialogueReply", replyId = 1 })
    end)
    return "Dialogue Auto-Reply Active"
end

GMItem["Auto/Anti_AFK"] = function()
    World.Timer(600, function()
        Me.motion.x = 0.01
        return true
    end)
    return "Anti-AFK Pulse Active"
end

-- ==========================================
-- SHIELD: LAG PROTECTION
-- ==========================================

GMItem["Shield/Lag_Shield_Toggle"] = function()
    Me.lagShield = not Me.lagShield
    return "Lag Shield (Chat/Emoji/Tips Filter): " .. (Me.lagShield and "ON" or "OFF")
end

print("[Core] Fully Expanded gm_client.lua Loaded Successfully")
return GMItem
