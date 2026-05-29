---@class BrokenItemConfig
local BrokenItemConfig = T(Config, "BrokenItemConfig")

local settings = {}

function BrokenItemConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/broken_item.csv", 2)
    for _, vConfig in pairs(config) do
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            item_alias = vConfig.s_item_alias or "",
            hp = tonumber(vConfig.n_hp) or 0,
            reborn_time = tonumber(vConfig.n_reborn_time) or 0,
        }
        settings[data.item_alias] = data
    end
end

function BrokenItemConfig:getCfgByItemAlias(itemAlias)
    if not settings[itemAlias] then
        Lib.logError("Error:Not found the data in broken_item.csv, item alias:", itemAlias)
        return
    end
    return settings[itemAlias]
end

function BrokenItemConfig:getAllCfgs()
    return settings
end

BrokenItemConfig:init()

return BrokenItemConfig

