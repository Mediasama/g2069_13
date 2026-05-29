---@class GenSkillFileHelper
local GenSkillFileHelper = T(Lib,"GenSkillFileHelper")
---@type SkillMovesConfig
local SkillMovesConfig = T(Config, "SkillMovesConfig")
---@type SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")

local Platform = require "common.platform"
local setting = require("common.setting")
require "lfs"


local function ClearFolder(directory)
    --os.execute("del "..directory.."/q")
    Lib.rmdir(directory)
end

local function CreateFolder(path)
    Lib.mkPath(path)
end

local function GetSkillDirectoryPath()
    return Root.Instance():getGamePath() .. "plugin/myplugin/skill/" .. Define.GenSkillFolder
end

local function GetMissileDirectoryPath()
    return Root.Instance():getGamePath() .. "plugin/myplugin/missile/" .. Define.GenMissileFolder
end

local function GetBuffDirectoryPath()
    return Root.Instance():getGamePath() .. "plugin/myplugin/buff/" .. Define.GenBuffFolder
end

local function GetHitEffectBuffDirectoryPath()
    return Root.Instance():getGamePath() .. "plugin/myplugin/buff/" .. Define.GenHitEffectBuffFolder
end

local function GenFile(path,jsonTable)
    --print(">>>>>>>>>>>>>>>>>>> GenFile",Lib.v2s(jsonTable))
    CreateFolder(path)
    local jsonStr = Lib.toJson(jsonTable)
    local f = io.open(path .. "/setting.json","w")
    if f then
        f:write(jsonStr)
    end
    f:close()
end

function GenSkillFileHelper:GenSkillAndMissileFiles()
    if not CGame.Instance():isDebuging() or not Root.platform() == Platform.WINDOWS  then
        return
    end

    ---@type SoundConfig
    local SoundConfig = T(Config, "SoundConfig")
    SoundConfig:init()
    SkillMovesConfig:initNewCfg()

    local skillDirectory = GetSkillDirectoryPath()
    ClearFolder(skillDirectory)
    CreateFolder(skillDirectory)
    local missileDirectory = GetMissileDirectoryPath()
    ClearFolder(missileDirectory)
    CreateFolder(missileDirectory)

    local hitEffectBuffDirectory = GetHitEffectBuffDirectoryPath()
    ClearFolder(hitEffectBuffDirectory)
    CreateFolder(hitEffectBuffDirectory)

    local skillList = SkillMovesConfig.getAllNewSkillConfig()
    for _,v in pairs(skillList) do
        if v.skillId ~= 0 then
            GenFile(skillDirectory .. "/"..Define.GenSkillPrefix..tostring(v.skillId) ,v.skillInf)
            if v.skillInf.missileCfg then
                GenFile(missileDirectory .. "/"..Define.GenMissilePrefix..tostring(v.skillId) ,v.missileInf)
                if v.genDefaultDamageSkill then
                    GenFile(skillDirectory .. "/"..Define.GenDefaultDamageSkillPrefix..tostring(v.skillId) ,
                            SkillMovesConfig:getDefaultDamageSkillTable(v))
                end
            end
            if v.hitEntityEffectCustomName then
                GenFile(hitEffectBuffDirectory .. "/"..v.hitEntityEffectCustomName ,v.hitEntityEffectCustom)
            end
        end
    end

    setting:reload()
    Me:sendPacket({pid = "C2SReloadSetting"})
    print("++++++++++++++++++++++++++++  GenSkillAndMissileFiles  success!")
end

function GenSkillFileHelper:GenSkillBuffFiles()
    if not CGame.Instance():isDebuging() or not Root.platform() == Platform.WINDOWS  then
        return
    end

    local buffDirectory = GetBuffDirectoryPath()
    ClearFolder(buffDirectory)
    CreateFolder(buffDirectory)

    SkillBuffConfig:init()

    local buffList = SkillBuffConfig:getAllCfgs()
    for buffId,v in pairs(buffList) do
        GenFile(buffDirectory .. "/"..Define.GenBuffPrefix..tostring(v.buffId) ,v)
    end

    setting:reload()
    Me:sendPacket({pid = "C2SReloadSetting"})
    print("++++++++++++++++++++++++++++  GenSkillBuffFiles  success!")
end