
local Player = Player
local friendRankApi = "/gameaide/api/v1/game/friend/rank"

function Player:getFriendRankByRankType(rankType, pageNo)
    local userId = self.platformUserId
    local url = AsyncProcess.ClientHttpHost .. friendRankApi
    local params = {
        { "gameId", World.GameName },
        { "key", tostring(self:getRankKey(rankType)) },
        { "pageNo", pageNo or 0 },
        { "pageSize", Define.RANK_PAGE_SIZE},
        { "userId", userId }
    }
    AsyncProcess.HttpRequest("GET", url, params, function(data)
        if data then
            --好友数据
            Lib.emitEvent(Event.EVENT_FRIEND_RANK, data)
        end
    end)
end