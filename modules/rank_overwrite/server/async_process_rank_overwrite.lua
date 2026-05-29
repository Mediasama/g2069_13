local function RequestPlayersSimpleInfo(userIds, callback, timeout)
	local timer
	local session = UserInfoCache.LoadCacheByUserIds(userIds, function ()
		if timer then
			timer()
		end
		callback()
	end)
	if session and timeout then
		timer = World.Timer(timeout, function ()
			--print("RequestPlayersSimpleInfo timeout", session, timeout, table.concat(userIds, ","))
			UserInfoCache.CancelRequest(session)
			callback()
		end)
	end
end

function AsyncProcess.RankLoadPlayersInfo(userIds, ...)
	local params = table.pack(...)
	RequestPlayersSimpleInfo(userIds, function ()
		local playerInfos = {}
		for _, userId in pairs(userIds) do
			playerInfos[userId] = UserInfoCache.GetCache(userId)
		end
		Rank.UpdatePlayerInfo(playerInfos, table.unpack(params))
	end, 20 * 5)
end