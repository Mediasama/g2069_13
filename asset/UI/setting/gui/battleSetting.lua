

function M:initSafeUI()
  local gameOptions = M.gameOptions
  gameOptions.optionsTab.Image = "setting/bg_BiaoTi"
  gameOptions.optionsTab.setting:setText(Lang:toText("g2069_game_setting_title1"))
  gameOptions.safety.desc:setText(Lang:toText("g2069_game_setting_safe"))

  M.gameOptions.safety.safeBtn.onMouseClick = function()
    local safeModeType = Me:getSafeModeType()
    if safeModeType == Define.PKModeType.safe then
      Me:setSafeModeType(Define.PKModeType.pkWait)
    elseif safeModeType == Define.PKModeType.pk1 or safeModeType == Define.PKModeType.pk2 then
      Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "g2069_pk_state_click_tips")
    end
  end
end

function M:initShakeUI()
  local gameOptions = M.gameOptions
  gameOptions.shake.shakeDesc:setText(Lang:toText("g2069_game_setting_shake"))

  M.gameOptions.shake.shakeBtn.onMouseClick = function()
    local skillOpenShake = Me:getSkillOpenShake()
    Me:setSkillOpenShake(not skillOpenShake)
  end
end

function M:init()
  M:initSafeUI()
  M:initShakeUI()
  M:updateView()

  M._allEvent = {}

  M._allEvent[#M._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SAFE_MODE_UPDATE, function(value)
    M:updateSaveModeView()
  end)

  M._allEvent[#M._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SKILL_OPEN_SHAKE_UPDATE, function(value)
    M:updateShakeModeView()
  end)
end

function M:onOpen(instance, settingConfigManager)
  M:init()
end

function M:onDestroy()
  if M._allEvent then
    for _, fun in pairs(M._allEvent) do
      fun()
    end
    M._allEvent = {}
  end
end

function M:onClose()
  if M._allEvent then
    for _, fun in pairs(M._allEvent) do
      fun()
    end
    M._allEvent = {}
  end
end

function M:updateSaveModeView()
  local safeModeType = Me:getSafeModeType()
  if safeModeType == Define.PKModeType.safe
      or safeModeType == Define.PKModeType.pkWait then
    M.gameOptions.safety.safeBtn:setNormalImage("setting/KaiGuan_Guan")
    M.gameOptions.safety.safeBtn:setPushedImage("setting/KaiGuan_Guan")
  else
    M.gameOptions.safety.safeBtn:setNormalImage("setting/KaiGuan_Kai")
    M.gameOptions.safety.safeBtn:setPushedImage("setting/KaiGuan_Kai")
  end
end

function M:updateShakeModeView()
  local skillOpenShake = Me:getSkillOpenShake()
  if skillOpenShake then
    M.gameOptions.shake.shakeBtn:setNormalImage("setting/KaiGuan_Kai")
    M.gameOptions.shake.shakeBtn:setPushedImage("setting/KaiGuan_Kai")
  else
    M.gameOptions.shake.shakeBtn:setNormalImage("setting/KaiGuan_Guan")
    M.gameOptions.shake.shakeBtn:setPushedImage("setting/KaiGuan_Guan")
  end
end

function M:updateData()

end

function M:onShown()
  M:updateView(true)
end

function M:updateView(updateData)
  if updateData then
    M:updateData()
    return 
  end
  M:updateSaveModeView()
  M:updateShakeModeView()
end