local cjson = require("cjson")
local strfmt = string.format
local tconcat = table.concat
local tostring = tostring
local type = type
local traceback = traceback

---@class RedisHandlerRank
local RedisHandlerRank = T(Lib, "RedisHandlerRank")

function RedisHandlerRank:init()
    self.ServerHttpHost = Server.CurServer:getServerHttpHost()

    self.enable		    = self.ServerHttpHost ~= ""
    self.postZIncrByUrl = strfmt("%s/gameaide/api/v1/inner/game/rank/list", self.ServerHttpHost)
    self.getZRangeUrl   = strfmt("%s/gameaide/api/v1/inner/game/rank", self.ServerHttpHost)
    self.getZScoreUrl   = strfmt("%s/gameaide/api/v1/inner/game/rank/member", self.ServerHttpHost)

    self.ZIncrByQueue = {}
    self.sendingZIncrBy = false
    self.sendZIncrByTime = 0
    if self.enable then
        self.checkPostTimer = World.Timer(20 * 60, self.checkPostData, self)
        self.checkReportTimer = World.Timer(20 * 60*1, self.reportAllPlayer, self)
    end
    print("RedisHandlerRank init", self.enable)
end

function RedisHandlerRank:checkPostData()
    self:trySendZIncBy()
    return true
end

function RedisHandlerRank:reportAllPlayer()
    local players = Game.GetAllPlayers()
    for _, player in pairs(players) do
        if player:isValid() then
            for rankType, info in pairs(World.cfg.rankSetting.ranks) do
                local key = Rank.getRankKey(rankType, player:data("mainInfo").regionId or 0)
                player:setRankKey({[rankType] = key})
                Rank.UserUpdateScore(player.platformUserId, rankType)
                --print("--------------------------- report all",player.platformUserId,rankType)
            end
        end
    end
    return true
end

function RedisHandlerRank:trySendZIncBy(immediately)
    local cacheCount = #self.ZIncrByQueue
    local canSend = immediately or
            (not self.sendingZIncrBy and cacheCount > 0 and (cacheCount >= 3 or os.time() - self.sendZIncrByTime > 60))
    if canSend then
        local ok, msg = xpcall(self.sendZIncrByData, traceback, self)
        if not ok then
            perror("RedisHandlerRank sendZIncrByData error", msg)
        end
    end
end

-- 上报玩家分数
function RedisHandlerRank:reportScore(rankKey, userId, score, expireTime, maxSize, reportScoreLimit,rankType)
    if not self.enable then
        return
    end
    local player = Game.GetPlayerByUserId(userId)
    if not player or not player:isValid() then
        return
    end

    if score >10000000 then
        print("++++++++++++++++++++++ SCRIPT_EXCEPTION reportScore ",userId,tostring(score),player:getDangerValue(),debug.traceback())
        return
    end

    local exData={}
    ---@type GrowthSystem
    local GrowthSystem = T(Lib, "GrowthSystem")
    exData.level=GrowthSystem:getLevel(player)
    local queue = self.ZIncrByQueue
    local item
    for _, v in pairs(queue) do
        if v.member==tostring(userId) and v.key==rankKey then
            item=v
            break
        end
    end
    if item then
        item.score=score
        item.data=exData
    else
        queue[#queue + 1] = {
            key = rankKey,
            member = tostring(userId),
            scores = score,
            expireTime = expireTime,
            maxSize = maxSize,
            isAdd = reportScoreLimit,
            data=exData,
            rankType=rankType
        }
    end
end

