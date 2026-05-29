---@class WidgetTaskGuideItemWidget : CEGUILayout
local WidgetTaskGuideItemWidget = M

---@private
function WidgetTaskGuideItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetTaskGuideItemWidget:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wGuideNode = self.guideNode
    ---@type CEGUIStaticImage
    self.siGuideNodeGuideIcon = self.guideNode.guideIcon
    ---@type CEGUIStaticText
    self.stGuideNodeGuideText = self.guideNode.guideText
end

---@private
function WidgetTaskGuideItemWidget:initUI()
    self.curScale = 1
end

function WidgetTaskGuideItemWidget:updateDistanceShow(dis)
    local str = math.ceil(dis) .. " m"
    self.stGuideNodeGuideText:setText(str)

    if dis >= World.cfg.task_systemSetting.guideChangeDis then
        if self.curScale ~= World.cfg.task_systemSetting.guideChangeScale then
            self.curScale = World.cfg.task_systemSetting.guideChangeScale
            self.wGuideNode:setWidth({ self.curScale, 0 })
            self.wGuideNode:setHeight({ self.curScale, 0 })
        end
    else
        if self.curScale ~= 1 then
            self.curScale = 1
            self.wGuideNode:setWidth({ self.curScale, 0 })
            self.wGuideNode:setHeight({ self.curScale, 0 })
        end
    end
end

function WidgetTaskGuideItemWidget:updateTaskTypeShow(taskType)
    if taskType == Define.TaskType.Main then
        self.siGuideNodeGuideIcon:setImage("asset/imageset/overhead_and_kill:img_0_main_head")
    else
        self.siGuideNodeGuideIcon:setImage("asset/imageset/overhead_and_kill:img_0_branch_head")
    end
end

---@private
function WidgetTaskGuideItemWidget:initEvent()
end

---@private
function WidgetTaskGuideItemWidget:onOpen()

end

---@private
function WidgetTaskGuideItemWidget:onDestroy()

end

WidgetTaskGuideItemWidget:init()
