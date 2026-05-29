local handles = T(Player, "PackageHandlers")

--rewrite
--function handles:friendRank(packet)
--    Lib.emitEvent(Event.EVENT_FRIEND_RANK,packet)
--end

--rewrite
function handles:allRank(packet)
    Lib.emitEvent(Event.EVENT_All_RANK,packet)
end

--rewrite
function handles:singleRank(packet)
    AsyncProcess.GetUserDetail(self.platformUserId, function (data)
    	if not data then
    		return
    	end
        local res = {
            rank = packet.rank,
            userId = packet.userId,
            nickName = data.nickName or "",
            picUrl = data.picUrl or "",
            score = packet.score,
            level=packet.level,
            rankType=packet.rankType
        }
        Lib.emitEvent(Event.EVENT_ALL_SINGLE_RANK, res)
    end)
end

function handles:S2CPlayerSkinData(packet)
    Lib.emitEvent(Event.EVENT_GET_TOP3_SKIN,packet)
end

function handles:S2CUpdateSceneRankUI(packet)
    --print("-------------------------handles:S2CUpdateSceneRankUI",Lib.v2s(packet))
    Lib.emitEvent(Event.EVENT_UPDATE_TOP3_RANK,packet)
end
