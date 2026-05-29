---@class WidgetRankItemWidget : CEGUILayout
local WidgetRankItemWidget = M

local RankBG={
    "set:list.json image:img_9_1bottom",
    "set:list.json image:img_9_2bottom",
    "set:list.json image:img_9_3bottom",
    "set:list.json image:img_9_line"
}
local RankIcon={
    "set:list.json image:img_0_1",
    "set:list.json image:img_0_2",
    "set:list.json image:img_0_3"
}
local RankColor={
    "FFB2420A",
    "FF055FD9",
    "FF743C37",
    "FF4F463F",
}

---@private
function WidgetRankItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetRankItemWidget:findAllWindow()
    ---@type CEGUIStaticImage
    self.siImageBG = self.ImageBG
    ---@type CEGUIStaticText
    self.stTextLv = self.TextLv
    ---@type CEGUIStaticText
    self.stTextName = self.TextName
    ---@type CEGUIStaticText
    self.stTextRank = self.TextRank
    ---@type CEGUIStaticText
    self.stTextBattle = self.TextBattle
    ---@type CEGUIStaticImage
    self.siImageRank = self.ImageRank
end

---@private
function WidgetRankItemWidget:initUI()
    --self.stTextLv:setText(Lang:toText(""))
    --self.stTextName:setText(Lang:toText(""))
    --self.stTextRank:setText(Lang:toText(""))
    --self.stTextBattle:setText(Lang:toText(""))
end

---@private
function WidgetRankItemWidget:initEvent()
end

---@private
function WidgetRankItemWidget:onOpen()

end

---@private
function WidgetRankItemWidget:onDestroy()

end

function WidgetRankItemWidget:updateInfo(data,isCurPlayer)
    --print(">>>>>>>>>>WidgetRankItemWidget:updateInfo ",Lib.v2s(data))
    self:setUIStyleByRank(data.rank,isCurPlayer)
    self.stTextBattle:setText(data.battle or "")
    local name=string.gsub(data.nickName,"%[S%=newvip_nameplate%g-%]","")
    self.stTextName:setText(name)
    --print(">>>>>>>>>>>>>>>>>>>data.nickName",data.nickName,name)
    self.stTextLv:setText(data.level and data.level or "1")
    self.stTextRank:setText(data.rank)
    self.stTextBattle:setText(data.score)
end

function WidgetRankItemWidget:setUIStyleByRank(rank,isCurPlayer)
    local isTop3=rank and tonumber(rank) and  rank>=1 and rank<=3
    local color=(isTop3 and not isCurPlayer) and RankColor[rank] or RankColor[4]
    local bg=isTop3 and RankBG[rank] or RankBG[4]
    local icon=isTop3 and RankIcon[rank] or RankIcon[4]

    self.stTextName:setProperty("TextColours", color)
    self.stTextLv:setProperty("TextColours", color)
    self.stTextBattle:setProperty("TextColours", color)
    self.siImageBG:setImage(bg)
    self.siImageRank:setImage(icon)
    self.siImageRank:setVisible(isTop3)
    self.stTextRank:setVisible(not isTop3)
    --self.siImageBG:setVisible(not isCurPlayer)
end

function WidgetRankItemWidget:hideBG()
    self.siImageBG:setVisible(false)
end

WidgetRankItemWidget:init()
