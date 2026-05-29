---@class BusinessSystem
local BusinessSystem = T(Lib, "BusinessSystem")
---@type ShopConfig
local ShopConfig = T(Config, "ShopConfig")

function BusinessSystem:init()

end

--- 添加数据
---@param player any
---@param shopId any
function BusinessSystem:addPurchaseData(player, shopId)
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        local purchase_limit = ShopConfig:getCfgByShopId(shopId).purchase_limit
        if purchase_limit ~= 0 then
            businessComponent:addPurchaseData(shopId)
        end
    end
end

--- 获取数据
---@param player any
---@param shopId any
---@param defaultValue any
function BusinessSystem:getPurchaseData(player, shopId, defaultValue)
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        return businessComponent:getPurchaseData(shopId)
    end
    return defaultValue or 0
end

--- 设置数据
---@param player any
---@param shopId any
---@param value any
function BusinessSystem:setPurchaseData(player, shopId, value)
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        businessComponent:setPurchaseData(shopId, value)
    end
end

--- 判断是否能交易
---@param player any
---@param shopId any
function BusinessSystem:checkCanPurchase(player, shopId)
    ---@type BusinessComponent
    local businessComponent = player:getComponent("business")
    if businessComponent then
        local num = businessComponent:getPurchaseData(shopId)
        local purchase_limit = ShopConfig:getCfgByShopId(shopId).purchase_limit
        if purchase_limit == 0 or num < purchase_limit then
            return true
        end
    end
    return false
end

BusinessSystem:init()

return BusinessSystem