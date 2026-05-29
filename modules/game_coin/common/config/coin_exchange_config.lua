---@class CoinExchangeConfig
local CoinExchangeConfig = T(Config, "CoinExchangeConfig")

local settings = {}

function CoinExchangeConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/coin_exchange.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            coin_id = tonumber(vConfig.n_coin_id) or 0,
            cost = tonumber(vConfig.n_cost) or 0,
            num = tonumber(vConfig.n_num) or 0
        }
        settings[data.id] = data
    end
end

--- 获取配置
---@param coinId number 货币id
---@return table { id, coin_id, cost, num }
function CoinExchangeConfig:getCfgById(id)
    if not settings[id] then
        Lib.logError("Error:Not found the data in coin_exchange.csv, id:", id)
    end
    return settings[id]
end

function CoinExchangeConfig:getAllCfgs()
    return settings
end

--- 获取兑换列表
---@param coinId any
---@param sort any
---@return table { { id, coin_id, cost, num } }
function CoinExchangeConfig:getCoinExchangeList(coinId, sort)
    local list = {}    
    for id, config in pairs(settings) do
        if config.coin_id == coinId then
            list[#list + 1] = config
        end
    end
    if sort then
        table.sort(list, function(e1, e2)
            return e1.id < e2.id
        end)
    end
    return list
end

--- 获取货币id
---@param id any
function CoinExchangeConfig:getCoinId(id)
    local config = self:getCfgById(id)
    return config.coin_id
end

--- 获取兑换数量
---@param id any
function CoinExchangeConfig:getNum(id)
    local config = self:getCfgById(id)
    return config.num
end

CoinExchangeConfig:init()

return CoinExchangeConfig

