---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type singleton
local singleton = require "common.3rd.middleclass.singleton"
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type WorldServer
local CW = World.CurWorld

local down = Vector3.new(0, -1, 0)
local forward = Vector3.new(0, 0, 1)

local setCollisionGroup

---@param cfg any
---@param collisionGroup any
setCollisionGroup = function(cfg, collisionGroup)
    cfg.properties.collisionGroup = collisionGroup
    local children = cfg.children
    if children then
        for _, child in pairs(children) do
            setCollisionGroup(child, collisionGroup)
        end
    end
end

---@class SceneObjectManagerServer : singleton
local SceneObjectManagerServer = class("SceneObjectManagerServer")
SceneObjectManagerServer:include(singleton)

--- 初始化
function SceneObjectManagerServer:initialize()
    self.isInited = false
    self.instances = {}
    --- 场景宝箱
    self.mapItems = {}
    --- 破坏物品
    self.brokenObjects = {}
    self.roots = {}
    self.instanceCfgs = {}
    self.events = {}
    self.timer = nil
end

function SceneObjectManagerServer:init()
    if self.isInited then
        return
    end
    self.isInited = true

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_ITEM, function(entity, part)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_OBTAIN_ITEM, entity, part)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_ABILITY, function(entity, part)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_OBTAIN_ABILITY, entity, part)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_OBTAIN_TREASURE_BOX, function(entity, part)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_OBTAIN_TREASURE_BOX, entity, part)
    end)

    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_INIT_MAP, function(map)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_INIT_MAP, map)
    end)
    
    self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_OBJECT_HIT_PART, function(entity, part)
        self:onEventHandler(Event.EVENT_SCENE_OBJECT_HIT_PART, entity, part)
    end)
    

    self.timer = LuaTimer:scheduleTicker(function()
        self:tick(0.05)
    end, 1)
end

