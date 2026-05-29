---@class PlayerActionConfig
local PlayerActionConfig = T(Config, "PlayerActionConfig")

local settings = {}
local sortedList={}

function PlayerActionConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/player_action.csv", 2)
    for _, vConfig in pairs(config) do
        ---@class PlayerActionItem
        local data = {
            id = tonumber(vConfig.n_id) or 0,
            anim = vConfig.s_anim or "",
            sort = tonumber(vConfig.n_sort) or 0,
            icon = vConfig.s_icon or "",
        }
        settings[data.id] = data
    end
    for _, v in pairs(settings) do
        table.insert(sortedList,v)
    end
    table.sort(sortedList,function(a,b)
        return a.sort<b.sort
    end)
end

---@return PlayerActionItem
function PlayerActionConfig:getCfgById(id)
    if not settings[id] then
        Lib.logError("can not find PlayerActionConfig, id:", id )
        return
    end
    return settings[id]
end

----@return PlayerActionItem[]
function PlayerActionConfig:getAllCfgs()
    return settings
end

----@return PlayerActionItem[]
function PlayerActionConfig:getSortedList()
    return sortedList
end

PlayerActionConfig:init()

return PlayerActionConfig

