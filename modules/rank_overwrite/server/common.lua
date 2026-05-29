---@class RankCommand
local RankCommand = T(Lib, "RankCommand")

---@type RedisHandlerRank
local RedisHandlerRank = T(Lib, "RedisHandlerRank")
---@type AbilitySystem
local AbilitySystem = T(Lib, "AbilitySystem")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

function RankCommand.getRankData(userId, rankType, pageNo, immediately)
    local player = Game.GetPlayerByUserId(userId)
    local regionId = player:data("mainInfo").regionId or 0
    if immediately then
        Rank.UpdateRankDataImmediately(userId, rankType, regionId,pageNo)
    else
        Rank.RequestAllRankInfo(rankType, regionId, userId, pageNo)
    end
end

--向客户端发SingleRank的包，有userId, score, rank
function RankCommand.getSingleRank(userId, rankType, immediately)
    local player = Game.GetPlayerByUserId(userId)
    local regionId = player:data("mainInfo").regionId or 0
    Rank.RequestUserRankInfo(userId, rankType, regionId, immediately)
end

--更新用户数据到排行榜
function RankCommand.updateZScore(userId, rankType,score)
    Rank.UserUpdateScore(userId, rankType, score)
    --实时更新
    RedisHandlerRank:trySendZIncBy(true)
end

function RankCommand:getRoomRankList()
    -----@type GrowthSystem
    --local GrowthSystem = T(Lib, "GrowthSystem")
    --self.roomRankData={}
    --local playerList=Game.GetAllPlayers()
    --for _, player in pairs(playerList) do
    --    if player and player:isValid() then
    --        local rank = {
    --            userId = player.platformUserId,
    --            score = tonumber(player:getDangerValue()),
    --            vip = 0,
    --            nickName = player:getName(),
    --            picUrl = "",
    --            level = GrowthSystem:getLevel(player)
    --        }
    --        table.insert(self.roomRankData,rank)
    --    end
    --end
    --table.sort(self.roomRankData,function (a,b)
    --    return a.score>b.score
    --end)
    --for k, v in pairs(self.roomRankData) do
    --    v.rank=k
    --end
    ----print("------------------ RankCommand:getRoomRankList",Lib.v2s(self.roomRankData))
    --return self.roomRankData
end

function RankCommand:getRoomSingleRank(player)
    --if  not self.roomRankData or not  player then
    --    return nil
    --end
    ----print("------------------ RankCommand:getRoomSingleRank",Lib.v2s(self.roomRankData))
    --for _, v in pairs(self.roomRankData) do
    --    if v.userId == player.platformUserId then
    --        return v
    --    end
    --end
end

