
---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
local engineOpenWindow = UI.openWindow
local engineCloseWindow = UI.closeWindow
---@param root table
---@param root table
---@param isIn boolean
local function transitionAnimation(root,mainWnd,isIn,...)
    local IN_OFFSET = 1400
    local IN_WAIT =2
    local OUT_OFFSET= 1400
    local IN_DURATION = 1.2
    local OUT_DURATION= 0.4
    if not mainWnd then
        return
    end
    local initPos = mainWnd:getPosition()
    local moveTimer = nil
    if isIn then
        mainWnd:setPosition(UDim2.new(initPos[1][1], initPos[1][2]-IN_OFFSET, initPos[2][1], initPos[2][2]))
        UI.doTrans(mainWnd,{x=initPos[1], y=initPos[2] },IN_DURATION)
        -- moveTimer = LuaTimer:scheduleTicker(function(...)
        --     UI.doTrans(mainWnd,{x=initPos[1], y=initPos[2] },IN_DURATION)
        --     LuaTimer:cancel(moveTimer)
        --     moveTimer = nil
		-- end, math.floor(IN_WAIT))
        
    else
        local operator = UI.doTrans(mainWnd,{x={initPos[1][1],initPos[1][2]+OUT_OFFSET}  ,y=initPos[2]},OUT_DURATION)
        operator:onFinish(function(...)
            engineCloseWindow(UI,root,...)
        end)
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