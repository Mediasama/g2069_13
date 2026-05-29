---@class WinEnterPkWaitLayout : CEGUILayout
local WinEnterPkWaitLayout = M

---@private
function WinEnterPkWaitLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinEnterPkWaitLayout:findAllWindow()
    ---@type CEGUIStaticImage
    self.siPKBg = self.PKBg
    ---@type CEGUIStaticText
    self.stPKBgPKTime = self.PKBg.PKTime
    ---@type CEGUIStaticText
    self.stPKBgPKTimePkTips = self.PKBg.PKTime.PkTips
end

---@private
function WinEnterPkWaitLayout:initUI()
    self.stPKBgPKTimePkTips:setText(Lang:toText("g2069_main_enter_pk_tips"))
end

---@private
function WinEnterPkWaitLayout:initEvent()
end

---@private
function WinEnterPkWaitLayout:onOpen(objID)
    self.objID = objID
    self:startEnterTimer()
end

function WinEnterPkWaitLayout:startEnterTimer()
    self:stopEnterTimer()
    local totalTime = World.cfg.pkWaitEnter.waitTime
    local passTime = 0
    self.stPKBgPKTime:setText(totalTime - passTime .. "s")
    self.enterTimer = World.Timer(20, function()
        passTime = passTime + 1
        self.stPKBgPKTime:setText(totalTime - passTime .. "s")
        if passTime >= totalTime then
            self:doClosePkWin()
            return false
        end
        return true
    end)
end

function WinEnterPkWaitLayout:doClosePkWin()
    self:stopEnterTimer()
    local entity = World.CurWorld:getEntity(self.objID)
    if entity and entity:isValid() then
        entity.headPkInstance = nil
    end
    if self.objID == Me.objID then
        Me:setSafeModeType(Define.PKModeType.pk1)
    end
    UI:closeSceneWindow(self:getName())
end

function WinEnterPkWaitLayout:stopEnterTimer()
    if self.enterTimer then
        self.enterTimer()
        self.enterTimer = nil
    end
end

---@private
function WinEnterPkWaitLayout:onDestroy()

end

---@private
function WinEnterPkWaitLayout:onClose()
    self:stopEnterTimer()
end

WinEnterPkWaitLayout:init()