function RankCommand:updateRoomRank(player,isLogIn)
    if not player or not player:isValid() then
        return
    end
    if not self.roomRankList then
        ---@type PlayerRankDataItem[]
        self.roomRankList={}
    end
    
    local top3Changed=false
    if isLogIn then
        local rankItem=self:getPlayerRankDataItem(player)
        if not rankItem then
            return
        end
        table.insert(self.roomRankList,rankItem)
        self:sortRoomRankList()
        if rankItem.rank<=3 then
            top3Changed=true
        end
       --print("+++++++++++++++++++++RankCommand:updateRoomRank,log in",player.platformUserId,rankItem.rank,top3Changed)
    else
        local playerIndex=#self.roomRankList
        for i, v in pairs(self.roomRankList) do
            if v.userId==player.platformUserId then
                table.remove(self.roomRankList,i)
                playerIndex=i
                break
            end
        end
        if playerIndex<=3 then
            top3Changed=true
        end
        --print("---------------------RankCommand:updateRoomRank,log out",player.platformUserId,playerIndex,top3Changed)
    end

    if top3Changed then
        local tops3List=self:getRoomRankListTop3()
        if tops3List and next(tops3List)~=nil then
            --print("---------------------RankCommand:updateRoomRank,BroadcastPacket",#tops3List)
            self:syncTop3Data(tops3List)
        end
    end
end

function RankCommand:sortRoomRankList()
    if not self.roomRankList or next(self.roomRankList) == nil then
        return
    end
    table.sort(self.roomRankList,function (a,b)
        return a.score>b.score
    end)
    for k, v in pairs(self.roomRankList) do
        v.rank=k
    end
end

---@return PlayerRankDataItem
function RankCommand:getPlayerRankDataItem(player)
    if not player or not player:isValid() then
        return nil
    end
    local GrowthSystem = T(Lib, "GrowthSystem")
    ---@class PlayerRankDataItem
    local rank = {
        userId = player.platformUserId,
        score = tonumber(player:getDangerValue()),
        vip = 0,
        nickName = player:getName(),
        picUrl = "",
        level = GrowthSystem:getLevel(player),
        rank=0
    }
    return rank
end

---@return PlayerRankDataItem[]
function RankCommand:getRoomRankListTop3()
    if not self.roomRankList then
        return nil
    end
    local listTop3={}
    table.move(self.roomRankList,1,3,1,listTop3)
    --print("=================================RankCommand:getRoomRankListTop3",Lib.v2s(self.roomRankList),Lib.v2s(listTop3))
    return listTop3
end

function RankCommand:updateRoomRankValueChanged(playerList)
    if not playerList or next(playerList)==nil or not self.roomRankList then
        return
    end
    for _, playerId in pairs(playerList) do
        local player=Game.GetPlayerByUserId(playerId)
        if player and player:isValid() then
            for k, v in pairs(self.roomRankList) do
                if player.platformUserId == v.userId then
                    v.score=tonumber(player:getDangerValue())
                    print("+++++++++++++++++++++++ new score",v.score,v.userId)
                    break
                end
            end
        end
    end
    local top3=self:getRoomRankListTop3()
    self:sortRoomRankList()
    local top3New=self:getRoomRankListTop3()
    if top3New and top3 and #top3==#top3New and next(top3New)~=nil then
        for i = 1, #top3New do
            if top3New[i].userId ~=top3[i].userId then
                self:syncTop3Data(top3New)
                break
            end
        end
    end
end

function RankCommand:updateRoomRankSkinChanged(userId)
    if not self.roomRankList then
        return
    end

    local top3=self:getRoomRankListTop3()
    for i = 1, #top3 do
        if top3[i].userId == userId then
            self:syncTop3Data(top3)
            break
        end
    end
end

Lib.subscribeEvent(Event.EVENT_GAME_ROLE_DANGER_VALUE_CHANGE,function (playerList)
    --print("+++++++++++++++++++++++++Event.EVENT_GAME_ROLE_DANGER_VALUE_CHANGE")
    RankCommand:updateRoomRankValueChanged(playerList)
end)

Lib.subscribeEvent(Event.EVENT_ENTITY_SKIN_INFO_UPDATE,function (userId)
    RankCommand:updateRoomRankSkinChanged(userId)
end)

function RankCommand:syncTop3Data(top3Data)
    if not top3Data then
        return
    end

    for i, data in pairs(top3Data) do
        local player = Game.GetPlayerByUserId(data.userId)
        if player and player:isValid() then

            local abilityId = AbilitySystem:getAbilitySkin(player)
            if not abilityId then
                local ability = AbilitySystem:getAbility(player)
                abilityId = ability:getAwakeAbilityId()
            end
            local config = AbilityConfig:getCfgByAbilityId(abilityId)
            if config then
                data.idleAction = config.idleAction
            end

            local skin=player:data("skin")
            local sex=player:data("main").sex
            data.skin=skin
            data.sex=sex
        end
    end
    --print(">>>>>>>>>>>>>>> syncTop3Data",Lib.v2s(top3Data))
    WorldServer.BroadcastPacket({
        pid = "S2CUpdateSceneRankUI",
        rankList = top3Data,
    })
end


