--表情弹窗中的表情widget
local ChatHelper = T(Lib, "ChatHelper")

function M:init()
    self.emojiIndex=1
    self:initUI()
    self:initEvent()
end

function M:initUI()

end

function M:initEvent()
    self.Image.onWindowClick=function()
        self:sendEmoji()
    end
end

function M:sendEmoji()
    local chatPage=ChatHelper:getCurPage()
    local chatTarget=ChatHelper:getCurChatTarget()
    if not ChatHelper:canSend(chatPage) then
        Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
        return
    end
    print("M:sendEmoji() ",chatPage,chatTarget)
    ChatHelper:sendChatMsg(chatPage, {
        fromId = Me.platformUserId,
        msg = self.emojiIndex,
        msgType = Define.MsgType.Emoji,
        targetUserId =chatTarget
    })
end

function M:setData(cfg)
    if cfg then
        self.emojiIndex=cfg.id
        self.Image:setImage(cfg.icon)
    end
end


M:init()