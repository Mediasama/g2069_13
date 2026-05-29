---@class WinSubscribeAbilityWndLayout : CEGUILayout
local WinSubscribeAbilityWndLayout = M
---@type widget_virtual_horz_list
local widget_virtual_horz_list = require "ui.widget.widget_virtual_horz_list"

---@private
function WinSubscribeAbilityWndLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinSubscribeAbilityWndLayout:findAllWindow()
	---@type CEGUIDefaultWindow
	self.wWinBody = self.WinBody
	---@type CEGUIStaticImage
	self.siWinBodyBg = self.WinBody.Bg
	---@type CEGUIStaticText
	self.stWinBodyTitle = self.WinBody.Title
	---@type CEGUIScrollableView
	self.wWinBodySvItem = self.WinBody.SvItem
	---@type CEGUIHorizontalLayoutContainer
	self.wWinBodySvItemHorizontalLayoutContainer = self.WinBody.SvItem.HorizontalLayoutContainer
	---@type CEGUIButton
	self.btnWinBodyConfirmButton = self.WinBody.ConfirmButton
	---@type CEGUIButton
	self.btnWinBodyCloseButton = self.WinBody.CloseButton
end

---@private
function WinSubscribeAbilityWndLayout:initUI()
	self.stWinBodyTitle:setText(Lang:toText("subscribe_game_ability_gift_title"))
	self.btnWinBodyConfirmButton:setText(Lang:toText("g2069_ok_button"))

	local this = self
	self.abilityView = widget_virtual_horz_list:init(self.wWinBodySvItem, self.wWinBodySvItemHorizontalLayoutContainer,
			function(self, parentWindow)
				local item = UI:openWidget("UI/game_role_common/gui/widget_subscribe_ability_item")
				parentWindow:addChild(item:getWindow())
				return item
			end,
			function(self, childWindow, data)
				local callFunc = function(item_alias)
					this:updateCurSelectAbility(item_alias)
				end
				childWindow:initData(data, callFunc)
			end
	)
end

---@private
function WinSubscribeAbilityWndLayout:initEvent()
	self.btnWinBodyConfirmButton.onMouseClick = function()
		--- 发送协议
		if self.curSelect then
			Me:sendPacket({
				pid = "C2SGetSubscribeVipAbility",
				alias = self.curSelect,
			})
		end

		UI:closeWindow("UI/game_role_common/gui/win_subscribe_ability_wnd")
	end
	self.btnWinBodyCloseButton.onMouseClick = function()
		Me:showConfirm(
			nil,
			Lang:toText("subscribe_game_ability_gift_give_up"),
			function()
				UI:closeWindow("UI/game_role_common/gui/win_subscribe_ability_wnd")
			end
		)
	end
end

---@private
function WinSubscribeAbilityWndLayout:onOpen()
	self.abilityView:clearVirtualChild()

	local subscribe_vipSetting = World.cfg.subscribe_vipSetting
	self.abilityView:addVirtualChildList(subscribe_vipSetting.heightVipRewardList or {})
	self:updateCurSelectAbility("")
end

function WinSubscribeAbilityWndLayout:updateCurSelectAbility(item_alias)
	self.curSelect = item_alias or ""
	Lib.emitEvent(Event.EVENT_GAME_UPDATE_SUBSCRIBE_SELECT_ABILITY, self.curSelect)
	self.btnWinBodyConfirmButton:setVisible(self.curSelect ~= "")
end

---@private
function WinSubscribeAbilityWndLayout:onDestroy()

end

---@private
function WinSubscribeAbilityWndLayout:onClose()
	self.abilityView:clearVirtualChild()
end

WinSubscribeAbilityWndLayout:init()
