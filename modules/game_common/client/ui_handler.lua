
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
local engineOpenWindow = UI.openWindow
local engineCloseWindow = UI.closeWindow
---@param root table
---@param root table
---@param isIn boolean
local function transitionAnimation(root,mainWnd,isIn,...)
    if not isIn then
        engineCloseWindow(UI,root,...)
    end
end
local WinBase = WinBase ---@class WinBase
function WinBase:setTransitionAnimation(item)
    self.mainAniWnd = item
end
---@return CEGUILayout
function UI:openWindow(windowName, instanceName, resGroup, ...)
    local instance,has = engineOpenWindow(UI,windowName, instanceName, resGroup, ...)
    if instance and instance.mainAniWnd then
        transitionAnimation(instance,instance.mainAniWnd,true,...)
    end 
    return instance,has
end

local windowOpenParamsMap = T(UI, "windowOpenParamsMap")
function UI:closeWindow(instanceOrName, ...)
	local instance
	if type(instanceOrName) == "table" then
		instance = instanceOrName
	elseif type(instanceOrName) == "string" then
		-- engineCloseWindow(UI,instanceOrName,...)
        -- return
        instance = UI:isOpenWindow(instanceOrName)
		for k,v in ipairs(windowOpenParamsMap) do
			local name = v[2] or v[1]
			if name == instanceOrName then
				table.remove(windowOpenParamsMap,k)
				break
			end
		end
	end

	if not instance then
		return
	end
    if instance.mainAniWnd then
        transitionAnimation(instance,instance.mainAniWnd,false,...)
    else
        engineCloseWindow(UI,instance,...)
	end
end