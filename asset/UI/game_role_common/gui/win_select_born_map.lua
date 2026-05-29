---@class PlayerBornConfig
local PlayerBornConfig = T(Config, "PlayerBornConfig")

---@class WinSelectBornMapLayout : CEGUILayout
local WinSelectBornMapLayout = M

---@private
function WinSelectBornMapLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinSelectBornMapLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticImage
	self.siMainWindowTitleBg = self.MainWindow.TitleBg
	---@type CEGUIStaticText
	self.stMainWindowTitle = self.MainWindow.Title
	---@type CEGUIDefaultWindow
	self.wMainWindowMap1 = self.MainWindow.Map1
	---@type CEGUIStaticImage
	self.siMainWindowMap1MapIcon = self.MainWindow.Map1.MapIcon
	---@type CEGUIStaticText
	self.stMainWindowMap1MapName = self.MainWindow.Map1.MapName
	---@type CEGUIButton
	self.btnMainWindowMap1SelectButton = self.MainWindow.Map1.SelectButton
	---@type CEGUIDefaultWindow
	self.wMainWindowMap2 = self.MainWindow.Map2
	---@type CEGUIStaticImage
	self.siMainWindowMap2MapIcon = self.MainWindow.Map2.MapIcon
	---@type CEGUIStaticText
	self.stMainWindowMap2MapName = self.MainWindow.Map2.MapName
	---@type CEGUIButton
	self.btnMainWindowMap2SelectButton = self.MainWindow.Map2.SelectButton
end

---@private
function WinSelectBornMapLayout:initUI()
	self.stMainWindowTitle:setText(Lang:toText("g2069_select_born_map"))
	-- self.stMainWindowMap1MapName:setText(Lang:toText(""))
	-- self.stMainWindowMap2MapName:setText(Lang:toText(""))
end

---@private
function WinSelectBornMapLayout:initEvent()
	self.btnMainWindowMap1SelectButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:selectMap(1)
	end
	self.btnMainWindowMap2SelectButton.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:selectMap(2)
	end
end

---@private
function WinSelectBornMapLayout:onOpen()
	self:initData()
	self:initMapInfo()
end

--- 选择地图
---@param index any
function WinSelectBornMapLayout:selectMap(index)
	if not self.maps[index] then
		Lib.logError("Error:Not found the born map, index:", index)
		return
	end

	local this = self
	local mapName = self.maps[index].mapName

	Me:teleportToMapPosition(mapName, nil, function()
		UI:closeWindow(this)
	end, true)
end

function WinSelectBornMapLayout:initMapInfo()
	for index, data in pairs(self.mapNodes) do
		---@type CEGUIWindow
		local node = data.node
		---@type CEGUIStaticText
		local name = data.name
		---@type CEGUIStaticImage
		local icon = data.icon
		if self.maps[index] then
			local config = self.maps[index]
			name:setText(Lang:toText(config.name))
			icon:setImage(config.born_icon)
		else
			node:setVisible(false)
		end
	end
end

function WinSelectBornMapLayout:initData()
	self.maps = {}
	self.mapNodes = {}

	self.mapNodes[#self.mapNodes + 1] = { node = self.wMainWindowMap1, name = self.stMainWindowMap1MapName, icon = self.siMainWindowMap1MapIcon }
	self.mapNodes[#self.mapNodes + 1] = { node = self.wMainWindowMap2, name = self.stMainWindowMap2MapName, icon = self.siMainWindowMap2MapIcon }

	local configs = PlayerBornConfig:getAllCfgs()
	for _, config in pairs(configs) do
		if config.selectableMap == 1 then
			self.maps[#self.maps + 1] = config
		end
	end

	table.sort(self.maps, function(e1, e2)
		return e1.id < e2.id
	end)
end

---@private
function WinSelectBornMapLayout:onDestroy()

end

---@private
function WinSelectBornMapLayout:onClose()

end

WinSelectBornMapLayout:init()
