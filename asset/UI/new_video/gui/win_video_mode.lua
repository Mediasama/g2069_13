

local Recorder = T(Lib, "Recorder")

---@type VideoEffectConfig
local VideoEffectConfig = T(Config, "VideoEffectConfig")

--- @type NewVideoHelper
local NewVideoHelper = T(Lib, "NewVideoHelper")

local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

local HANDLE_STATE = {
    DOWN_HANDLE_LIST = 1,--展开
    UP_HANDLE_LIST = 2--收起
}

function M:init()
    self._allEvent = {}

    self.curHideData = {}
    self.btnVideoModeSettingData = {}
    self.txtVideoModeSettingDataDec = {}
    self.btnVideoModeTabBtn = {}
    self.txtVideoModeTabBtnDec = {}

    self.curSelectEffectTab = 1
    self.curEffectData = {}
    self.curHandleState = HANDLE_STATE.DOWN_HANDLE_LIST
    self.curHideUIState = 0

    self:initUI()
    self:initEvent()
    self:setLevel(49)
end

function M:initUI()

    self.lytVideoModeHandleList = self:child("handleList")
    self.lytVideoModeHideSettingList = self:child("hideSettingList")
    for i = 1, 3 do
        self.btnVideoModeSettingData[i] = self:child("settingData"..i)
        self.btnVideoModeSettingData[i]:setSelected(false)
        self.txtVideoModeSettingDataDec[i] = self:child("settingDataDec"..i)
        self.txtVideoModeSettingDataDec[i]:setText(Lang:toText("gui.new_video.hide.setting.data"..i))
        self.curHideData[i] = false
    end
    self.lytVideoModeHideSettingList:setVisible(false)

    self.btnVideoModeEffectBtn = self:child("effectBtn")
    self.txtVideoModeEffectBtnText = self:child("effectBtnText")
    self.txtVideoModeEffectBtnText:setText(Lang:toText("gui.new_video.handle.tab1"))
    self.imgEffectNormalIcon = self:child("normalIcon")
    self.imgEffectSelectIcon = self:child("selectIcon")
    self.imgEffectNormalIcon:setVisible(true)
    self.imgEffectSelectIcon:setVisible(false)

    self.btnVideoModeHideUiBtn = self:child("hideUiBtn")
    self.txtVideoModeHideUIBtnText = self:child("hideUIBtnText")
    self.txtVideoModeHideUIBtnText:setText(Lang:toText("gui.new_video.handle.tab2"))
    self.btnVideoModeHideUiSettingBtn = self:child("hideUiSettingBtn")

    self.imgVideoModeSettingListBtnUpImg = self:child("settingListBtnUpImg")
    self.imgVideoModeSettingListBtnDownImg = self:child("settingListBtnDownImg")
    self.imgVideoModeSettingListBtnUpImg:setVisible(false)
    self.imgVideoModeSettingListBtnDownImg:setVisible(true)

    self.txtVideoModeHideUISettingBtnText = self:child("hideUISettingBtnText")
    self.txtVideoModeHideUISettingBtnText:setText(Lang:toText("gui.new_video.handle.tab3"))
    self.btnVideoModeShowOrHideHandleListBtn = self:child("showOrHideHandleListBtn")
    self.lytDownFlagPanel = self:child("downFlagPanel")
    self.imgVideoModeHideFlagImg = self:child("hideFlagImg")
    self.imgVideoModeUpFlagImg = self:child("upFlagImg")
    self.imgVideoModeDownFlagImg = self:child("downFlagImg")
    self.imgVideoModeHideFlagImg:setVisible(false)
    self.lytDownFlagPanel:setVisible(false)

    self.lytRecordPanel = self:child("recordPanel")
    self.lytRecordPanel:setVisible(false)
    self.lytRecordHidePanel = self:child("recordHidePanel")
    self.lytRecordHidePanel:setVisible(false)
    self.imgHideRecordImg = self:child("hideRecordImg")
    self.txtHideRecordTime = self:child("hideRecordTime")
    self.imgHideRecordImg:setVisible(false)
    self.btnWaitRecordBtn = self:child("waitRecordBtn")
    self.btnRecordingBtn = self:child("recordingBtn")
    self.imgRecordDownIcon = self:child("recordDownIcon")
    self.txtRecordDownStr = self:child("recordDownStr")
    self.txtRecordTimeStr = self:child("recordTimeStr")
    self.btnWaitRecordBtn:setVisible(false)
    self.btnRecordingBtn:setVisible(false)
    self.imgRecordDownIcon:setVisible(false)

    self.lytVideoModeEffectListPanel = self:child("effectListPanel")
    self:updateEffectListPanelShow(false)
    self.lytVideoModeCloseEffect = self:child("CloseEffect")

    for i = 1, 3 do
        self.btnVideoModeTabBtn[i] = self:child("tabBtn"..i)
        self.txtVideoModeTabBtnDec[i] = self:child("tabBtnDec"..i)
        self.txtVideoModeTabBtnDec[i]:setText(Lang:toText("gui.new_video.tab"..i))

        if self.curSelectEffectTab == i then
            self.btnVideoModeTabBtn[i]:setSelected(true)
        else
            self.btnVideoModeTabBtn[i]:setSelected(false)
        end
    end
    self:updateTabTitleColor()

    self.btnVideoModeExitBtn = self:child("exitBtn")

    self.ScrollableView = self:child("ScrollableView")
    self.effectInfoList = self:child("VerticalLayout")
    self.messageView = widget_virtual_vert_list:init(self.ScrollableView, self.effectInfoList,
            function(self, parentWindow)
                local item = UI:openWidget("UI/new_video/gui/widget_video_effect_item")
                parentWindow:addChild(item:getWindow())
                item:setWidth({ 1, 0 })
                return item
            end,
            function(self, childWindow, msg)
                childWindow:initData(msg)
            end
    )
