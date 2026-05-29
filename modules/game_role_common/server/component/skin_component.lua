--- skin_component.lua
--- 装备组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@type SkinComponent
local SkinComponent = require "common.component.skin_component"
---@class SkinComponentServer : SkinComponent
local SkinComponentServer = class("SkinComponentServer", SkinComponent)

function SkinComponentServer:initialize(owner)
    SkinComponent.initialize(self, owner)
    --- 初始化数据
    local data = self.owner:data("skin") or {}
    local skins = Lib.copy(data)
    self.skins[Define.SKIN_LAYER.ORIGINAL] = skins
    if data.exclusive_parts then
        self.exclusiveSkins = Lib.copy(data.exclusive_parts)
    end
    --- 同步初始皮肤数据
    self.owner:setOriginSkins(skins)
    --- 缓存数据
    self.dirtySkins = nil
end

--- 修改装备
---@param layer number 层级，1为原始装备，2为能力装备，3为buff装备
---@param part any
---@param skin any
function SkinComponentServer:changeSkinPart(layer, part, skin)
    --- 不允许修改
    if layer == Define.SKIN_LAYER.ORIGINAL then
        return
    end
    self:dirtyMark(layer)
    SkinComponent.changeSkinPart(self, layer, part, skin)
    if self:isDirty() then
        self:changeGameSkin()
    end
    self:dirtyRelease()
end

--- 修改皮肤
---@param layer number 层级，1为原始装备，2为能力装备，3为buff装备
---@param skinData table 皮肤数据
function SkinComponentServer:changeSkin(layer, skinData)
    --- 不允许修改
    if layer == Define.SKIN_LAYER.ORIGINAL then
        return
    end
    self:dirtyMark(layer)
    SkinComponent.changeSkin(self, layer, skinData)
    if self:isDirty() then
        self:changeGameSkin()
    end
    self:dirtyRelease()
end

--- 设置层级数据
---@param layer any
---@param value any
function SkinComponentServer:setLayerSkin(layer, value)
    self:dirtyMark(layer)
    SkinComponent.setLayerSkin(self, layer, value or {})
    if self:isDirty() then
        self:changeGameSkin()
    end
    self:dirtyRelease()
end

--- 更新皮肤
function SkinComponentServer:changeGameSkin()
    --- 合并数据
    local mergeSkinData = self:getMergeSkinData()
    self.owner:changeSkinPart(mergeSkinData)
end

--- 合并数据
function SkinComponentServer:getMergeSkinData()
    local mergeSkinData = {}
    local count = Define.SKIN_LAYER.COUNT
    for layer = count, Define.SKIN_LAYER.ABILITY, -1 do
        local skins = self:getLayerSkin(layer) or {}
        for k, v in pairs(skins) do
            if not mergeSkinData[k] then
                mergeSkinData[k] = v
            end
        end
    end
    return mergeSkinData
end

--- 标记dirty
---@param layer number
function SkinComponentServer:dirtyMark(layer)
    local skins = self:getLayerSkin(layer)
    self.dirtySkins = {}
    self.dirtySkins[layer] = Lib.copy(skins)
end

--- 释放dirty
function SkinComponentServer:dirtyRelease()
    self.dirtySkins = nil
end

--- 判断是否脏数据
function SkinComponentServer:isDirty()
    local dirty = false
    if self.dirtySkins then
        local layer, skins = next(self.dirtySkins)
        if layer == Define.SKIN_LAYER.BUFF then
            local curSkins = self:getLayerSkin(layer) or {}
            local len1 = Lib.getTableSize(skins)
            local len2 = Lib.getTableSize(curSkins)
            --- 数量不同必定需要同步
            if len1 ~= len2 then
                dirty = true
            else
                --- 只要有不同的key，就需要同步
                for k, v in pairs(skins) do
                    if not curSkins[k] or curSkins[k] ~= v then
                        dirty = true
                        break
                    end
                end
            end
        elseif layer == Define.SKIN_LAYER.ABILITY then
            --- 只能查找不同的key
            local buffSkins = self:getLayerSkin(Define.SKIN_LAYER.BUFF) or {}
            local curSkins = self:getLayerSkin(layer) or {}
            for k, v in pairs(skins) do
                if buffSkins[k] then
                    --- 存在覆盖关系，不处理

                else
                    --- 只有不相同的
                    if not curSkins[k] or curSkins[k] ~= v then
                        dirty = true
                        break
                    end
                end
            end
        end
    end
    return dirty
end

return SkinComponentServer