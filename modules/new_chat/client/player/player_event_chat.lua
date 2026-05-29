local playerEventEngineHandler = L("playerEventEngineHandler", player_event)

local ChatHelper = T(Lib, "ChatHelper")

local events = {}

function player_event(player, event, ...)
	playerEventEngineHandler(player, event, ...)
	local func = events[event]
	if func then
		func(player, ...)
	end
end

function events:receiveMessage(sourceType, messageType, content)
	ChatHelper:receivePlatformPrivateMsg(sourceType, messageType, content)
end

function events:receiveHistoryTalkList(listInfo)
	ChatHelper:receiveHistoryTalkList(listInfo)
end

function events:receiveHistoryTalkDetail( targetId, detailContent)
	ChatHelper:receiveHistoryTalkDetail(targetId, detailContent)
end
