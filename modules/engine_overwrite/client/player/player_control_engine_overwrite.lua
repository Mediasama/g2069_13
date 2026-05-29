local bm			 = Blockman.Instance()
--local slideJumpFlag	 = L("slideJumpFlag", false)

local nextJumpTime = 0
local jumpBeginTime = 0
local jumpEndTime = 0
local onGround = true

local function showJumpCountMessage(jumpCount, maxJumpCount)
    local message = string.format(Lang:toText("gui_jump_count_message"),
            jumpCount > 0 and jumpCount or 0, maxJumpCount)
    Lib.emitEvent("EVENT_SHOW_BOTTOM_MESSAGE", message, { jumpCount = jumpCount })
end

---@param player EntityClientMainPlayer
local function jump_impl(player)
    local jumpCount = player:getJumpCount()
    local maxJumpCount = player:getMaxJumpCount()

    if jumpCount <= 0 then
        return
    end

    player:setForceMove()
    player.hitchingToId = 0
    player:changeJumpState("JumpRaiseState")
end

local function processJumpEvent(player)
    if not player:isInStateType(Define.RoleStatus.JUMP) then
        return
    end

    if player.curJumpClass then
        player.curJumpClass:update(player)
    end
end

---@param control PlayerControl
---@param player EntityClientMainPlayer
local function checkJump(control, player)
    if not Me:checkCanControlPlayer() or Me:checkJumpLimitBySkill() then
        return
    end
    if tonumber(player:getEntityProp("jumpSpeed")) <= 0 or player.curHp <= 0 then
        return
    end

    processJumpEvent(player)

    local playerCfg = player:cfg()
    local worldCfg = World.cfg
    local nowTime = World.Now()
    if onGround ~= player.onGround then  -- aerial landing
        onGround = player.onGround
        if onGround then
            nextJumpTime = nowTime + (playerCfg.jumpInterval or 2)
            if worldCfg.jumpProgressIcon then
                Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
            end
            player.twiceJump = nil
            player.takeoff = false
            jumpBeginTime = 0
        end
    end

    if player:checkPlayerIsCanJump() and bm:isKeyPressing("key.jump") then
        local canJump = player.onGround or player:isSwimming()
        local id = player.rideOnId
        local pet
        if id > 0 and not player:isCameraMode() then
            pet = player.world:getEntity(id)
            canJump = pet.onGround or pet:isSwimming()
        end
        canJump = canJump or true
        if canJump then
            jumpBeginTime = nowTime
            jumpEndTime = nowTime + (playerCfg.maxPressJumpTime or 0)
            if worldCfg.jumpProgressIcon then
                Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStart = true, jumpBeginTime = jumpBeginTime, jumpEndTime = jumpEndTime})
            end
        end

        jump_impl(player)
    else
        if worldCfg.jumpProgressIcon then
            Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
        end
        jumpEndTime = 0
    end
end

local inertanceEnabled = false
local inertanceDuration = 10    --帧
local inertanceEndTime = 0
local inertanceForward = 0
local inertanceLeft = 0
function PlayerControl.enableInertance(enable, duration)
    inertanceEnabled = enable
    inertanceDuration = duration or 10
end

function PlayerControl.updateInertance(forward, left)
    if not inertanceEnabled then
        return
    end
    local now = World.Now()
    inertanceEndTime = now + inertanceDuration
    inertanceForward = forward
    inertanceLeft = left
end

function PlayerControl.checkInertance()
    return inertanceEnabled and World.Now() < inertanceEndTime and (inertanceForward ~= 0 or inertanceLeft ~= 0)
end

function PlayerControl.checkJump_impl(control, player)
    checkJump(control, player)
    player:updateFallStatus()
end

--点击处理逻辑独立出来，方便业务根据需求进行覆盖扩展处理
function PlayerControl.processClick(hit, packet)
    if not hit then
        return
    end

    if hit.type == "PART" then
        if packet.partID then
            -- 拍照模式下还能点击到零件交互，需屏蔽
            if Me:isCameraMode() then
                return false
            end
        end
    end

    packet.targetPos = hit.worldPos

    Skill.ClickCast(packet)

    if hit.type == "BLOCK" then
        PlayerControl.checkClickChangeBlock(packet.blockPos)
    elseif hit.type=="ENTITY" then

    elseif hit.type == "PART" then
        if packet.partID then
            local part = Instance.getByInstanceId(packet.partID)
            if part and part:isValid() then
                Trigger.CheckTriggers(part._cfg, "PART_CLICKED", {part1 = part, from = Me})
            end
        end
    end
end