---@class AttributeInfoConfig
local AttributeInfoConfig = T(Config, "AttributeInfoConfig")
---@class AttributeLevelConfig
local AttributeLevelConfig = T(Config, "AttributeLevelConfig")

local settings = {}
local levelSettings = {}


function AttributeInfoConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/attribute_info.csv", 2)
    for _, vConfig in pairs(config) do
        local comp_attr_ids = nil
        if vConfig.s_comp_attr_ids and vConfig.s_comp_attr_ids ~= "" then
            comp_attr_ids = Lib.splitString(vConfig.s_comp_attr_ids, "#")
        end
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            attr_id = vConfig.s_attr_id or "",
            attr_type = tonumber(vConfig.n_attr_type) or 0,
            name = vConfig.s_name or "",
            desc = vConfig.s_desc or "",
            base_value = tonumber(vConfig.n_base_value) or 0,
            max_value = tonumber(vConfig.n_max_value),
            min_value = tonumber(vConfig.n_min_value),
            comp_attr_ids = comp_attr_ids,
            inc_rates = vConfig.s_inc_rates or "",
            sort_index = tonumber(vConfig.n_sort_index) or 0,
            icon = vConfig.s_icon or "",
        }
        settings[data.attr_id] = data
    end

    for attrId, data in pairs(settings) do
        if data.attr_type == 2 then
            AttributeLevelConfig:init(attrId)
        end
    end
end


--- 获取属性信息
---@param id any
function AttributeInfoConfig:getCfgByAttributeId(id)
    if not settings[id] then
        Lib.logError("Error:Not found the data in attribute_info.csv, attribute id:", id)
    end
    return settings[id]
end

--- 获取属性基础值
---@param id any
---@return number
function AttributeInfoConfig:getBaseValue(id)
    local config = self:getCfgByAttributeId(id)
    return config.base_value
end

function AttributeInfoConfig:getMaxValue(id)
    local config = self:getCfgByAttributeId(id)
    return config.max_value
end

function AttributeInfoConfig:getMinValue(id)
    local config = self:getCfgByAttributeId(id)
    return config.min_value
end

function AttributeInfoConfig:getAllCfgs()
    return settings
end

--- 获取对应属性的二级属性组成
---@param id any
---@return table 属性id数组
function AttributeInfoConfig:getCompositeAttributeIds(id)
    local config = self:getCfgByAttributeId(id)
    return config.comp_attr_ids
end

--- 获取属性信息
---@param attributeType any
function AttributeInfoConfig:getAttributesByType(attributeType)
    local attributes = {}
    for _, config in pairs(settings) do
        if config.attr_type == attributeType then
            attributes[#attributes + 1] = config
        end
    end
    table.sort(attributes, function(e1, e2)
        return e1.sort_index < e2.sort_index
    end)
    return attributes
end

----------------------------------- 等级数据 --------------------------------------

local copy = function(tb)
    local t = {}
    if tb then
        for k, v in pairs(tb) do
            if settings[k] then
                t[k] = tonumber(v)
            end
        end
    end
    return t
end

function AttributeLevelConfig:init(id)
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/" .. id .. "_level_mapping.csv", 2)
    levelSettings[id] = {}
    for _, vConfig in pairs(config) do
        local level = tonumber(vConfig.n_id)
        levelSettings[id][level] = copy(vConfig)
    end
end

function AttributeLevelConfig:getCfg(id)
    if not levelSettings[id] then
        Lib.logError("Error:Not found the attribute level mapping data, attribute id:", id)
    end
    return levelSettings[id]
end

function AttributeLevelConfig:getCfgByLevel(id, level)
    local configs = self:getCfg(id)
    if not configs[level] then
        Lib.logError("Error:Not found the attribute level data, attribute id:", id, " level:", level)
    end
    return configs[level]
end

function AttributeLevelConfig:getMaxLevel(id)
    local configs = self:getCfg(id)
    return #configs
end

AttributeInfoConfig:init()

return AttributeInfoConfig