-- 请求平台批量上报玩家分数
function RedisHandlerRank:sendZIncrByData()
    if not self.enable or not next(self.ZIncrByQueue) then
        return
    end
    local list = {}
    local reportList={}
    for i, data in pairs(self.ZIncrByQueue) do
        list[i] = {
            expireTime = data.expireTime,
            key = data.key,
            maxSize = data.maxSize,
            member = data.member,
            scores = data.scores,
            isAdd = data.isAdd,
            data=data.data
        }
        local player=Game.GetPlayerByUserId(tonumber(data.member))
        if player and player:isValid() then
            if not reportList[data.member] then
                reportList[data.member]={}
                reportList[data.member].region=player:data("mainInfo").regionId or 0
            end
            local playerRankBuff=Rank:getPlayerRankData(data.member,data.rankType)
            if data.rankType=="g2069_Rank_Global" then
                reportList[data.member].global_string_danger_exp=tostring(data.scores)
                reportList[data.member].global_rank_position=playerRankBuff and playerRankBuff.rank or 0
            else
                reportList[data.member].region_string_danger_exp=tostring(data.scores)
                reportList[data.member].region_rank_position=playerRankBuff and playerRankBuff.rank or 0
            end
        end
    end

    for id, data in pairs(reportList) do
        local player=Game.GetPlayerByUserId(tonumber(id))
        if player and player:isValid() then
            Plugins.CallTargetPluginFunc("report", "report", "rank_report", data, player)
        end
    end
    self.ZIncrByQueue = {}

    self.sendingZIncrBy = true
    local params = {}
    local body = cjson.encode(list)
    local function sendRequest(tryTimes, url)
        if tryTimes >= 3 then
            perror("RedisHandlerRank sendZIncrByData failed", body)
            self.sendingZIncrBy = false
            self.sendZIncrByTime = os.time()
            return
        end
        AsyncProcess.HttpRequest("POST", url, params, function(response)
            local code = response.code
            if code ~= 1 then
                sendRequest(tryTimes + 1, url)
                return
            end
            self.sendingZIncrBy = false
            self.sendZIncrByTime = os.time()
        end, body)
    end
    sendRequest(1, self.postZIncrByUrl)
    --print("+++++++++++++++++++++ sendZIncrByData",#list)
end

function RedisHandlerRank:GetRankDataByRange(rankKey, pageNo, pageSize, callback)	-- callback(success, data)
    --Lib.logDebug("----------- RedisHandlerRank:GetRankDataByRange---", rankKey)
    if not self.enable then
        callback(true, "")
        return
    end
    local params = { { "key", rankKey }, { "pageNo", pageNo }, { "pageSize", pageSize }}
    AsyncProcess.HttpRequest("GET", self.getZRangeUrl, params, function(response)
        if response.status_code then
            print("RedisHandlerRank GetRankDataByRange response error", rankKey, pageNo, pageSize, response.status_code)
            callback(false, cjson.encode(response))
            return
        end
        local success, ret = false, "has parse error"
        local code, data, message = response.code, response.data, response.message
        local exData={}
        if not code or not data or not message then
            print("RedisHandlerRank GetRankDataByRange error, lack of field", rankKey, pageNo, pageSize, cjson.encode(response))
        elseif code ~= 1 then	-- 1: SUCCESS; 2: FAILED; 3: PARAM ERROR; 4: INNER ERROR; 5: TIME OUT; 6: AUTH_FAILED
            print("RedisHandlerRank GetRankDataByRange error code", rankKey, pageNo, pageSize, cjson.encode(response))
        elseif not data or type(data) == "table" and not next(data) then
            success, ret = true, ""
        elseif type(data) ~= "table" then
            print("RedisHandlerRank GetRankDataByRange error data", rankKey, pageNo, pageSize, cjson.encode(response))
        else
            local list = {}
            for i, v in ipairs(data) do
                if not v.member or not v.score then
                    success, list = false, nil
                    break
                end
                list[#list + 1] = strfmt("%s:%s:%s", tostring(v.member), tostring(v.score),tostring(v.rank))
                exData[tonumber(v.member)]=v.data or {}
            end
            if list then
                success, ret = true, table.concat(list, "#")
            end
        end
        callback(success, ret,exData)
    end)
end

--查单个人排名
function RedisHandlerRank:GetSignalScore(rankKey, member, callback)	-- callback(success, score, rank)
    if not self.enable then
        callback(true, -1, 0)
        return
    end
    local params = { { "key", rankKey }, { "member", member }}
    AsyncProcess.HttpRequest("GET", self.getZScoreUrl, params, function(response)
        local content = cjson.encode(response)
        print("RedisHandlerRank GetSignalScore response", #content, content:sub(1, 100))
        if response.status_code then
            print("RedisHandlerRank GetSignalScore response error", rankKey, member, response.status_code)
            callback(false, response.status_code, -1)
            return
        end
        local success, score, rank = false, -1, 0
        local code, data, message = response.code, response.data, response.message
        if not code or not data or not message then
            print("RedisHandlerRank GetSignalScore error, lack of field", rankKey, member, cjson.encode(response))
        elseif code ~= 1 then	-- 1: SUCCESS; 2: FAILED; 3: PARAM ERROR; 4: INNER ERROR; 5: TIME OUT; 6: AUTH_FAILED
            print("RedisHandlerRank GetSignalScore error code", rankKey, member, cjson.encode(response))
        elseif not data or type(data) == "table" and not next(data) then
            success, score, rank = true, 0, 0
        elseif type(data) ~= "table" or not data.rank or not data.score then
            print("RedisHandlerRank GetSignalScore error data", rankKey, member, cjson.encode(response))
        else
            success, score, rank = true, tonumber(data.score), math.floor(tonumber(data.rank))
        end
        callback(success, score, rank,(data and data.data) and data.data or {})
    end)
end

RedisHandlerRank:init()