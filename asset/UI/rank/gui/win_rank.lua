---@class WinRankLayout : CEGUILayout
local WinRankLayout = M
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

---@private
function WinRankLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initData()
    self:initEvent()
    self.isShow=true
    self.mainAniWnd = self.panel
end

---@private
function WinRankLayout:findAllWindow()
    local panel=self.panel
    ---@type CEGUIStaticImage
    self.siImageBG = panel.ImageBG
    ---@type CEGUIStaticImage
    self.siImageBGBuilding = panel.ImageBGBuilding
    ---@type CEGUIStaticText
    self.stTextTitle = panel.TextTitle
    ---@type CEGUIButton
    self.btnButtonClose = panel.ButtonClose
    ---@type CEGUIDefaultWindow
    self.wPanelLeft = panel.PanelLeft
    ---@type CEGUIStaticImage
    self.siPanelLeftImagePodium = panel.PanelLeft.ImagePodium
    ---@type CEGUIDefaultWindow
    self.wPanelRank = panel.PanelRank
    ---@type CEGUIStaticImage
    self.siPanelRankImageBGRank = panel.PanelRank.ImageBGRank
    ---@type CEGUIDefaultWindow
    self.wPanelRankPanelTop = panel.PanelRank.PanelTop
    ---@type CEGUIStaticImage
    self.siPanelRankPanelTopImageRank = panel.PanelRank.PanelTop.ImageRank
    ---@type CEGUIStaticImage
    self.siPanelRankPanelTopImageName = panel.PanelRank.PanelTop.ImageName
    ---@type CEGUIStaticImage
    self.siPanelRankPanelTopImageLv = panel.PanelRank.PanelTop.ImageLv
    ---@type CEGUIStaticImage
    self.siPanelRankPanelTopImageBattle = panel.PanelRank.PanelTop.ImageBattle
    ---@type CEGUIDefaultWindow
    self.wPanelRankPanelList = panel.PanelRank.PanelList
    ---@type CEGUIScrollableView
    self.wPanelRankPanelListScrollableView = panel.PanelRank.PanelList.ScrollableView
    ---@type CEGUIVerticalLayoutContainer
    self.wPanelRankPanelListScrollableViewVerticalLayoutList = panel.PanelRank.PanelList.ScrollableView.VerticalLayoutList
    ---@type CEGUIDefaultWindow
    self.wPanelRankPanelBottom = panel.PanelRank.PanelBottom
    ---@type CEGUIStaticImage
    self.siPanelRankPanelBottomImageBottom = panel.PanelRank.PanelBottom.ImageBottom
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner1 = panel.PanelLeft.PanelWinner1
    ---@type CEGUIActorWindow
    self.awPanelLeftPanelWinner1PlayerActor = panel.PanelLeft.PanelWinner1.PlayerActor
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner1PanelHead = panel.PanelLeft.PanelWinner1.PanelHead
    ---@type CEGUIStaticImage
    self.siPanelLeftPanelWinner1PanelHeadImage = panel.PanelLeft.PanelWinner1.PanelHead.Image
    ---@type CEGUIStaticText
    self.stPanelLeftPanelWinner1PanelHeadText = panel.PanelLeft.PanelWinner1.PanelHead.Text
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner2 = panel.PanelLeft.PanelWinner2
    ---@type CEGUIActorWindow
    self.awPanelLeftPanelWinner2PlayerActor = panel.PanelLeft.PanelWinner2.PlayerActor
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner2PanelHead = panel.PanelLeft.PanelWinner2.PanelHead
    ---@type CEGUIStaticImage
    self.siPanelLeftPanelWinner2PanelHeadImage = panel.PanelLeft.PanelWinner2.PanelHead.Image
    ---@type CEGUIStaticText
    self.stPanelLeftPanelWinner2PanelHeadText = panel.PanelLeft.PanelWinner2.PanelHead.Text
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner3 = panel.PanelLeft.PanelWinner3
    ---@type CEGUIActorWindow
    self.awPanelLeftPanelWinner3PlayerActor = panel.PanelLeft.PanelWinner3.PlayerActor
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner3PanelHead = panel.PanelLeft.PanelWinner3.PanelHead
    ---@type CEGUIStaticImage
    self.siPanelLeftPanelWinner3PanelHeadImage = panel.PanelLeft.PanelWinner3.PanelHead.Image
    ---@type CEGUIStaticText
    self.stPanelLeftPanelWinner3PanelHeadText = panel.PanelLeft.PanelWinner3.PanelHead.Text
    ---@type CEGUIStaticText
    self.stTextRank = self:child("TextRank")
    ---@type CEGUIStaticText
    self.stTextName = self:child("TextName")
    ---@type CEGUIStaticText
    self.stTextLV = self:child("TextLV")
    ---@type CEGUIStaticText
    self.stTextBattle = self:child("TextBattle")
    ---@type CEGUIDefaultWindow
    self.wPanelLeftPanelWinner3 = panel.PanelLeft.PanelWinner3

    self.tabList={}
    --self.tabList[Define.RANK_ROOM_ID]=self:child("PanelTab").Panel1
    self.tabList[Define.RANK_ALL_ID]=self:child("PanelTab").Panel1
    self.tabList[Define.RANK_GLOBAL_ID]=self:child("PanelTab").Panel2