end

function M:initEvent()
    self.btnVideoModeExitBtn.onMouseClick=function()
        self:close()
    end

    for i = 1, 3 do
        self.btnVideoModeSettingData[i].onSelectStateChanged=function(instance, toggle)
            self:setCurHideData(i, toggle:isSelected())
        end
    end

    self.lytVideoModeCloseEffect.onMouseClick=function()
        self:updateEffectViewShow()
    end

    self.btnVideoModeEffectBtn.onMouseClick=function()
        local defaultData = {
            entrance = 0,
            filter = 1,
            hideUI = 0,
            hideSetting = 0,
            pull = 0,
            push = 0,
            exit = 0,
        }
        Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
        self:updateEffectViewShow()
    end

    self.btnVideoModeHideUiBtn.onMouseClick=function()
        local defaultData = {
            entrance = 0,
            filter = 0,
            hideUI = 1,
            hideSetting = 0,
            pull = 0,
            push = 0,
            exit = 0,
        }
        Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
        Recorder:SetHideUi(true)
        self:updateEffectListPanelShow(false)
        self.imgVideoModeHideFlagImg:setVisible(true)
        self:setHandleListState(true)
        self.curHandleState = HANDLE_STATE.UP_HANDLE_LIST
    end

    self.btnVideoModeHideUiSettingBtn.onMouseClick=function()
        local defaultData = {
            entrance = 0,
            filter = 0,
            hideUI = 0,
            hideSetting = 1,
            pull = 0,
            push = 0,
            exit = 0,
        }
        Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
        if self.lytVideoModeHideSettingList:isVisible() then
            self:setHideSettingState(false)
        else
            self:setHideSettingState(true)
        end
    end

    self.btnVideoModeShowOrHideHandleListBtn.onMouseClick=function()
        if self.curHandleState == HANDLE_STATE.DOWN_HANDLE_LIST then
            self.curHandleState = HANDLE_STATE.UP_HANDLE_LIST
            self:setHandleListState(true)
            local defaultData = {
                entrance = 0,
                filter = 0,
                hideUI = 0,
                hideSetting = 0,
                pull = 1,
                push = 0,
                exit = 0,
            }
            Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
            return
        end

        if self.curHandleState == HANDLE_STATE.UP_HANDLE_LIST then
            self.imgVideoModeHideFlagImg:setVisible(false)
            self.curHandleState = HANDLE_STATE.DOWN_HANDLE_LIST
            self:setHandleListState(false)
            Recorder:SetHideUi(false)
            local defaultData = {
                entrance = 0,
                filter = 0,
                hideUI = 0,
                hideSetting = 0,
                pull = 0,
                push = 1,
                exit = 0,
            }
            Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
            return
        end
    end

    for i = 1, 3 do
        self.btnVideoModeTabBtn[i].onSelectStateChanged = function(instance, toggle)
            for j = 1, 3 do
                if self.btnVideoModeTabBtn[j]:isSelected() then
                    self.curSelectEffectTab = j
                    self:showEffectData(j)
                end
            end
            self:updateTabTitleColor()
        end
    end

    self.btnWaitRecordBtn.onMouseClick=function()
        self:updateRecordState(Define.newVideoRecordState.WaitStart)
        Plugins.CallTargetPluginFunc("report", "report", "video_start",  {}, Me)
    end

    self.btnRecordingBtn.onMouseClick=function()
        NewVideoHelper:stopNewVideoRecord()
    end

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_NEW_VIDEO_EFFECT_ITEM, function(tabId, sortIndex)
        if not self.curEffectData[tabId] then
            return
        end

        for key, val in pairs(self.curEffectData[tabId]) do
            if val.sortIndex == sortIndex then
                self.curEffectData[tabId][key].selectState = not val.selectState
                if self.curEffectData[tabId][key].selectState then
                    local defaultData = {
                        videoSelectId = tabId .. "_" .. sortIndex,
                    }
                    Plugins.CallTargetPluginFunc("report", "report", "video_select", defaultData, Me)
                    Recorder:OnSelect(self.curEffectData[tabId][key], true)
                else
                    Recorder:OnSelect(self.curEffectData[tabId][key], false)
                end
            else
                self.curEffectData[tabId][key].selectState = false
            end
        end
        self.messageView:refresh(self.curEffectData[tabId])
    end)

    self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_VIDEO_RECORD_STATE, function(state)
        self:updateRecordState(state)
    end)
