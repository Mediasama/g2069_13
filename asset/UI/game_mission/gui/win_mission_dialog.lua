---@class WinMissionDialogLayout : CEGUILayout
local WinMissionDialogLayout = M

---@type NpcConfig
local NpcConfig = T(Config, "NpcConfig")
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@private
function WinMissionDialogLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinMissionDialogLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIDefaultWindow
	self.wRootPanel = self.RootPanel
	---@type CEGUIDefaultWindow
	self.wRootPanelRightPanel = self.RootPanel.RightPanel
	---@type CEGUIButton
	self.btnRootPanelRightPanelReplyBtn1 = self.RootPanel.RightPanel.replyBtn1
	---@type CEGUIButton
	self.btnRootPanelRightPanelReplyBtn2 = self.RootPanel.RightPanel.replyBtn2
	---@type CEGUIButton
	self.btnRootPanelRightPanelReplyBtn3 = self.RootPanel.RightPanel.replyBtn3
	---@type CEGUIButton
	self.btnRootPanelRightPanelReplyBtn4 = self.RootPanel.RightPanel.replyBtn4
	---@type CEGUIDefaultWindow
	self.wRootPanelLeftPanel = self.RootPanel.LeftPanel
	---@type CEGUIStaticImage
	self.siRootPanelLeftPanelLeftBg = self.RootPanel.LeftPanel.leftBg
	---@type CEGUIStaticImage
	self.siRootPanelLeftPanelTitleBg = self.RootPanel.LeftPanel.TitleBg
	---@type CEGUIStaticText
	self.stRootPanelLeftPanelTitleText = self.RootPanel.LeftPanel.TitleText
	---@type CEGUIStaticText
	self.stRootPanelLeftPanelContentText = self.RootPanel.LeftPanel.ContentText
end

---@private
function WinMissionDialogLayout:initUI()
	self.btnRootPanelRightPanelReplyBtn1:setText(Lang:toText("g2069_dialog_reply_1001"))
	self.btnRootPanelRightPanelReplyBtn2:setText(Lang:toText("g2069_select_mission_re_select"))
	self.btnRootPanelRightPanelReplyBtn3:setText(Lang:toText("g2069_select_mission_signal_open"))
	self.btnRootPanelRightPanelReplyBtn4:setText(Lang:toText("g2069_select_mission_multi_open"))
end

---@private
function WinMissionDialogLayout:initEvent()
	self._allEvent = {}
	self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_NPC_DIALOG_CLOSE, function(npcId)
		if self.curNpcId == npcId then
			UI:closeWindow("UI/game_mission/gui/win_mission_dialog")
		end
	end)

	self.btnRootPanelRightPanelReplyBtn1.onMouseClick = function()
		UI:closeWindow("UI/game_mission/gui/win_mission_dialog")
	end

	-- 重选
	self.btnRootPanelRightPanelReplyBtn2.onMouseClick = function()
		UI:openWindow("UI/game_mission/gui/win_mission_select", nil, nil, self.curNpcId, self.missionGroup)
		UI:closeWindow("UI/game_mission/gui/win_mission_dialog")
	end

	-- 开启副本
	self.btnRootPanelRightPanelReplyBtn3.onMouseClick = function()
		if not self:checkIsCanOpenMission() then
			return
		end
		Me:requestOpenMissionTeleport(Define.MISSION_PLAY_MODE.SINGLE, self.curMissionId)
		UI:closeWindow("UI/game_mission/gui/win_mission_dialog")
	end

	-- 多人开启
	self.btnRootPanelRightPanelReplyBtn4.onMouseClick = function()
		if not self:checkIsCanOpenMission() then
			return
		end
		UI:openWindow("UI/game_mission/gui/win_teammate_select", nil, nil, self.curMissionId)
		UI:closeWindow("UI/game_mission/gui/win_mission_dialog")
	end
end

function WinMissionDialogLayout:checkIsCanOpenMission()
	local missionCountInfo = Me:getMissionCountInfo()
	local remainCounts = missionCountInfo[self.missionGroup] or 0
	if remainCounts <= 0 then
		Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "g2069_select_mission_no_counts")
		return false
	end


	for _, val in pairs(self.missionCfg.costs or {}) do
		local config = ItemConfig:getCfgByItemAlias(val.item_alias)
		local inventoryType = Define.ITEM_INVENTORY_TYPE[config.type_alias]
		local amount = InventorySystem:getItemAmountByItemAlias(Me, inventoryType, val.item_alias)
		if amount < val.item_num then
			Plugins.CallTargetPluginFunc("fly_new_tips", "pushFlyNewTipsText", "g2069_select_mission_no_item")
			return false
		end
	end

	return true
end

local NormalColor = "[colour='FF000000']"
local function parseItemText(itemList)
	local result = NormalColor .. ""
	for key, val in pairs(itemList or {}) do
		if key > 1 then
			result = result .. NormalColor .. ","
		end
		local itemCfg = ItemConfig:getCfgByItemAlias(val.item_alias)
		local name = itemCfg.name
		local text = Lang:toText(name)
		if Define.ITEM_QUALITY_FONT_COLOR[itemCfg.quality_alias] then
			local color = string.format("[colour='%s']", Define.ITEM_QUALITY_FONT_COLOR[itemCfg.quality_alias])
			text = color .. Lang:toText(name)
		end
		result = result .. text .. "x" .. val.item_num .. NormalColor
	end
	return result
end

function WinMissionDialogLayout:initView(npcId, missionId)
	self.curNpcId = npcId
	self.curMissionId = missionId

	local npcConfig = NpcConfig:getCfgById(npcId)
	self.stRootPanelLeftPanelTitleText:setText(Lang:toText(npcConfig.npcShowName))

	self.missionCfg = MissionInfoConfig:getCfgByMissionId(missionId)
	self.missionGroup = self.missionCfg.mission_group

	local costText = parseItemText(self.missionCfg.costs)
	local rewardText = parseItemText(self.missionCfg.rewards)
	local showText = NormalColor .. Lang:toText({"g2069_select_mission_reward_tips" ,costText, rewardText})
	self.stRootPanelLeftPanelContentText:setText(showText)
end

---@private
function WinMissionDialogLayout:onOpen(npcId, missionId)
	self:initView(npcId, missionId)
end

---@private
function WinMissionDialogLayout:onDestroy()

end

---@private
function WinMissionDialogLayout:onClose()
	if self._allEvent then
		for k, fun in pairs(self._allEvent) do
			fun()
		end
		self._allEvent = {}
	end
end

WinMissionDialogLayout:init()
