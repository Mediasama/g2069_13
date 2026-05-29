

M.viewDatas = {}
M.sensitiveDatas = {
  lowerBound = World.cfg.minSensitive or 4,
  upperBound = World.cfg.maxSensitive or 10,
}

M.viewOptions = {
  [0] = "firstPersonView",
  [1] = "thridPersonView",
  [2] = "thirdPersonPositiveView",
  [3] = "flexibleView",
  [4] = "fixedView",
}

local function saveAudioData()
  M.settingConfig.audioData = Lib.copy(M.audioData)
end

local function saveSensitiveData()
  local savedDatas = {}
  for view, _ in pairs(M.viewDatas) do
    local data = M.sensitiveDatas[view]
    local sensitiveData = {}
    sensitiveData.sensitive = data.sensitive
    savedDatas[view] = sensitiveData
  end
  M.cameraSettingConfig.sensitiveDatas = savedDatas
end

local function saveFovAngleData()
  local savedDatas = {}
  for view, data in pairs(M.viewDatas) do
    local fovAngleData = {}
    fovAngleData.viewFovAngle = data.viewFovAngle
    savedDatas[view] = fovAngleData
  end
  M.cameraSettingConfig.viewDatas = savedDatas
end

local function saveData()
  saveAudioData()
  saveFovAngleData()
  --saveSensitiveData()
end

local function loadAudioData()
  M.audioData = {}
  local bgmData = {}
  local bgmConfigData = M.settingConfig.audioData and M.settingConfig.audioData["bgm"] or {}
  bgmData.enable = bgmConfigData.enable ~= false
  bgmData.volume = bgmConfigData.volume or 0
  M.audioData["bgm"] = bgmData

  local effectData = {}
  local effectConfigData = M.settingConfig.audioData and M.settingConfig.audioData["effect"] or {}
  effectData.enable = effectConfigData.enable ~= false
  effectData.volume = effectConfigData.volume or 0
  M.audioData["effect"] = effectData
end

local function loadSensitiveData()
  local curPersonView = Blockman.instance:getPersonView()
  if M.cameraSettingConfig.curPersonView and M.viewDatas[M.cameraSettingConfig.curPersonView] then
    curPersonView = M.cameraSettingConfig.curPersonView
  end
  M.curPersonView = curPersonView

  M.sensitiveDatas.range = M.sensitiveDatas.upperBound - M.sensitiveDatas.lowerBound
  local sensitive = Blockman.instance.gameSettings:getCameraSensitive()
  local settingConfig = M.cameraSettingConfig.sensitiveDatas
  for view, _ in pairs(M.viewDatas) do
    local sensitiveData = {}
    M.sensitiveDatas[view] = sensitiveData
    sensitiveData.sensitive = sensitive * 10
    for key, val in pairs(settingConfig and settingConfig[view] or {}) do
      sensitiveData[key] = val
    end
  end
end


local function loadFovAngleData()
  local curPersonView = Blockman.instance:getPersonView()
  if M.cameraSettingConfig.curPersonView and M.viewDatas[M.cameraSettingConfig.curPersonView] then
    curPersonView = M.cameraSettingConfig.curPersonView
  end
  M.curPersonView = curPersonView

  local cameraCfg = World.cfg.cameraCfg
  local isPhoneEditorCfg =  cameraCfg and cameraCfg.selectViewBtn
  local optionalViewIdxs = {}
  if isPhoneEditorCfg then
    if cameraCfg.canSwitchView then
      optionalViewIdxs[0] = true
      optionalViewIdxs[1] = true
    else
      optionalViewIdxs[3] = true
    end
  else -- PC Editor Cfg
    for idx, _ in pairs(M.viewOptions) do
      local viewCfg = Blockman.instance:getCameraInfo(idx).viewCfg
      if viewCfg.enable then
        optionalViewIdxs[idx] = true
      end
    end
  end

  for idx, name in pairs(M.viewOptions) do
    local viewCfg = Blockman.instance:getCameraInfo(idx).viewCfg
    local enable = optionalViewIdxs[idx]
    if not enable then

    else
      local viewData = {}
      M.viewDatas[idx] = viewData
      viewData.lowerBound = math.floor(viewCfg.viewFovAngle * 0.5)
      viewData.lowerBound = viewData.lowerBound < 0 and 0 or viewData.lowerBound
      viewData.upperBound = math.floor(viewCfg.viewFovAngle * 1.5)
      viewData.upperBound = viewData.upperBound > 180 and 180 or viewData.upperBound
      viewData.viewFovAngle = viewCfg.viewFovAngle
      viewData.fovAngleRange = viewData.upperBound - viewData.lowerBound
      viewData.viewCfg = viewCfg

      local settingConfig = M.cameraSettingConfig.viewDatas
      for key, val in pairs(settingConfig and settingConfig[tostring(idx)] or {}) do
        viewData[key] = val
      end
    end
  end
