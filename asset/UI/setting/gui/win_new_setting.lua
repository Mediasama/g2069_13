local settingConfigManager = {}

local pSett = World.cfg.personalSettingUI or {}

local isPGC = Lib.fileExists(Root.Instance():getRootPath() .. "pgc_editor.ini")

function settingConfigManager:load()
    if World.cfg.notReadUserSettingCfgAtEditor and os.getenv("startFromWorldEditor") then
        self.config = {}
        return
    end
    local path = Root.Instance():getRootPath() .. "document/setting_config.json"
    local content = Lib.read_json_file(path)
    if not content then
        content = {}
    end
    self.config = content
end

function settingConfigManager:save()
    local file = "setting_config.json"
    local path = Root.Instance():getRootPath() .. "document/"
    Lib.saveGameJson1(file, self.config, path)
end

function settingConfigManager:getGlobalConfig(mod)
    assert(self.config)
    if not self.config.globalConfig then
        self.config.globalConfig = {}
    end
    if mod then
        if not self.config.globalConfig[mod] then
            self.config.globalConfig[mod] = {}
        end
        return self.config.globalConfig[mod]
    end
    return self.config.globalConfig
end

function settingConfigManager:getSpecialGameConfig(gameName, mod)
    assert(self.config)
    if not self.config.specialGameConfig then
        self.config.specialGameConfig = {}
    end

    if not self.config.specialGameConfig[gameName] then
        self.config.specialGameConfig[gameName] = {}
    end

    if mod then
        if not self.config.specialGameConfig[gameName][mod] then
            self.config.specialGameConfig[gameName][mod] = {}
        end
        return self.config.specialGameConfig[gameName][mod]
    end

    return self.config.specialGameConfig[gameName]
end

function M:onHidden()
    settingConfigManager:save()
end

function M:onShown()
    if M.curSettingWindow and M.curSettingWindow.updateView then
        M.curSettingWindow:updateView(true)
    end
end

local function addChildWindow(parentWindow, childName, visible, name)
    visible = visible or false
    local window = parentWindow[childName]
    if not window then
        window = UI:openSystemWindowOnly(childName, nil, nil, settingConfigManager)
        parentWindow:addChild(window.__window)
        window:setName(name or childName)
        window:setVisible(visible)
    end
end

function M:onOpen()
    settingConfigManager:load()
    addChildWindow(M.detailFunctionArea, "UI/setting/gui/battleSetting", nil, "battleSetting")
    addChildWindow(M.detailFunctionArea, "UI/setting/gui/new_audioAndVideoSetting", nil, "new_audioAndVideoSetting")
    
    M:initUI()
    M:setAlwaysOnTop(true)
end

function M:initFunctionAreaUI()

    local functionArea = M.functionArea
    functionArea.Bg:setImage("setting/bg_tab_DaBeiJing")

    local new_audioAndVideoSetting = functionArea.VerticalLayout.new_audioAndVideoSetting
    new_audioAndVideoSetting.Text:setText(Lang:toText("g2069_setting_audioAndVideoSetting"))
    new_audioAndVideoSetting.selectableImage = "setting/bg_SheZhiZuoCe_TAB_DieHao"
    new_audioAndVideoSetting.unselectableImage = ""
    new_audioAndVideoSetting:setSelected(false)
    M:setSelected("new_audioAndVideoSetting", new_audioAndVideoSetting:isSelected())

    local battleSetting = functionArea.VerticalLayout.battleSetting
    battleSetting.Text:setText(Lang:toText("g2069_game_setting_title1"))
    battleSetting.selectableImage = "setting/bg_SheZhiZuoCe_TAB_DieHao"
    battleSetting.unselectableImage = ""
    battleSetting:setSelected(true)

    local quitButton = functionArea.quit
    quitButton.PushedImage = "setting/icon_exit"
    quitButton.HoverImage = "setting/icon_exit"
    quitButton.NormalImage = "setting/icon_exit"
    quitButton.Text:setText(Lang:toText("g2069_setting_quit"))
end

function M:initTabsUI()
    local Tabs = M.Tabs
    Tabs.Image:setImage("setting/bg_DingBuBiaoTi")
    Tabs.returnButton.PushedImage = "setting/icon_back_setting"
    Tabs.returnButton.HoverImage = "setting/icon_back_setting"
    Tabs.returnButton.NormalImage = "setting/icon_back_setting"
    Tabs.SettingTab:setText(Lang:toText("g2069_setting_title"))
end

function M:adaptUI()
    local root = UI.root
    local displaySize = root:getPixelSize()
    local functionAreaSize = M.functionArea:getPixelSize()
    local detailFunctionAreaSize = UDim2.new(0, displaySize.width - functionAreaSize.width, 1, 0)
    M.detailFunctionArea:setSize(detailFunctionAreaSize)

    M.Image:setSize(UDim2.new(1, 0, 1, 0))
end

function M:initUI()
    M:adaptUI()
    M.Image:setImage("setting/bg_SheZhiDiBuDieHao")
    M:initFunctionAreaUI()
    M:initTabsUI()
end

function M:getSettingButton(name)
    return assert(M.functionArea.VerticalLayout.name, name)
end

function M.Tabs.returnButton:onMouseClick()
    M:setVisible(false)
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
end

function M.functionArea.quit:onMouseButtonDown()
    if not self.orginSize then
        self.orginSize = self:getSize()
    end
    if not self.orginPos then
        self.orginPos = self:getPosition()
    end
    local newSize = UDim2.new(self.orginSize["width"][1], self.orginSize["width"][2] + 8, self.orginSize["height"][1], self.orginSize["height"][2] + 8)
    local newPos = UDim2.new(self.orginPos[1][1], self.orginPos[1][2] - 4, self.orginPos[2][1], self.orginPos[2][2] - 4)
    self:setSize(newSize)
    self:setPosition(newPos)
end

function M.functionArea.quit:onMouseButtonUp()
    self:setSize(self.orginSize)
    self:setPosition(self.orginPos)
end

function M.functionArea.quit:onMouseClick()
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
    --self:setVisible(false)
    Lib.emitEvent(Event.EVENT_ONLINE_ROOM_SHOW, true)
    local window = UI:isOpenWindow("exitGameConfirmationWindow")
    if window then
        window:setVisible(not window:isVisible())
    else
        window = UI:openSystemWindow("exitGameConfirmationWindow")
        --UI:openSystemWindowAsync(function(window)
        --end, "exitGameConfirmationWindow")
    end
end

function M:setSelected(name, select)
    local window = M.functionArea.VerticalLayout:child(name)
    local settingWindow = M.detailFunctionArea:child(name)
    if select then
        settingWindow:setVisible(true)
        window.Text:setTextColours(Color3.fromRGB(41, 44, 47))--"FF292C2F")
        window.Text:setAlpha(1)
        M.curSettingWindow = settingWindow
    else
        settingWindow:setVisible(false)
        window.Text:setTextColours(Color3.new(1, 1, 1))
        window.Text:setAlpha(0.5)
    end
end

function M.functionArea.VerticalLayout.new_audioAndVideoSetting:onSelectStateChanged()
    M:setSelected("new_audioAndVideoSetting", self:isSelected())
end

function M.functionArea.VerticalLayout.battleSetting:onSelectStateChanged()
    M:setSelected("battleSetting", self:isSelected())
end
