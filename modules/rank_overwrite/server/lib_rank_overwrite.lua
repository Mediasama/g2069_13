
---@type RedisHandlerRank
local RedisHandlerRank = T(Lib, "RedisHandlerRank")

local tonumber = tonumber
local pairs = pairs

local self = Rank
Rank.REQUEST_INTERVAL = Define.REQUEST_INTERVAL	-- 90 seconds

local rank_sort = require "rank_class"
local cjson = require("cjson")

function Rank.Init()
	self.localRankList = {}
	self.redisRankDatas = {}
	self.playerRankDatas = {}
	self.rankKeyList = {}
	self.receiveTimer = {}
	self.lastRequestTime = {}
	for rankType, cfg in pairs(World.cfg.rankSetting.ranks or {}) do
		if cfg.db == "local" then
			local key = Rank.getRankKey(rankType, 5)
			--create new rank
			local rank = Lib.derive(rank_sort)
			rank:init(cfg.comparedata, { maxLen = cfg.size })
			rank.Local = cfg.db == "local"
			self.localRankList[key] = rank
		end
	end

	self.RequestRankData()
	--self.requestRankTimer = World.Timer(self.REQUEST_INTERVAL, Rank.RequestRankData)
end

function Rank.getRankScore(rankName, id)
	return self.localRankList[rankName].queryData(id)
end

function Rank.isregisterKey(rankType, regionId)
	local userKey = Rank.getRankKey(rankType, regionId)
	for key,info in pairs(self.rankKeyList or {}) do
		if key == userKey then
			return true
		end
	end
	return false
end

function Rank.registerKey(rankType, regionId)
	local key = Rank.getRankKey(rankType, regionId)
	self.rankKeyList[key] = {
		rankType = rankType,
		regionId = regionId,
	}
	self.redisRankDatas[key] = {}
	Lib.logDebug("--- registerKey ---", rankType, regionId)
end

function Rank.getRankKey(rankType, regionId)
	local cfg = World.cfg.rankSetting.ranks[rankType]
	local suffix = tostring(Rank.getRankExpireTime(cfg.expireType))
	if cfg.isGlobal then
		return rankType .. "_expire" .. suffix
	else
		return rankType .. "_region" .. regionId .. "_expire" .. suffix
	end
end

function Rank.getRankExpireTime(expireType)
	local curTime = os.time()
	local expireTime = 0
	if expireType == "CurDay" then
		expireTime = Lib.getDayEndTime(curTime)
	elseif expireType == "NextDay" then
		expireTime = Lib.getDayEndTime(curTime + 86400)
	elseif expireType == "CurWeek" then
		expireTime = Lib.getWeekEndTime(curTime)
	elseif expireType == "NextWeek" then
		expireTime = Lib.getWeekEndTime(curTime + 86400 * 7)
	elseif expireType == "CurMonth" then
		expireTime = Lib.getMonthEndTime(curTime)
	elseif expireType == "NextMonth" then
		expireTime = Lib.getMonthEndTime(Lib.getMonthEndTime(curTime) + 1)
	elseif expireType == "Hist" then
		expireTime = 0
	elseif expireType == "forever" then
		expireTime = 0
	end
	return expireTime
end

--todo 定时从平台拉对低频需求来说，反而消耗更大，不如触发式刷新
function Rank.RequestRankData(rankType, regionId,pageNo)
	Lib.logDebug("--- request rank data---", rankType, regionId)
	if rankType and regionId and not Rank.isregisterKey(rankType, regionId) then
		Rank.registerKey(rankType, regionId)
	end
	if not rankType then
		--for rankType, cfg in pairs(World.cfg.rankSetting.ranks or {}) do
		--	if cfg.db == "redis" then
		--		for key,info in pairs(self.rankKeyList or {}) do
		--			Rank.RequestRankData(info.rankType, info.regionId,pageNo)
		--		end
		--	end
		--end
		--local timer = self.requestRankTimer
		--if timer then
		--	timer()
		--end
		--self.requestRankTimer = World.Timer(self.REQUEST_INTERVAL, Rank.RequestRankData)
	else
		local cfg = World.cfg.rankSetting.ranks[rankType]
		local key = Rank.getRankKey(rankType, regionId)
		local pageSize = Define.RANK_PAGE_SIZE
		self.lastRequestTime[regionId] = os.time()
		RedisHandlerRank:GetRankDataByRange(key, pageNo or 0, pageSize, function(success, data,exData)
			if not success then
				print("AsyncProcess.RequestRankRange request error", key, data)
			else
				Rank.ReceiveRankData(rankType, regionId, data,exData,pageNo or 0)
			end
		end)
	end
end

