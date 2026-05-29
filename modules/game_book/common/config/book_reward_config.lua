---@class BookRewardConfig
local BookRewardConfig = T(Config, "BookRewardConfig")

local settings = {}

function BookRewardConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/book_reward.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {
            Id = tonumber(vConfig.n_Id) or 0,
            collectNum = tonumber(vConfig.n_collectNum) or 0
        }
        local itemAliasList = Lib.splitString(vConfig.s_item_alias or "", "#")
        local itemNumList = Lib.splitString(vConfig.s_item_num or "", "#", true)

        local itemList = {}
        for key, val in pairs(itemAliasList) do
            local item = {}
            item.item_alias = val
            item.item_num = itemNumList[key] or 0
            itemList[#itemList + 1] = item
        end
        data.itemList = itemList
        table.insert(settings, data)
    end
    table.sort(settings, function(a,b)
        return a.collectNum<b.collectNum
    end)
end

function BookRewardConfig:getCfgById(id)
    for _, val in pairs(settings) do
        if val.Id == id then
            return val
        end
    end
    Lib.logError("can not find BookRewardConfig, id:", id )
    return
end

function BookRewardConfig:getAllCfgs()
    return settings
end

BookRewardConfig:init()

return BookRewardConfig

