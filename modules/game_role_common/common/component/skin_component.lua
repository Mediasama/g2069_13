--- skin_component.lua
--- 装备组件
---@type middleclass
local class = require "common.3rd.middleclass.middleclass"
---@class SkinComponent : middleclass
local SkinComponent = class("SkinComponent")

function SkinComponent:initialize(owner)
    self.owner = owner
    self.skins = {}
    --- 平台冲突数据，只保存初始数据
    self.exclusiveSkins = {}
    
    self.skins[Define.SKIN_LAYER.ORIGINAL] = {}
    self.skins[Define.SKIN_LAYER.ABILITY] = {}
    self.skins[Define.SKIN_LAYER.BUFF] = {}
end

--- 修改装备
---@param layer number 层级，1为原始装备，2为能力装备，3为buff装备
---@param part any
---@param skin any
function SkinComponent:changeSkinPart(layer, part, skin)
    self.skins[layer][part] = skin
end

--- 修改皮肤
---@param layer number 层级，1为原始装备，2为能力装备，3为buff装备
---@param skinData table 皮肤数据
function SkinComponent:changeSkin(layer, skinData)
    for part, skin in pairs(skinData) do
        self.skins[layer][part] = skin
    end
end

--- 获取当前装备
---@param part any
function SkinComponent:getPartSkin(part)
    local count = Define.SKIN_LAYER.COUNT    
    for layer = count, 1, -1 do
        local skin = self.skins[layer][part]
        if skin and skin ~= "" then
            return skin
        end
    end
    return ""
end

--- 获取层级数据
---@param layer any
function SkinComponent:getLayerSkin(layer)
    return self.skins[layer]
end

--- 设置层级数据
---@param layer any
---@param value any
function SkinComponent:setLayerSkin(layer, value)
    self.skins[layer] = value
end

return SkinComponent