end

---@private
function WinRankLayout:initUI()
    self.stTextTitle:setText(Lang:toText("g2069_role_rank_title"))
    self.stTextRank:setText(Lang:toText("g2069_role_rank_ranking"))
    self.stTextName:setText(Lang:toText("g2069_role_rank_name"))
    self.stTextLV:setText(Lang:toText("g2069_role_rank_lv"))
    self.stTextBattle:setText(Lang:toText("g2069_role_rank_danger"))
    --self.tabList[Define.RANK_ROOM_ID].Text:setText(Lang:toText("g2069_rank_tab_room"))
    self.tabList[Define.RANK_ALL_ID].Text:setText(Lang:toText("g2069_rank_tab_region"))
    self.tabList[Define.RANK_GLOBAL_ID].Text:setText(Lang:toText("g2069_rank_tab_global"))

    ---@type widget_virtual_vert_list
    self.lvRank = widget_virtual_vert_list:init(
            self.wPanelRankPanelListScrollableView,
            self.wPanelRankPanelListScrollableViewVerticalLayoutList,
    ---@type any, CEGUIWindow
            function(self, parent)
                local node = UI:openWidget("UI/rank/gui/widget_rank_item")
                parent:addChild(node:getWindow())
                return node
            end,
    ---@type any, WidgetAbilityItemWidget, table
            function(self, node, data)
                node:updateInfo(data)
            end
    )
    self.myRankView = UI:openWidget("UI/rank/gui/widget_rank_item")
    self.wPanelRankPanelBottom:addChild(self.myRankView:getWindow())
    self.myRankView:hideBG()

    self.top3ViewList={}
    self.top3ViewList[1]=self.wPanelLeftPanelWinner1
    self.top3ViewList[2]=self.wPanelLeftPanelWinner2
    self.top3ViewList[3]=self.wPanelLeftPanelWinner3

    local rankType = World.cfg.rankSetting.newRankType[Define.RANK_ALL_ID]
    self.maxNum=World.cfg.rankSetting.ranks[rankType].maxSize
end

