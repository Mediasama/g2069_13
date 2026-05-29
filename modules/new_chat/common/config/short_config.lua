---@class ShortConfig
local ShortConfig = T(Config, "ShortConfig")
local setting = {}

function ShortConfig:init()
    local csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "modules/new_chat/csv/short.csv", 2)
    if not csvData then
        csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "modules/new_chat/csv/short.csv", 2) or {}
    end
    for _, config in pairs(csvData) do
        local data = {
            id = tonumber(config.id),
            name = config.name,
            text = config.text,
            event = config.event,
            eventArgs = config.eventArgs
        }
        table.insert(setting, data)
    end

    table.sort(setting, function(a, b )
        return a.id < b.id
    end)
end

function ShortConfig:getAllCfgs()
    return setting or {}
end

function ShortConfig:getCfgById(id)
    for _, v in pairs(setting) do
        if v.id == id then
            return v
        end
    end
end

function ShortConfig:getShortMsgByText(text)
    for i, v in pairs(setting) do
        if v.text == text then
            return v
        end
    end
end

ShortConfig:init()
return ShortConfig