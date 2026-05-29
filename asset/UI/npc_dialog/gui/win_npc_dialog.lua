---@class WinNpcDialogLayout : CEGUILayout
local WinNpcDialogLayout = M
---@type widget_virtual_vert_list
local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

---@type NpcSystemHelper
local NpcSystemHelper = T(Lib, "NpcSystemHelper")
---@type NpcConfig
local NpcConfig = T(Config, "NpcConfig")
---@type NpcDialogueReplyConfig
local NpcDialogueReplyConfig = T(Config, "NpcDialogueReplyConfig")
---@type NpcDialogueConfig
local NpcDialogueConfig = T(Config, "NpcDialogueConfig")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type ShopConfig
local ShopConfig = T(Config, "ShopConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type TaskConfig
local TaskConfig = T(Config, "TaskConfig")
---@type NpcRewardSettingConfig
local NpcRewardSettingConfig = T(Config, "NpcRewardSettingConfig")
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")

local LeftShowPosX = -168
---@private
function WinNpcDialogLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinNpcDialogLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIDefaultWindow
	self.wRootPanel = self.RootPanel
	---@type CEGUIDefaultWindow
	self.wLeftPanel = self.RootPanel.LeftPanel
	---@type CEGUIStaticImage
	self.siLeftPanelLeftBg = self.RootPanel.LeftPanel.leftBg
	---@type CEGUIStaticText
	self.stLeftPanelTitleText = self.RootPanel.LeftPanel.TitleText
	---@type CEGUIStaticText
	self.stLeftPanelContentText = self.RootPanel.LeftPanel.ContentText
	---@type CEGUIStaticImage
	self.siLeftPanelNextIcon = self.RootPanel.LeftPanel.NextIcon
	---@type CEGUIDefaultWindow
	self.wRightPanel = self.RootPanel.RightPanel
	---@type CEGUIScrollableView
	self.wRightPanelScrollableView = self.RootPanel.RightPanel.ScrollableView
	---@type CEGUIVerticalLayoutContainer
	self.wRightPanelScrollableViewVerticalContainer = self.RootPanel.RightPanel.ScrollableView.VerticalContainer
end

---@private
function WinNpcDialogLayout:initUI()
	self._allEvent = {}

	self.replyView = widget_virtual_vert_list:init(self.wRightPanelScrollableView, self.wRightPanelScrollableViewVerticalContainer,
			function(self, parentWindow)
				local item = UI:openWidget("UI/npc_dialog/gui/widget_dialog_reply")
				parentWindow:addChild(item:getWindow())
				item:setWidth({ 1, 0 })
				return item
			end,
			function(self, childWindow, data)
				childWindow:initData(data)
			end
	)
end

---@private
function WinNpcDialogLayout:initEvent()
	self.onMouseClick = function()
		if self.isMidPosDialog then
			if self.leftMoveActionEnd and self.contentActionEnd then
				self:updateDialogContent(self.curDialogIndex + 1)
			elseif not self.contentActionEnd then
				self:doContentActionEndShow()
			end
		else
			if not self.contentActionEnd then
				self:doContentActionEndShow()
			end
		end
	end

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_NPC_DIALOG_CLOSE, function(npcId, source)
		if npcId and source then
			if self.curNpcId == npcId and self.source == source then
				UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
			end
		else
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GAME_BUSINESS_SHOP_BUY, function(player, shopId, success)
		if self.buyShopReply and self.buyShopReply.shopId == shopId then
			if success then
				if self.buyShopReply.replySuccess > 0 then
					NpcSystemHelper:jumpToNpcDialog(self.curNpcId, self.buyShopReply.replySuccess)
				else
					UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
				end
			else
				if self.buyShopReply.replyFail > 0 then
					NpcSystemHelper:jumpToNpcDialog(self.curNpcId, self.buyShopReply.replyFail)
				else
					UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
				end
			end
		end
	end)

	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_NPC_DIALOG_REPLY, function(replyId, replyType)
		local replyConfig = NpcDialogueReplyConfig:getCfgById(replyId)
		if not replyConfig then
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
			return
		end
		self.wLeftPanel:setVisible(false)
		self.wRightPanel:setVisible(false)
		if replyType == Define.Dialog_REPLY_TYPE.CLOSE then
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		elseif replyType == Define.Dialog_REPLY_TYPE.BUY_ITEMS then
			if not Me:clientBuyShopByShopId(replyConfig.shopId) then
				self.buyShopReply = nil
				if replyConfig.replyFail > 0 then
					NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replyFail)
				else
					UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
				end
			else
				self.buyShopReply = replyConfig
				self.wRootPanel:setVisible(false)
			end
		elseif replyType == Define.Dialog_REPLY_TYPE.CONTINUE then
			self:updateDialogContent(self.curDialogIndex + 1)
		elseif replyType == Define.Dialog_REPLY_TYPE.TRANSFER then
			local function teleportSuccess(isSuccess)
				if isSuccess then
					if replyConfig.replySuccess > 0 then
						NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replySuccess)
					end
				else
					if replyConfig.replyFail > 0 then
						NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replyFail)
					end
				end
			end
			self.scene_teleports = self.scene_teleports + 1
			if Me:teleportToMapPosition(replyConfig.deliverMap, replyConfig.deliverCoordinate, teleportSuccess) then
				UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
			else
				if replyConfig.replyFail > 0 then
					NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replyFail)
				else
					UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
				end
			end
		elseif replyType == Define.Dialog_REPLY_TYPE.TASK then
			self.task_distributions = self.task_distributions + 1
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
			Me:sendPacket({pid = "RequestReceiveNpcTask", replyId = replyId}, function (result)
				if result then
					if replyConfig.replySuccess > 0 then
						NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replySuccess)
					end
				else
					if replyConfig.replyFail > 0 then
						NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.replyFail)
					end
				end
			end)
		elseif replyType == Define.Dialog_REPLY_TYPE.REWARD then
			Me:sendPacket({
				pid = "ReceiveDialogReward",
				replyId = replyId,
			})
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		elseif replyType == Define.Dialog_REPLY_TYPE.BACK then
			if self.dialogList[self.curDialogIndex - 1] then
				self:updateDialogContent(self.curDialogIndex - 1)
			else
				UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
			end
		elseif replyType == Define.Dialog_REPLY_TYPE.JUMP_DIALOG then
			if replyConfig.jumpDialogId > 0 then
				NpcSystemHelper:jumpToNpcDialog(self.curNpcId, replyConfig.jumpDialogId)
			end
		elseif replyType == Define.Dialog_REPLY_TYPE.LUCKY_DRAW then
			if self.remainTime > 0 then
				return
			end
			Me:doNPCLuckyDrawBuyPool(self.curDialogConfig.luckyDrawId)
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		elseif replyType == Define.Dialog_REPLY_TYPE.OPEN_MISSION then
			UI:openWindow("UI/game_mission/gui/win_mission_select", nil, nil, self.curNpcId, self.curDialogConfig.missionGroup)
			UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
		end
	end)
