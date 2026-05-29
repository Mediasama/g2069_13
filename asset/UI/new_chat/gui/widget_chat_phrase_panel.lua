--表情弹窗短语面板
function M:init()
    self:initUI()
    self:initEvent()
end

function M:initUI()
    local ShortConfig = T(Config, "ShortConfig")
    local allCfg = ShortConfig:getAllCfgs()
    for i=1,#allCfg do
        local phraseItem=UI:openWidget("UI/new_chat/gui/widget_chat_phrase_item")
        phraseItem:setData(allCfg[i])
        self.ScrollableView.VerticalLayout:addChild(phraseItem)
    end
end

function M:initEvent()
end


M:init()