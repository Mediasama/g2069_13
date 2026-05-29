---@class WinSubscribeGameWndLayout : CEGUILayout
local WinSubscribeGameWndLayout = M

local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

---@type SubscribeVipHelper
local SubscribeVipHelper = SubscribeVipHelper

-- ContentPanel节点对应的tab、类型
local SubscribeNodeKey = {
    NORMAL_VIP = 1,           -- 普V会员档次
    SUBSCRIBE = 2,      -- 订阅状态,
    HEIGHT_VIP = 3      -- 高V会员档次
}

---@private
function WinSubscribeGameWndLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinSubscribeGameWndLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siMaskBg = self.MaskBg
    ---@type CEGUIDefaultWindow
    self.wContentBg = self.ContentBg
    ---@type CEGUIDefaultWindow
    self.wContentBgContentPanel1 = self.ContentBg.ContentPanel1
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel1ShowBg = self.ContentBg.ContentPanel1.ShowBg
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel1TitleIcon = self.ContentBg.ContentPanel1.TitleIcon
    ---@type CEGUIStaticText
    self.stContentBgContentPanel1TitleText = self.ContentBg.ContentPanel1.TitleText
    ---@type CEGUIStaticText
    self.stContentBgContentPanel1AwardTitle = self.ContentBg.ContentPanel1.awardTitle
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel1AwardTitleAwardLine = self.ContentBg.ContentPanel1.awardTitle.awardLine
    ---@type CEGUIScrollableView
    self.wContentBgContentPanel1AwardList = self.ContentBg.ContentPanel1.AwardList
    ---@type CEGUIVerticalLayoutContainer
    self.wContentBgContentPanel1AwardListVerticalLayoutContainer = self.ContentBg.ContentPanel1.AwardList.VerticalLayoutContainer
    ---@type CEGUIButton
    self.btnContentBgContentPanel1ContentBtn = self.ContentBg.ContentPanel1.ContentBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel1NextBtn = self.ContentBg.ContentPanel1.nextBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel1PreBtn = self.ContentBg.ContentPanel1.preBtn
    ---@type CEGUIDefaultWindow
    self.wContentBgContentPanel2 = self.ContentBg.ContentPanel2
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel2ShowBg = self.ContentBg.ContentPanel2.ShowBg
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel2TitleIcon = self.ContentBg.ContentPanel2.TitleIcon
    ---@type CEGUIStaticText
    self.stContentBgContentPanel2TitleText = self.ContentBg.ContentPanel2.TitleText
    ---@type CEGUIStaticText
    self.stContentBgContentPanel2AwardTitle = self.ContentBg.ContentPanel2.awardTitle
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel2AwardTitleAwardLine = self.ContentBg.ContentPanel2.awardTitle.awardLine
    ---@type CEGUIScrollableView
    self.wContentBgContentPanel2AwardList = self.ContentBg.ContentPanel2.AwardList
    ---@type CEGUIVerticalLayoutContainer
    self.wContentBgContentPanel2AwardListVerticalLayoutContainer = self.ContentBg.ContentPanel2.AwardList.VerticalLayoutContainer
    ---@type CEGUIButton
    self.btnContentBgContentPanel2ContentBtn = self.ContentBg.ContentPanel2.ContentBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel2NextBtn = self.ContentBg.ContentPanel2.nextBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel2PreBtn = self.ContentBg.ContentPanel2.preBtn
    ---@type CEGUIDefaultWindow
    self.wContentBgContentPanel3 = self.ContentBg.ContentPanel3
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel3ShowBg = self.ContentBg.ContentPanel3.ShowBg
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel3TitleIcon = self.ContentBg.ContentPanel3.TitleIcon
    ---@type CEGUIStaticText
    self.stContentBgContentPanel3TitleText = self.ContentBg.ContentPanel3.TitleText
    ---@type CEGUIStaticText
    self.stContentBgContentPanel3AwardTitle = self.ContentBg.ContentPanel3.awardTitle
    ---@type CEGUIStaticImage
    self.siContentBgContentPanel3AwardTitleAwardLine = self.ContentBg.ContentPanel3.awardTitle.awardLine
    ---@type CEGUIScrollableView
    self.wContentBgContentPanel3AwardList = self.ContentBg.ContentPanel3.AwardList
    ---@type CEGUIVerticalLayoutContainer
    self.wContentBgContentPanel3AwardListVerticalLayoutContainer = self.ContentBg.ContentPanel3.AwardList.VerticalLayoutContainer
    ---@type CEGUIButton
    self.btnContentBgContentPanel3ContentBtn = self.ContentBg.ContentPanel3.ContentBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel3NextBtn = self.ContentBg.ContentPanel3.nextBtn
    ---@type CEGUIButton
    self.btnContentBgContentPanel3PreBtn = self.ContentBg.ContentPanel3.preBtn
    ---@type CEGUIDefaultWindow
    self.wContentBgTabPanel = self.ContentBg.TabPanel
    ---@type CEGUIDefaultWindow
    self.wContentBgTabPanelTabBtn1 = self.ContentBg.TabPanel.TabBtn1
    ---@type CEGUIStaticImage
    self.siContentBgTabPanelTabBtn1NormalBg = self.ContentBg.TabPanel.TabBtn1.NormalBg
    ---@type CEGUIStaticImage
    self.siContentBgTabPanelTabBtn1SelectBg = self.ContentBg.TabPanel.TabBtn1.SelectBg
    ---@type CEGUIStaticText
    self.stContentBgTabPanelTabBtn1TabTitle = self.ContentBg.TabPanel.TabBtn1.TabTitle
    ---@type CEGUIDefaultWindow
    self.wContentBgTabPanelTabBtn2 = self.ContentBg.TabPanel.TabBtn2
    ---@type CEGUIStaticImage
    self.siContentBgTabPanelTabBtn2NormalBg = self.ContentBg.TabPanel.TabBtn2.NormalBg
    ---@type CEGUIStaticImage
    self.siContentBgTabPanelTabBtn2SelectBg = self.ContentBg.TabPanel.TabBtn2.SelectBg
    ---@type CEGUIStaticText
    self.stContentBgTabPanelTabBtn2TabTitle = self.ContentBg.TabPanel.TabBtn2.TabTitle
    ---@type CEGUIButton
    self.btnContentBgCloseBtn = self.ContentBg.CloseBtn


    self.tabCurPage = {}
    self.lytSubscribeGameWndContentPanel = {}
    self.imgSubscribeGameWndTitleIcon = {}
    self.txtSubscribeGameWndTitleText = {}
    self.txtSubscribeGameWndAwardTitle = {}
    self.imgSubscribeGameWndAwardLine = {}
    self.lytSubscribeGameWndAwardList = {}
    self.btnSubscribeGameWndContentBtn = {}
    self.btnSubscribeGameWndNextBtn = {}
    self.btnSubscribeGameWndPreBtn = {}
    self.lytSubscribeGameWndTabBtn = {}
    self.imgSubscribeGameWndNormalBg = {}
    self.imgSubscribeGameWndSelectBg = {}
    self.txtSubscribeGameWndTabTitle = {}

    self.contentGridView = {}
    for key, tabId in pairs(Define.SubscribeTabUI) do
        self.lytSubscribeGameWndTabBtn[tabId] = self.ContentBg.TabPanel["TabBtn" .. tabId]
        self.imgSubscribeGameWndNormalBg[tabId] = self.lytSubscribeGameWndTabBtn[tabId].NormalBg
        self.imgSubscribeGameWndSelectBg[tabId] = self.lytSubscribeGameWndTabBtn[tabId].SelectBg
        self.txtSubscribeGameWndTabTitle[tabId] = self.lytSubscribeGameWndTabBtn[tabId].TabTitle

        if tabId == Define.SubscribeTabUI.VIP then
            self.txtSubscribeGameWndTabTitle[tabId]:setText(Lang:toText("subscribe_vip_tab_vip_title"))
        else
            self.txtSubscribeGameWndTabTitle[tabId]:setText(Lang:toText("subscribe_vip_tab_subscribe_title"))
        end
    end

    for _, nodeKey in pairs(SubscribeNodeKey) do
        self.lytSubscribeGameWndContentPanel[nodeKey] =  self.ContentBg["ContentPanel" .. nodeKey]
        self.imgSubscribeGameWndTitleIcon[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].TitleIcon
        self.txtSubscribeGameWndTitleText[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].TitleText
        self.txtSubscribeGameWndAwardTitle[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].awardTitle
        self.imgSubscribeGameWndAwardLine[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].awardTitle.awardLine
        self.lytSubscribeGameWndAwardList[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].AwardList
        self.btnSubscribeGameWndContentBtn[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].ContentBtn
        self.btnSubscribeGameWndNextBtn[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].nextBtn
        self.btnSubscribeGameWndPreBtn[nodeKey] = self.lytSubscribeGameWndContentPanel[nodeKey].preBtn


        self.btnSubscribeGameWndNextBtn[nodeKey]:setVisible(false)
        self.btnSubscribeGameWndPreBtn[nodeKey]:setVisible(false)
        if nodeKey == SubscribeNodeKey.SUBSCRIBE then
            self.imgSubscribeGameWndTitleIcon[nodeKey]:setVisible(false)
            self.txtSubscribeGameWndTitleText[nodeKey]:setText(Lang:toText("subscribe_vip_main_subscribe_title"))
            self.btnSubscribeGameWndContentBtn[nodeKey]:setText(Lang:toText("subscribe_vip_main_go_subscribe"))
        else
            self.imgSubscribeGameWndTitleIcon[nodeKey]:setVisible(true)
            self.txtSubscribeGameWndTitleText[nodeKey]:setText(Lang:toText("subscribe_vip_main_vip_title"))
            self.btnSubscribeGameWndContentBtn[nodeKey]:setText(Lang:toText("subscribe_vip_main_go_charge"))
        end

        self.contentGridView[nodeKey] = widget_virtual_vert_list:init(self.lytSubscribeGameWndContentPanel[nodeKey].AwardList,
                self.lytSubscribeGameWndContentPanel[nodeKey].AwardList.VerticalLayoutContainer,
                function(self, parentWindow)
                    local item = UI:openWidget("UI/subscribe_vip/gui/widget_subscribe_Item")
                    parentWindow:addChild(item:getWindow())
                    item:setWidth({ 1, 0 })
                    return item
                end,
                function(self, childWindow, data)
                    childWindow:initData(data)
                end
        )
    end
