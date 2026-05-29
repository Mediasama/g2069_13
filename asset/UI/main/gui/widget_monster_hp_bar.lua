---@class WidgetMonsterHpBarWidget : CEGUILayout
local WidgetMonsterHpBarWidget = M

---@type AttributeSystem
local AttributeSystem = T(Lib, "AttributeSystem")
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")

---@private
function WidgetMonsterHpBarWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetMonsterHpBarWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siBg = self.Bg
	---@type CEGUIStaticImage
	self.siFront = self.Front
end

---@private
function WidgetMonsterHpBarWidget:initUI()
	self.events = {}
end

---@private
function WidgetMonsterHpBarWidget:initEvent()
	self.events[#self.events + 1] = Lib.subscribeEvent(Event.EVENT_GAME_ROLE_COMMON_UPDATE_MONSTER_HP, function(objId, value)
		if objId and self.entityObjID == objId then
			self:updateHpShow(value)
		end
	end)
end

function WidgetMonsterHpBarWidget:updateMaxHp(value, entity)
	self.maxHp = value
	self.curHp = entity:getCurHp()
	self:updateHpShow(self.curHp)
end

function WidgetMonsterHpBarWidget:initData(entity)
	local maxHp = entity:prop("maxHp") or 100
	self.curHp = entity:getCurHp()
	self.entityObjID = entity.objID
	self.maxHp = maxHp
	self:updateMaxHp(maxHp, entity)
end

--- 刷新进度条
function WidgetMonsterHpBarWidget:updateHpShow(curHp)
	self.curHp = curHp
	local progress = math.clamp(self.curHp / self.maxHp, 0, 1)
	self.Front:setProperty("FillArea", tostring(progress))
end

---@private
function WidgetMonsterHpBarWidget:onOpen()
	self.infoTimer = LuaTimer:scheduleTicker(function()
		local sceneUIId = self.__sceneUIID
		local sceneUIObj = Instance.getByRuntimeId(sceneUIId)
		if not sceneUIObj or not sceneUIObj:isValid() then
			return
		end
		if sceneUIObj.parentEntityObjID then
			local entity = World.CurWorld:getEntity(sceneUIObj.parentEntityObjID)
			if entity and entity:isValid() then
				self:initData(entity)
				if self.infoTimer then
					LuaTimer:cancel(self.infoTimer)
					self.infoTimer = nil
				end
				return
			end
		end
	end, 10, 10)
end

---@private
function WidgetMonsterHpBarWidget:onDestroy()
	if self.events then
		for _, func in pairs(self.events) do
			func()
		end
		self.events = {}
	end

	if self.infoTimer then
		LuaTimer:cancel(self.infoTimer)
		self.infoTimer = nil
	end
end

WidgetMonsterHpBarWidget:init()