---事件处理
---@param event any
function SceneObjectManagerServer:onEventHandler(event, ...)
    if event == Event.EVENT_SCENE_OBJECT_INIT_MAP then
        -- local args = { ... }
        -- local map = args[1]
        -- local mapName = map.name
        -- --- 获取场景物品
        -- local config = SceneItemConfig:getCfgByMapName(mapName)
        -- if config and not self.mapItems[mapName] then
        --     local reborn_time = config.reborn_time
        --     local mapItems = {}
        --     self.mapItems[mapName] = mapItems
        --     local items = config.items
        --     local positions = config.positions

        --     --- 测试位置
        --     ---@type Vector3
        --     -- local bornPosition = PlayerBornConfig:getCfgByMapName(mapName).bornPosition
        --     -- local forward = Vector3.new(0,0,1)

        --     for i = 1, #items, 1 do
        --         local data = {}
        --         --- 测试位置
        --         -- local angle = math.random(0, 359)
        --         -- local q = Quaternion.fromEulerAngle(0, angle, 0)
        --         -- data.position = bornPosition + q * (forward * 2)
        --         data.position = positions[i]

        --         local type_alias = ItemConfig:getCfgByItemAlias(items[i]).type_alias
        --         data.item_alias = items[i]
        --         data.collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP[type_alias] or Define.SCENE_OBJECT_COLLISION_GROUP.DEFAULT
        --         local itemType = ItemConfig:getCfgByItemAlias(items[i]).type_alias
        --         if itemType == Define.ITEM_TYPE.CHEST then
        --             data.attributes = { treasure_box = "1", map_name = mapName, index = i }
        --         end
        --         data.reborn_time = reborn_time
        --         data.time = -1
        --         data.instance = self:createInstanceByItemAlias(map, data.item_alias, data.position, nil, data.attributes)
        --         mapItems[#mapItems + 1] = data
        --     end
        -- end
    elseif event == Event.EVENT_SCENE_OBJECT_OBTAIN_TREASURE_BOX then

        local args = { ... }
        ---@type Entity
        local entity = args[1]
        ---@type Instance
        local part = args[2]

        --- 已打开
        if not part:isTreasureBox() or part:isOpen() then
            return
        end
        ---@type MapServer
        local map = part:GetMap()
        local mapName = map.name
        local instanceId = part:getInstanceID()
        local reborn_time = tonumber(part:getAttribute("reborn_time"))

        self.mapItems[mapName] = self.mapItems[mapName] or {}
        self.mapItems[mapName][instanceId] = self.mapItems[mapName][instanceId] or { instance = part }
        self.mapItems[mapName][instanceId].time = reborn_time

        part.collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP.NONE
        part:setOpen(true)

        --- 触发打开宝箱
        map:broadcastPacket({
            pid = "S2CTreasureBoxOpen",
            instanceId = part:getInstanceID(),
            objId = entity.objID
        })

        --- 宝箱id
        local itemAlias = part:getAttribute("item_alias")

        Plugins.CallTargetPluginFunc("game_role_common", "gainTreasureBox", entity, itemAlias)
    elseif event == Event.EVENT_SCENE_OBJECT_OBTAIN_ITEM then
        
        local args = { ... }
        ---@type Entity
        local entity = args[1]
        ---@type Instance
        local part = args[2]
        --- 宝箱id
        local itemId = tonumber(part:getAttribute("item_id"))

        self:destroyInstance(part)
        
        Plugins.CallTargetPluginFunc("game_role_common", "gainDropItem", entity, itemId)
    elseif event == Event.EVENT_SCENE_OBJECT_OBTAIN_ABILITY then
        local args = { ... }
        ---@type Entity
        local entity = args[1]
        ---@type Instance
        local part = args[2]

        local itemId = tonumber(part:getAttribute("item_id"))
        local aid = part:getAttribute("aid")

        self:destroyInstance(part)
        --- 拾取能力
        Plugins.CallTargetPluginFunc("game_role_common", "addDropAbility", entity, aid, itemId)
    elseif event == Event.EVENT_SCENE_OBJECT_HIT_PART then
        local args = { ... }
        ---@type Entity
        local entity = args[1]
        ---@type Instance
        local part = args[2]
        if not part:isBrokenObject() or part:isBroken() then
            return
        end
        part:changeHp(-1)
        if part:getCurHp() <= 0 then
            ---@type MapServer
            local map = part:GetMap()
            local mapName = map.name
            local instanceId = part:getInstanceID()
            local brokenObjects = self.brokenObjects[mapName] or {}
            self.brokenObjects[mapName] = brokenObjects
            --- 触发客户端表现
            local data = brokenObjects[instanceId] or { instance = part, time = -1 }
            brokenObjects[instanceId] = data

            data.time = part:getBrokenRebornTime()
            part.collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP.NONE
            part:setBroken(true)
            
            map:broadcastPacket({
                pid = "S2CSceneObjectBroken",
                instanceId = part:getInstanceID(),
                objId = entity.objID,
            })
        end
    end
end

--- 丢弃物品
---@param entity Entity
---@param item Item
function SceneObjectManagerServer:onDropItem(entity, item)
    local itemId = item:getItemId()
    ---@type Vector3
    local position = entity:getPosition()
    --- 处理位置
    local height = entity:cfg().collider.height
    ---@type Quaternion
    local q = Quaternion.fromEulerAngle(0, 360 - entity:getRotationYaw(), 0)
    position = position + q * (forward * 2)

    local posY = position.y
    position.y = posY + height
    ---@type World
    local world = entity.map:getPhysicsWorld()
    local result = world:raycast(position, down, height * 2, 1)
    if result and result.collidePos then
        position.y = result.collidePos.y
    else
        position.y = posY
    end

    self:createInstance(entity.map, itemId, position, nil, { drop_item = 1})
end

--- 丢弃能力
---@param entity Entity
---@param ability Ability
function SceneObjectManagerServer:onDropAbility(entity, ability)
    local aid = ability:getId()
    local itemId = ability:getItemId()
    ---@type Vector3
    local position = entity:getPosition()
    --- 处理位置
    local height = entity:cfg().collider.height
    ---@type Quaternion
    local q = Quaternion.fromEulerAngle(0, 360 - entity:getRotationYaw(), 0)
    position = position + q * (forward * 2)

    local posY = position.y
    position.y = posY + height
    ---@type World
    local world = entity.map:getPhysicsWorld()
    local result = world:raycast(position, down, height * 2, 1)
    if result and result.collidePos then
        position.y = result.collidePos.y
    else
        position.y = posY
    end

    self:createInstance(entity.map, itemId, position, nil, { drop_ability = 1, aid = aid })

end

--- 获取文件名
---@param itemId any
---@return table json内容
function SceneObjectManagerServer:getItemPartCfg(itemId)
    if not self.instanceCfgs[itemId] then
        local config = ItemConfig:getCfgByItemId(itemId)
        local resName = config.res_name
        if not resName or resName == "" then
            Lib.logError("Error:Not found the resource name in item.csv, item id:", itemId, " resName:", tostring(resName))
        end
        resName = "child." .. resName .. ".json"
        local gamePath = Root.Instance():getGamePath()
        local cfg = Lib.read_json_file(gamePath .. "part_storage/" .. resName)
        if not cfg then
            Lib.logError("Error:Not found the json file in path part_storage/, json name:", tostring(resName), " gamePath:", gamePath)
        end
        if cfg.properties then
            cfg.properties.id = nil
            local collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP[config.type_alias] or Define.SCENE_OBJECT_COLLISION_GROUP.DEFAULT
            cfg.properties.needSync = "true"
            setCollisionGroup(cfg, collisionGroup)
        end
        self.instanceCfgs[itemId] = cfg
    end
    return self.instanceCfgs[itemId]
end

--- 获取父节点
---@param map any
---@param itemId any
---@return Instance 父节点
function SceneObjectManagerServer:getRoot(map, itemId)
    local mapName = map.name
    local rootName = "scene_object_root"
    --- 可以依据类型创建不同父节点

    if self.roots[mapName] and self.roots[mapName][rootName] then
        return self.roots[mapName][rootName]
    end
    self.roots[mapName] = self.roots[mapName] or {}
    ---@type World
    local CW = World.CurWorld
    local scene = CW:getScene(map.obj)
    ---@type Instance
    local root = scene:getRoot()
    ---@type Instance
    local parent = Instance.Create("EmptyNode")
    parent:setParent(root)
    parent:setProperty("name", rootName)
    self.roots[mapName][rootName] = parent
    return parent
end

--- 创建物品
---@param map any
---@param itemId any
---@param position any
---@param rotation any
function SceneObjectManagerServer:createInstance(map, itemId, position, rotation, attributes)
    local cfg = self:getItemPartCfg(itemId)
    ---@type Instance
    local instance = Instance.newInstance(cfg, map)
    if instance then
        local parent = self:getRoot(map, itemId)
        instance:setParent(parent)
        instance:setAttribute("item_id", itemId)
        if attributes then
            for key, value in pairs(attributes) do
                instance:setAttribute(key, value)
            end
        end
        if position then
            instance:setPosition(position)
        end
        if rotation then
            instance:setRotation(rotation)
        end
        local instanceId = instance:getInstanceID()

        local config = ItemConfig:getCfgByItemId(itemId)

        self.instances[instanceId] = { instance = instance, time = config.recycling_time }

        return instance
    end
    return nil
end

--- 依据物品别名创建
---@param map any
---@param itemAlias any
---@param position any
---@param rotation any
---@param attributes any
function SceneObjectManagerServer:createInstanceByItemAlias(map, itemAlias, position, rotation, attributes)
    local itemId = ItemConfig:getCfgByItemAlias(itemAlias).item_id
    return self:createInstance(map, itemId, position, rotation, attributes)
end

--- 移除
---@param instance Instance
function SceneObjectManagerServer:destroyInstance(instance)
    if instance:isValid() then
        local instanceId = instance:getInstanceID()
        self.instances[instanceId] = nil
        instance:destroy()
    end
end

--- 心跳函数
---@param deltaTime number 时间间隔，单位秒
function SceneObjectManagerServer:tick(deltaTime)
    ------------------------- begin 宝箱处理 ----------------------- 
    local list = nil
    for mapName, items in pairs(self.mapItems) do
        for instanceId, data in pairs(items) do
            if data.time > 0 then
                data.time = data.time - deltaTime
                if data.time <= 0 then
                    data.time = -1
                    ---@type Instance
                    local instance = data.instance
                    instance.collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP.CHEST
                    instance:setOpen(false)
                    list = list or {}
                    list[mapName] = list[mapName] or {}
                    list[mapName][#list[mapName] + 1] = instanceId
                end
            end
        end
    end
    if list then
        for mapName, ids in pairs(list) do
            ---@type MapServer
            local map = CW:getOrCreateStaticMap(mapName)
            map:broadcastPacket({
                pid = "S2CTreasureBoxReborn",
                ids = ids,
            })
        end
        list = nil
    end
    ------------------------- end 宝箱处理 -----------------------

    ------------------------- begin 破碎物件处理 -----------------------
    for mapName, objects in pairs(self.brokenObjects) do
        for instanceId, data in pairs(objects) do
            local time = data.time
            if time > 0 then
                time = time - deltaTime
                data.time = time
                if time <= 0 then
                    ---@type Instance
                    local instance = data.instance
                    instance.collisionGroup = Define.SCENE_OBJECT_COLLISION_GROUP.BROKEN_OBJECT
                    instance:setBroken(false)
                    instance:resetHp()
                    --- 记录同步数据
                    list = list or {}
                    list[mapName] = list[mapName] or {}
                    list[#list + 1] = instanceId
                end
            end
        end
        
    end
    if list then
        for mapName, ids in pairs(list) do
            ---@type MapServer
            local map = CW:getOrCreateStaticMap(mapName)
            map:broadcastPacket({
                pid = "S2CBrokenObjectReborn",
                ids = ids,
            })
        end
        list = nil
    end
    ------------------------- end 破碎物件处理 -----------------------


    ------------------------- begin 零件处理 -------------------------
    for instanceId, data in pairs(self.instances) do
        local time = data.time
        if time and time > 0 then
            time = time - deltaTime
            data.time = time
            if time <= 0 then
                list = list or {}
                list[instanceId] = data.instance
            end
        end
    end
    if list then
        for instanceId, instance in pairs(list) do
            self:destroyInstance(instance)
        end
        list = nil
    end
    ------------------------- end 零件处理 -------------------------
end

return SceneObjectManagerServer