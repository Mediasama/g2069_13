---@class WinG2060FriendLayout : CEGUILayout
local WinG2060FriendLayout = M

local FriendTagMainType = Define.FriendTagMainType
local FriendTagSubType = Define.FriendTagSubType
local requestDataTimeInterval = Define.requestDataTimeInterval
local FriendSpecialData = T(Lib, "FriendSpecialData")
local FriendUtils = T(Lib, "FriendUtils")

local widget_virtual_vert_list = require "ui.widget.widget_virtual_vert_list"

---@private
function WinG2060FriendLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
	self.mainAniWnd = self.siBg
end

---@private
function WinG2060FriendLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMask = self.Mask
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIDefaultWindow
	self.wBgFriendSubTag = self.Bg.FriendSubTag
	---@type CEGUIDefaultWindow
	self.wBgFriendSubTagFriends = self.Bg.FriendSubTag.Friends
	---@type CEGUIStaticImage
	self.siBgFriendSubTagFriendsSelectOff = self.Bg.FriendSubTag.Friends.SelectOff
	---@type CEGUIStaticImage
	self.siBgFriendSubTagFriendsSelectOn = self.Bg.FriendSubTag.Friends.SelectOn
	---@type CEGUIStaticText
	self.stBgFriendSubTagFriendsTagName = self.Bg.FriendSubTag.Friends.TagName
	---@type CEGUIDefaultWindow
	self.wBgFriendSubTagInvite = self.Bg.FriendSubTag.Invite
	---@type CEGUIStaticImage
	self.siBgFriendSubTagInviteSelectOff = self.Bg.FriendSubTag.Invite.SelectOff
	---@type CEGUIStaticImage
	self.siBgFriendSubTagInviteSelectOn = self.Bg.FriendSubTag.Invite.SelectOn
	---@type CEGUIStaticText
	self.stBgFriendSubTagInviteTagName = self.Bg.FriendSubTag.Invite.TagName
	---@type CEGUIDefaultWindow
	self.wBgNearbySubTag = self.Bg.NearbySubTag
	---@type CEGUIDefaultWindow
	self.wBgNearbySubTagNearby = self.Bg.NearbySubTag.Nearby
	---@type CEGUIStaticText
	self.stBgNearbySubTagNearbyHorizontalLayoutTagName = self.Bg.NearbySubTag.Nearby.TagName
	---@type CEGUIStaticImage
	self.siBgScrollableViewBg = self.Bg.ScrollableViewBg
	---@type CEGUIScrollableView
	self.wBgScrollableView = self.Bg.ScrollableView
	---@type CEGUIVerticalLayoutContainer
	self.wBgScrollableViewVerticalLayout = self.Bg.ScrollableView.VerticalLayout
	---@type CEGUIDefaultWindow
	self.wBgMainTagRoot = self.Bg.MainTagRoot
	---@type CEGUIStaticImage
	self.siBgMainTagRootFriendMainTagOff = self.Bg.MainTagRoot.FriendMainTagOff
	---@type CEGUIStaticImage
	self.siBgMainTagRootFriendMainTagOn = self.Bg.MainTagRoot.FriendMainTagOn
	---@type CEGUIStaticText
	self.stBgMainTagRootFriendTextOff = self.Bg.MainTagRoot.FriendTextOff
	---@type CEGUIStaticText
	self.stBgMainTagRootFriendTextOn = self.Bg.MainTagRoot.FriendTextOn
	---@type CEGUIStaticImage
	self.siBgMainTagRootNearbyMainTagOff = self.Bg.MainTagRoot.NearbyMainTagOff
	---@type CEGUIStaticImage
	self.siBgMainTagRootNearbyMainTagOn = self.Bg.MainTagRoot.NearbyMainTagOn
	---@type CEGUIStaticText
	self.stBgMainTagRootNearbyTextOff = self.Bg.MainTagRoot.NearbyTextOff
	---@type CEGUIStaticText
	self.stBgMainTagRootNearbyTextOn = self.Bg.MainTagRoot.NearbyTextOn
	---@type CEGUIButton
	self.btnBgBackBtn = self.Bg.BackBtn
end

