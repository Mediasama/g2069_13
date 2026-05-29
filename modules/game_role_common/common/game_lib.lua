---@class GameLib
local GameLib = T(Lib, "GameLib")

--- 浮点数精度既定常数
local e = 1e-9

--- 四舍五入
---@param num number
function GameLib.round(num)
    if num < 0 then
        return math.ceil(num - 0.5)
    else
        return math.floor(num + 0.5)
    end
end

--- 保留小数位
---@param num number 数值
---@param keepNum number 保留位
function GameLib.keepPreciseDecimal(num, keepNum)
    keepNum = keepNum or 0;
    local nDecimal = 10 ^ keepNum
    local nTemp = math.floor((num + e) * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

--- 格式化UI显示浮点数，将形如120.0转为120
---@param num number
---@return string 格式化字符串
function GameLib.formatUINumber(num)
    local str = tostring(num)
	local startIndex = string.find(str, "%.")
	if startIndex and startIndex > 0 then
		local index = nil
		local len = #str
		for i = len, startIndex, -1 do
			if i ~= startIndex then
				local idx = string.find(str, "0", i)
				if not idx then
					break
				end
				index = idx
			else
				index = i
			end
		end
		if index and index > 1 then
			str = string.sub(str, 1, index - 1)
		end
	end
	return str
end

local day = 3600 * 24
local hour = 3600
local min = 60

--- 格式化时间
---@param second any
---@param dayText any
---@param hourText any
---@param minText any
---@param secText any
function GameLib.formatLeftTime(second, dayText, hourText, minText, secText)
	dayText = dayText or "d"
	hourText = hourText or "h"
	minText = minText or "m"
	secText = secText or "s"
	local text = ""
	if second >= day then
		local timeDay = math.floor(second / day)
		second = second - timeDay * day
		text = text .. tostring(timeDay) .. dayText
	end
	if second >= hour then
		local timeHour = math.floor(second / hour)
		second = second - timeHour * hour
		text = text .. tostring(timeHour) .. hourText
	end
	if second >= min then
		local timeMin = math.floor(second / min)
		second = second - timeMin * min
		text = text .. tostring(timeMin) .. minText
	end
	text = text .. tostring(second) .. secText
	return text
end

return GameLib