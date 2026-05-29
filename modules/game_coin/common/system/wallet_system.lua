---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@class WalletSystem
local WalletSystem = T(Lib, "WalletSystem")

function WalletSystem:init()

end

--- 获取金立方
---@param player any
function WalletSystem:getCube(player)
    local wallet = player:data("wallet")
    if wallet and wallet["gDiamonds"] then
        return wallet["gDiamonds"].count or 0
    end
    return 0
end

--- 支付金立方
---@param player any
---@param uniqueId any
---@param count any
---@param callback any
---@param goodsNum any
---@param reason any
function WalletSystem:payCube(player, uniqueId, count, callback, goodsNum, reason)
    Lib.payMoney(player, uniqueId, 0, count, function(success)
        if success and player and player:isValid() then
            Lib.emitEvent(Event.EVENT_GAME_COIN_CHANGE_COIN_NUM, player, Define.ITEM_ALIAS.GOLDEN_CUBE, -count)
        end
        callback(success)
    end, goodsNum, reason)
end

--- 获取货币数量
---@param player any
---@param coinId any
function WalletSystem:getCoin(player, coinName)
    if coinName == Define.ITEM_ALIAS.GOLDEN_CUBE then
        return self:getCube(player)
    else
        local coin = Coin:getCoin(coinName)
        if coin then
            local count = 0
            local item = coin.item
            if item and next(item) then
                count = player:tray():find_item_count(item.type == "Item" and item.name or "/block", item.name)
            else
                local wallet = player:data("wallet")
                if wallet and wallet[coinName] then
                    count = wallet[coinName].count or 0
                end
            end
            return count
        end
    end
    return 0
end

-- --- 判断货币是否足够
-- ---@param player any
-- ---@param coins any
-- ---@param isCheckNull any 是否判空
-- ---@return boolean
-- function WalletSystem:isCoinsEnough(player, coins, isCheckNull)
--     if isCheckNull and (not coins or not next(coins)) then
--         return false
--     end
--     if coins then
--         for coinId, checkCount in pairs(coins) do
--             local coinCount = self:getCoin(player, coinId)
--             if coinCount < checkCount then
--                 return false
--             end
--         end
--     end
--     return true
-- end

-- --- 判读货币是否足够
-- ---@param player any
-- ---@param coinId any
-- ---@param checkCount any
-- ---@return boolean
-- function WalletSystem:isCoinEnough(player, coinId, checkCount)
--     local coinCount = self:getCoin(player, coinId)
--     return coinCount >= checkCount
-- end

--- 消耗游戏内货币
---@param player any
---@param coinId any
---@param costCount any
---@param clear any
---@param check any
---@param reason any
---@param related any
function WalletSystem:payCoinById(player, coinId, costCount, clear, check, reason, related)
    local coinName = ItemConfig:getCfgByItemId(coinId).item_alias
    self:payCoin(player, coinName, costCount, clear, check, reason, related)
end

--- 通过货币名称消耗货币
---@param player any
---@param coinName any
---@param costCount any
---@param clear any
---@param check any
---@param reason any
---@param related any
function WalletSystem:payCoin(player, coinName, costCount, clear, check, reason, related)
    player:payCurrency(coinName, costCount, clear, check, reason, related)

    Lib.emitEvent(Event.EVENT_GAME_COIN_CHANGE_COIN_NUM, player, coinName, -costCount)
end

--- 添加游戏内货币
---@param player any
---@param coinId any
---@param addCount any
---@param reason any
---@param related any
function WalletSystem:addCoinById(player, coinId, addCount, reason, related)
    local coinName = ItemConfig:getCfgByItemId(coinId).item_alias
    self:addCoin(player, coinName, addCount, reason, related)
end

--- 通过货币名称添加货币
---@param player any
---@param coinName any
---@param addCount any
---@param reason any
---@param related any
function WalletSystem:addCoin(player, coinName, addCount, reason, related)
    --- 禁止添加金魔方
    if coinName == Define.ITEM_ALIAS.GOLDEN_CUBE then
        Lib.logError("Error:Prohibit adding currency, coin name:", coinName)
        return
    end
    player:addCurrency(coinName, addCount, reason, related)
    Lib.emitEvent(Event.EVENT_GAME_COIN_CHANGE_COIN_NUM, player, coinName, addCount)
end

WalletSystem:init()