---@private
function WinG2060FriendLayout:initUI()

	self.defaultSelectSubTag = {
		[FriendTagMainType.Friend] = FriendTagSubType.Friends,
		[FriendTagMainType.Nearby] = FriendTagSubType.PeopleNearby
	}

	self.subTagUI = {
		[FriendTagSubType.Friends] = {
			root = self.wBgFriendSubTagFriends,
			on = self.siBgFriendSubTagFriendsSelectOn,
			off = self.siBgFriendSubTagFriendsSelectOff,
			tagNameText = self.stBgFriendSubTagFriendsTagName
		},
		[FriendTagSubType.Invite] = {
			root = self.wBgFriendSubTagInvite,
			on = self.siBgFriendSubTagInviteSelectOn,
			off = self.siBgFriendSubTagInviteSelectOff,
			tagNameText = self.stBgFriendSubTagInviteTagName
		},
		[FriendTagSubType.PeopleNearby] = {
			root = self.wBgNearbySubTagNearby,
			tagNameText = self.stBgNearbySubTagNearbyHorizontalLayoutTagName
		}
	}

	self.mainTagSelectUI = {
		[FriendTagMainType.Friend] = {
			on = self.siBgMainTagRootFriendMainTagOn,
			off = self.siBgMainTagRootFriendMainTagOff,
			subTagRoot = self.wBgFriendSubTag,
			textOn = self.stBgMainTagRootFriendTextOn,
			textOff = self.stBgMainTagRootFriendTextOff,
		},
		[FriendTagMainType.Nearby] = {
			on = self.siBgMainTagRootNearbyMainTagOn,
			off = self.siBgMainTagRootNearbyMainTagOff,
			subTagRoot = self.wBgNearbySubTag,
			textOn = self.stBgMainTagRootNearbyTextOn,
			textOff = self.stBgMainTagRootNearbyTextOff,
		}
	}

	self.vertView = widget_virtual_vert_list:init(self.wBgScrollableView, self.wBgScrollableViewVerticalLayout,
			function(self, parentWindow)
				local item = UI:openWidget("UI/friend/gui/widget_friend_item")
				parentWindow:addChild(item:getWindow())
				return item
			end,
			function(self, childWindow, msg)
				if childWindow.initData then
					childWindow:initData(msg)
				end
			end
	)

	self.wBgScrollableView.onWindowTouchDown = function(instance, window, x, y)
		local scrollPos = self.vertView:getVirtualBarPosition()
		if scrollPos < 0.1 then
			self.canRequestFriend = -1
		elseif scrollPos >= 0.9 then
			self.canRequestFriend = 1
		else
			self.canRequestFriend = 0
		end
		self.scrollViewBeginDragPosY = y
	end

	self.wBgScrollableView.onWindowTouchUp = function(instance, window, x, y)
		if self.canRequestFriend == 0 then
			return
		end
		local distance = y - self.scrollViewBeginDragPosY  --distance < 0 向上滑动
		if math.abs(distance) > 10 then
			if self.selectTagSubType == FriendTagSubType.Friends then
				if self.friendData and self.friendData.pageNo then
					if not self:canRequestNextPageData() then
						return
					end
					local scrollPos = self.vertView:getVirtualBarPosition()
					if distance > 0 then
						--向上滑动 请求上一页
						if self.friendData.pageNo > 0 and self.canRequestFriend == -1 then
							self:requestFriendData(self.friendData.pageNo - 1, false)
						end
					elseif distance < 0 then
						--向下滑动 请求下一页
						if self.friendData.pageNo < self.friendData.totalPage - 1 and self.canRequestFriend == 1 then
							self:requestFriendData(self.friendData.pageNo + 1, true)
						end
					end
				end
			end
		end
	end

	self.stBgFriendSubTagInviteTagName:setText(Lang:toText("g2060_friend_invite_title"))
	self.stBgFriendSubTagFriendsTagName:setText(Lang:toText("g2060_friend_title"))
	self.stBgNearbySubTagNearbyHorizontalLayoutTagName:setText(Lang:toText("g2060_friend_nearby_title"))


	self.stBgMainTagRootFriendTextOn:setText(Lang:toText("g2060_friend_text"))
	self.stBgMainTagRootFriendTextOff:setText(Lang:toText("g2060_friend_text"))

	self.stBgMainTagRootNearbyTextOn:setText(Lang:toText("g2060_nearby_text"))
	self.stBgMainTagRootNearbyTextOff:setText(Lang:toText("g2060_nearby_text"))
end

