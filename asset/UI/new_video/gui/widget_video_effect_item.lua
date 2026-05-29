
function  M:init()
    self:initEvent()
end

function M:initEvent()
    self.onMouseClick=function()
        if self.data then
            Lib.emitEvent(Event.EVENT_NEW_VIDEO_EFFECT_ITEM, self.data.tabId, self.data.sortIndex)
        end
    end
end

function M:initData(data)
    self.data = data
    self.icon:setImage(data.icon)
    self.titleDec:setText(Lang:toText(data.titleLang))
    self:setSelectState(data.selectState)
end

function M:setSelectState(isSelect)
    self.iconSelected:setVisible(isSelect)
end

M:init()