end

local function loadData()
  loadAudioData()
  loadFovAngleData()
  --loadSensitiveData()
  saveData()
end

function M:initAudioUI()
  local audio = M.audio
  audio.audioTab.Image = "setting/bg_BiaoTi"
  audio.audioTab.setting:setText(Lang:toText("g2069_setting_audioAndVideoSetting_audioTab"))
  audio.music.desc:setText(Lang:toText("g2069_setting_audioAndVideoSetting_music_desc"))
  audio.effect.desc:setText(Lang:toText("g2069_setting_audioAndVideoSetting_effect_desc"))
  local bgmSlider = M.audio.music.Slider
  local bgmCheckbox = M.audio.music.Checkbox
  bgmSlider.TopImageStretch = "1 0 1 0"
  bgmCheckbox.selectableImage = "setting/KaiGuan_Kai"
  bgmCheckbox.unselectableImage = "setting/KaiGuan_Guan"

  local effectSlider = M.audio.effect.Slider
  local effectCheckbox = M.audio.effect.Checkbox
  effectSlider.TopImageStretch = "1 0 1 0"
  effectCheckbox.selectableImage = "setting/KaiGuan_Kai"
  effectCheckbox.unselectableImage = "setting/KaiGuan_Guan"
end

function M:initSensitiveUI()
  --local sensitiveLayout = M.sensitiveLayout
  --local layout = sensitiveLayout.layout
  --sensitiveLayout.Tab.setting:setText(Lang:toText("setting.cameraSetting.sensitiveLayout.tab"))
  --sensitiveLayout.Tab:setImage("setting/bg_BiaoTi")
  --layout.desc:setText(Lang:toText("setting.cameraSetting.sensitiveLayout.desc"))
  --layout.min:setText(Lang:toText("setting.cameraSetting.sensitiveLayout.min"))
  --layout.max:setText(Lang:toText("setting.cameraSetting.sensitiveLayout.max"))
  --local Slider = layout.Slider
  --Slider.slider_bg = "setting/HuaGan_Xia"
  --Slider.slider_top = "setting/HuaGan_Shang"
  --Slider.TopImageStretch = "1 0 1 0"
  --local thumb = Slider:getThumb()
  --thumb:setProperty("thumb_image", "setting/HuaGan_KongZhiHuaGan")
end

function M:initFovUI()
  local fovLayout = M.fovLayout
  local layout = fovLayout.layout
  fovLayout.Tab.setting:setText(Lang:toText("g2069_setting_cameraSetting_fovLayout_tab"))
  fovLayout.Tab:setImage("setting/bg_BiaoTi")
  layout.desc:setText(Lang:toText("g2069_setting_cameraSetting_fovLayout_desc"))
  layout.min:setText(Lang:toText("g2069_setting_cameraSetting_fovLayout_min"))
  layout.max:setText(Lang:toText("g2069_setting_cameraSetting_fovLayout_max"))
  local Slider = layout.Slider
  Slider.slider_bg = "setting/HuaGan_Xia"
  Slider.slider_top = "setting/HuaGan_Shang"
  Slider.TopImageStretch = "1 0 1 0"
  local thumb = Slider:getThumb()
  thumb:setProperty("thumb_image", "setting/HuaGan_KongZhiHuaGan")
end

function M:init()
  loadData()
  M:initAudioUI()
  M:initFovUI()
  M.sensitiveLayout:setVisible(false)

  local viewData = M.viewDatas[M.curPersonView]
  Blockman.instance:setViewFovAngle(math.floor(viewData.viewFovAngle))

  --M:initSensitiveUI()
  --
  --local sensitiveData = M.sensitiveDatas[M.curPersonView]
  --local sensitive = sensitiveData.sensitive / 10
  --Blockman.instance.gameSettings:setCameraSensitive(sensitive)

  M:updateView()
end

function M:onOpen(instance, settingConfigManager)
  M.settingConfig = settingConfigManager:getGlobalConfig("audioAndVideoSetting")
  M.cameraSettingConfig = settingConfigManager:getSpecialGameConfig(World.GameName, "cameraSetting")
  M:init()
end

function M.audio.music.Checkbox:onSelectStateChanged(instance)
  local type = 0
  local data = M.audioData["bgm"]
  data.enable = instance:isSelected()
  saveAudioData()
  TdAudioEngine.Instance():mute(type, not data.enable)
  M:updateAudioView(type, true)
end

function M.audio.effect.Checkbox:onSelectStateChanged(instance)
  local type = 1
  local data = M.audioData["effect"]
  data.enable = instance:isSelected()
  saveAudioData()
  TdAudioEngine.Instance():mute(type, not data.enable)
  M:updateAudioView(type, true)
end

function M.audio.music.Slider:onSliderValueChanged(instance)
  local bgmData = M.audioData["bgm"]
  local volume = instance:getCurrentValue() / 100
  TdAudioEngine.Instance():setBgmVolume(volume)
  bgmData.volume = volume
  saveAudioData()