function Rank.ReceiveRankData(rankType, regionId, rankDataStr,exData,pageNo)
	local cfg = World.cfg.rankSetting.ranks[rankType]
	local orderByDesc = cfg.orderByDesc
    local ranks = {}
    local userIds = {}
	local split = Lib.splitString
    for i, data in pairs(split(rankDataStr, "#")) do
		local info = split(data, ":")
		if #info < 2 then
			goto continue
		end
		local userId = tonumber(info[1])
		local level=(exData and exData[userId] and exData[userId].level) and tonumber(exData[userId].level)
        local rank = {
            rank = tonumber(info[3]) ,
            userId = userId,
            score = tonumber(info[2]),
            vip = 0,
			nickName = "anonymous_"..info[1],
			picUrl = "",
			level = level or 1
        }
		if orderByDesc then
			rank.score = -rank.score
		end
        local cache = UserInfoCache.GetCache(userId)
        if cache then
            rank.vip = cache.vip
			rank.picUrl = cache.picUrl or ""
            rank.nickName = cache.nickName
        else
            userIds[#userIds + 1] = userId
        end
        ranks[#ranks + 1] = rank
		::continue::
    end
	local key = Rank.getRankKey(rankType, regionId)
	self.redisRankDatas[key] = ranks
	--print("++++++++++++++++++ReceiveRankData,ranks:",rankDataStr,pageNo,Lib.v2s(ranks))
	Lib.emitEvent(Event.EVENT_RECEIVE_NEW_RANK_DATA,rankType, regionId,pageNo or 0)
	AsyncProcess.RankLoadPlayersInfo(userIds, key)
end

function Rank.UpdatePlayerInfo(playerInfos, key)
	for _, rank in pairs(self.redisRankDatas[key]) do
        local info = playerInfos[rank.userId]
        if info then
            rank.vip = info.vip
            rank.nickName = info.nickName
			rank.picUrl = info.picUrl or ""
        end
    end
end

--立即更新服务器排行榜数据并发给用户
function Rank.UpdateRankDataImmediately(userId, rankType, regionId,pageNo)
	--print("===================UpdateRankDataImmediately",userId,pageNo)
	--小优化，如果该玩家的金币数量和缓存一致，就发缓存，不请求
	--if not Rank.checkNeedRequestByUserId(userId,rankType,regionId) then
	--	Lib.logDebug("--- immediately request send stash ---",userId, rankType, regionId)
	--	return
	--end
	if self.receiveTimer[tostring(userId)] then
		self.receiveTimer[tostring(userId)]()
	end
	self.receiveTimer[tostring(userId)] = Lib.subscribeEvent(Event.EVENT_RECEIVE_NEW_RANK_DATA,function(ReceiveRankType, ReceiveRegionId,ReceivePageNo)
		--print(">>>>>>>>>>>>>>>>>>>>EVENT_RECEIVE_NEW_RANK_DATA  ReceivePageNo,",ReceivePageNo)
		if rankType ~= ReceiveRankType or regionId ~= ReceiveRegionId or pageNo~=ReceivePageNo then
			return
		end
		local player = Game.GetPlayerByUserId(userId)
		local key = Rank.getRankKey(rankType, regionId)
		if not player then
			return
		end
		Rank.RequestAllRankInfo(rankType, regionId, userId,0)
		--先在大区榜找，没有再请求
		local flag = false
		for index, info in pairs(self.redisRankDatas[key]) do
			if userId == info.userId then
				local player = Game.GetPlayerByUserId(userId)
				if player and player:isValid() then
					player:sendMyRankPacket(rankType, info.score, info.rank,info.level)
				end
				--缓存
				--if not self.playerRankDatas[tostring(userId)] then
				--	self.playerRankDatas[tostring(userId)] = {}
				--end
				--self.playerRankDatas[tostring(userId)].score = info.score
				--self.playerRankDatas[tostring(userId)].rank = info.rank
				--self.playerRankDatas[tostring(userId)].level = info.level
				self:setPlayerRankData(userId,rankType,info)
				flag = true
				break
			end
		end
		if not flag then
			Rank.RequestUserRankInfo(userId, rankType, regionId, true)
		end
		if self.receiveTimer[tostring(userId)] then
			self.receiveTimer[tostring(userId)]()
			self.receiveTimer[tostring(userId)] = nil
		end
	end)
	if self.requestRankTimer then
		self.requestRankTimer()
	end
	Rank.RequestRankData(rankType, regionId,pageNo)
	--self.requestRankTimer = World.Timer(self.REQUEST_INTERVAL, Rank.RequestRankData)
end

function Rank.UpdateRankData(params)
	local rank = params.rank or self.localRankList[params.rankName]
	if rank and rank.Local and params.id then
		local tb = params.addList or {}
		if params.key then
			tb[params.key] = params.val
		end
		local upData = {}
		for key,score in pairs(tb) do
			upData[key] = score
		end
		rank:UpdataRanks(params.id, upData)
	elseif rank and not rank.Local and params.id then
		--TODO WORLD RANK
	end
end

function Rank.UserAddScore(userId, rankType, regionId, score)
	local key = Rank.getRankKey(rankType, regionId)
	RedisHandlerRank:ZIncrBy(key, tostring(userId), score)
end

--查单个人排名
function Rank.RequestUserRankInfo(userId, rankType, regionId, immediately)
	--print(">>>>>>>>>>>>>>>>>>Rank.RequestUserRankInfo",userId, rankType, regionId, immediately)
	local key = Rank.getRankKey(rankType, regionId)
	local playerRankCache=self:getPlayerRankData(userId,rankType)
	if playerRankCache and next(playerRankCache)~=nil and not immediately then
		local player = Game.GetPlayerByUserId(userId)
		if player:isValid() then
			player:sendMyRankPacket(rankType, playerRankCache.score,playerRankCache.rank,playerRankCache.level)
		end
		return
	end
	Lib.logDebug("--- request single rank ---",userId)
	RedisHandlerRank:GetSignalScore(key, tostring(userId), function(success, score, rank,exData)
		if not success then
			print("AsyncProcess.RequestPlayerRankInfo request error", key, userId, score, rank)
		else
			local player = Game.GetPlayerByUserId(userId)
			if player and player:isValid() then
				local level=(exData and exData.level and tonumber(exData.level)) and tonumber(exData.level) or 1
				player:sendMyRankPacket(rankType, score, rank,level)
				self:setPlayerRankData(userId,rankType,{
					score = score,
					rank = rank,
					level=level
				})
				--self.playerRankDatas[tostring(userId)] = {
				--	score = score,
				--	rank = rank,
				--	level=level
				--}
				--起定时器删除个人的数据缓存，全区的数据更新就行
				World.Timer(20 * 60 * Define.RANK_DELETE_SINGLE_CACHE_TIME,function()
					--self.playerRankDatas[tostring(userId)] = nil
					--self:setPlayerRankData(userId,rankType,nil)
				end)
			end

		end
	end)
end

--查全区排名(缓存里找)
function Rank.RequestAllRankInfo(rankType, regionId, userId, pageNo)
	Lib.logDebug("--- RequestAllRankInfo ---", rankType, regionId, userId, pageNo)
	local key = Rank.getRankKey(rankType, regionId)
	local rankList = {}
	if not self.redisRankDatas[key] then
		Rank.UpdateRankDataImmediately(userId, rankType, regionId,pageNo)
		return
	end
	if (pageNo + 1) * Define.RANK_PAGE_SIZE > World.cfg.rankSetting.ranks[rankType].size then
		return
	end
	for i = pageNo * Define.RANK_PAGE_SIZE + 1, (pageNo + 1) * Define.RANK_PAGE_SIZE do
		if self.redisRankDatas[key][i] then
			table.insert(rankList, self.redisRankDatas[key][i])
		end
	end
	local player = Game.GetPlayerByUserId(userId)
	if player then
		Lib.logDebug("--- server send all rank data to user ---", userId)
		player:sendAllRankPacket(rankType, rankList)
	end
end

--数据更新，写入排行榜,score不传则更新一下自己的(不是立即发到平台)
function Rank.UserUpdateScore(userId, rankType, score)
	local cfg = World.cfg.rankSetting.ranks[rankType]
	local player = Game.GetPlayerByUserId(userId)
	if player and player:isValid() then
		local regionId = player:data("mainInfo").regionId or 0
		local key = Rank.getRankKey(rankType, regionId)
		if not key then
			return
		end
		if not score then
			score = Plugins.CallTargetPluginFunc("rank_overwrite", "getMyNewRankScore",  player, rankType)
		end
		if not score then
			return
		end

		if score >10000000 then
			print("++++++++++++++++++++++ SCRIPT_EXCEPTION score ",userId,tostring(score),player:getDangerValue(),debug.traceback())
			return
		end

		if cfg.db == "redis" then
			local expireTime = Rank.getRankExpireTime(cfg.expireType)
			RedisHandlerRank:reportScore(key, userId, score, expireTime, cfg.maxSize, cfg.reportScoreLimit,rankType)
		else
			--todo 其他数据库
		end
	end
end

function Rank:getPlayerRankData(userId,rankType)
	if not userId or not rankType then
		return nil
	end
	if not self.playerRankDatas[tostring(userId)] then
		return nil
	end
	return self.playerRankDatas[tostring(userId)][rankType]
end

function Rank:setPlayerRankData(userId,rankType,data)
	--print("++++++++++++++ setPlayerRankData",userId,rankType,Lib.v2s(data))
	if not userId or not rankType then
		return
	end
	if not self.playerRankDatas[tostring(userId)] then
		self.playerRankDatas[tostring(userId)]={}
	end

	if not data then
		self.playerRankDatas[tostring(userId)][rankType]=nil
	else
		if not self.playerRankDatas[tostring(userId)][rankType] then
			self.playerRankDatas[tostring(userId)][rankType] = {}
		end
		self.playerRankDatas[tostring(userId)][rankType].score = data.score
		self.playerRankDatas[tostring(userId)][rankType].rank = data.rank
		self.playerRankDatas[tostring(userId)][rankType].level = data.level
	end
end