---@private
function WinG2060FriendLayout:initEvent()
	self.btnBgBackBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
		UI:closeWindow(self)
	end

	self.siBgMainTagRootFriendMainTagOff.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:mainTagSelect(FriendTagMainType.Friend)
	end

	self.siBgMainTagRootNearbyMainTagOff.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		self:mainTagSelect(FriendTagMainType.Nearby)
	end

	self.siBgFriendSubTagFriendsSelectOff.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--显示好友
		self:subTagSelect(FriendTagSubType.Friends)
	end

	self.siBgFriendSubTagInviteSelectOff.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		--显示好友邀请
		self:subTagSelect(FriendTagSubType.Invite)
	end

	self:subscribeEvent(Event.EVENT_UPDATE_FRIEND_LIST_SHOW, function(type)
		if self.selectTagSubType ~= FriendTagSubType.Friends or type ~= Define.chatFriendType.game then
			return
		end
		self:setFriendData()
		self:setFriendList()
	end)

	self:subscribeEvent(Event.EVENT_FINISH_PARSE_REQUESTS_DATA, function()
		self:setInviteData()
	end)

	self:subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(player)
		self:updateNearbyPlayerList()
	end)

	self:subscribeEvent(Event.EVENT_PLAYER_LOGOUT, function(player)
		self:updateNearbyPlayerList()
	end)

	self:subscribeEvent(Event.EVENT_PLAYER_RECONNECT, function()
		self:updateNearbyPlayerList()
	end)

	self:subscribeEvent(Event.EVENT_G2060_FRIEND_GET_SPECIAL_DATA, function()
		if self.selectTagSubType ~= FriendTagSubType.Friends then
			return
		end
		--self:setFriendList()
		--if self.itemType == "friend" then
		--	self:refreshFriendStatus()
		--elseif self.itemType == "nearby" then
		--	self:refreshNearbyData(self.itemData.userId)
		--end
	end)
end

function WinG2060FriendLayout:requestFriendData(pageNo, isScrollDown)
	self.isScrollDown = isScrollDown
	self.lastRequestDataTime = os.time()
	Lib.logInfo("doRequestServerFriendInfo  ", pageNo)
	Me:doRequestServerFriendInfo(Define.chatFriendType.game, pageNo)
end

function WinG2060FriendLayout:setFriendData()
	local userIds = {}
	self.friendData = Me.allFriendData[Define.chatFriendType.game]
	Lib.logInfo("EVENT_UPDATE_FRIEND_LIST_SHOW  ", self.friendData.pageNo, self.friendData.totalPage)
	local onlineNum = 0
	local totalFriendNum = self.friendData.totalSize or 0
	Lib.FriendUtils:encodeFriendGameData(self.friendData.dataList)
	for i, v in pairs(self.friendData.dataList) do
		if v.status ~= Define.onlineStatus.offline then
			onlineNum = onlineNum + 1
		end
		table.insert(userIds, v.userId)
	end
	local numText = string.format("(%s/%s)", onlineNum, totalFriendNum)
	self.stBgFriendSubTagFriendsTagName:setText(Lang:toText("g2060_friend_title") .. numText)

	--FriendSpecialData:requestFriendOnlineState(userIds)
	--Me:sendPacket({
	--	pid = "C2SGetSpecialDataList",
	--	userIds = userIds
	--})
end

--需要等玩家的状态数据回来进行排序
function WinG2060FriendLayout:setFriendList()
	local list = {}
	for i, v in pairs(self.friendData.dataList) do
		local data = {
			itemType = "friend",
			itemData = v
		}
		table.insert(list, data)
	end
	table.sort(list, function(a, b)
		local aCanFollow = FriendUtils:isCanFollowFriend(a.itemData.userId) and 1 or 0
		local bCanFollow = FriendUtils:isCanFollowFriend(b.itemData.userId) and 1 or 0
		if a.status == b.status then
			if aCanFollow ~= bCanFollow then
				return aCanFollow > bCanFollow
			else
				if a.status == Define.onlineStatus.offline then
					return a.itemData.userId < b.itemData.userId
				else
					return a.itemData.logoutTime > b.itemData.logoutTime
				end
			end
		else
			return a.status < b.status
		end
	end)
	self.vertView:refresh(list)
	self.vertView:setVirtualBarPosition(self.isScrollDown and 0 or 1)
end

