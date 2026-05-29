---@type LuaTimer
local LuaTimer = T(Lib, "LuaTimer")
---@class WinSceneWelcomeLayout : CEGUILayout
local WinSceneWelcomeLayout = M
---@type MonsterConfig
local MonsterConfig = T(Config, "MonsterConfig")

---@private
function WinSceneWelcomeLayout:init()
    self:findAllWindow()
    self:initUI()
    self:initEvent()
end

---@private
function WinSceneWelcomeLayout:findAllWindow()
    ---@type CEGUIDefaultWindow
    self.wPos = self.pos
    ---@type CEGUIStaticImage
    self.siPosImage = self.pos.Image
    ---@type CEGUIStaticText
    self.stPosMapTitle = self.pos.mapTitle
    ---@type CEGUIStaticText
    self.stPosMapInfo = self.pos.mapInfo
end

---@private
function WinSceneWelcomeLayout:initUI()
    self.stPosMapTitle:setText(Lang:toText(""))
    self.stPosMapInfo:setText(Lang:toText(""))
end

---@private
function WinSceneWelcomeLayout:initEvent()
end

local function getEnemyStr(info)
    local str = ""
    if type(info) == "number" then
        return info
    end
    for _, monsterId in pairs(info) do
        local monster = MonsterConfig:getCfgByMonsterId(tonumber(monsterId))
        str =str.." ".. Lang:toText(monster.monsterName).."(Lv."..monster.monsterLevel..")"
    end
    return str
end
local function getGotoMapStr(info)
    local str = ""
    if type(info) == "string" then
        return info
    end
    for _, mapLang in pairs(info) do
        str =str.." ".. Lang:toText(mapLang)
    end
    return str
end
---@private
function WinSceneWelcomeLayout:onOpen(data)
    if data then
        self.lock = true
        self.lock2 = true
        local moveTimer = nil
        Me:playMovieByXML(data.camera_path,function()
            self.lock2 = false
        end)
        local initPos = self.wPos:getPosition()
        self.wPos:setPosition(UDim2.new(initPos[1][1], initPos[1][2]-400, initPos[2][1], initPos[2][2]))
        local operator = UI.doTrans(self.wPos,{x={initPos[1][1],initPos[1][2]}  ,y=initPos[2]},2)
        operator:onFinish(function()
            local name = Lang:toText(data.name)
            local operator2 = UI.doText(self.stPosMapTitle, name, 2)
            operator2:onFinish(function()
                local info = ""
                if data.enemy then
                    info = Lang:toText({"g2069_map_welcome_tip1",getEnemyStr(data.enemy)})
                end
                if data.gotoMap then
                    info = info.."\n"..Lang:toText({"g2069_map_welcome_tip2",getGotoMapStr(data.gotoMap)})
                end
                local operator3 = UI.doText(self.stPosMapInfo,info,2)
                operator3:onFinish(function()
                    self.lock = false

                end)

            end)
        end)
        moveTimer = LuaTimer:scheduleTicker(function()
            if self.lock or self.lock2 then
                return true
            end
            UI:closeWindow(self)
            if data.reShow then
                data.reShow()
            end
            LuaTimer:cancel(moveTimer)
            moveTimer = nil
        end,20)
    end

end

---@private
function WinSceneWelcomeLayout:onDestroy()

end

---@private
function WinSceneWelcomeLayout:onClose()

end

WinSceneWelcomeLayout:init()
