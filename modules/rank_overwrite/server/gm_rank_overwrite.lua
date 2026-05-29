local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
    GMItem = require("gm_server")
    file:close()
end
if not GMItem then
    GMItem = GM:createGMItem()
end

GMItem["rank_overwrite/取大区榜数据"] = function(self)
    local rankType = World.cfg.rankSetting.newRankType[1]
    local ret = Plugins.CallTargetPluginFunc("rank_overwrite", "getRankData",  self.platformUserId, rankType)
    print("取大区榜数据", Lib.v2s(ret))
end

GMItem["rank_overwrite/写入测试数据"] = GM:inputStr(function(self, score)
    local score = tonumber(score)
    local rankType = World.cfg.rankSetting.newRankType[1]
    if score >10000000 then
        print("++++++++++++++++++++++ SCRIPT_EXCEPTION gm score ",self.platformUserId,tostring(score),self:getDangerValue(),debug.traceback())
        return
    end
    Plugins.CallTargetPluginFunc("rank_overwrite", "UserUpdateScore",  self.platformUserId, rankType, score)
end, "1")

GMItem["rank_overwrite/singleRank"] = function(self)
    local rankType = World.cfg.rankSetting.newRankType[1]
    local player = Game.GetPlayerByUserId(self.platformUserId)
    local regionId = player:data("mainInfo").regionId or 0
    Rank.RequestUserRankInfo(self.platformUserId, rankType, regionId)
end

GMItem["rank_overwrite/取大区榜数据111"] = function(self)
    local rankType = World.cfg.rankSetting.newRankType[1]
    Rank.RequestAllRankInfo(rankType, 1001, self.platformUserId,0)
end

GMItem["rank_overwrite/更新自己的分数"] = function(self)
    local score = 100
    Plugins.CallTargetPluginFunc("rank_overwrite", "updatePlayerRankData",  World.cfg.rankSetting.newRankType[1], self, score)
end

GMItem["rank_overwrite/test"] = function(self)
    local dbHandler = require "dbhandler"
    local seri = require "seri"
    local misc = require "misc"
    dbHandler:getDataByUserId(self.platformUserId, 1, function(userId, text)
        -- 成功
        local data = seri.deseristring_string(misc.base64_decode(text))
        if data and data.skin then
            print("------------------------------ success",Lib.v2s(data.skin,10))
        end
    end, function(userId, isEmptyData)
    end)
end