end

function M:updateTabTitleColor()
    for j = 1, 3 do
        if self.curSelectEffectTab ~= j then
            self.txtVideoModeTabBtnDec[j]:setProperty("TextColours", "FFFFFFFF")
        else
            self.txtVideoModeTabBtnDec[j]:setProperty("TextColours", "FF000000")
        end
    end
end

function M:setHandleListState(isUp)
    if isUp then
        self.lytVideoModeHandleList:setYPosition({0, -80})
        self.btnVideoModeExitBtn:setVisible(false)
        if self.lytVideoModeHideSettingList:isVisible() then
            self.lytVideoModeHideSettingList:setVisible(false)
        end

        self.imgVideoModeUpFlagImg:setVisible(false)
        self.lytDownFlagPanel:setVisible(true)
    else
        self.lytVideoModeHandleList:setYPosition({0, 0})
        self.btnVideoModeExitBtn:setVisible(true)

        self.imgVideoModeUpFlagImg:setVisible(true)
        self.lytDownFlagPanel:setVisible(false)
    end
end

function M:updateEffectViewShow()
    if self.lytVideoModeEffectListPanel:isVisible() then
        self:setEffectListPanelState(false)
    else
        self:updateEffectListPanelShow(true)
        self:setEffectListPanelState(true)
    end
end

function M:setEffectListPanelState(isShow)
    if not isShow then
        self:updateEffectListPanelShow(false)
    else
        self:updateEffectListPanelShow(true)
        self:showEffectData(self.curSelectEffectTab)
    end
end

function M:updateEffectListPanelShow(isShow)
    self.lytVideoModeEffectListPanel:setVisible(isShow)
    self.imgEffectNormalIcon:setVisible(not isShow)
    self.imgEffectSelectIcon:setVisible(isShow)
end

function M:showEffectData(tab)
    ---@type VideoEffectConfigData[]
    local cfg = VideoEffectConfig:getCfgByTabId(tab)
    if cfg then
        if not self.curEffectData[tab] then
            self.curEffectData[tab] = Lib.copy(cfg)
        end
        self.messageView:clearVirtualChild()
        self.messageView:addVirtualChildList(self.curEffectData[tab])
        self.messageView:setVirtualBarPosition(0)
    end
end

function M:setHideSettingState(isShow)
    if not isShow then
        self.lytVideoModeHideSettingList:setVisible(false)
        self.imgVideoModeSettingListBtnUpImg:setVisible(false)
        self.imgVideoModeSettingListBtnDownImg:setVisible(true)
    else
        self.lytVideoModeHideSettingList:setVisible(true)
        self.imgVideoModeSettingListBtnUpImg:setVisible(true)
        self.imgVideoModeSettingListBtnDownImg:setVisible(false)
    end
end

---@param index number 数据索引：1-隐藏名字；2-隐藏玩家；3-隐藏自己
---@param isSelected boolean 是否选中隐藏选项
function M:setCurHideData(index, isSelected)
    self.curHideData[index] = isSelected

    if index == 1 then
        Recorder:SetHideName(isSelected)
    elseif index == 2 then
        Recorder:SetHideOtherPlayers(isSelected)
        Me.videoHideOther = isSelected
    elseif index == 3 then
        Recorder:SetHideSelf(isSelected)
    end
end

