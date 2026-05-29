---@class WinActionSkillLayout : CEGUILayout
local WinActionSkillLayout = M

---@type SkillConfig
local SkillConfig = T(Config, "SkillConfig")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type GameSkillHelper
local GameSkillHelper = T(Lib, "GameSkillHelper")
---@type GameSkillCastHelper
local GameSkillCastHelper = T(Lib,"GameSkillCastHelper")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")
---@type SprintSkillHelper
local SprintSkillHelper = T(Lib, "SprintSkillHelper")

local socket = require("socket")

local ACTIVE_SKILL_NUM=4
local SPRINT_SKILL_POS=ACTIVE_SKILL_NUM+1
local FLY_SKILL_POS=ACTIVE_SKILL_NUM+2
local ADD_FLY_SKILL_POS=ACTIVE_SKILL_NUM+3
local NORMAL_SKILL_POS=ACTIVE_SKILL_NUM+4

local NORMAL_SKILL_IMG={
	[Define.DAMAGE_TYPE.PHYSICS]=
		{
			"img_0_physicall_attack_normal",
			"img_0_physicall_attack_on"
		},
	[Define.DAMAGE_TYPE.ELEMENT]=
	{
		"img_0_element_attack_normal",
		"img_0_element_attack_on"
	},
}

---@private
function WinActionSkillLayout:init()
	self._allEvent={}
	self.skillsInfo = {}
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinActionSkillLayout:findAllWindow()
	---@type CEGUIButton
	self.btnJumpBtn = self.JumpBtn
	---@type CEGUIButton
	self.SprintBtn = self.SprintBtn
	---@type CEGUIButton
	self.NormalSkillBtn = self.NormalSkillBtn
	---@type CEGUIButton
	self.btnFlyBtn = self.FlyBtn
	---@type CEGUIButton
	self.btnAddFlyBtn = self.AddFlyBtn
	---@type CEGUIButton
	self.btnJumpBtnNewPos = self.JumpBtnNewPos
	---@type CEGUIButton
	self.btnSprintBtnNewPos = self.SprintBtnNewPos

end

