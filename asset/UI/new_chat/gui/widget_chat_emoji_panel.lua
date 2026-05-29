--表情弹窗表情面板
function M:init()

    self:initUI()
    self:initEvent()
end

function M:initUI()
    local EmojiConfig = T(Config, "EmojiConfig")
    local allEmojiCfg = EmojiConfig:getAllCfgs()
    for i=1,#allEmojiCfg do
        local emojiItem=UI:openWidget("UI/new_chat/gui/widget_chat_emoji_item")
        emojiItem:setData(allEmojiCfg[i])
        self.ScrollableView.GridView:addChild(emojiItem)
    end
end

function M:initEvent()
end


M:init()