end

---@private
function WinSubscribeGameWndLayout:initUI()

end

---@private
function WinSubscribeGameWndLayout:initEvent()
    for _, nodeKey in pairs(SubscribeNodeKey) do
        self.btnSubscribeGameWndContentBtn[nodeKey].onMouseClick = function()
            if (nodeKey == SubscribeNodeKey.NORMAL_VIP) or (nodeKey == SubscribeNodeKey.HEIGHT_VIP) then
                Interface.onRecharge(1)
            else
                Interface.onRecharge(6)
            end
            UI:closeWindow("UI/subscribe_vip/gui/win_subscribe_game_wnd")
        end

        self.btnSubscribeGameWndNextBtn[nodeKey].onMouseClick = function()
            self:updateTabPageShow(self.curTabId, self.tabCurPage[self.curTabId] + 1)
        end

        self.btnSubscribeGameWndPreBtn[nodeKey].onMouseClick = function()
            self:updateTabPageShow(self.curTabId, self.tabCurPage[self.curTabId] - 1)
        end
    end

    for key, tabId in pairs(Define.SubscribeTabUI) do
        self.lytSubscribeGameWndTabBtn[tabId].onMouseClick = function()
            self:updateTabViewShow(tabId)
        end
    end

    self.btnContentBgCloseBtn.onMouseClick = function()
        UI:closeWindow("UI/subscribe_vip/gui/win_subscribe_game_wnd")
    end