---@private
function WinActionSkillLayout:initUI()
	self.skillCDProgress={}
	self.skillCDTimer={}
	self.touchBtnState={}
	self.skillsInfo = {}
	self.skillsInfo.activeSkills={}  ---主动技能
	self.skillsInfo.sprintSkill={}	 ---冲刺技能
	self.skillsInfo.normalSkill={}	 ---普攻技能
	self.skillsInfo.flySkill={}	     ---代替跳跃的飞行技能
	self.skillsInfo.addFlySkill={}	 ---额外的飞行技能
	for pos = 1, ACTIVE_SKILL_NUM do
		self.touchBtnState[pos]=false
		self.skillsInfo.activeSkills[pos] = {}
		self.skillsInfo.activeSkills[pos].button = self:child("SkillBtn"..pos)
		self.skillsInfo.activeSkills[pos].icon = self.skillsInfo.activeSkills[pos].button:child("SkillIcon")
		self.skillsInfo.activeSkills[pos].cdIcon = self.skillsInfo.activeSkills[pos].button:child("CdIcon")
		self.skillsInfo.activeSkills[pos].cdIcon:setVisible(false)
		self.skillsInfo.activeSkills[pos].cdTime = self.skillsInfo.activeSkills[pos].cdIcon:child("CDTime")
		self.skillsInfo.activeSkills[pos].maskIcon = self.skillsInfo.activeSkills[pos].button:child("MaskIcon")
		self.skillsInfo.activeSkills[pos].maskIcon:setVisible(false)
		self.skillsInfo.activeSkills[pos].limitText = self.skillsInfo.activeSkills[pos].maskIcon:child("LimitText")
		self.skillsInfo.activeSkills[pos].effect = self.skillsInfo.activeSkills[pos].button:child("OpenEffect")
		self.skillsInfo.activeSkills[pos].effect:setVisible(false)
		self.skillsInfo.activeSkills[pos].skillId = 0
		self.skillsInfo.activeSkills[pos].cd = false
		self.skillsInfo.activeSkills[pos].noMPMask = self.skillsInfo.activeSkills[pos].button:child("NoMPMask")
	end

	self.skillsInfo.normalSkill.button = self.NormalSkillBtn
	self.skillsInfo.normalSkill.skillId = 0
	self.skillsInfo.normalSkill.icon = self.skillsInfo.normalSkill.button:child("SkillIcon")

	self.skillsInfo.sprintSkill.button = self.SprintBtn
	self.skillsInfo.sprintSkill.skillId = 0
	self.skillsInfo.sprintSkill.startTime = 0
	self.skillsInfo.sprintSkill.skillTime = 0
	self.skillsInfo.sprintSkill.noNumMask= self.skillsInfo.sprintSkill.button:child("ImageNoNumMask")
	self.skillsInfo.sprintSkill.textSprintNum= self.skillsInfo.sprintSkill.button:child("TextSprintNum")
	self.skillsInfo.sprintSkill.cdIcon= self.skillsInfo.sprintSkill.button:child("CdIcon")

	self.skillsInfo.flySkill.button = self.btnFlyBtn
	self.skillsInfo.flySkill.skillId = 0
	self.skillsInfo.flySkill.icon = self.skillsInfo.flySkill.button:child("SkillIcon")
	self.skillsInfo.flySkill.cdIcon = self.skillsInfo.flySkill.button:child("CdIcon")
	self.skillsInfo.flySkill.cdIcon:setVisible(false)
	self.skillsInfo.flySkill.cdTime = self.skillsInfo.flySkill.cdIcon:child("CDTime")
	self.skillsInfo.flySkill.effect = self.skillsInfo.flySkill.button:child("OpenEffect")
	self.skillsInfo.flySkill.effect:setVisible(false)
	self.skillsInfo.flySkill.cd = false

	self.skillsInfo.addFlySkill.button = self.btnAddFlyBtn
	self.skillsInfo.addFlySkill.skillId = 0
	self.skillsInfo.addFlySkill.icon = self.skillsInfo.addFlySkill.button:child("SkillIcon")
	self.skillsInfo.addFlySkill.cdIcon = self.skillsInfo.addFlySkill.button:child("CdIcon")
	self.skillsInfo.addFlySkill.cdIcon:setVisible(false)
	self.skillsInfo.addFlySkill.cdTime = self.skillsInfo.addFlySkill.cdIcon:child("CDTime")
	self.skillsInfo.addFlySkill.effect = self.skillsInfo.addFlySkill.button:child("OpenEffect")
	self.skillsInfo.addFlySkill.effect:setVisible(false)
	self.skillsInfo.addFlySkill.cd = false
	self:initButtonSize()
	self.initPosJumpBtn = self.btnJumpBtn:getPosition()
	self.initPosSprintBtn = self.SprintBtn:getPosition()
	self.initPosJumpBtnNew = self.btnJumpBtnNewPos:getPosition()
	self.initPosSprintBtnNew = self.btnSprintBtnNewPos:getPosition()
	self.detectMPTimer=World.Timer(20*1,function ()
		self:detectMP()
		return true
	end)
end

function WinActionSkillLayout:handleSceneTouch(x,y,skill,pos,isTouchBegin)
	if isTouchBegin then
		local nodeX = CEGUICoordConverter.screenToWindowX1(skill.button:getWindow(), x)
		local nodeY= CEGUICoordConverter.screenToWindowY1(skill.button:getWindow(), y)
		if not skill.cd and skill.button:isVisible() and nodeX >=0 and nodeY>=0 and nodeX<=skill.button:getWidth()[2] and nodeY<=skill.button:getHeight()[2] then
			--print("++++++++++++++++++++++++++++++++++++++ btn down:",pos,nodeX,nodeY)
			self.touchBtnState[pos]=true
			Me.touchSkillBtn=true
			self:skillTouchDown(skill,pos)
		end
	else
		if self.touchBtnState[pos] then
			--print("++++++++++++++++++++++++++++++++++++++ btn up:",pos)
			self.touchBtnState[pos]=false
			Me.touchSkillBtn=false
			self:skillTouchUp(skill,pos)
			self:skillTouchClick(skill)
		end
	end
end

function WinActionSkillLayout:clearSceneTouch()
	self.touchBtnState={}
end

