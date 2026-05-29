---@class WinTeleportInfoLayout : CEGUILayout
local WinTeleportInfoLayout = M

---@type PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@private
function WinTeleportInfoLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinTeleportInfoLayout:findAllWindow()
	---@type CEGUIStaticText
	self.stMapName = self.MapName
end

---@private
function WinTeleportInfoLayout:initUI()
	self.stMapName:setText(Lang:toText(""))
end

---@private
function WinTeleportInfoLayout:initEvent()
end

---@private
function WinTeleportInfoLayout:onOpen()
    self.infoTimer = LuaTimer:scheduleTicker(function()
        local sceneUIId = self.__sceneUIID
        local sceneUIObj = Instance.getByRuntimeId(sceneUIId)
        if not sceneUIObj or not sceneUIObj:isValid() then
            return
        end
        ---@type Instance
        local instance = sceneUIObj:getParent()
        if not instance or not instance:isValid() then
            return
        end
        LuaTimer:cancel(self.infoTimer)
        self.infoTimer = nil
        local alias = instance:getTeleportAlias()
        if alias and alias ~= "" then
            self.stMapName:setText(Lang:toText(alias))
        else
            local mapName = instance:getAttribute("teleport_map")
            local config = PlayerBornConfig:getCfgByMapName(mapName)
            local name = config.name
            self.stMapName:setText(Lang:toText(name))
        end
    end, 10, 10)
end

---@private
function WinTeleportInfoLayout:onDestroy()
    if self.infoTimer then
        LuaTimer:cancel(self.infoTimer)
        self.infoTimer = nil
    end
end

---@private
function WinTeleportInfoLayout:onClose()

end

WinTeleportInfoLayout:init()
