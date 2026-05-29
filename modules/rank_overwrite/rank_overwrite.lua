require "common.entity_rank_overwrite"
require "common.event_rank_overwrite"
require "common.define_rank_overwrite"

if World.isClient then
    require "client.gm_rank_overwrite"
	require "client.player.packet_rank_overwrite"
	require "client.player.player_rank_overwrite"
	require "client.scene_rank_ui_helper"
else
	require "server.redis_handler_rank_overwrite"
	require "server.async_process_rank_overwrite"
    require "server.player_rank_overwrite"
    require "server.lib_rank_overwrite"
    require "server.gm_rank_overwrite"
	require "server.packet_rank_overwrite"
	require "server.common"
end

---@type RankCommand
local RankCommand = T(Lib, "RankCommand")
---@type SceneRankUIHelper
local SceneRankUIHelper = T(Lib, "SceneRankUIHelper")

local handlers = {}

--玩家进入游戏
function handlers.ENTITY_ENTER(context)
	local entity = context.obj1
	if not entity.isPlayer then
		return
	end
	for rankType, info in pairs(World.cfg.rankSetting.ranks) do
		if info.loginUpdateScore then
			local key = Rank.getRankKey(rankType, entity:data("mainInfo").regionId or 0)
			entity:setRankKey({[rankType] = key})
			Rank.UserUpdateScore(entity.platformUserId, rankType)
			Rank.RequestUserRankInfo(entity.platformUserId, rankType, entity:data("mainInfo").regionId or 0, true)
		end
	end
end

function handlers.OnPlayerLogin(player)
	RankCommand:updateRoomRank(player,true)
end

function handlers.onPlayerLogout(player)
	RankCommand:updateRoomRank(player,false)
end

Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
	SceneRankUIHelper:openSceneRankUI(objID)
end)

Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
	SceneRankUIHelper:closeSceneRankUI(objID)
end)

--function handlers.PART_ENTER(context)
--	if not World.isClient then
--		return
--	end
--	--print("++++++++++++++++++++++PART_ENTER",context.obj1,context.obj1:getName())
--	if context.obj1:getName()=="rank_board" then
--		--print("++++++++++++++++++++++PART_ENTER rank_board",context.obj1)
--		SceneRankUIHelper:openSceneRankUI(context.obj1)
--	end
--end

--function handlers.PART_DESTORY(context)
--	if not World.isClient then
--		return
--	end
--	--print("-----------------------PART_DESTORY",context.part,context.part.runtimeId)
--	SceneRankUIHelper:closeSceneRankUI(context.part)
--end

--主动更新排行榜数据
function handlers.updateRedisRankData(userId, rankType)
	local player = Game.GetPlayerByUserId(userId)
	if player and player:isValid() then
		local regionId = player:data("mainInfo").regionId or 0
		Rank.RequestRankData(rankType, regionId)
	end
end

-- 外部调用更新玩家的排行榜分数
function handlers.updatePlayerRankData(rankType, userId, score)
	RankCommand.updateZScore(userId, rankType, score)
end

-- 外部调用获取玩家自己当前排行数据，用于上传给排行榜
function handlers.getMyNewRankScore(player, rankType)
	local scoreFuncName = World.cfg.rankSetting.ranks[rankType].scoreFuncName
	if player and player[scoreFuncName] then
		return player[scoreFuncName](player)
	end
end

return function(name, ...)
	if type(handlers[name]) ~= "function" then
		return
	end
	return handlers[name](...)
end