end

--界面数据初始化
function WinSubscribeGameWndLayout:initView(showTab)
    if not showTab and not self.curTabId then
        showTab = Define.SubscribeTabUI.VIP
    end
    self.tabCurPage = {}
    for key, tabId in pairs(Define.SubscribeTabUI) do
        self.tabCurPage[tabId] = 1
    end
    local subscribeVipStage = Me:getSubscribeVipStage()
    if subscribeVipStage == Define.SubscribeVIPStage.Height then
        self.tabCurPage[Define.SubscribeTabUI.VIP] = 2
    else
        self.tabCurPage[Define.SubscribeTabUI.VIP] = 1
    end
    self:initSubscribeData()
    self:updateTabViewShow(showTab or  self.curTabId)
end

function WinSubscribeGameWndLayout:initSubscribeData()
    if self.subscribeItemData then
        return
    end
    self.subscribeItemData = {}

    local subscribe_vipSetting = World.cfg.subscribe_vipSetting
    for key, tabId in pairs(Define.SubscribeTabUI) do
        if not self.subscribeItemData[tabId] then
            self.subscribeItemData[tabId] = {}
        end
        if tabId == Define.SubscribeTabUI.VIP then
            self.subscribeItemData[tabId] = subscribe_vipSetting.vipRewardItem or {}
        else
            table.insert(self.subscribeItemData[tabId], subscribe_vipSetting.subscribeRewardItem)
        end
    end