function WinG2060FriendLayout:setInviteData()
	Lib.logInfo("receive Event.EVENT_FINISH_PARSE_REQUESTS_DATA ")
	local list = {}
	local userIds = {}
	for i, v in pairs(FriendManager.requests) do
		local data = {
			itemType = "invite",
			itemData = v
		}
		table.insert(list, data)
		table.insert(userIds, v.userId)
	end
	local numText = string.format("(%s)", #list)
	self.stBgFriendSubTagInviteTagName:setText(Lang:toText("g2060_friend_invite_title") .. numText)
	if self.selectTagSubType ~= FriendTagSubType.Invite then
		return
	end
	self.vertView:refresh(list)
	Me:sendPacket({
		pid = "C2SGetSpecialDataList",
		userIds = userIds
	})
end

function WinG2060FriendLayout:setSubTagDisplay(tagMainType)
	if tagMainType == FriendTagMainType.Friend then
		self.subTagUI[FriendTagSubType.Friends].root:setVisible(true)
		self.subTagUI[FriendTagSubType.Invite].root:setVisible(true)
		self.subTagUI[FriendTagSubType.PeopleNearby].root:setVisible(false)
	elseif tagMainType == FriendTagMainType.Nearby then
		self.subTagUI[FriendTagSubType.Friends].root:setVisible(false)
		self.subTagUI[FriendTagSubType.Invite].root:setVisible(false)
		self.subTagUI[FriendTagSubType.PeopleNearby].root:setVisible(true)
	end
end

function WinG2060FriendLayout:subTagSelect(tagSubType)
	for i, v in pairs(self.subTagUI) do
		if i == tagSubType then
			self.selectTagSubType = tagSubType
			if v.on then
				v.on:setVisible(true)
			end
			if v.off then
				v.off:setVisible(false)
			end
			v.root:setAlpha(1)
			self:subTagHandle(tagSubType)
		else
			if v.on then
				v.on:setVisible(false)
			end
			if v.off then
				v.off:setVisible(true)
			end
			v.root:setAlpha(0.4)
		end
	end
end

function WinG2060FriendLayout:mainTagSelect(tagMainType)
	for i, v in pairs(self.mainTagSelectUI) do
		if i == tagMainType then
			v.on:setVisible(true)
			v.textOn:setVisible(true)
			v.off:setVisible(false)
			v.textOff:setVisible(false)
			v.subTagRoot:setVisible(true)
			self:setSubTagDisplay(tagMainType)
			self:subTagSelect(self.defaultSelectSubTag[tagMainType])
		else
			v.subTagRoot:setVisible(false)
			v.on:setVisible(false)
			v.textOn:setVisible(false)
			v.off:setVisible(true)
			v.textOff:setVisible(true)
		end
	end
end

function WinG2060FriendLayout:canRequestNextPageData()
	return os.time() - self.lastRequestDataTime >= requestDataTimeInterval
end

function WinG2060FriendLayout:updateNearbyPlayerList()
	if self.selectTagSubType ~= FriendTagSubType.PeopleNearby then
		return
	end
	local players = Game.GetAllPlayersInfo()
	local list = {}
	local userIds = {}
	for _, player in pairs(players) do
		if player.userId ~= Me.platformUserId then
			local data = {
				itemType = "nearby",
				itemData = player
			}
			table.insert(list, data)
			table.insert(userIds, player.userId)
		end
	end
	self.vertView:refresh(list)
	local numText = string.format("(%d)", #list)
	self.stBgNearbySubTagNearbyHorizontalLayoutTagName:setText(Lang:toText("g2060_friend_nearby_title")..numText)
	Me:sendPacket({
		pid = "C2SGetSpecialDataList",
		userIds = userIds
	})
end

function WinG2060FriendLayout:subTagHandle(tagSubType)
	if tagSubType == FriendTagSubType.Friends then
		self:requestFriendData(0, true)
	elseif tagSubType == FriendTagSubType.Invite then
		-- 好友邀请消息
		AsyncProcess.LoadUserRequests()
	elseif tagSubType == FriendTagSubType.PeopleNearby then
		self:updateNearbyPlayerList()
	end
end

---@private
function WinG2060FriendLayout:onOpen()
	self:mainTagSelect(FriendTagMainType.Friend)
	AsyncProcess.LoadUserRequests()
end

---@private
function WinG2060FriendLayout:onDestroy()

end

---@private
function WinG2060FriendLayout:onClose()

end

WinG2060FriendLayout:init()