---@private
function WinActionSkillLayout:initEvent()
	Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y)
		for pos = 1, ACTIVE_SKILL_NUM do
			self:handleSceneTouch(x,y,self.skillsInfo.activeSkills[pos],pos,true)
		end
		self:handleSceneTouch(x,y,self.skillsInfo.flySkill,FLY_SKILL_POS,true)
		self:handleSceneTouch(x,y,self.skillsInfo.addFlySkill,ADD_FLY_SKILL_POS,true)
		self:handleSceneTouch(x,y,self.skillsInfo.normalSkill,NORMAL_SKILL_POS,true)
	end)

	Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y)
		for pos = 1, ACTIVE_SKILL_NUM do
			self:handleSceneTouch(x,y,self.skillsInfo.activeSkills[pos],pos,false)
		end
		self:handleSceneTouch(x,y,self.skillsInfo.flySkill,FLY_SKILL_POS,false)
		self:handleSceneTouch(x,y,self.skillsInfo.addFlySkill,ADD_FLY_SKILL_POS,false)
		self:handleSceneTouch(x,y,self.skillsInfo.normalSkill,NORMAL_SKILL_POS,false)
	end)

	self.skillsInfo.normalSkill.button.onMouseClick = function()
		self:skillTouchClick(self.skillsInfo.normalSkill)
	end

	self.skillsInfo.normalSkill.button.onMouseButtonDown = function()
		self:skillTouchDown(self.skillsInfo.normalSkill)
	end

	self.skillsInfo.normalSkill.button.onMouseButtonUp = function()
		self:skillTouchUp(self.skillsInfo.normalSkill)
	end

	self.btnJumpBtn.onMouseButtonDown = function()
		--Blockman.Instance():control():jump()
		if not self:canControlPlayer() then
			return
		end
		Blockman.Instance():setKeyPressing("key.jump", true)
	end

	self.btnJumpBtn.onMouseButtonUp = function()
		--if not self:canControlPlayer() then
		--	return
		--end
		Blockman.Instance():setKeyPressing("key.jump", false)
	end

	self.btnJumpBtn.onMouseLeavesArea = function()
		--if not self:canControlPlayer() then
		--	return
		--end
		Blockman.Instance():setKeyPressing("key.jump", false)
	end


	self.SprintBtn.onMouseButtonDown = function()
		if not self:canControlPlayer() then
			return
		end
		self:doFreeSprintSkill(false,true)
		self:startSprintLongTouch()
	end

	self.SprintBtn.onMouseButtonUp = function()
		--if not self:canControlPlayer() then
		--	return
		--end
		self:stopSprintLongTouch()
	end

	self.SprintBtn.onMouseLeavesArea = function()
		--if not self:canControlPlayer() then
		--	return
		--end
		self:stopSprintLongTouch()
	end

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_SYNC_ROLE_DATA, function()
		self:updateSkillSlotFromAbility()
		self:clearSceneTouch()
		self:setNormalSkillImg(self.skillsInfo.normalSkill,false)
	end)
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY, function(success)
		self:updateSkillSlotFromAbility()
		self:clearSceneTouch()
		if success then
			self:cleanPreAbilitySkillState()
			self:setNormalSkillImg(self.skillsInfo.normalSkill,false)
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_AWAKE, function(success, player, ability)
		if not success then
			return
		end
		self:updateSkillSlotFromAbility()
		self:clearSceneTouch()
		self:cleanPreAbilitySkillState()
		self:setNormalSkillImg(self.skillsInfo.normalSkill,false)
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_ABILITY_LEVEL, function(player, ability, addLevel)
		self:updateSkillSlotFromAbility(self.resetSlotList,true)
	end)
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EventButtonCDTimer, function(skillId,exCD)
		local config = SkillConfig:getSkillConfig(skillId)
		if config then
			local skill
			for _, v in pairs(self.skillsInfo.activeSkills) do
				if v.skillId==skillId then
					skill=v
					break
				end
			end
			if self.skillsInfo.normalSkill.skillId==skillId then
				skill=self.skillsInfo.normalSkill
			end
			if self.skillsInfo.flySkill.skillId==skillId then
				skill=self.skillsInfo.flySkill
			end
			if self.skillsInfo.addFlySkill.skillId==skillId then
				skill=self.skillsInfo.addFlySkill
			end
			if skill then
				local cd=Me:getRealSkillCd(config.skillCd)+(exCD and exCD or 0)
				self:buttonCDTimer(skill,cd)
			end
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SWITCH_SKILL_UPDATE, function(skillId, isOpen,exCD)
		local config = SkillConfig:getSkillConfig(skillId)
		if config then
			local skill
			for i, v in pairs(self.skillsInfo.activeSkills) do
				if v.skillId==skillId then
					skill=v
					break
				end
			end
			if self.skillsInfo.normalSkill.skillId==skillId then
				skill=self.skillsInfo.normalSkill
			end
			if self.skillsInfo.flySkill.skillId==skillId then
				skill=self.skillsInfo.flySkill
			end
			if self.skillsInfo.addFlySkill.skillId==skillId then
				skill=self.skillsInfo.addFlySkill
			end
			if skill then
				if isOpen then
					if skill.effect then
						skill.effect:setVisible(true)
						skill.effect:playEffect()
					end
					skill.cdIcon:setVisible(false)
				else
					if skill.effect then
						skill.effect:setVisible(false)
					end
					local cd=  Me:getRealSkillCd(config.skillCd)+(exCD and exCD or 0)
					self:buttonCDTimer(skill,cd)
				end
			end
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function()
		self:stopSprintLongTouch()
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLIENT_PLAYER_DEAD, function()
		self:cleanPreAbilitySkillState()
		self:stopSprintLongTouch()
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_RESET_SKILL, function(slotList,skillList)
		self:recordResetSlot(slotList)
		if skillList and slotList then
			for i = 1, #skillList do
			    local cfg = SkillConfig:getSkillConfig(skillList[i])
			    if cfg then
					if slotList[i]<=ACTIVE_SKILL_NUM then
						self:_updateSkillButton(self.skillsInfo.activeSkills[slotList[i]], cfg, true, true)
					elseif slotList[i]==NORMAL_SKILL_POS then
						self:_updateSkillButton(self.skillsInfo.normalSkill, cfg, true, true)
					end
			    end
			end
		end
	end)
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_RESUME_SKILL, function()
		---@type AbilitySkill
		local abilitySkill = AbilitySystem:getAbilitySkill(Me)
		for pos = 1, ACTIVE_SKILL_NUM do
			local askill = abilitySkill.skills[pos]
			if askill then
				local skill = SkillConfig:getSkillConfig(askill.skillId)
				self:_updateSkillButton(self.skillsInfo.activeSkills[pos], skill, true, askill.unlock, askill.level)
			else
				self:_updateSkillButton(self.skillsInfo.activeSkills[pos], nil, true)
			end
		end
		self:_updateSkillButton(self.skillsInfo.normalSkill,  SkillConfig:getSkillConfig(abilitySkill.attack), true)
	end)
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SPRINT_NUM_CHANGE, function(sprintNum)
		local imageMask=self.skillsInfo.sprintSkill.noNumMask
		if imageMask then
			imageMask:setVisible(sprintNum<=0)
		end

		local textSprintNum=self.skillsInfo.sprintSkill.textSprintNum
		if textSprintNum then
			textSprintNum:setText(sprintNum)
		end
	end)
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SPRINT_NUM_RECOVER, function(progress)
		local cdIcon=self.skillsInfo.sprintSkill.cdIcon
		if cdIcon then
			local rate = math.clamp(progress , 0, 1)
			cdIcon:setProperty("FillArea", tostring(rate))
			cdIcon:setVisible(rate>0 and rate<1)
		end
	end)