---@private
function WinRankLayout:initEvent()
    self.btnButtonClose.onMouseClick = function()
        UI:closeWindow(self)
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
    end

    self.wPanelRankPanelListScrollableView.onWindowTouchDown = function(instance, window, x, y)
        local scrollPos = self.lvRank:getVirtualBarPosition()
        if scrollPos < 0.1 then
            self.canRequestData = -1
        elseif scrollPos >= 0.9 then
            self.canRequestData = 1
        else
            self.canRequestData = 0
        end
        self.scrollViewBeginDragPosY = y
        --print("--------------------------down",scrollPos)
    end

    self.wPanelRankPanelListScrollableView.onWindowTouchUp = function(instance, window, x, y)
        if self.canRequestData == 0 then
            return
        end
        local distance = y - self.scrollViewBeginDragPosY
        --print("--------------------------up",distance,math.abs(distance))
        if math.abs(distance) > 10 then
            if distance > 0 then
                if self.canRequestData == -1 then
                    --向上滑动 请求上一页

                end
            elseif distance < 0 then
                if not self:needRequest(self.rankId) then
                    return
                end
                if self.canRequestData == 1 then
                    --向下滑动 请求下一页
                    print(" == next page == ")
                    if self.rankId ~= Define.RANK_ROOM_ID then
                        self:getAllInfo(self.rankId)
                    end
                end
            end
        end
    end

    for k, v in pairs(self.tabList) do
        v.onMouseClick = function()
            self:selectTab(k)
        end
    end

    self:subscribeEvent(Event.EVENT_All_RANK,function(packet)
        --print("全区的包,#list,rankId",#packet["rankList"],self:getRankId(packet.rankType))
        --Lib.pv(packet,10)
        self.receiveAllPacket = true
        if not packet["rankList"] or next(packet["rankList"])==nil then
            return
        end
        local rankList=packet.rankList
        local packetRankId=self:getRankId(packet.rankType)
        --缓存
        table.sort(rankList,function(a, b)
            return a.rank < b.rank
        end)
        for k,v in pairs(rankList) do
            table.insert(self.msg[packetRankId].rankList,v)
        end
        if rankList[1].rank == 1 then
            local inf={}
            local len=math.min(#rankList,3)
            for i = 1, len do
                table.insert(inf,rankList[i])
            end
            self.msg[packetRankId].top3Inf=inf
            print("--------------------- Event.EVENT_All_RANK top3 inf,packetRankId,#inf",packetRankId,#inf)
        end
        if self.rankId == self:getRankId(packet.rankType)then
            self:addInfo(packet.rankList)
        end
    end)

    self:subscribeEvent(Event.EVENT_ALL_SINGLE_RANK,function(packet)
        --print("单人的包,rankId",self:getRankId(packet.rankType))
        --Lib.pv(packet,10)
        self.receiveAllPacket = true
        local packetRankId=self:getRankId(packet.rankType)
        self.msg[packetRankId].userRank = packet
        if self.rankId == packetRankId then
            World.Timer(1,function()
                if self.receiveAllPacket == false then
                    return true
                end
                self:updateMyView(packet, self.rankId)
                return false
            end)
        end
    end)

    --self:subscribeEvent(Event.EVENT_GET_TOP3_SKIN,function(packet)
    --    --Lib.pv("SKIN DATA")
    --    --Lib.pv(packet,10)
    --    self:updateTop3PlayerSkin(packet.index,packet.skinData,packet.sex)
    --end)
end

function WinRankLayout:getRankId(rankType)
    if rankType =="g2069_Rank" then
        return Define.RANK_ALL_ID
    elseif rankType =="g2069_Rank_Global" then
        return Define.RANK_GLOBAL_ID
    else
        return Define.RANK_ROOM_ID
    end
end

function WinRankLayout:initData()
    self.msg = {
        [1] = {
            userRank = {},
            rankList = {},
            pageNo = 0,
            top3Inf={}
        },
        [2] = {
            userRank = {},
            rankList = {},
            pageNo = 0,
            top3Inf={}
        }
        --[3] = {
        --    userRank = {},
        --    rankList = {},
        --    pageNo = 0,
        --    top3Inf={}
        --}
    }
    --个人信息更新要在全区更新之后，不然可能信息不对称(个人获取比全区获取快，而全区和个人的排名可能不一样，以全区的为准)
    self.receiveAllPacket = true
    self.lastRequestTime = 0
    self.lvRank:clearVirtualChild()
    self:selectTab(Define.RANK_ALL_ID)
end

function WinRankLayout:needRequest(rankId)
    --有包没收到，不请求
    if self.receiveAllPacket == false then
        return false
    end
    --没有缓存，一定要拉
    if self.msg[rankId].pageNo == 0 then
        return true
    end
    --间隔时间太短，不请求
    if os.time() - self.lastRequestTime <= Define.RANK_REFRESH_TIME then
        return false
    end
    local rankType = World.cfg.rankSetting.newRankType[rankId]
    local maxNum=World.cfg.rankSetting.ranks[rankType].maxSize
    --已拉满设置的最大页数，不请求
    if self.msg[rankId].pageNo * Define.RANK_PAGE_SIZE >= maxNum then
        return false
    end
    return true
end

function WinRankLayout:getMyALlInfo(rankId)
    if self.msg[rankId].userRank["rank"] then
        --self:updateMyView(self.msg[Define.RANK_ALL_ID].userRank,Define.RANK_ALL_ID)
        return
    end
    print("*****************************getMyALlInfo",rankId)
    Me:sendPacket({
        pid = "requestSingleAllRank",
        userId = Me.platformUserId,
        rankType = World.cfg.rankSetting.newRankType[rankId],
        rankId=rankId
    })
end

function WinRankLayout:getAllInfo(rankId)
    print(">>>>>>>>>>>>WinRankLayout:getAllInfo",rankId,World.cfg.rankSetting.newRankType[rankId])
    --判需不需要请求
    if not self:needRequest(rankId) then
        return
    end
    --请求
    self.receiveAllPacket = false
    Me:sendPacket({
        pid = "requestAllRankRealTime",
        userId = Me.platformUserId,
        rankType = World.cfg.rankSetting.newRankType[rankId],
        pageNo = self.msg[rankId].pageNo,
        rankId=rankId
    })
    self:getMyALlInfo(rankId)
    --Lib.logDebug("--- request rank page (all) --- pageNo.", self.msg[Define.RANK_ALL_ID].pageNo)
    self.msg[rankId].pageNo = self.msg[rankId].pageNo + 1
    self.lastRequestTime = os.time()
end

function WinRankLayout:addInfo(rankList)
    if not rankList or not next(rankList)then
        return
    end
    table.sort(rankList,function(a, b)
        return a.rank < b.rank
    end)
    --Lib.pv("插入的数据")
    --Lib.pv(rankList,10)
    self.lvRank:addVirtualChildList(rankList)
    local pageNo = math.ceil(rankList[1].rank / Define.RANK_PAGE_SIZE)
    self.msg[self.rankId].pageNo = pageNo
    if rankList[1].rank == 1 then
        --local inf={}
        --local len=math.min(#rankList,3)
        --for i = 1, len do
        --    table.insert(inf,rankList[i])
        --end
        --self.msg[self.rankId].top3Inf=inf
        --print("--------------------- update top3 inf",Lib.v2s(inf))
        self:updateTop3Player()
        self:requestTop3PlayerSkin()
    end
end

function WinRankLayout:updateMyView(data, rankId)
    local myMsg = data
    if not data or not next(data) then
        return
    end

    print("**********************===>",myMsg.rank,tonumber(myMsg.rank),self.maxNum)
    if not myMsg.rank or not tonumber(myMsg.rank) or tonumber(myMsg.rank) > self.maxNum or tonumber(myMsg.rank) <= 0 then
        myMsg.rank = self.maxNum.."+"
        myMsg.score = Me:getDangerValue()
        ---@type GrowthSystem
        local GrowthSystem = T(Lib, "GrowthSystem")
        myMsg.level=GrowthSystem:getLevel(Me) or 1
        --print(">>>>>>>>>>>>>>",GrowthSystem:getLevel(Me),Me:getDangerValue())
    end

    --个人信息与总榜同步，未出现在总榜则使用原数据
    for index, info in pairs(self.msg[rankId].rankList) do
        if info.userId == Me.platformUserId then
            myMsg.rank = info.rank
            if not info.rank or tonumber(info.rank) > self.maxNum or tonumber(info.rank) <= 0 then
                myMsg.rank = self.maxNum.."+"
            end
            myMsg.score = info.score
            myMsg.level = info.level
            break
        end
    end
    self.myRankView:updateInfo(myMsg,true)
end

function WinRankLayout:updateTop3Player()
    if next(self.msg[self.rankId].top3Inf) == nil then
        return
    end
    local infList=self.msg[self.rankId].top3Inf
    for i = 1, #self.top3ViewList do
        local node=self.top3ViewList[i]
        if i>#infList then
            node:setVisible(false)
        else
            node:setVisible(true)
            node.PanelHead.Text:setText(infList[i].nickName)
        end
    end
end

function WinRankLayout:requestTop3PlayerSkin()
    if next(self.msg[self.rankId].top3Inf) == nil then
        return
    end
    self:clearTimer()
    local infList=self.msg[self.rankId].top3Inf
    local rankId=self.rankId
    for index = 1, #infList do
        AsyncProcess.GetPlayerActorInfo(infList[index].userId, function(data)
            if self.isShow and self.rankId==rankId then
                self:updateTop3PlayerSkin(index,data.skin,data.sex)
            end
        end)
    end
end

function WinRankLayout:updateTop3PlayerSkin(index,skinData,sex)
    if not index or not skinData then
        return
    end
    local node=self.top3ViewList[index]
    if not node then
        return
    end
    local actorName=self:getActorName(sex)
    node.PlayerActor:setActorName(actorName)
    local skins = EntityClient.processSkin(actorName, skinData)
    --print("----------------- updateTop3PlayerSkin",index,Lib.v2s(skinData),Lib.v2s(skins))
    for master, slave in pairs(skins) do
        node.PlayerActor:useBodyPart(master, slave)
    end
    if not self.updateSkinLightTimer then
        self.updateSkinLightTimer={}
    end
    self.updateSkinLightTimer[index]=World.Timer(20,function ()
        node.PlayerActor:setActorBrightnessScale(1.3)
    end)
end

function WinRankLayout:getActorName(sex)
    --print("----------------->WinRankLayout:getActorName ",sex)
    local playerSetting=Entity.GetCfg("myplugin/player1")
    if sex==1 then
        return playerSetting and playerSetting.actorName or "asset/Actor/player/g2069_boy.actor"
    else
        return playerSetting and playerSetting.actorGirlName or "asset/Actor/player/g2069_girl.actor"
    end
end

function WinRankLayout:selectTab(rankId)
    --print("==================================================== WinRankLayout:selectTab",rankId)
    for k, tab in pairs(self.tabList) do
        tab.ImageSelect:setVisible(k==rankId)
    end
    self.rankId=rankId
    self.receiveAllPacket = true
    self.lastRequestTime=0
    self:clearTimer()
    self.lvRank:refresh(self.msg[rankId].rankList)
    self.lvRank:setVirtualBarPosition(0)
    local request=self.msg[rankId].pageNo == 0 or next(self.msg[rankId].rankList)==nil
    if next(self.msg[rankId].rankList) == nil then
        self.msg[rankId].pageNo=0
    end
    if request then
        self:getAllInfo(rankId)
    else
        self:updateMyView(self.msg[self.rankId].userRank, self.rankId)
        self:updateTop3Player()
        self:requestTop3PlayerSkin()
    end
end

---@private
function WinRankLayout:onOpen()
    --self:getAllInfo()
end

---@private
function WinRankLayout:onDestroy()

end

---@private
function WinRankLayout:onClose()
    self.msg = {
        [1] = {
            userRank = {},
            rankList = {},
            pageNo = 0,
        }
    }
    self.lastRequestTime = 0
    self.receiveAllPacket = true
    self.lvRank:clearVirtualChild()
    self:clearTimer()
    self.isShow=false
end

function WinRankLayout:clearTimer()
    if self.updateSkinLightTimer then
        for i, timer in pairs(self.updateSkinLightTimer) do
            timer()
        end
        self.updateSkinLightTimer=nil
    end
end

WinRankLayout:init()
