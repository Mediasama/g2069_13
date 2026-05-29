---

function Player:syncRankData(rankType, retryTimes)
    if not rankType then
        for _, cfg in pairs(World.cfg.ranks or {}) do
            self:syncRankData(cfg.type or 0, retryTimes)
        end
        return
    end
    local syncTimers = self:data("syncRankTimers")
    local timer = syncTimers[rankType]
    if timer and not retryTimes then
        return
    end
    syncTimers[rankType] = nil
    if self:trySyncRankData(rankType) then
        return
    elseif (retryTimes or 0) > 5 then
        print("Player:syncRankData retry times too much", self.platformUserId, rankType)
        return
    end
    syncTimers[rankType] = self:timer(20 * 5, self.syncRankData, self, rankType, (retryTimes or 0) + 1)
end

function Player:trySyncRankData(rankType)
    local rankData = Rank.GetRankData(rankType)
    if not rankData then
        return false
    end
    local cfgs = Rank.GetSubRankCfgs(rankType)
    if not cfgs then
        return false
    end
    local myRanks, myScores = {}, {}
    local myUserId = self.platformUserId
    for subId in pairs(cfgs) do
        if cfgs[subId].clientPush == false then
            goto continue
        end
        local subRank = rankData[subId] or {}
        local subData = myData[subId]
        if not subData then
            return false
        end
        local rank = subData.rank
        local data = subRank[rank]
        if not data or data.userId ~= myUserId then
            rank = 0
        end
        myRanks[subId] = rank
        local orderByDesc = cfgs[subId].orderByDesc and cfgs[subId].orderByDesc or false
        local score = subData.score
        myScores[subId] = not orderByDesc and score or -score
        ::continue::
    end
    self:sendPacket({
        pid = "RankData",
        rankType = rankType,
        rankData = rankData,
        myRanks = myRanks,
        myScores = myScores,
    })
    return true
end

function Player:getMyRank(rankType, subId)
    local rankData = Rank.GetRankData(rankType) or {}
    local subData = rankData[subId] or {}
    for _, data in pairs(subData) do
        if data.userId == self.platformUserId then
            return data.rank
        end
    end
    return 0
end

--rewrite
--服务器向客户端发送全区排行榜信息
function Player:sendAllRankPacket(rankType, rankList)
    self:sendPacket({
        pid = "allRank",
        rankType = rankType,
        rankList = rankList,
    })
end

--rewrite
--服务器向客户端发送个人排行信息
function Player:sendMyRankPacket(rankType, score, rank,level)
    --print(">>>>>>>>>>>>Player:sendMyRankPacket",rankType,score, rank,level)
    self:sendPacket({
        pid = "singleRank",
        userId = self.luaPlatformUserId,
        rankType = rankType,
        score = score,
        rank = rank,
        level=level or 1
    })
end

function Player:getNewRankScore()
    return self:getDangerValue()
end