end

function WinActionSkillLayout:updateSkillSlotFromAbility(exclude,doNotResetCD)
	---@type AbilitySkill
	local abilitySkill=AbilitySystem:getAbilitySkill(Me)
	--print(">>>>>>>>>>>>>>>>>>>> updateSkillSlotFromAbility",Lib.v2s(abilitySkill))
	for pos = 1, ACTIVE_SKILL_NUM do
		if not (exclude and exclude[pos]) then
			local askill = abilitySkill.skills[pos]
			if askill then
				local skill = SkillConfig:getSkillConfig(askill.skillId)
				self:_updateSkillButton(self.skillsInfo.activeSkills[pos],skill, doNotResetCD, askill.unlock, askill.level)
			else
				self:_updateSkillButton(self.skillsInfo.activeSkills[pos], nil, doNotResetCD)
			end
		end
	end

	if not (exclude and exclude[NORMAL_SKILL_POS]) then
		local normalSkill=SkillConfig:getSkillConfig(abilitySkill.attack)
		self:_updateSkillButton(self.skillsInfo.normalSkill,normalSkill, doNotResetCD, true)
	end

	local sprintSkill=SkillConfig:getSkillConfig(abilitySkill.sprint)
	self:_updateSkillButton(self.skillsInfo.sprintSkill,sprintSkill, doNotResetCD, true)
	local flySkill=SkillConfig:getSkillConfig(abilitySkill.fly)
	self:_updateSkillButton(self.skillsInfo.flySkill,flySkill, doNotResetCD, true)
	local addFlySkill=SkillConfig:getSkillConfig(abilitySkill.addFly)
	self:_updateSkillButton(self.skillsInfo.addFlySkill,addFlySkill, doNotResetCD, true)
	self:adjustSkillBtnLayout(flySkill~=nil,addFlySkill~=nil)
