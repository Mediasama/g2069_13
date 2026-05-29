
local Instance = Instance

---@type MonsterRegionConfig
local MonsterRegionConfig = T(Config, "MonsterRegionConfig")

--function Instance:loadTriggerOnCreate(extendCfg, properties)
--	--local monsterRegion = MonsterRegionConfig:getCfgById(properties.name)
--	--if monsterRegion then
--	--	return self:loadPartCollisionEvent(extendCfg, properties)
--	--end
--
--	if TaskConfig:checkIsTaskRegionPart(properties.name) then
--		return self:loadPartCollisionEvent(extendCfg, properties)
--	end
--	if extendCfg.triggers then
--		return self:loadTriggerByExtendCfg(extendCfg)
--	end
--	return self:loadTrigger(properties.btsKey, true)
--end
--
--function Instance:loadPartCollisionEvent(extendCfg, properties)
--	return self:loadTriggerByExtendCfg({triggers = {
--		"PART_TOUCH_ENTITY_BEGIN",
--		"PART_TOUCH_ENTITY_END"
--	}})
--end

function Instance:onCreated(params, map)
	local properties = params.properties
	if World.isClient then

	else
		local monsterRegion = MonsterRegionConfig:getCfgById(properties.name)
		if monsterRegion then
			Plugins.CallTargetPluginFunc("monster_manager", "monsterRegionInit", properties.id, map)
		end
	end
end

RETURN()