---@class NpcConfig
local NpcConfig = T(Config, "NpcConfig")

local settings = {}

function NpcConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {
            npcId = vConfig.s_npcId or "",
            dialogGroupID = tonumber(vConfig.n_dialogGroupID) or 0,
            npcShowName = vConfig.s_npcShowName or "",
            npcShowIcon = vConfig.s_npcShowIcon or "",
        }
        if vConfig.s_npcShowTime and vConfig.s_npcShowTime ~= "" then
            data.npcShowTime = {}
            local info = Lib.splitString(vConfig.s_npcShowTime, "$")
            for _, val in pairs(info) do
                local temp = Lib.splitString(val, "#")
                local oneTime = {}
                oneTime.startTime = Lib.splitString(temp[1], ":", true)
                oneTime.endTime = Lib.splitString(temp[2], ":", true)
                table.insert(data.npcShowTime, oneTime)
            end
        end
        settings[data.npcId] = data
    end
end

function NpcConfig:getCfgById(npcId)
    if not settings[npcId] then
        Lib.logError("can not find cfgNpcConfig, npcId:", npcId )
        return
    end
    return settings[npcId]
end

function NpcConfig:getAllCfgs()
    return settings
end

NpcConfig:init()

return NpcConfig

