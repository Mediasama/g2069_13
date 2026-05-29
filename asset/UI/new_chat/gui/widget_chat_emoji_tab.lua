--表情弹窗Tab
local ChatHelper = T(Lib, "ChatHelper")
local chatSetting = World.cfg.chatSetting

function M:init()
    self.winEmoji=nil
    self.tabType=nil
    self:initUI()
    self:initEvent()
end

function M:initUI()

end

function M:initEvent()
    self.onWindowTouchDown=function()
        self.winEmoji:setTab(self.tabType)
    end
end

function M:initTab(tabConfig,winEmoji)
    self.winEmoji=winEmoji
    if tabConfig then
        self.tabType=tabConfig.tabType
        self.TextTabName:setText(Lang:toText(tabConfig.tabNameText))
    end
end

function M:setSelected(selected)
    self.ImageBG:setVisible(selected)
    local cfg=chatSetting.emojiWinCfg.textColor
    if cfg then
        if selected then
            self.TextTabName:setProperty("TextColours", cfg.selected or "FF100E0D")
        else
            self.TextTabName:setProperty("TextColours", cfg.unselected or "FFEBDAA9")
        end

    end
end



M:init()