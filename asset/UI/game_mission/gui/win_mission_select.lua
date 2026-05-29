---@class WinMissionSelectLayout : CEGUILayout
local WinMissionSelectLayout = M

---@type widget_virtual_grid
local widget_virtual_grid = require "ui.widget.widget_virtual_grid"
---@type MissionInfoConfig
local MissionInfoConfig = T(Config, "MissionInfoConfig")
---@type GrowthSystem
local GrowthSystem = T(Lib, "GrowthSystem")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

--- 定义事件
local CALL_EVENT = {
	SELECT_ITEM = "select_item",
	IS_SELECTED_ITEM = "selected_item",
}

---@private
function WinMissionSelectLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinMissionSelectLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIDefaultWindow
	self.wWindowPanel = self.WindowPanel
	---@type CEGUIStaticImage
	self.siWindowPanelBg = self.WindowPanel.Bg
	---@type CEGUIStaticText
	self.stWindowPanelTitle = self.WindowPanel.Title
	---@type CEGUIStaticImage
	self.siWindowPanelImage = self.WindowPanel.Image
	---@type CEGUIScrollableView
	self.wWindowPanelSvItem = self.WindowPanel.SvItem
	---@type CEGUIGridView
	self.gvWindowPanelSvItemGvItem = self.WindowPanel.SvItem.GvItem
	---@type CEGUIStaticImage
	self.siWindowPanelNoItemBg = self.WindowPanel.NoItemBg
	---@type CEGUIStaticText
	self.stWindowPanelNoItemBgTitle = self.WindowPanel.NoItemBg.Title
	---@type CEGUIButton
	self.btnWindowPanelCloseButton = self.WindowPanel.CloseButton
	---@type CEGUIStaticText
	self.stWindowPanelRemainText = self.WindowPanel.RemainText
	---@type CEGUIButton
	self.btnWindowPanelNextBtn = self.WindowPanel.NextBtn
end

---@private
function WinMissionSelectLayout:initUI()
	self.stWindowPanelTitle:setText(Lang:toText("g2069_select_mission_main_title"))
	self.btnWindowPanelNextBtn:setText(Lang:toText("g2069_select_mission_next_tips"))
	self.stWindowPanelNoItemBgTitle:setText(Lang:toText("g2069_mission_no_can_select_tips"))

	self:initVirtualUI()
end

function WinMissionSelectLayout:initVirtualUI()
	local this = self
	self.gvItem = widget_virtual_grid:init(
			self.wWindowPanelSvItem,
			self.gvWindowPanelSvItemGvItem,
			function(self, parent)
				---@type WidgetMissionSelectItemWidget
				local node = UI:openWidget("UI/game_mission/gui/widget_mission_select_item")
				parent:addChild(node:getWindow())
				node:registerCallHandler(CALL_EVENT.SELECT_ITEM, this, this.onCallHandler)
				node:registerCallHandler(CALL_EVENT.IS_SELECTED_ITEM, this, this.onCallHandler)
				return node
			end,
			---@type any, WidgetMissionSelectItemWidget, table
			function(self, node, data)
				node:initData(data)
			end, 4
	)
end

---@private
function WinMissionSelectLayout:initEvent()
	self.btnWindowPanelCloseButton.onMouseClick = function()
		UI:closeWindow("UI/game_mission/gui/win_mission_select")
	end

	self.btnWindowPanelNextBtn.onMouseClick = function()
		UI:openWindow("UI/game_mission/gui/win_mission_dialog", nil, nil, self.curNpcId, self.curMissionId)
		UI:closeWindow("UI/game_mission/gui/win_mission_select")
	end
end

--- 回调
---@param event any
function WinMissionSelectLayout:onCallHandler(event, ...)
	if event == CALL_EVENT.SELECT_ITEM then
		local missionId = table.unpack({...})
		self:updateCurSelectMission(missionId)
	elseif event == CALL_EVENT.IS_SELECTED_ITEM then
		local missionId = table.unpack({...})
		return self.curMissionId == missionId
	end
end

function WinMissionSelectLayout:updateCurSelectMission(missionId)
	self.curMissionId = missionId
	Lib.emitEvent(Event.EVENT_GAME_MISSION_SELECT_MISSION, self.curMissionId)
end

function WinMissionSelectLayout:initView(npcId, missionGroup)
	self.curNpcId = npcId
	self.missionGroup = missionGroup
	self.curMissionId = nil
	local curLevel = GrowthSystem:getLevel(Me)
	self.missionList = MissionInfoConfig:getCfgsByGroupAndLevel(missionGroup, curLevel)

	local missionCountInfo = Me:getMissionCountInfo()
	local remainCounts = missionCountInfo[missionGroup] or 0
	self.stWindowPanelRemainText:setText(Lang:toText({"g2069_select_teammate_remain_tips", remainCounts}))

	self.gvItem:clearVirtualChild()

	local canShowList = {}
	for _, missionCfg in pairs(self.missionList or {}) do
		local haveItem = true
		for _, val in pairs(missionCfg.costs or {}) do
			local config = ItemConfig:getCfgByItemAlias(val.item_alias)
			local inventoryType = Define.ITEM_INVENTORY_TYPE[config.type_alias]
			local amount = InventorySystem:getItemAmountByItemAlias(Me, inventoryType, val.item_alias)
			if amount < val.item_num then
				haveItem = false
			end
		end
		if haveItem then
			table.insert(canShowList, missionCfg)
		end
	end

	if #canShowList > 0 then
		self.siWindowPanelNoItemBg:setVisible(false)
		self.gvItem:addVirtualChildList(canShowList)
		self:updateCurSelectMission(canShowList[1].mission_id)
		if remainCounts <= 0 then
			self.btnWindowPanelNextBtn:setVisible(false)
		else
			self.btnWindowPanelNextBtn:setVisible(true)
		end
	else
		self.siWindowPanelNoItemBg:setVisible(true)
		self.btnWindowPanelNextBtn:setVisible(false)
	end
end

---@private
function WinMissionSelectLayout:onOpen(npcId, missionGroup)
	self:initView(npcId, missionGroup)
end

---@private
function WinMissionSelectLayout:onDestroy()

end

---@private
function WinMissionSelectLayout:onClose()
	self.gvItem:clearVirtualChild()
end

WinMissionSelectLayout:init()