function M:updateRecordState(state)
    self.curRecordState = state
    if self.curRecordState == Define.newVideoRecordState.NoneRecord then
        self.btnWaitRecordBtn:setVisible(true)
        self.btnRecordingBtn:setVisible(false)
        self.imgRecordDownIcon:setVisible(false)
        self.imgHideRecordImg:setVisible(false)
        self:cleanRecordTimer()
    elseif self.curRecordState == Define.newVideoRecordState.WaitStart then
        self.btnWaitRecordBtn:setVisible(false)
        self.btnRecordingBtn:setVisible(false)
        self.imgRecordDownIcon:setVisible(true)
        self.imgHideRecordImg:setVisible(false)
        self.recordPassTime = 0
        self.waitTotalTime = 3
        self.txtRecordDownStr:setText(self.waitTotalTime)
        self:startRecordTimer()
    elseif self.curRecordState == Define.newVideoRecordState.WaitConfirm then
        self.btnWaitRecordBtn:setVisible(false)
        self.btnRecordingBtn:setVisible(false)
        self.imgRecordDownIcon:setVisible(true)
        self.imgHideRecordImg:setVisible(false)
        self.recordPassTime = 0
        self.waitTotalTime = 0
        self.txtRecordDownStr:setText(self.waitTotalTime)
        self:cleanRecordTimer()
    elseif self.curRecordState == Define.newVideoRecordState.Recording then
        self.btnWaitRecordBtn:setVisible(false)
        self.btnRecordingBtn:setVisible(true)
        self.imgRecordDownIcon:setVisible(false)
        self.imgHideRecordImg:setVisible(true)
        self.recordPassTime = 0
        local hours, min, second = Lib.timeFormatting(self.recordPassTime)
        self.txtRecordTimeStr:setText(string.format("%02d:%02d", min, second))
        self.txtHideRecordTime:setText(string.format("%02d:%02d", min, second))
        self:startRecordTimer()
    end
end

function M:updateRecordShow()
    self.curRecordState = Define.newVideoRecordState.NoneRecord
    self.recordPassTime = 0
    if NewVideoHelper:isCanNewVideoRecord() then
        self.lytRecordPanel:setVisible(true)
        self.lytRecordHidePanel:setVisible(true)
        if NewVideoHelper:isGoingNewVideoRecord() then
            self:updateRecordState(Define.newVideoRecordState.Recording)
        else
            self:updateRecordState(Define.newVideoRecordState.NoneRecord)
        end
    else
        self.lytRecordPanel:setVisible(false)
        self.lytRecordHidePanel:setVisible(false)
        Plugins.CallTargetPluginFunc("report", "report", "error_not_available",  {}, Me)
    end
end

function M:startRecordTimer()
    self:cleanRecordTimer()
    self.recordVideoTimer = World.Timer(20, function()
        self.recordPassTime =  self.recordPassTime + 1
        if self.curRecordState == Define.newVideoRecordState.WaitStart then
            local remainTime = self.waitTotalTime - self.recordPassTime
            self.txtRecordDownStr:setText(remainTime)
            if remainTime <= 0 then
                self:cleanRecordTimer()
                NewVideoHelper:beginNewVideoRecord()
            end
        elseif self.curRecordState == Define.newVideoRecordState.Recording then
            local hours, min, second = Lib.timeFormatting(self.recordPassTime)
            self.txtRecordTimeStr:setText(string.format("%02d:%02d", min, second))
            self.txtHideRecordTime:setText(string.format("%02d:%02d", min, second))
        end
        return true
    end)
end

function M:cleanRecordTimer()
    if self.recordVideoTimer then
        self.recordVideoTimer()
        self.recordVideoTimer = nil
    end
end

function M:onOpen()
    local defaultData = {
        entrance = 1,
        filter = 0,
        hideUI = 0,
        hideSetting = 0,
        pull = 0,
        push = 0,
        exit = 0,
    }
    Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
    self.startShowTime = os.time()
    self:cleanRecordTimer()
    self:updateRecordShow()
end

function M:onClose()
    if self.curRecordState == Define.newVideoRecordState.Recording then
        NewVideoHelper:stopNewVideoRecord()
    end
    self:cleanRecordTimer()
    if self._allEvent then
        for _, fun in pairs(self._allEvent) do
            fun()
        end
        self._allEvent={}
    end
    self.messageView:clearVirtualChild()
    if self.startShowTime then
        local defaultData = {
            stayVideoTime = os.time() - self.startShowTime,
        }
        Plugins.CallTargetPluginFunc("report", "report", "video_time", defaultData, Me)
    end
    local defaultData = {
        entrance = 0,
        filter = 0,
        hideUI = 0,
        hideSetting = 0,
        pull = 0,
        push = 0,
        exit = 1,
    }
    Plugins.CallTargetPluginFunc("report", "report", "video_press", defaultData, Me)
    Recorder:OnQuit()
    self.curEffectData = {}
end

M:init()
