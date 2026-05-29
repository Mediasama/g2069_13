local ValueDef = T(Entity, "ValueDef")
-- key				            = {isCpp,	client,	toSelf,	toOther,	init,   saveDB}
--ValueDef.xxx 					= {false,   false,  true,   false,      0,      true  }
ValueDef.RankKeyList 			= {false,   false,  true,   false,     {},      false }

local Entity = Entity

function Entity:getRankKey(rankType)
    if rankType == nil then
        return
    end
    local keyList = self:getRankKeyList()
    return keyList[rankType]
end

function Entity:getRankKeyList()
    return self:getValue("RankKeyList")
end

function Entity:setRankKey(RankKey)
    local keyList = self:getRankKeyList()
    if type(keyList) ~= "table" then
        keyList = {}
    end
    for rankType,key in pairs(RankKey) do
        keyList[rankType] = key
    end
    self:setValue("RankKeyList",keyList)
end