end

function WinNpcDialogLayout:initView(npcId, dialogId, source)
	self.wRootPanel:setVisible(true)
	self.source = source or dialogId
	self.buyShopReply = nil
	self.curNpcId = npcId
	self.curDialogIndex = 0
	self.curShowContent = "......"
	self.curDialogConfig = {}
	self.isMidPosDialog = true
	self.wLeftPanel:setXPosition({0, 0})
	self.itemDataList = {}

	local npcConfig = NpcConfig:getCfgById(npcId)
	self.stLeftPanelTitleText:setText(Lang:toText(npcConfig.npcShowName))

	if dialogId then
		self.dialogList = { dialogId }
	else
		self.dialogList = NpcSystemHelper:getCanShowDialogList(npcId)
	end
	self:updateDialogView(1)
end

function WinNpcDialogLayout:updateDialogContent(showIndex)
	if self.dialogList[showIndex] then
		self:updateDialogView(showIndex)
	else
		UI:closeWindow("UI/npc_dialog/gui/win_npc_dialog")
	end
end

function WinNpcDialogLayout:updateShowContentText()
	self.curShowContent = "......"
	if not self.curDialogConfig then
		return
	end
	if self.curDialogConfig.showShopId and self.curDialogConfig.showShopId > 0 then
		local shopCfg = ShopConfig:getCfgByShopId(self.curDialogConfig.showShopId)
		if shopCfg then
			local goodsName = Lang:toText(shopCfg.shop_name)
			local goodsDesc = Lang:toText(shopCfg.shop_desc)
			local costCfg = ItemConfig:getCfgByItemAlias(shopCfg.cost.item_alias)
			local costName = Lang:toText(costCfg.name)
			local costNum = shopCfg.cost.item_num

			local showName = Lang:toText({"g2069_dialog_shop_name_tips", goodsName})
			local showDesc = Lang:toText({"g2069_dialog_shop_desc_tips", goodsDesc})
			local showCost = Lang:toText({"g2069_dialog_shop_cost_tips", costName, costNum})
			self.curShowContent = showName .. "\n" .. showDesc .. "\n" .. showCost
			self.product_displays = self.product_displays + 1
		end
	elseif self.curDialogConfig.showTaskId and self.curDialogConfig.showTaskId > 0 then
		local taskCfg = TaskConfig:getCfgById(self.curDialogConfig.showTaskId)
		if taskCfg then
			local taskName = Lang:toText(taskCfg.taskName)
			local taskCondition = Me:getTaskOpenConditionText(self.curDialogConfig.showTaskId)
			local taskReward = Me:getRewardListText(taskCfg.rewards)

			local showName = Lang:toText({"g2069_dialog_task_name_tips", taskName})
			local showDesc = Lang:toText({"g2069_dialog_task_desc_tips", taskCondition})
			local showAward = Lang:toText({"g2069_dialog_task_reward_tips", taskReward})
			self.curShowContent = showName .. "\n" .. showDesc .. "\n" .. showAward
		end
	elseif self.curDialogConfig.luckyDrawId and self.curDialogConfig.luckyDrawId > 0 then
		local dialogDrawTime = Me:getDialogDrawTime()
		local curLevel = GrowthSystem:getLevel(Me)
		local rewardCfg
		if dialogDrawTime[self.curDialogConfig.luckyDrawId] then
			rewardCfg = NpcRewardSettingConfig:getCfgByGroupAndLv(self.curDialogConfig.luckyDrawId, curLevel)
		else -- 首次抽奖
			local firstDraw = NpcRewardSettingConfig:getCfgByGroupAFirst(self.curDialogConfig.luckyDrawId, curLevel)
			if firstDraw then
				rewardCfg = firstDraw
			else
				rewardCfg = NpcRewardSettingConfig:getCfgByGroupAndLv(self.curDialogConfig.luckyDrawId, curLevel)
			end
		end
		if rewardCfg then
			local lastDrawTime = dialogDrawTime[self.curDialogConfig.luckyDrawId] or 0
			local passTime = os.time() - lastDrawTime
			self.remainTime = rewardCfg.coolTime - passTime
			if self.remainTime > 0 then
				self.curDialogConfig.replyList = nil
				self.lottery_cd_displays = 1
			else
				local costNum = rewardCfg.kValue*curLevel + rewardCfg.bValue
				if Me:isCanUseFreeLuckyDraw() then
					costNum = 0
				end
				local coinName = Lang:toText(ItemConfig:getName(rewardCfg.item_alias))
				local showName = Lang:toText({self.curDialogConfig.dialogueText, curLevel,costNum, coinName, costNum, coinName})
				self.curShowContent = showName
				self.lottery_displays = 1
			end
		else
			self.curDialogConfig.replyList = nil
		end
	elseif self.curDialogConfig.missionGroup and self.curDialogConfig.missionGroup > 0 then
		local curLevel = GrowthSystem:getLevel(Me)
		local missionList = MissionInfoConfig:getCfgsByGroupAndLevel(self.curDialogConfig.missionGroup, curLevel)
		if missionList and (#missionList >0) then
			local difficultyText = missionList[1].difficulty_text
			local showName = Lang:toText({self.curDialogConfig.dialogueText, curLevel, difficultyText})
			self.curShowContent = showName
		else
			self.curDialogConfig.replyList = nil
		end
	else
		local content = {self.curDialogConfig.dialogueText}
		for _, val in ipairs(self.curDialogConfig.dialogueInput) do
			if val[1] == "LEVEL" then
				local curLevel = GrowthSystem:getLevel(Me)
				table.insert(content, curLevel)
			elseif val[1] == "TEXT" then
				table.insert(content, Lang:toText(val[2] or ""))
			end
		end
		self.curShowContent = Lang:toText(content)
	end
end

function WinNpcDialogLayout:updateDialogView(index)
	self.curDialogIndex = index
	self.remainTime = 0
	if self.dialogList[index] then
		self.curDialogConfig = Lib.copyTable1(NpcDialogueConfig:getCfgById(self.dialogList[index]))
		self:updateShowContentText()
	else
		self.curDialogConfig = {}
		self.curShowContent = "......"
	end
	self.leftMoveActionEnd = false
	self.contentActionEnd = false
	self.siLeftPanelNextIcon:setVisible(false)
	self.replyView:clearVirtualChild()

	self:checkLeftDoMoveAction()
	self:startDoContentAction()

	self.conversations = self.conversations + 1

	if not self.dialogRecordList[self.curNpcId] then
		self.dialogRecordList[self.curNpcId] = {}
	end
	local curDialogId = self.dialogList[index]
	if curDialogId then
		self.dialogRecordList[self.curNpcId][curDialogId] = true
	end
end

function WinNpcDialogLayout:startDoContentAction()
	if self.contentTimer then
		self.contentTimer()
		self.contentTimer = nil
	end
	if self.remainDownTimer then
		self.remainDownTimer()
		self.remainDownTimer = nil
	end
	self.wLeftPanel:setVisible(true)

	if self.remainTime > 0 then
		self:doContentDownTimeShow()
	else
		if self.curDialogConfig.luckyDrawId and self.curDialogConfig.luckyDrawId > 0 then
			self:doContentActionEndShow()
			return
		end
		local endIndex = Lib.subStringGetTotalIndex(self.curShowContent)
		local curIndex = 0
		local time = World.cfg.npc_systemSetting.dialogUpdateTime
		self.contentTimer = World.Timer(time, function()
			curIndex = curIndex + World.cfg.npc_systemSetting.dialogUpdateLen
			local content = Lib.subStringUTF8(self.curShowContent, 1, curIndex)
			self.stLeftPanelContentText:setText(content)
			if curIndex >= endIndex then
				self:doContentActionEndShow()
				return false
			end
			return true
		end)
	end
end

function WinNpcDialogLayout:doContentDownTimeShow()
	self:doContentActionEndShow()
	if self.remainDownTimer then
		self.remainDownTimer()
		self.remainDownTimer = nil
	end
	local text = string.format("%02d:%02d:%02d",Lib.timeFormatting(self.remainTime))
	self.curShowContent = Lang:toText({"g2069_dialog_reward_time", text})
	self.stLeftPanelContentText:setText(self.curShowContent)

	self.remainDownTimer = World.Timer(20, function()
		self.remainTime = self.remainTime - 1
		local text = string.format("%02d:%02d:%02d",Lib.timeFormatting(self.remainTime))
		self.curShowContent = Lang:toText({"g2069_dialog_reward_time", text})
		self.stLeftPanelContentText:setText(self.curShowContent)
		if self.remainTime <= 0 then
			NpcSystemHelper:jumpToNpcDialog(self.curNpcId, nil, self.source)
			return false
		end
		return true
	end)
end

function WinNpcDialogLayout:doContentActionEndShow()
	if self.contentTimer then
		self.contentTimer()
		self.contentTimer = nil
	end

	if self.isMidPosDialog then
		self.siLeftPanelNextIcon:setVisible(true)
	else
		self.siLeftPanelNextIcon:setVisible(false)
	end

	self.stLeftPanelContentText:setText(self.curShowContent)

	self.contentActionEnd = true
	self:doMoveActionEndShow()
end

function WinNpcDialogLayout:checkLeftDoMoveAction()
	self.wRightPanel:setVisible(false)

	local isNeedMove = false
	if self.curDialogConfig.replyList then
		if self.isMidPosDialog then
			isNeedMove = true
		end
		self.isMidPosDialog = false
	else
		if not self.isMidPosDialog then
			isNeedMove = true
		end
		self.isMidPosDialog = true
	end

	if isNeedMove then
		local targetPosX, initPosX
		if self.isMidPosDialog then
			initPosX = LeftShowPosX
			targetPosX = 0
		else
			initPosX = 0
			targetPosX = LeftShowPosX
		end
		self.wLeftPanel:setXPosition({0, initPosX})
		local oneTimeMove = (targetPosX - initPosX)/World.cfg.npc_systemSetting.dialogMoveTime
		local passTime = 0
		self.leftMoveTimer = World.Timer(1, function()
			passTime = passTime + 1
			local curPosX = initPosX + oneTimeMove*passTime
			self.wLeftPanel:setXPosition({0, curPosX})
			if passTime >= World.cfg.npc_systemSetting.dialogMoveTime then
				self.leftMoveActionEnd = true
				self.leftMoveTimer()
				self.leftMoveTimer = nil
				self.wLeftPanel:setXPosition({0, targetPosX})
				self:doMoveActionEndShow()
				return false
			else
				return true
			end
		end)
	else
		self.leftMoveActionEnd = true
		self:doMoveActionEndShow()
	end
end

function WinNpcDialogLayout:doMoveActionEndShow()
	if not (self.leftMoveActionEnd and self.contentActionEnd) then
		return
	end
	if self.leftMoveTimer then
		self.leftMoveTimer()
		self.leftMoveTimer = nil
	end

	if self.curDialogConfig.replyList then
		self.wRightPanel:setVisible(true)
		self.replyView:addVirtualChildList(self.curDialogConfig.replyList or {})
		self.wLeftPanel:setXPosition({0, LeftShowPosX})
	else
		self.wRightPanel:setVisible(false)
		self.wLeftPanel:setXPosition({0, 0})
	end
end

---@private
function WinNpcDialogLayout:onOpen(npcId, dialogId, source)
	self.conversations = 0
	self.product_displays = 0
	self.scene_teleports = 0
	self.task_distributions = 0
	self.lottery_displays = 0
	self.lottery_cd_displays = 0
	self.dialogRecordList = {}

	self:initView(npcId, dialogId, source)
end

---@private
function WinNpcDialogLayout:onDestroy()
end

---@private
function WinNpcDialogLayout:onClose()
	local defaultData = {
		npc_id_alias = self.curNpcId or "",
		conversations = self.conversations,
		product_displays = self.product_displays,
		scene_teleports = self.scene_teleports,
		task_distributions = self.task_distributions,
		lottery_displays = self.lottery_displays,
		lottery_cd_displays = self.lottery_cd_displays
	}
	Plugins.CallTargetPluginFunc("report", "report", "g2069_npc_access", defaultData, Me)

	self.replyView:clearVirtualChild()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
	if self.leftMoveTimer then
		self.leftMoveTimer()
		self.leftMoveTimer = nil
	end
	if self.contentTimer then
		self.contentTimer()
		self.contentTimer = nil
	end
	if self.remainDownTimer then
		self.remainDownTimer()
		self.remainDownTimer = nil
	end
	NpcSystemHelper:updateNpcDialogRecord(self.dialogRecordList)
end

WinNpcDialogLayout:init()
