---@class WinTop3Layout : CEGUILayout
local WinTop3Layout = M

---@private
function WinTop3Layout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinTop3Layout:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wPanel1 = self.Panel1
    ---@type CEGUIStaticImage
    self.siPanel1ImageBG = self.Panel1.ImageBG
    ---@type CEGUIDefaultWindow
    self.wPanel1ActorPanel = self.Panel1.ActorPanel
    ---@type CEGUIActorWindow
    self.awPanel1ActorPanelActorWindow = self.Panel1.ActorPanel.ActorWindow
    ---@type CEGUIStaticText
    self.stPanel1TextName = self.Panel1.TextName
    ---@type CEGUIStaticImage
    self.siPanel1ImageIcon = self.Panel1.ImageIcon
    ---@type CEGUIStaticText
    self.stPanel1TextScore = self.Panel1.TextScore
    ---@type CEGUIDefaultWindow
    self.wPanel2 = self.Panel2
    ---@type CEGUIStaticImage
    self.siPanel2ImageBG = self.Panel2.ImageBG
    ---@type CEGUIDefaultWindow
    self.wPanel2ActorPanel = self.Panel2.ActorPanel
    ---@type CEGUIActorWindow
    self.awPanel2ActorPanelActorWindow = self.Panel2.ActorPanel.ActorWindow
    ---@type CEGUIStaticText
    self.stPanel2TextName = self.Panel2.TextName
    ---@type CEGUIStaticImage
    self.siPanel2ImageIcon = self.Panel2.ImageIcon
    ---@type CEGUIStaticText
    self.stPanel2TextScore = self.Panel2.TextScore
    ---@type CEGUIDefaultWindow
    self.wPanel3 = self.Panel3
    ---@type CEGUIStaticImage
    self.siPanel3ImageBG = self.Panel3.ImageBG
    ---@type CEGUIDefaultWindow
    self.wPanel3ActorPanel = self.Panel3.ActorPanel
    ---@type CEGUIActorWindow
    self.awPanel3ActorPanelActorWindow = self.Panel3.ActorPanel.ActorWindow
    ---@type CEGUIStaticText
    self.stPanel3TextName = self.Panel3.TextName
    ---@type CEGUIStaticImage
    self.siPanel3ImageIcon = self.Panel3.ImageIcon
    ---@type CEGUIStaticText
    self.stPanel3TextScore = self.Panel3.TextScore
end

---@private
function WinTop3Layout:initUI()
    self.stPanel1TextName:setText(Lang:toText(""))
    self.stPanel1TextScore:setText(Lang:toText(""))
    self.stPanel2TextName:setText(Lang:toText(""))
    self.stPanel2TextScore:setText(Lang:toText(""))
    self.stPanel3TextName:setText(Lang:toText(""))
    self.stPanel3TextScore:setText(Lang:toText(""))
    self.top3ViewList={}
    self.top3ViewList[1]=self.wPanel1
    self.top3ViewList[2]=self.wPanel2
    self.top3ViewList[3]=self.wPanel3
    self.isShow=true
end

function WinTop3Layout:updateTop3Player(top3Inf)
    if not top3Inf or next(top3Inf) == nil then
        return
    end
    self.top3Inf=top3Inf
    for i = 1, #self.top3ViewList do
        local node=self.top3ViewList[i]
        if i>#self.top3Inf then
            node:setVisible(false)
        else
            node:setVisible(true)
            node.TextName:setText(self.top3Inf[i].nickName)
            node.TextScore:setText(self.top3Inf[i].score)
        end
    end
    if #self.top3Inf ==1 then
        self.top3ViewList[1]:setPosition(UDim2.new(0,200,0,0))
    elseif #self.top3Inf ==2 then
        self.top3ViewList[1]:setPosition(UDim2.new(0,100,0,0))
        self.top3ViewList[2]:setPosition(UDim2.new(0,300,0,0))
    else
        self.top3ViewList[1]:setPosition(UDim2.new(0,0,0,0))
        self.top3ViewList[2]:setPosition(UDim2.new(0,200,0,0))
        self.top3ViewList[3]:setPosition(UDim2.new(0,400,0,0))
    end
    self:requestTop3PlayerSkin()
end

function WinTop3Layout:requestTop3PlayerSkin()
    if not self.top3Inf or  next(self.top3Inf) == nil then
        return
    end
    self:clearTimer()
    for index = 1, #self.top3Inf do
        --AsyncProcess.GetPlayerActorInfo(self.top3Inf[index].userId, function(data)
        --    if self.isShow then
        --        self:updateTop3PlayerSkin(index,data.skin,data.sex)
        --    end
        --end)
        self:updateTop3PlayerSkin(index,self.top3Inf[index].skin,self.top3Inf[index].sex, self.top3Inf[index].idleAction)
    end
end

function WinTop3Layout:updateTop3PlayerSkin(index,skinData,sex, idleAction)
    if not index then
        return
    end
    local node=self.top3ViewList[index]
    if not node then
        return
    end
    --print(">>>>>>>>>>>>>updateTop3PlayerSkin====",index,Lib.v2s(skinData))
    local actorName=self:getActorName(sex)
    node.ActorPanel.ActorWindow:setActorName(actorName)
    node.ActorPanel.ActorWindow:setSkillName(idleAction or "")

    --local skins = EntityClient.processSkin(actorName, skinData)
    --print("----------------- updateTop3PlayerSkin",index,Lib.v2s(skinData),Lib.v2s(skins))
    --for master, slave in pairs(skins) do
    --    node.ActorPanel.ActorWindow:useBodyPart(master, slave)
    --end
    if skinData then
        for k, v in pairs(skinData) do
            local t = type(v)
            if t == nil or
                    (t == "string" and (v == "" or v == "0")) or
                    (t == "number" and v == 0)
            then
                node.ActorPanel.ActorWindow:unloadBodyPart(k)
            else
                node.ActorPanel.ActorWindow:useBodyPart(k, v)
            end
        end
    end
    if not self.updateSkinLightTimer then
        self.updateSkinLightTimer={}
    end
    self.updateSkinLightTimer[index]=World.Timer(20,function ()
        node.ActorPanel.ActorWindow:setActorBrightnessScale(1.3)
    end)
end

function WinTop3Layout:getActorName(sex)
    --print("----------------->WinTop3Layout:getActorName ",sex)
    local playerSetting=Entity.GetCfg("myplugin/player1")
    if sex==1 then
        return playerSetting and playerSetting.actorName or "asset/Actor/player/g2069_boy.actor"
    else
        return playerSetting and playerSetting.actorGirlName or "asset/Actor/player/g2069_girl.actor"
    end
end

function WinTop3Layout:clearTimer()
    if self.updateSkinLightTimer then
        for i, timer in pairs(self.updateSkinLightTimer) do
            timer()
        end
        self.updateSkinLightTimer=nil
    end
end

---@private
function WinTop3Layout:initEvent()
    self:subscribeEvent(Event.EVENT_UPDATE_TOP3_RANK,function(packet)
        --print(">>>>>>>>>>>>>>>>>>> receive Event.EVENT_UPDATE_TOP3_RANK",Lib.v2s(packet.rankList))
        self:updateTop3Player(packet.rankList)
    end)
end

---@private
function WinTop3Layout:onOpen()
    Me:sendPacket({pid = "requestRankTop3"})
end

---@private
function WinTop3Layout:onDestroy()

end

---@private
function WinTop3Layout:onClose()
    self:clearTimer()
    self.isShow=false
end

WinTop3Layout:init()
