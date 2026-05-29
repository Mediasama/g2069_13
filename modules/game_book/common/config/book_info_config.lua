---@class BookInfoConfig
local BookInfoConfig = T(Config, "BookInfoConfig")

local settings = {}

function BookInfoConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/book_info.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {
            Id = tonumber(vConfig.n_Id) or 0,
            abilityId = tonumber(vConfig.n_abilityId) or 0,
            abilityRole = vConfig.s_abilityRole or "",
            showPosY = tonumber(vConfig.n_showPosY) or 0,
        }
        table.insert(settings, data)
    end
end

function BookInfoConfig:getCfgById(abilityId)
    for _, val in pairs(settings) do
        if val.abilityId == abilityId then
            return val
        end
    end
    Lib.logError("can not find cfgBookInfoConfig, abilityId:", abilityId )
    return
end

function BookInfoConfig:getAllCfgs()
    return settings
end

BookInfoConfig:init()

return BookInfoConfig

