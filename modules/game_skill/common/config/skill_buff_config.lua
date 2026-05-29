---@class SkillBuffConfig
local SkillBuffConfig = T(Config, "SkillBuffConfig")

local notStringNullOrEmpty = function(str)
    if str and str ~= "" then
        return true
    end
    return false
end

local settings = {}
local flyBuff={}

function SkillBuffConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skill_buff.csv", 2)
    for _, vConfig in pairs(config) do

        local cfg = {
            id = tonumber(vConfig.n_id) or 0,
            buffId = tonumber(vConfig.n_buffId) or 0,
            g = vConfig.tag or "",
            name = notStringNullOrEmpty(vConfig.s_name) and vConfig.s_name or nil,
            icon = notStringNullOrEmpty(vConfig.s_icon) and vConfig.s_icon or nil,
            duration = tonumber(vConfig.n_duration),
            location = tonumber(vConfig.n_location),
            interval = tonumber(vConfig.n_interval),
            buffEffect = vConfig.s_buffEffect or "",
            buffEffectPos = vConfig.s_buffEffectPos or "",
            buffScale = tonumber(vConfig.n_buffScale) or 1,
            dizziness = tonumber(vConfig.n_dizziness),
            knockDown = tonumber(vConfig.n_knockDown),
            knockDownTime = tonumber(vConfig.n_knockDownTime) or 1,
            expRate = tonumber(vConfig.n_expRate),
            apRate = tonumber(vConfig.n_apRate),
            addHp = tonumber(vConfig.n_addHp),
            addHpPct = tonumber(vConfig.n_addHpPct),
            addMp = tonumber(vConfig.n_addMp),
            addMpPct = tonumber(vConfig.n_addMpPct),
            maxHpPct = tonumber(vConfig.n_maxHpPct),
            hpRegen = tonumber(vConfig.n_hpRegen),
            attDamagePct = tonumber(vConfig.n_attDamagePct),
            eleDamagePct = tonumber(vConfig.n_eleDamagePct),
            defDamagePct = tonumber(vConfig.n_defDamagePct),
            maxMpPct = tonumber(vConfig.n_maxMpPct),
            mpRegen = tonumber(vConfig.n_mpRegen),
            moveSpeedPct = tonumber(vConfig.n_moveSpeedPct),
            jumpSpeedPct = tonumber(vConfig.n_jumpSpeedPct),
            attCrit = tonumber(vConfig.n_attCrit),
            attCritDmg = tonumber(vConfig.n_attCritDmg),
            skillSpeedUp = tonumber(vConfig.n_skillSpeedUp),
            defDodge = tonumber(vConfig.n_defDodge),
            defToughPct = tonumber(vConfig.n_defToughPct),
            partChange = vConfig.s_partChange or "",
            deadRemove = tonumber(vConfig.n_deadRemove) or 1,
            avoidBuff = vConfig.s_avoidBuff or "",
            removeBuff = vConfig.s_removeBuff or "",
            actionMap1 = vConfig.s_actionMap1 or "",
            actionMap2 = vConfig.s_actionMap2 or "",
            flyMode = tonumber(vConfig.n_flyMode),
            resetSkill = vConfig.s_resetSkill or "",
            childActor = vConfig.s_childActor or "",
            fixTime = notStringNullOrEmpty(vConfig.s_fixTime) and vConfig.s_fixTime or nil,
            appendTime = tonumber(vConfig.n_appendTime),
            buffSoundKey = vConfig.s_buffSoundKey or "",
            casterLevelScale = vConfig.s_casterLevelScale or "",
            needSave = tonumber(vConfig.n_needSave) or 0,
        }

        local data = {
            icon = cfg.icon,
            name = cfg.name,
            buffId = cfg.buffId,
            addHpPct = cfg.addHpPct,
            addMpPct = cfg.addMpPct,
            addHp = cfg.addHp,
            addMp = cfg.addMp,
            interval = cfg.interval,
            duration = cfg.duration,
            deadRemove = cfg.deadRemove and cfg.deadRemove > 0 or false,
            partChange = cfg.partChange ~= "" and cfg.partChange or nil,
            fixTime = cfg.fixTime,
            appendTime = cfg.appendTime,
            location = cfg.location,
            needSave = cfg.needSave == 1,
        }

        data.buffName = self:getBuffName(data.buffId)

        if notStringNullOrEmpty(cfg.casterLevelScale) then
            local casterLevelScale = {}
            data.casterLevelScale = casterLevelScale
            local list1 = Lib.splitString(cfg.casterLevelScale, ",")
            for _, v in pairs(list1) do
                casterLevelScale[#casterLevelScale + 1] = Lib.splitString(v, "#", true)
            end
        end
        
        --- 晕眩
        if cfg.dizziness and cfg.dizziness > 0 then
            data.dizziness = true
        end
        if cfg.knockDown and cfg.knockDown > 0 then
            data.knockDown = true
            data.knockDownTime = cfg.knockDownTime
        end

        -- 特效
        if cfg.buffEffect ~= "" then
            data.effect = {}
            data.effect.effect = cfg.buffEffect
            data.effect.once = true
            local pos = Lib.splitString(cfg.buffEffectPos, "#", true)
            data.effect.pos = {
                x = pos[1] or 0,
                y = pos[2] or 0,
                z = pos[3] or 0
            }
            data.effect.scale = {
                x = cfg.buffScale or 1,
                y = cfg.buffScale or 1,
                z = cfg.buffScale or 1
            }
        end
        --- 属性处理
        for _, id in pairs(Define.ATTR) do
            local addValue = cfg[id]
            local pctValue = cfg[id .. "Pct"]
            if addValue and addValue ~= 0 then
                if not data.attribute then
                    data.attribute = {}
                end
                data.attribute[id] = addValue
            end

            if pctValue and pctValue ~= 0 then
                if not data.attribute_pct then
                    data.attribute_pct = {}
                end
                data.attribute_pct[id] = pctValue
            end
        end

        if cfg.avoidBuff ~= "" then
            local buffList = Lib.splitString(cfg.avoidBuff, "#", true)
            for _, id in pairs(buffList) do
                if not data.avoidBuff then
                    data.avoidBuff = {}
                end
                table.insert(data.avoidBuff, self:getBuffName(id))
            end
        end

        if cfg.removeBuff ~= "" then
            local buffList = Lib.splitString(cfg.removeBuff, "#", true)
            for _, id in pairs(buffList) do
                if not data.removeBuff then
                    data.removeBuff = {}
                end
                table.insert(data.removeBuff, self:getBuffName(id))
            end
        end

        if cfg.actionMap1 ~= "" and cfg.actionMap2 ~= "" then
            local action1 = Lib.splitString(cfg.actionMap1, "#")
            local action2 = Lib.splitString(cfg.actionMap2, "#")
            for key, val in pairs(action1) do
                if not data.actionMap then
                    data.actionMap = {}
                end
                data.actionMap[val] = action2[key]
            end
        end

        if cfg.buffSoundKey and cfg.buffSoundKey ~= "" then
            data.buffSoundKey = cfg.buffSoundKey
        end

        if cfg.flyMode and cfg.flyMode > 0 then
            data.flyMode = true
            data.actionPriority = 9999
        end

        if cfg.skillSpeedUp then
            data.skillSpeedUp = cfg.skillSpeedUp / 100
        end

        if cfg.resetSkill ~= "" then
            local resetSkill = {}
            resetSkill.slotList={}
            resetSkill.skillList={}
            local result=Lib.splitString(cfg.resetSkill, "#")
            for _, v in pairs(result) do
                local skillData=Lib.splitString(v, ",",true)
                if skillData[1] and skillData[2] then
                    table.insert(resetSkill.slotList,skillData[1])
                    table.insert(resetSkill.skillList,skillData[2])
                end
            end
            if next(resetSkill.slotList) ~= nil then
                data.resetSkill = resetSkill
            end
        end
        if cfg.childActor ~= "" then
            local childActor = {}
            local result=Lib.splitString(cfg.childActor, "#")
            local posData=Lib.splitString(result[2] or "", ",",true)
            childActor.actorName=result[1]
            childActor.pos={}
            childActor.pos.x=posData[1] or 0
            childActor.pos.y=posData[2] or 0
            childActor.pos.z=posData[3] or 0
            childActor.scale=result[3] or 1
            if childActor.actorName and string.match(childActor.actorName,"%.actor") then
                data.childActor= childActor
            end
        end
        settings[data.buffId] = data
        if data.flyMode then
            flyBuff[data.buffId]=data
        end
    end
end

function SkillBuffConfig:getCfgByBuffId(buffId)
    if not settings[buffId] then
        Lib.logError("Error:Not found the data in skill_buff.csv, buff id:", buffId)
    end
    return settings[buffId]
end

function SkillBuffConfig:getBuffName(buffId)
    return "myplugin/"..Define.GenBuffFolder.."/"..Define.GenBuffPrefix..tostring(buffId)
end

function SkillBuffConfig:getAllCfgs()
    return settings
end

function SkillBuffConfig:getAllFlyBuffCfgs()
    return flyBuff
end

SkillBuffConfig:init()

return SkillBuffConfig

