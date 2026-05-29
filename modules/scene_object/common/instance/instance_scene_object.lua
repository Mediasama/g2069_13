local Instance = Instance

---@type BrokenItemConfig
local BrokenItemConfig = T(Config, "BrokenItemConfig")
---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")
local setting = require "common.setting"

--- 是否掉落物品
---@return boolean
function Instance:isSceneDropItem()
    if self._isDropItem == nil then
        local drop_item = self:getAttribute("drop_item")
        if drop_item and drop_item == "1" then
            self._isDropItem = true
        else
            self._isDropItem = false
        end
    end
    return self._isDropItem    
end

--- 是否丢弃能力
---@return boolean
function Instance:isDropAbility()
    if self._isDropAbility == nil then
        local drop_ability = self:getAttribute("drop_ability")
        if drop_ability and drop_ability == "1" then
            self._isDropAbility = true
        else
            self._isDropAbility = false
        end
    end
    return self._isDropAbility    
end

--- 是否场景宝箱
---@return boolean
function Instance:isTreasureBox()
    if self._isTreasureBox == nil then
        local treasure_box = self:getAttribute("treasure_box")
        if treasure_box and treasure_box == "1" then
            self._isTreasureBox = true
        else
            self._isTreasureBox = false
        end
    end
    return self._isTreasureBox  
end

--- 是否传送门
---@return boolean
function Instance:isTeleport()
    if self._isTeleport == nil then
        local teleport_id = self:getAttribute("teleport_id")
        if teleport_id and teleport_id ~= "" then
            self._isTeleport = true
        else
            self._isTeleport = false
        end
    end
    return self._isTeleport
end

--- 获取传送门别称
function Instance:getTeleportAlias()
    if self:isTeleport() then
        local teleport_alias = self:getAttribute("teleport_alias")
        if teleport_alias and teleport_alias ~= "" then
            return teleport_alias
        end
    end
    return nil
end

--- 是否初始地图的传送门
function Instance:isNoviceMapTeleport()
    if self:isTeleport() then
        local teleportMap = self:getTeleportMap()
        if teleportMap and teleportMap ~= "" then
            local config = PlayerBornConfig:getCfgByMapName(teleportMap)
            if config.selectableMap == 1 then
                return true
            end
        end
    end
    return false
end

--- 获取传送门开启等级
function Instance:getTeleportOpenLevel()
    if self:isTeleport() then
        local teleport_open_level = self:getAttribute("teleport_open_level")
        if teleport_open_level and teleport_open_level ~= "" then
            return tonumber(teleport_open_level)
        end
    end
    return nil
end

--- 获取传送地图
---@return string
function Instance:getTeleportId()
    if self:isTeleport() then
        local teleport_id = self:getAttribute("teleport_id")
        if teleport_id and teleport_id ~= "" then
            return teleport_id
        end
    end
    return nil
end

--- 获取传送地图
---@return string
function Instance:getTeleportMap()
    if self:isTeleport() then
        local teleport_map = self:getAttribute("teleport_map")
        if teleport_map and teleport_map ~= "" then
            return teleport_map
        end
    end
    return nil
end

--- 判断是否关闭
function Instance:isTeleportClose()
    if self:isTeleport() then
        return self._isTeleportClose or false
    end
    return false
end

--- 设置是否关闭
---@param close any
function Instance:setTeleportClose(close)
    if self:isTeleport() then
        self.isVisible = not close
        self._isTeleportClose = close
    end
end

--- 判断是否副本入口
function Instance:isMissionGate()
    if self._isMissionGate == nil then
        self._isMissionGate = false
        local mission_gate = self:getAttribute("mission_gate")
        if mission_gate and mission_gate == "1" then
            self._isMissionGate = true
        end
    end
    return self._isMissionGate
end

--- 获取任务组
function Instance:getMissionGroup()
    if self:isMissionGate() then
        if not self._missionGroup then
            local mission_group = self:getAttribute("mission_group")
            self._missionGroup = tonumber(mission_group)
        end
        return self._missionGroup
    end
    return nil
end

--- 是否副本关闭
function Instance:isMissionGateClose()
    if self:isMissionGate() then
        return self._isMissionGateClose or false
    end
    return false
end

--- 设置是否关闭
---@param close any
function Instance:setMissionGateClose(close)
    if self:isMissionGate() then
        self.isVisible = not close
        self._isMissionGateClose = close
    end
end

--- 是否火山岩浆
---@return boolean
function Instance:isMagmaPart()
    local partName = self:getProperty("name")
    return partName == "g2069_volcanovillage_terrain_002.mesh"
end

--- 显示传送门信息
function Instance:showTeleportInfo()
    if not self:isTeleport() then
        return
    end
    if not self._sceneTeleportInfo then
        local PartCfg = setting:mod("part")
        local cfg = PartCfg:get("myplugin/scene_ui_teleport")
        ---@type Instance
        local instance = Instance.newInstance(cfg)
        instance:setParent(self)
        self._sceneTeleportInfo = instance
    end
end

--- 显示副本信息
function Instance:showMissionInfo()
    if not self:isMissionGate() then
        return
    end
    if not self._missionInfo then
        local PartCfg = setting:mod("part")
        local cfg = PartCfg:get("myplugin/scene_ui_mission")
        ---@type Instance
        local instance = Instance.newInstance(cfg)
        instance:setParent(self)
        self._missionInfo = instance
    end
end

--- 场景宝箱是否已打开
---@return boolean
function Instance:isOpen()
    if self:isTreasureBox() then
        local open = self:getAttribute("open")
        if open and open == "1" then
            return true
        end
    end
    return false
end

--- 是否可破坏物件
---@return boolean 
function Instance:isBrokenObject()
    if self._isBrokenObject == nil then
        local broken_object = self:getAttribute("broken_object")
        if broken_object and broken_object ~= "" then
            self._isBrokenObject = true
        else
            self._isBrokenObject = false
        end
    end
    return self._isBrokenObject
end

--- 是否已经破坏
---@return boolean
function Instance:isBroken()
    if self:isBrokenObject() then
        local broken = self:getAttribute("broken")
        if broken and broken == "1" then
            return true
        end
    end
    return false
end

--- 设置是否破坏
---@param broken boolean
function Instance:setBroken(broken)
    self:setAttribute("broken", broken and "1" or "0")
end

--- 设置是否打开
---@param open boolean
function Instance:setOpen(open)
    self:setAttribute("open", open and "1" or "0")
end

--- 获取当前血量
function Instance:getCurHp()
    return self._curHp or self:getMaxHp()
end

--- 获取最大血量
function Instance:getMaxHp()
    if self:isBrokenObject() then
        if self._maxHp == nil then
            local broken_object = self:getAttribute("broken_object")
            local config = BrokenItemConfig:getCfgByItemAlias(broken_object)
            self._maxHp = config.hp
        end
        return self._maxHp
    end
    return 1
end

--- 修改血量
---@param hp number 可正负
function Instance:changeHp(hp)
    local maxHp = self:getMaxHp()
    local curHp = self._curHp or maxHp
    if hp > 0 then
        curHp = math.min(curHp + hp, maxHp)
    else
        curHp = math.max(curHp + hp, 0)
    end
    self._curHp = curHp
end

--- 重置血量
function Instance:resetHp()
    self._curHp = self:getMaxHp()
end

--- 获取破碎物复活时间
function Instance:getBrokenRebornTime()
    if self:isBrokenObject() then
        local broken_object = self:getAttribute("broken_object")
        local config = BrokenItemConfig:getCfgByItemAlias(broken_object)
        return config.reborn_time
    end
    return 0
end