end

function WinSubscribeGameWndLayout:updateTabViewShow(showTab)
    self.curTabId = showTab

    if showTab == Define.SubscribeTabUI.VIP then
        SubscribeVipHelper:clientClickSubscribeVipReward()
    end

    for key, tabId in pairs(Define.SubscribeTabUI) do
        if tabId == self.curTabId then
            self.imgSubscribeGameWndNormalBg[tabId]:setVisible(false)
            self.imgSubscribeGameWndSelectBg[tabId]:setVisible(true)
        else
            self.imgSubscribeGameWndNormalBg[tabId]:setVisible(true)
            self.imgSubscribeGameWndSelectBg[tabId]:setVisible(false)
        end
    end
    self:updateTabPageShow(self.curTabId, self.tabCurPage[self.curTabId])
end

function WinSubscribeGameWndLayout:updateTabPageShow(tabId, showPage)
    if tabId ~= self.curTabId then
        return
    end

    if showPage <= 1 then
        showPage = 1
    end
    local totalPage = #self.subscribeItemData[tabId]
    if showPage >= totalPage then
        showPage = totalPage
    end

    local showNodeKey = SubscribeNodeKey.SUBSCRIBE
    if tabId == Define.SubscribeTabUI.VIP then
        if showPage > 1 then
            showNodeKey = SubscribeNodeKey.HEIGHT_VIP
        else
            showNodeKey = SubscribeNodeKey.NORMAL_VIP
        end
    end
    for _, nodeKey in pairs(SubscribeNodeKey) do
        if nodeKey == showNodeKey then
            self.lytSubscribeGameWndContentPanel[nodeKey]:setVisible(true)
        else
            self.lytSubscribeGameWndContentPanel[nodeKey]:setVisible(false)
        end
    end

    if showPage <= 1 then
        self.btnSubscribeGameWndPreBtn[showNodeKey]:setVisible(false)
    else
        self.btnSubscribeGameWndPreBtn[showNodeKey]:setVisible(true)
    end
    if showPage >= totalPage then
        self.btnSubscribeGameWndNextBtn[showNodeKey]:setVisible(false)
    else
        self.btnSubscribeGameWndNextBtn[showNodeKey]:setVisible(true)
    end
    self.tabCurPage[self.curTabId] = showPage

    self.contentGridView[showNodeKey]:clearVirtualChild()
    self.contentGridView[showNodeKey]:setVirtualBarPosition(0)
    if tabId == Define.SubscribeTabUI.VIP then
        local showData = Lib.copyTable1(self.subscribeItemData[tabId][showPage] or {})
        for key, val in pairs(showData) do
            showData[key].isBlack = showPage >= totalPage
        end
        self.contentGridView[showNodeKey]:addVirtualChildList(showData)
    else
        self.contentGridView[showNodeKey]:addVirtualChildList(self.subscribeItemData[tabId][showPage] or {})
    end

    local showTitleStr = ""
    if showNodeKey == SubscribeNodeKey.SUBSCRIBE then
        local subscribeGameState = Me:getSubscribeGameState()
        if subscribeGameState then
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(false)
            local subscribeExpireTime = Me:getSubscribeExpireTime()
            showTitleStr = Lang:toText({"subscribe_vip_subscribe_time_tips", subscribeExpireTime})
        else
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(true)
            showTitleStr = Lang:toText("subscribe_vip_subscribe_reward_tips")
        end
        self.txtSubscribeGameWndAwardTitle[showNodeKey]:setText(showTitleStr)
    elseif showNodeKey == SubscribeNodeKey.NORMAL_VIP then
        local subscribeVipStage = Me:getSubscribeVipStage()
        if subscribeVipStage == Define.SubscribeVIPStage.Normal
                or subscribeVipStage == Define.SubscribeVIPStage.Height then
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(false)
            local subscribeVipLevel = Me:getSubscribeVipLevel()
            showTitleStr = Lang:toText({"subscribe_vip_subscribe_vip_effect_tips", subscribeVipLevel})
        else
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(true)
            local subscribeStageCfg = Me:getSubscribeStageCfg()[1] or {}
            showTitleStr = Lang:toText({"subscribe_vip_subscribe_vip_limit_tips", subscribeStageCfg.startVipLv or 99})
        end
        self.txtSubscribeGameWndAwardTitle[showNodeKey]:setText(showTitleStr)
    elseif showNodeKey == SubscribeNodeKey.HEIGHT_VIP then
        local subscribeVipStage = Me:getSubscribeVipStage()
        if subscribeVipStage == Define.SubscribeVIPStage.Height then
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(false)
            local subscribeVipLevel = Me:getSubscribeVipLevel()
            showTitleStr = Lang:toText({"subscribe_vip_subscribe_vip_effect_tips_height", subscribeVipLevel})
        else
            self.btnSubscribeGameWndContentBtn[showNodeKey]:setVisible(true)
            local subscribeStageCfg = Me:getSubscribeStageCfg()[2] or {}
            showTitleStr = Lang:toText({"subscribe_vip_subscribe_vip_limit_tips_height", subscribeStageCfg.startVipLv or 99})
        end
        self.txtSubscribeGameWndAwardTitle[showNodeKey]:setText(showTitleStr)
    end
    self:updateAwardTitleWidth(showNodeKey, showTitleStr)
end

function WinSubscribeGameWndLayout:updateAwardTitleWidth(showNodeKey, showTitleStr)
    local strText = showTitleStr:gsub("(%[colour='[%a%d][%a%d][%a%d][%a%d][%a%d][%a%d][%a%d][%a%d]'%])", "")
    local strW = self.txtSubscribeGameWndAwardTitle[showNodeKey]:getFont():getTextExtent(strText, 1.0)
    local resultW = strW + 40
    local maxW =  self.txtSubscribeGameWndAwardTitle[showNodeKey]:getWidth()[2] + 30
    if resultW > maxW then
        resultW = maxW
    end
    self.imgSubscribeGameWndAwardLine[showNodeKey]:setWidth({0, resultW})
end

---@private
function WinSubscribeGameWndLayout:onOpen(showTab)
    self:initView(showTab)
end

---@private
function WinSubscribeGameWndLayout:onDestroy()

end

---@private
function WinSubscribeGameWndLayout:onClose()
    for key, val in pairs(self.contentGridView) do
        val:clearVirtualChild()
    end
end

WinSubscribeGameWndLayout:init()
