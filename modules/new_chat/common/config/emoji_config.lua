---@class EmojiConfig
local EmojiConfig = T(Config, "EmojiConfig")
local setting = {}

function EmojiConfig:init()
    local csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "modules/new_chat/csv/emoji.csv", 2)
    if not csvData then
        csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "modules/new_chat/csv/emoji.csv", 2) or {}
    end
    for _, config in pairs(csvData) do
        local data = {
            id = tonumber(config.id),
            icon = config.icon,
            text = config.text
        }
        setting[data.id] = data
    end

    table.sort(setting, function(a, b )
        return a.id < b.id
    end)
end

function EmojiConfig:getAllCfgs()
    return setting
end

function EmojiConfig:getCfgById(id)
    for _, data in pairs(setting) do
        if data.id == id then
            return data
        end
    end
end

function EmojiConfig:getIconByText(text)
    for i, v in pairs(setting) do
        if v.text == text then
            return v.icon
        end
    end
    return nil
end

EmojiConfig:init()
return EmojiConfig