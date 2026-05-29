local lfs = require("lfs")
local UtilCameraEdit = T(Lib, "UtilCameraEdit")

---@class CameraEditLayout : CEGUILayout
local CameraEditLayout = M
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"
---@private
function CameraEditLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function CameraEditLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siNodePanel = self.nodePanel
    ---@type CEGUIStaticText
    self.stNodePanelText = self.nodePanel.Text
    ---@type CEGUIStaticText
    self.stNodePanelInfo = self.nodePanel.info
    ---@type CEGUIEditbox
    self.wNodePanelSmoothDur = self.nodePanel.smoothDur
    ---@type CEGUIScrollableView
    self.wNodePanelNodeCon = self.nodePanel.nodeCon
    ---@type CEGUIVerticalLayoutContainer
    self.wNodePanelNodeConVerNodeCon = self.nodePanel.nodeCon.verNodeCon
    ---@type CEGUIButton
    self.btnNodePanelAddNode = self.nodePanel.addNode
    ---@type CEGUIStaticText
    self.stNodePanelPos = self.nodePanel.pos
    ---@type CEGUIStaticText
    self.stNodePanelRotate = self.nodePanel.rotate
    ---@type CEGUIButton
    self.btnNodePanelResetNode = self.nodePanel.resetNode
    ---@type CEGUIButton
    self.btnNodePanelInOrOut = self.nodePanel.inOrOut
    ---@type CEGUIStaticImage
    self.siFilePanel = self.filePanel
    ---@type CEGUIStaticText
    self.stFilePanelFileName = self.filePanel.fileName
    ---@type CEGUIStaticText
    self.stFilePanelText = self.filePanel.Text
    ---@type CEGUIButton
    self.btnFilePanelCreateFile = self.filePanel.createFile
    ---@type CEGUIButton
    self.btnFilePanelWriteFile = self.filePanel.writeFile
    ---@type CEGUIDefaultWindow
    self.wFileWindowRoot = self.fileWindowRoot
    ---@type CEGUIStaticImage
    self.siFileWindowRootMask = self.fileWindowRoot.mask
    ---@type CEGUIStaticImage
    self.siFileWindowRootFileWindow = self.fileWindowRoot.fileWindow
    ---@type CEGUIButton
    self.btnFileWindowRootFileWindowCreateFile1 = self.fileWindowRoot.fileWindow.createFile1
    ---@type CEGUIEditbox
    self.wFileWindowRootFileWindowFileNameInt = self.fileWindowRoot.fileWindow.fileNameInt
    ---@type CEGUIStaticText
    self.stFileWindowRootFileWindowText = self.fileWindowRoot.fileWindow.Text
    ---@type CEGUIStaticImage
    self.siFileWindowRootTipWindow = self.fileWindowRoot.tipWindow
    ---@type CEGUIButton
    self.btnFileWindowRootTipWindowCancel = self.fileWindowRoot.tipWindow.cancel
    ---@type CEGUIButton
    self.btnFileWindowRootTipWindowOk = self.fileWindowRoot.tipWindow.ok
    ---@type CEGUIStaticText
    self.stFileWindowRootTipWindowTipText = self.fileWindowRoot.tipWindow.TipText
    ---@type CEGUIButton
    self.btnHideOrShow = self.hideOrShow
    ---@type CEGUIButton
    self.btnPreview = self.preview
end

---@private
function CameraEditLayout:initUI()
    self.stFilePanelFileName:setText("尚未加載xml")

    self.wFileWindowRoot:setVisible(false)
end