end

function WinActionSkillLayout:_updateSkillButton(skillInf, skill, doNotResetCD, unlock, level)
	--print(">>>>>>>>>>>>>>>>> _updateSkillButton ",skill.skillId,currentAbility,doNotResetCD)
	if not skillInf then
		return
	end
	if skill then
		skillInf.skillId =skill.skillId
		if skillInf.icon  then
			if skill.image and #skill.image>0 then
				skillInf.icon:setImage(skill.image)
			end
			skillInf.icon:setVisible(true)
		end
		if skillInf.cdIcon and not doNotResetCD then
			skillInf.cdIcon:setVisible(false)
		end
		if skillInf.button then
			skillInf.button:setVisible(true)
		end
		if skillInf.maskIcon then
			if unlock then
				skillInf.maskIcon:setVisible(false)
			else
				skillInf.maskIcon:setVisible(true)
				skillInf.limitText:setText("LV." .. (level or -1))
			end
		end
	else
		skillInf.skillId = 0
		if skillInf.button then
			skillInf.button:setVisible(false)
		end
	end
end

function WinActionSkillLayout:updateSprintSkillInfo()
	local skillId = Me:getSprintSkillId()
	local skillTime = GameSkillHelper:getSkillTotalTime(skillId, Me)/1000
	self.sprintSkillInfo = {
		skillTime = skillTime,
		startTime = 0,
		skillId = skillId,
		button = self.SprintBtn
	}
end

function WinActionSkillLayout:startSprintLongTouch()
	self.sprintTimer = World.LightTimer("WinActionSkillLayout:startSprintLongTouch", 1, function()
		self:doFreeSprintSkill(true,true)
		return true
	end)
end

function WinActionSkillLayout:stopSprintLongTouch()
	if self.sprintTimer then
		self.sprintTimer()
		self.sprintTimer = nil
	end
end

function WinActionSkillLayout:doFreeSprintSkill(donNotPlaySound,isSprintSkill)
	if socket.gettime() - self.skillsInfo.sprintSkill.startTime >= self.skillsInfo.sprintSkill.skillTime then
		if SprintSkillHelper:canSprint() then
			self:doFreeGameSkill(self.skillsInfo.sprintSkill,donNotPlaySound,isSprintSkill)
		end
	end
end

function WinActionSkillLayout:doFreeGameSkill(skill,donNotPlaySound,isSprintSkill)
	if Me.lockGameSkill then
		return
	end
	local canFree, skillCd = Me:checkCanFreeSkill(skill.skillId,{donNotPlaySound=donNotPlaySound,isSprintSkill=isSprintSkill})
	if canFree then
		if skill.skillId == self.skillsInfo.sprintSkill.skillId then
			self.skillsInfo.sprintSkill.startTime = socket.gettime()
		end
		local config = SkillConfig:getSkillConfig(skill.skillId)
		if config.skillMode~=Define.GameSkillCastType.Charge then
			Me:clientFreeGameSkill(skill.skillId)
			Me:requestCostMp(skill.skillId)
			--self:buttonCDTimer(skill,skillCd)
			if isSprintSkill then
				GameSkillCastHelper:clearStrategy(Define.GameSkillCastType.Combo)
			end
		end
	end
	return canFree