end

function M.audio.effect.Slider:onSliderValueChanged(instance)
  local effectData = M.audioData["effect"]
  local volume = instance:getCurrentValue() / 100
  TdAudioEngine.Instance():setEffectVolume(volume)
  effectData.volume = volume
  saveAudioData()
end

function M:updateAudioView(type, triggerByCheckbox)
  local data
  local Audio
  if type == 0 then
    Audio = M.audio:child("music")
    data = M.audioData["bgm"]
  elseif type == 1 then
    Audio = M.audio:child("effect")
    data = M.audioData["effect"]
  end
  local Slider = Audio:child("Slider")
  local Thumb = Slider:getThumb()
  local Checkbox = Audio:child("Checkbox")
  local enable = data.enable
  if enable then
    Slider.slider_bg = "setting/HuaGan_Xia"
    Slider.slider_top = "setting/HuaGan_Shang"
    Thumb:setProperty("thumb_image", "setting/HuaGan_KongZhiHuaGan")
  else
    Slider.slider_bg = "setting/HuaGan_Xia_Hui"
    Slider.slider_top = "setting/HuaGan_Shang_Hui"
    Thumb:setProperty("thumb_image", "setting/HuaGan_KongZhiHuaGan_Hui")
  end

  if not triggerByCheckbox then
    Checkbox:setSelected(enable)
  end
  Slider:setEnabled(enable)
  Slider:setCurrentValue(data.volume*100)
end

function M:updateData()
  local bgmData = M.audioData["bgm"]
  local effectData = M.audioData["effect"]
  TdAudioEngine.Instance():getBgmVolume(function(volume)
    bgmData.volume = volume
    M:updateAudioView(0)
    saveData()
  end)
  TdAudioEngine.Instance():getMute(0, function(isMute)
    bgmData.enable = not isMute
    M:updateAudioView(0)
    saveData()
  end)

  TdAudioEngine.Instance():getEffectVolume(function(volume)
    effectData.volume = volume
    M:updateAudioView(1)
    saveData()
  end)
  TdAudioEngine.Instance():getMute(1, function(isMute)
    effectData.enable = not isMute
    M:updateAudioView(1)
    saveData()
  end)
  saveData()
end

function M:onShown()
  M:updateView(true)
end


function M:updateSensitiveView(triggerBySlider)
  local sensitiveLayout = M.sensitiveLayout.layout
  local sensitiveData = M.sensitiveDatas[M.curPersonView]
  local curValText = string.format("%.1f", sensitiveData.sensitive)
  sensitiveLayout.curValue:setText(curValText)
  if not triggerBySlider then
    local sensitiveSliderVal = (sensitiveData.sensitive - M.sensitiveDatas.lowerBound) / M.sensitiveDatas.range
    sensitiveLayout.Slider:setCurrentValue(sensitiveSliderVal)
  end
end

function M:updateFovView(triggerBySlider)
  local viewData = M.viewDatas[M.curPersonView]
  local fovLayout = M.fovLayout.layout
  local curValText = string.format("x%.2f", viewData.viewFovAngle / viewData.viewCfg.viewFovAngle)
  fovLayout.curValue:setText(curValText)
  if not triggerBySlider then
    local sliderVal = (viewData.viewFovAngle - viewData.lowerBound) / viewData.fovAngleRange
    fovLayout.Slider:setCurrentValue(sliderVal)
  end
end

function M:updateView(updateData)
  if updateData then
    M:updateData()
    return 
  end
  M:updateAudioView(0)
  M:updateAudioView(1)
  M:updateFovView()
  --M:updateSensitiveView()
end

--function M.sensitiveLayout.layout.Slider:onSliderValueChanged(instance)
--  local sensitiveLayout = M.sensitiveLayout.layout
--  local sensitiveData = M.sensitiveDatas[M.curPersonView]
--  local sliderVal = sensitiveLayout.Slider:getCurrentValue()
--  sensitiveData.sensitive = sliderVal * M.sensitiveDatas.range + M.sensitiveDatas.lowerBound
--  local sensitive = sensitiveData.sensitive / 10
--  Blockman.instance.gameSettings:setCameraSensitive(sensitive)
--  saveSensitiveData()
--  M:updateSensitiveView(true)
--end

function M.fovLayout.layout.Slider:onSliderValueChanged(instance)
  local fovLayout = M.fovLayout.layout
  local viewData = M.viewDatas[M.curPersonView]
  local sliderVal = fovLayout.Slider:getCurrentValue()
  viewData.viewFovAngle = sliderVal * viewData.fovAngleRange + viewData.lowerBound
  Blockman.instance:setViewFovAngle(math.floor(viewData.viewFovAngle))
  saveFovAngleData()
  M:updateFovView(true)
end