---@private
function CameraEditLayout:initEvent()
    self.btnNodePanelAddNode.onMouseClick = function()
        if self.xmlData then
            self:addNode()
        else
            self:showTipWnd("请先创建或加载xml",function()
                self:showLoadWnd()
            end)
        end

    end
    self.btnNodePanelResetNode.onMouseClick = function()
        if self.curNodeIdx <1 then
            self:showTipWnd("请先创建或加载xml",function()
                self:showLoadWnd()
            end)
        else
            self:setNode()
        end
    end
    self.btnNodePanelInOrOut.onMouseClick = function()
        local initPos = self.siNodePanel:getPosition()
        if self.isin then
            self.isin = false
            UI.doTrans(self.siNodePanel,{x={initPos[1][1],initPos[1][2]+250}  ,y=initPos[2]},0.5)
            self.btnNodePanelInOrOut:setText("<-")
        else
            self.isin = true
            UI.doTrans(self.siNodePanel,{x={initPos[1][1],initPos[1][2]-250}  ,y=initPos[2]},0.5)
            self.btnNodePanelInOrOut:setText("->")
        end

    end
    self.btnFilePanelCreateFile.onMouseClick = function()
        if self.xmlData and #self.xmlData > 0 then
            self:showTipWnd("新建或读取其他xml之前，请确保已保存",function()
                self:showLoadWnd()
            end)
        else
            self:showLoadWnd()
        end
    end
    self.btnFilePanelWriteFile.onMouseClick = function()
        if not self.xmlName then
            self:showTipWnd("请先加载或新建一个xml",function()
                self:showLoadWnd()
            end)
            return
        end
        if not self.xmlData or #self.xmlData<1 then
            self:showTipWnd("还没有创建节点。")
        end
        self:saveXML()
        self:showTipWnd("文件："..self.xmlName.."已保存更新")
    end
    self.btnFileWindowRootFileWindowCreateFile1.onMouseClick = function()
        if not self.xmlName then
            self:showTipWnd("请输入镜头xml文件名",function()
                self:showLoadWnd()
            end)
        end
        local path = string.format("%sconfig/camera_path_xml/%s.xml", Root.Instance():getGamePath(), self.xmlName)
        local xmlSrc = io.open(path)
        if not xmlSrc then
            self:showTipWnd("未找到xml，要新建吗？",function()
                self:initNewPath()
            end,function()
                self:showLoadWnd()
            end)
        else
            self.xmlData = UtilCameraEdit:xml2tb(xmlSrc)
            self.stFilePanelFileName:setText(self.xmlName)
            self.curNodeIdx = #self.xmlData
            self.nodeList:refresh(self.xmlData)
            self.wFileWindowRoot:setVisible(false)
        end
    end

    --print("sdasdasdas",self.btnFileWindowRootTipWindowClose)
    self.btnFileWindowRootTipWindowCancel.onMouseClick = function()
        self.wFileWindowRoot:setVisible(false)
        if self.cbClose then
            self.cbClose()
            self.cbClose = false
        end

    end
    self.btnFileWindowRootTipWindowOk.onMouseClick = function()
        self.wFileWindowRoot:setVisible(false)
        if self.cbOk then
            self.cbOk()
            self.cbOk = false
        end
    end
    self.btnHideOrShow.onMouseClick = function()
        self:showTipWnd("是否保存当前镜头信息到当前XML？",function()
            self:saveXML()
            self:showTipWnd("文件："..self.xmlName.."已保存更新",function()
                UI:closeWindow(self)
            end)

        end,
        function()
            UI:closeWindow(self)
        end)

    end
    self.btnPreview.onMouseClick = function()
        if self.xmlData and #self.xmlData>0 then
            Me:playMovie(self.xmlData)
        else
            self:showTipWnd("还没有创建节点。")
        end

    end

    self.wNodePanelSmoothDur.onTextChanged = function()
        local text = self.wNodePanelSmoothDur:getText()
        if text then
            self.smoothDur = tonumber(text)
        end


    end

    self.wFileWindowRootFileWindowFileNameInt.onTextChanged = function()
        local text = self.wFileWindowRootFileWindowFileNameInt:getText()
        if text then
            self.xmlName = text
        end
    end

    self.updateInfo = World.Timer(5,function()
        local pos = self.mainCamera:getPosition()
        pos.x = math.floor(pos.x*100)/100
        pos.y = math.floor(pos.y*100)/100
        pos.z = math.floor(pos.z*100)/100

        --toEulerAngle
        local _,_,r = self.mainCamera:getOrientation():toEulerAngle()

        local pitch = math.floor(Blockman.instance:getViewerPitch()*100)/100
        local yaw = math.floor(Blockman.instance:getViewerYaw()*100)/100
        local roll = math.floor(r*100)/100
        self.stNodePanelPos:setText("pos:"..tostring(pos.x..","..pos.y..","..pos.z))
        self.stNodePanelRotate:setText("rotate:"..tostring(pitch..","..yaw))
        return true
    end)

end

---@private
function CameraEditLayout:onOpen()
    self:initList()
    self.mainCamera = Camera.getActiveCamera()
    Me:setActorHide(true)
    Blockman.instance:setPersonView(0)
    Me:setFlyMode(1)
    self.reShow = UI:hideAllWindow({ "UI/gm/gui/camera_edit" })
end

---@private
function CameraEditLayout:onDestroy()

end

