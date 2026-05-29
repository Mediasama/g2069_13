---@class WinTopTipsLayout : CEGUILayout
local WinTopTipsLayout = M

---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@private
function WinTopTipsLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinTopTipsLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siImage = self.Image
    ---@type CEGUIStaticText
    self.stText = self.Text
end

---@private
function WinTopTipsLayout:initUI()
    self.stText:setText(Lang:toText(""))
end

---@private
function WinTopTipsLayout:initEvent()
end

---@private
function WinTopTipsLayout:onOpen(showText, params)
    self:showTip(showText, params)
    
end

function WinTopTipsLayout:showTip(showText, params)
    self.stText:setText(showText)
    if params and params.bgImage then
        self.siImage:setImage(params.bgImage)
    end
    local time = 40
    if params and params.showTime then
        time = params.showTime
    end
    -- 刷新底图
    local width = math.clamp(self.stText:getWidth()[2] + 80, 250, 800)
    self.siImage:setWidth({ 0, width })

    self.timer = LuaTimer:scheduleTicker(function()
        UI:closeWindow(self)
    end, time)
end

function WinTopTipsLayout:updateContent(showText, params)
    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
    self:showTip(showText, params)
end

---@private
function WinTopTipsLayout:onDestroy()

end

---@private
function WinTopTipsLayout:onClose()
    if self.timer then
        LuaTimer:cancel(self.timer)
        self.timer = nil
    end
end

WinTopTipsLayout:init()