end

function WinActionSkillLayout:buttonCDTimer(skill,skillCd)
	if not skill or not skill.cdIcon then
		return
	end
	if skillCd >= 100 then
		local totalTime = math.ceil(skillCd/1000)
		local times = math.floor(skillCd / 20)
		local progress = 0
		skill.cdIcon:setProperty("FillArea", "1")
		skill.cdIcon:setVisible(true)
		skill.cd=true
		skill.cdTime:setText(totalTime)
		self.skillCDTimer[skill.skillId]=LuaTimer:scheduleTimerWithEnd(function()
			progress = progress + 1
			local rate = math.clamp(1 - progress / times, 0, 1)
			self:setSkillCDProgress(skill.skillId,rate)
			skill.cdTime:setText(math.ceil(rate*totalTime))
			skill.cdIcon:setProperty("FillArea", tostring(rate))
		end, function()
			skill.cdIcon:setVisible(false)
			skill.cd=false
			self:setSkillCDProgress(skill.skillId,0)
		end, 20, times)
	end
end

function WinActionSkillLayout:clearSkillCDTimer()
	for _, v in pairs(self.skillCDTimer) do
		LuaTimer:cancel(v)
	end
end

function WinActionSkillLayout:clearSkillCDProgress()
	self.skillCDProgress={}
end

function WinActionSkillLayout:setSkillCDProgress(skillId,value)
	self.skillCDProgress[skillId]=value
end

---记录技能cd进度
function WinActionSkillLayout:getSkillCDProgress(skillId)
	return self.skillCDProgress[skillId] or 0
end

function WinActionSkillLayout:skillTouchDown(skill,pos)
	GameSkillCastHelper:onTouchDown(skill.skillId)
	self:setButtonUITouch(skill,pos,true)
end

function WinActionSkillLayout:skillTouchUp(skill,pos)
	GameSkillCastHelper:onTouchUp(skill.skillId)
	self:setButtonUITouch(skill,pos,false)
end

function WinActionSkillLayout:skillTouchClick(skill)
	GameSkillCastHelper:onTouchClick(skill.skillId)
end

function WinActionSkillLayout:resetSkillCD(skill)
	if skill.skillId > 0 then
		if skill.maskIcon and skill.maskIcon:isVisible() then
			return
		end
		local config = SkillConfig:getSkillConfig(skill.skillId)
		local realSkillCd = Me:getRealSkillCd(config.skillCd)
		self:buttonCDTimer(skill, realSkillCd)
	end
end

function WinActionSkillLayout:cleanPreAbilitySkillState()
	self:clearSkillCDTimer()
	self:clearSkillCDProgress()
	for pos = 1, ACTIVE_SKILL_NUM do
		self:resetSkillCD(self.skillsInfo.activeSkills[pos])
	end
	self:resetSkillCD(self.skillsInfo.flySkill)
	self:resetSkillCD(self.skillsInfo.addFlySkill)
	self:cleanStateSkillEffect()
	GameSkillCastHelper:cleanAllSkillState()
end

function WinActionSkillLayout:cleanStateSkillEffect()
	if self.skillsInfo.flySkill.effect then
		self.skillsInfo.flySkill.effect:setVisible(false)
	end
	if self.skillsInfo.addFlySkill.effect then
		self.skillsInfo.addFlySkill.effect:setVisible(false)
	end
	for pos = 1, ACTIVE_SKILL_NUM do
		if self.skillsInfo.activeSkills[pos].effect then
			self.skillsInfo.activeSkills[pos].effect:setVisible(false)
		end
	end
end

function WinActionSkillLayout:canControlPlayer()
	return Me:checkCanControlPlayer()
end

function WinActionSkillLayout:switchFlyJumpBtn(showFlyBtn)
	self.btnFlyBtn:setVisible(showFlyBtn)
	self.btnJumpBtn:setVisible(not showFlyBtn)
end