---@private
function CameraEditLayout:onClose()
    Me:setActorHide(false)
    Blockman.instance:setPersonView(3)
    Me:setFlyMode(0)
    if self.updateInfo then
        self.updateInfo()
    end
    if self.reShow then
        self.reShow()
        self.reShow = nil
    end
end

---@private
function CameraEditLayout:initData()
    self.xmlName = nil
    self.xmlData = nil
end

function CameraEditLayout:initList()
    local this = self
    ---@type widget_virtual_vert_list
    self.nodeList = widget_virtual_vert_list:init(
            self.wNodePanelNodeCon,self.wNodePanelNodeConVerNodeCon,
    ---@type any, CEGUIWindow
            function(self, parent)
                ---@type WidgetCameraItemWidget
                local node = UI:openWidget("UI/gm/gui/widget_camera_item")
                parent:addChild(node:getWindow())
                node:registerCallHandler("select", this, this.onCallHandler)
                node:registerCallHandler("selected", this, this.onCallHandler)
                return node
            end,
    ---@type any, WidgetCameraItemWidget, table
            function(self, node, data)
                node:updateInfo(data)
            end
    )
    self.nodeList:addVirtualChildList(self.xmlData)
end
function CameraEditLayout:onCallHandler(event, ...)
    if event == "selected" then
        local index = table.unpack({ ... })
        return  self.curNodeIdx == index
    elseif event == "select" then
        local index = table.unpack({ ... })
        self.curNodeIdx = index

        print("CameraEditLayout onCallHandler select",index)

        Lib.emitEvent("select_now", self.curNodeIdx)
    end
end
---@private
function CameraEditLayout:showLoadWnd()
    self.wFileWindowRoot:setVisible(true)
    self.siFileWindowRootFileWindow:setVisible(true)
    self.siFileWindowRootTipWindow:setVisible(false)
end
---@private
function CameraEditLayout:showTipWnd(msg,cbOk,cbClose)
    self.wFileWindowRoot:setVisible(true)
    self.siFileWindowRootFileWindow:setVisible(false)
    self.siFileWindowRootTipWindow:setVisible(true)
    self.stFileWindowRootTipWindowTipText:setText(msg)
    if cbOk then
        self.cbOk = cbOk
    else
        self.cbOk = false
    end
    if cbClose then
        self.cbClose = cbClose
        self.btnFileWindowRootTipWindowCancel:setVisible(true)
    else
        self.cbClose = false
        self.btnFileWindowRootTipWindowCancel:setVisible(false)
    end

end
function CameraEditLayout:saveXML()
    if self.xmlData then
        UtilCameraEdit:tb2xmlAndSave(self.xmlName,self.xmlData)
    end
end
function CameraEditLayout:initNewPath()
    if self.xmlName then
        self.stFilePanelFileName:setText(self.xmlName)
    end
    self.xmlData = {}
    self.curNodeIdx = 0
    self.smoothDur = 0

end

function CameraEditLayout:addNode()
    if self.curNodeIdx == 0 then
        self.smoothDur = 0
    end
    local pos = self.mainCamera:getPosition()
    local data = {}
    data.index = self.curNodeIdx+1
    data.smooth = self.smoothDur
    data.x = math.floor(pos.x*100)/100
    data.y = math.floor(pos.y*100)/100
    data.z = math.floor(pos.z*100)/100
    data.pitch = math.floor(Blockman.instance:getViewerPitch()*100)/100
    data.yaw = math.floor(Blockman.instance:getViewerYaw()*100)/100
    table.insert(self.xmlData,data)
    self.curNodeIdx = #self.xmlData
    self.nodeList:refresh(self.xmlData)
end
function CameraEditLayout:setNode()
    if self.curNodeIdx and self.curNodeIdx>0 and self.xmlData[self.curNodeIdx] then
        local pos = self.mainCamera:getPosition()
        self.xmlData[self.curNodeIdx] = {}
        self.xmlData[self.curNodeIdx].index = self.curNodeIdx
        self.xmlData[self.curNodeIdx].smooth = self.smoothDur
        self.xmlData[self.curNodeIdx].x =  math.floor(pos.x*100)/100
        self.xmlData[self.curNodeIdx].y =  math.floor(pos.y*100)/100
        self.xmlData[self.curNodeIdx].z =  math.floor(pos.z*100)/100
        self.xmlData[self.curNodeIdx].pitch =  math.floor(Blockman.instance:getViewerPitch()*100)/100
        self.xmlData[self.curNodeIdx].yaw = math.floor(Blockman.instance:getViewerYaw()*100)/100
        self.nodeList:refresh(self.xmlData)

    end
end


CameraEditLayout:init()


