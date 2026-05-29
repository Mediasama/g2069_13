---@class WinAwakeConfirmLayout : CEGUILayout
local WinAwakeConfirmLayout = M

---@type AbilityAwakeConfig
local AbilityAwakeConfig = T(Config, "AbilityAwakeConfig")
---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type WalletSystem
local WalletSystem = T(Lib, "WalletSystem")
---@type InventorySystem
local InventorySystem = T(Lib, "InventorySystem")

---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"

---@private
function WinAwakeConfirmLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinAwakeConfirmLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMask = self.Mask
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticText
	self.stBgTitle = self.Bg.Title
	---@type CEGUIStaticImage
	self.siBgBg = self.Bg.Bg
	---@type CEGUIButton
	self.btnBgConfirm = self.Bg.Confirm
	---@type CEGUIButton
	self.btnBgCancel = self.Bg.Cancel
	---@type CEGUIButton
	self.btnBgClose = self.Bg.Close
	---@type CEGUIScrollableView
	self.wBgSvItem = self.Bg.SvItem
	---@type CEGUIHorizontalLayoutContainer
	self.wBgSvItemLvItem = self.Bg.SvItem.LvItem
end

---@private
function WinAwakeConfirmLayout:initUI()
	self.stBgTitle:setText(Lang:toText(""))
	self.btnBgConfirm:setText(Lang:toText("g2069_ok_button"))
	self.btnBgCancel:setText(Lang:toText("g2069_cancel_button"))
end

---@private
function WinAwakeConfirmLayout:initEvent()
	self.btnBgConfirm.onMouseClick = function()
		if not self.ability then
			return
		end
		if self.confirmCallback then
			self.confirmCallback()
		end
		Me:sendPacket({
			pid = "C2SAbilityAwake",
			id = self.ability:getId()
		})
		UI:closeWindow(self)
	end
	self.btnBgCancel.onMouseClick = function()
		if not self.ability then
			return
		end
		if self.cancelCallback then
			self.cancelCallback()
		end
		UI:closeWindow(self)
	end
	self.btnBgClose.onMouseClick = function()
		if not self.ability then
			return
		end
		if self.closeCallback then
			self.closeCallback()
		end
		UI:closeWindow(self)
	end
end

---@private
function WinAwakeConfirmLayout:onOpen(args)
	self:initData(args)
	self:initVirtualUI()
	self:updateInfo()
end

function WinAwakeConfirmLayout:initData(args)
	---@type Ability
	self.ability = args.ability
	self.confirmCallback = args.confirmCallback or nil
	self.cancelCallback = args.cancelCallback or nil
	self.closeCallback = args.closeCallback or nil
end

function WinAwakeConfirmLayout:initVirtualUI()
	---@type widget_virtual_horz_list
	self.lvItem = widget_virtual_horz_list:init(
		self.wBgSvItem,
		self.wBgSvItemLvItem,
		function(self, parent)
			---@type WidgetAbilityAwakeCostWidget
			local node = UI:openWidget("UI/game_role_common/gui/widget_ability_awake_cost")
			parent:addChild(node:getWindow())
			return node
		end, function(self, node, data)
			node:updateInfo(data)
		end
	)
end

--- 刷新信息
function WinAwakeConfirmLayout:updateInfo()
	---- 能力信息
	local ability = self.ability
	local config = AbilityAwakeConfig:getCfgByAbilityId(ability:getItemId())
	local coin_nums = config.coin_nums
	local item_nums = config.item_nums
	local awake = ability:getAwake() + 1

	local itemList = Lib.copy(config.item_costs[awake])
	if item_nums[awake] and item_nums[awake] > 0 then
		table.insert(itemList, 1, {
			item_alias = self.ability:getItemAlias(),
			item_num = item_nums[awake]
		})
	end
	if coin_nums[awake] and coin_nums[awake] > 0 then
		table.insert(itemList, 1, {
			item_alias = Define.ITEM_ALIAS.GOLD_COIN,
			item_num = coin_nums[awake]
		})
	end

	local enough = true

	for _, item in pairs(itemList) do
		local curNum = nil
		if item.item_alias == Define.ITEM_ALIAS.GOLD_COIN then
			curNum = WalletSystem:getCoin(Me, Define.ITEM_ALIAS.GOLD_COIN)
		else
			local itemType = ItemConfig:getCfgByItemAlias(item.item_alias).type_alias
			local inventoryType = Define.ITEM_INVENTORY_TYPE[itemType]
			curNum = InventorySystem:getItemAmountByItemAlias(Me, inventoryType, item.item_alias)
		end
		item.current_num = curNum
		item.enough = curNum >= item.item_num
		if not item.enough then
			enough = false
		end
		self.lvItem:addVirtualChild(item)
	end

	--- 按钮处理
	self.btnBgConfirm:setEnabled(enough)
end

---@private
function WinAwakeConfirmLayout:onDestroy()

end

---@private
function WinAwakeConfirmLayout:onClose()

end

WinAwakeConfirmLayout:init()
