local GMItem = GM:createGMItem()

--GM.setItemsShowPriorityMap("g2069", 999)
---@type GenSkillFileHelper
local GenSkillFileHelper = T(Lib,"GenSkillFileHelper")

GMItem["g2069/生成技能和Missile"] = function()
    GenSkillFileHelper:GenSkillAndMissileFiles()
end

GMItem["g2069/生成buff"] = function()
    GenSkillFileHelper:GenSkillBuffFiles()
end

GMItem["角色通用/击杀奖励"] = function()
    Me:showKillReward(100, 100)
end

local guiMgr = L("guiMgr", GUIManager:Instance())
local function hitDownAni()
    local root = guiMgr:getRootWindow()
    local item = UI:openWidget("UI/main/gui/widget_hitdown_tips")
    root:addChild(item:getWindow())
    item:setLevel(5)
    print("root:getChildCount()",root:getChildCount())
end
GMItem["角色通用/hitDown效果"] = function()
    hitDownAni()
end

return GMItem