function WinActionSkillLayout:adjustSkillBtnLayout(showFlyBtn,addFlySkill)
	--print("---------------adjustSkillBtnLayout",showFlyBtn,addFlySkill)
	self:switchFlyJumpBtn(showFlyBtn)
	self.btnAddFlyBtn:setVisible(addFlySkill)
	if addFlySkill then
		self.btnJumpBtn:setPosition(self.initPosJumpBtnNew)
		self.btnFlyBtn:setPosition(self.initPosJumpBtnNew)
		self.SprintBtn:setPosition(self.initPosSprintBtnNew)
	else
		self.btnJumpBtn:setPosition(self.initPosJumpBtn)
		self.btnFlyBtn:setPosition(self.initPosJumpBtn)
		self.SprintBtn:setPosition(self.initPosSprintBtn)
	end
end

function WinActionSkillLayout:recordResetSlot(slotList)
	self.resetSlotList={}
	if slotList then
		for _, v in pairs(slotList) do
			self.resetSlotList[v]=true
		end
	end
end

function WinActionSkillLayout:initButtonSize()
	self.buttonInitSize={}
	self.buttonEffectInitSize={}
	for pos, v in pairs(self.skillsInfo.activeSkills) do
		local size = v.button:getSize()
		self.buttonInitSize[pos]={size[1][2],size[2][2]}
		local effectSize = v.effect:getSize()
		self.buttonEffectInitSize[pos]={effectSize[1][2],effectSize[2][2]}
	end
end

function WinActionSkillLayout:setButtonUITouch(skill,pos,touchDown)
	if skill and skill.button then
		if self.buttonInitSize[pos] then
			local size=self.buttonInitSize[pos]
			local effectSize = self.buttonEffectInitSize[pos]
			local scale=touchDown and 1.2 or 1
			skill.button:setWidth({ 0, size[1]*scale })
			skill.button:setHeight({ 0, size[2]*scale })
			if skill.effect then
				skill.effect:setWidth({ 0, effectSize[1]*scale })
				skill.effect:setHeight({ 0, effectSize[2]*scale })
			end
		else
			---持续飞行技能
			if pos == FLY_SKILL_POS or pos == ADD_FLY_SKILL_POS then
				local cfg=SkillConfig:getSkillConfig(skill.skillId)
				if cfg and cfg.skillMode ==Define.GameSkillCastType.Continuous  then
					local img=touchDown and "img_0_fly_on" or "img_0_fly_normal"
					skill.icon:setImage("set:main.json image:"..img)
				end
			elseif pos == NORMAL_SKILL_POS then
				self:setNormalSkillImg(skill,touchDown)
			end
		end
	end
end

function WinActionSkillLayout:setNormalSkillImg(skill,touchDown)
	local currentAbility = AbilitySystem:getAbility(Me)
	local damageType=currentAbility and currentAbility:getDamageType() or Define.DAMAGE_TYPE.PHYSICS
	local img=touchDown and NORMAL_SKILL_IMG[damageType][2] or NORMAL_SKILL_IMG[damageType][1]
	--print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> setNormalSkillImg ",damageType,touchDown)
	skill.icon:setImage("set:main.json image:"..img)
end

function WinActionSkillLayout:detectMP()
	for pos = 1, ACTIVE_SKILL_NUM do
		local mask=self.skillsInfo.activeSkills[pos].noMPMask
		if mask then
			local cfg=SkillConfig:getSkillConfig(self.skillsInfo.activeSkills[pos].skillId)
			if cfg then
				local lockMask=self.skillsInfo.activeSkills[pos].maskIcon
				if lockMask then
					mask:setVisible(Me:getCurMp()<cfg.mpCost and not lockMask:isVisible() )
				else
					mask:setVisible(Me:getCurMp()<cfg.mpCost)
				end
			end
		end
	end
end

---@private
function WinActionSkillLayout:onOpen()

end

---@private
function WinActionSkillLayout:onDestroy()

end

---@private
function WinActionSkillLayout:onClose()
	if self._allEvent then
		for _, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
	self:stopSprintLongTouch()
	if self.detectMPTimer then
		self.detectMPTimer()
		self.detectMPTimer=nil
	end
end

WinActionSkillLayout:init()
