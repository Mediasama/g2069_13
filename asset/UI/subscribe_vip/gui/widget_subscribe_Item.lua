---@class WidgetSubscribeItemWidget : CEGUILayout
local WidgetSubscribeItemWidget = M

---@private
function WidgetSubscribeItemWidget:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WidgetSubscribeItemWidget:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wPanel = self.panel
    ---@type CEGUIStaticImage
    self.siPanelBG = self.panel.BG
    ---@type CEGUIStaticImage
    self.siPanelIcon = self.panel.Icon
    ---@type CEGUIStaticText
    self.stPanelText = self.panel.Text
end

---@private
function WidgetSubscribeItemWidget:initUI()

end

function WidgetSubscribeItemWidget:initData(data)
    self.data = data
    if data.isBlack then
        self.siPanelBG:setImage("gameres|asset/UI/subscribe_vip/imageset/subscribe_new_game_vip:img_9_bottom3black")
        self.siPanelIcon:setImage("gameres|asset/UI/subscribe_vip/imageset/subscribe_new_game_vip:img_0_dot2black")
        self.stPanelText:setProperty("TextColours", "FFFFCA4A")
    else
        self.siPanelBG:setImage("gameres|asset/UI/subscribe_vip/imageset/subscribe_new_game_vip:img_9_bottom3")
        self.siPanelIcon:setImage("gameres|asset/UI/subscribe_vip/imageset/subscribe_new_game_vip:img_0_dot")
        self.stPanelText:setProperty("TextColours", "FF582F1D")
    end

    local subscribe_vipSetting = World.cfg.subscribe_vipSetting
    local langTable = {data.itemText}
    if data.itemParma then
        for _, val in pairs(data.itemParma) do
            table.insert(langTable, subscribe_vipSetting[val])
        end
    end
    local text = Lang:toText(langTable)
    self.stPanelText:setText(text)
end

---@private
function WidgetSubscribeItemWidget:initEvent()
end

---@private
function WidgetSubscribeItemWidget:onOpen()

end

---@private
function WidgetSubscribeItemWidget:onDestroy()

end

WidgetSubscribeItemWidget:init()
