---@class WidgetFriendItemWidget : CEGUILayout
local WidgetFriendItemWidget = M

local FriendUtils = T(Lib, "FriendUtils")

local FriendSpecialData = T(Lib, "FriendSpecialData")
local FriendGameStatus = Define.FriendGameStatus

---@private
function WidgetFriendItemWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetFriendItemWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIDefaultWindow
	self.wBgPanelHead = self.Bg.PanelHead
	---@type CEGUIStaticImage
	self.siBgPanelHeadImageHead = self.Bg.PanelHead.ImageHead
	---@type CEGUIStaticImage
	self.siBgPanelHeadImageFrame = self.Bg.PanelHead.ImageFrame
	---@type CEGUIStaticImage
	self.siBgPanelHeadImageMale = self.Bg.PanelHead.ImageMale
	---@type CEGUIStaticImage
	self.siBgPanelHeadImageFemale = self.Bg.PanelHead.ImageFemale
	---@type CEGUIStaticText
	self.stBgPlayerName = self.Bg.PlayerName
	---@type CEGUIStaticText
	self.stBgStatusText = self.Bg.StatusText
	---@type CEGUIButton
	self.btnBgAllowBtn = self.Bg.AllowBtn
	---@type CEGUIButton
	self.btnBgRefuseBtn = self.Bg.RefuseBtn
	---@type CEGUIButton
	self.btnBgAddFriendBtn = self.Bg.AddFriendBtn
end

---@private
function WidgetFriendItemWidget:initUI()
	self.btnBgAllowBtn:setText(Lang:toText("g2060_friend_agree"))
	self.btnBgRefuseBtn:setText(Lang:toText("g2060_friend_refuse"))
	self.btnBgAddFriendBtn:setText(Lang:toText("new.chat.player_addFriend"))

	self.dialogBoxOffset=50
end

---@private
function WidgetFriendItemWidget:initEvent()
	self.btnBgAllowBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		local opType = FriendManager.operationType.AGREE
		Me:friendRequestReport(opType, self.itemData.userId, true)
		AsyncProcess.FriendOperation(opType, self.itemData.userId)
	end

	self.btnBgRefuseBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		local opType = FriendManager.operationType.REFUSE
		Me:friendRequestReport(opType, self.itemData.userId, true)
		AsyncProcess.FriendOperation(opType, self.itemData.userId)
	end

	self.btnBgAddFriendBtn.onMouseClick = function()
		Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_click")
		Lib.FriendUtils:sendAddFriend(self.itemData.userId, self.btnBgAddFriendBtn)
	end

	self.wBgPanelHead.onMouseClick = function(instance, window, x, y)
		if self.itemData and self.itemData.userId~=Me.platformUserId then
			local box = UI:openWindow("UI/new_chat/gui/win_chat_player_dialog_box")
			local nodeX = CEGUICoordConverter.screenToWindowX1(box:getWindow(), x)
			local nodeY= CEGUICoordConverter.screenToWindowY1(box:getWindow(), y)
			box:setPanelPos(nodeX+self.dialogBoxOffset,nodeY)
			box:initData(self.itemData)
		end
	end

	--好友产生变化
	self:subscribeEvent(Event.EVENT_CHAT_FRIEND_EXIST_CHANGE, function(userId)
		if not self.itemData then
			return
		end
		if self.itemData.userId == userId then
			if self.itemType == "nearby" then
				self:refreshNearbyData(userId)
			end
		end
	end)

	--获取到玩家特殊数据 刷新 跟随显示和个人介绍
	self:subscribeEvent(Event.EVENT_G2060_FRIEND_GET_SPECIAL_DATA, function()
		if not self.itemData then
			return
		end
		if self.itemType == "invite" then
			FriendUtils:setPlayerIntroductionText(self.itemData.userId)
		elseif self.itemType == "nearby" then
			self:refreshNearbyData(self.itemData.userId)
			FriendUtils:setPlayerIntroductionText(self.itemData.userId)
		end
	end)

	self:subscribeEvent(Event.EVENT_UPDATE_ONLINE_STATE_SHOW, function()
		if not self.itemData then
			return
		end
		if self.itemData.userId then
			if self.itemType == "friend" then
				self:refreshFriendStatus()
			end
		end
	end)
end

function WidgetFriendItemWidget:hideOptBtn()
	self.btnBgAllowBtn:setVisible(false)
	self.btnBgRefuseBtn:setVisible(false)
	self.btnBgAddFriendBtn:setVisible(false)
end

function WidgetFriendItemWidget:refreshFriendStatus()
	local onlineState = self.itemData.status
	local isOffline = onlineState == Define.onlineStatus.offline
	if isOffline then
		self:hideOptBtn()
	end
	self.stBgStatusText:setVisible(true)
	Lib.FriendUtils:setPlayerStatusText(self.itemData.userId, self.stBgStatusText, self.itemData)
end

function WidgetFriendItemWidget:refreshNearbyData(userId)
	Lib.FriendUtils:setAddFriendBtnStatus(self.btnBgAddFriendBtn, self.itemData.userId)
end

function WidgetFriendItemWidget:refreshInviteData()
	self.btnBgAllowBtn:setVisible(true)
	self.btnBgRefuseBtn:setVisible(true)
end

function WidgetFriendItemWidget:refreshHeadData(name, picUrl, sex)
	if picUrl == "" then
		picUrl = World.cfg.defaultAvatar
	end
	self.stBgPlayerName:setText(name)
	self.siBgPanelHeadImageHead:setImage(picUrl)
	self.siBgPanelHeadImageMale:setVisible(sex == 1)
	self.siBgPanelHeadImageFemale:setVisible(sex == 0)
	if sex == 1 then
		self.siBgPanelHeadImageFemale:setImage("gameres|asset/imageset/chat2:img_9_headframe_players")
	else
		self.siBgPanelHeadImageFemale:setImage("gameres|asset/imageset/chat2:img_9_headframe_captain")
	end
end

function WidgetFriendItemWidget:initData(data)
	self:hideOptBtn()
	self.itemType = data.itemType
	self.itemData = data.itemData
	if self.itemData.gameData then
		FriendUtils:setPlayerIntroductionText(self.itemData.userId, self.itemData.gameData)
	end
	if self.itemType == "friend" then
		--展示好友item
		self.stBgStatusText:setVisible(true)
		self:refreshHeadData(self.itemData.nickName, self.itemData.picUrl, self.itemData.sex)
		self:refreshFriendStatus()
	elseif self.itemType == "nearby" then
		self.stBgStatusText:setVisible(false)
		UserInfoCache.LoadCacheByUserIds({self.itemData.userId}, function()
			local cache = UserInfoCache.GetCache(self.itemData.userId)
			self.itemData.nickName = cache.name
			self.itemData.picUrl = cache.picUrl
			self.itemData.sex = cache.sex
			self:refreshHeadData(cache.name, cache.picUrl, cache.sex)
		end)
		self:refreshNearbyData()
	elseif self.itemType == "invite" then
		self.stBgStatusText:setVisible(false)
		self:refreshHeadData(self.itemData.nickName, self.itemData.picUrl, self.itemData.sex)
		self:refreshInviteData()
	end
end

---@private
function WidgetFriendItemWidget:onOpen()

end

---@private
function WidgetFriendItemWidget:onDestroy()

end

WidgetFriendItemWidget:init()
