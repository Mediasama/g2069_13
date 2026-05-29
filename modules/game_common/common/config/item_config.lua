---@class ItemConfig
local ItemConfig = T(Config, "ItemConfig")

local settings = {}
local alias2settings = {}

local PARAM_TYPE = {
    NUMBER = "n",               --- 数值型
    MAP = "map",                --- kv集合
    NUMBER_MAP = "nmap",        --- kv集合，v为number
    LIST = "ls",                --- 字符串数组
    NUMBER_LIST = "ln",         --- 数值型数组
    STRING = "s",               --- 字符串
    VECTOR3 = "v3",             --- Vector3
}

local key2type = {
    box_id = PARAM_TYPE.NUMBER,
    buff_id = PARAM_TYPE.NUMBER,
    ability_id = PARAM_TYPE.NUMBER,
    income_decay = PARAM_TYPE.NUMBER,
}

--- 自定义参数转换
---@param params any
local parseParam = function(params)
    if not params or params == "" then
        return nil
    end
    local t = {}
    local list = Lib.splitString(params, ",")
    for i = 1, #list, 1 do
        local args = Lib.splitString(list[i], "#")
        local key = args[1]
        local type = key2type[key] or "s"
        if type == PARAM_TYPE.NUMBER then
            --- 数字
            t[key] = tonumber(args[2])
        elseif type == PARAM_TYPE.VECTOR3 then
            --- 坐标
            t[key] = Vector3.new(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
        elseif type == PARAM_TYPE.NUMBER_LIST then
            --- 数字数组
            t[key] = {}
            for j = 2, #args, 1 do
                t[key][#t[key] + 1] = tonumber(args[j])
            end
        elseif type == PARAM_TYPE.LIST then
            --- 字符串数组
            t[key] = {}
            for j = 2, #args, 1 do
                t[key][#t[key] + 1] = args[j]
            end
        elseif type == PARAM_TYPE.MAP then
            for j = 2, #args, 2 do
                t[key][args[j]] = args[j + 1]
            end
        elseif type == PARAM_TYPE.NUMBER_MAP then
            for j = 2, #args, 2 do
                t[key][args[j]] = tonumber(args[j + 1])
            end
        else
            t[key] = args[2]
        end
    end
    return t
end

function ItemConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/item.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            item_id = tonumber(vConfig.n_item_id) or 0,
            item_alias = vConfig.s_item_alias or "",
            name = vConfig.s_name or "",
            desc = vConfig.s_desc or "",
            type_alias = vConfig.s_type_alias or "",
            sub_type_alias = vConfig.s_sub_type_alias or "",
            quality_alias = vConfig.s_quality_alias or "",
            icon = vConfig.s_icon or "",
            small_icon = vConfig.s_small_icon or "",
            res_name = vConfig.s_res_name or "",
            isOverlay = tonumber(vConfig.n_isOverlay) or 0,
            params = parseParam(vConfig.s_params),
            recycling_time = tonumber(vConfig.n_recycling_time) or 0,
            isDiscard = tonumber(vConfig.n_isDiscard) or 0,
            isUse = tonumber(vConfig.n_isUse) or 0,
        }
        settings[data.item_id] = data
        alias2settings[data.item_alias] = data
    end
end

--- 通过物品id获取数据
---@param itemId any
function ItemConfig:getCfgByItemId(itemId)
    if not settings[itemId] then
        Lib.logError("Error:Not found the data in item.csv, item id:", itemId)
        return
    end
    return settings[itemId]
end

--- 通过物品id别称获取数据
---@param itemId any
function ItemConfig:getCfgByItemAlias(alias)
    if not alias2settings[alias] then
        Lib.logError("Error:Not found the data in item.csv, item alias:", alias)
        return
    end
    return alias2settings[alias]
end

function ItemConfig:getName(alias)
    local config = self:getCfgByItemAlias(alias)
    return config.name
end

function ItemConfig:getIcon(alias)
    local config = self:getCfgByItemAlias(alias)
    return config.icon
end

function ItemConfig:getTypeByItemId(itemId)
    local config = self:getCfgByItemId(itemId)
    return config.type_alias
end

function ItemConfig:getAliasByItemId(itemId)
    local config = self:getCfgByItemId(itemId)
    return config.item_alias
end

function ItemConfig:getItemListByType(type)
    local itemList = nil
    for _, config in pairs(settings) do
        if config.type_alias == type then
            itemList = itemList or {}
            itemList[#itemList + 1] = config
        end
    end
    return itemList
end

function ItemConfig:getAllCfgs()
    return settings
end

ItemConfig:init()

return ItemConfig

