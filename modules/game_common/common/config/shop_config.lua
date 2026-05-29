---@class ShopConfig
local ShopConfig = T(Config, "ShopConfig")

local settings = {}

function ShopConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/shop.csv", 2)
    for _, vConfig in pairs(config) do
        local item = Lib.splitString(vConfig.s_item, "#")
        item = { item_alias = item[1], item_num = tonumber(item[2]) }
        --- 消耗
        local cost = Lib.splitString(vConfig.s_cost, "#")
        cost = { item_alias = cost[1], item_num = tonumber(cost[2]) }

        local data = {
            shop_id = tonumber(vConfig.n_shop_id) or 0,
            shop_alias = vConfig.s_shop_alias or "", 
            shop_name = vConfig.s_shop_name or "",
            shop_desc = vConfig.s_shop_desc or "",
            item = item,
            tab = vConfig.s_tab or "",
            sort = tonumber(vConfig.n_sort) or 0,
            cost = cost,
            display = tonumber(vConfig.n_display) or 0,
            is_use = tonumber(vConfig.n_is_use) or 0,
            purchase_limit = tonumber(vConfig.n_purchase_limit) or 0,
        }
        settings[data.shop_id] = data
    end
end

function ShopConfig:getCfgByShopId(shopId)
    if not settings[shopId] then
        Lib.logError("Error:Not found the data in shop.csv, shop id:", shopId)
    end
    return settings[shopId]
end

function ShopConfig:getAllCfgs()
    return settings
end

--- 获取商店物品
---@param shopTab string
---@param display boolean 是否检测display，默认nil为false，获取全部商品
---@return table 对应tab所有商品
function ShopConfig:getShopItemsByShopTab(shopTab, display)
    display = display and 1 or nil

    local items = {}
    for _, config in pairs(settings) do
        if config.tab == shopTab and (not display or config.display == display) then
            items[#items + 1] = config
        end
    end
    if #items > 1 then
        table.sort(items, function(e1, e2)
            return e1.sort < e2.sort
        end)
    end
    return items
end

ShopConfig:init()

return ShopConfig

