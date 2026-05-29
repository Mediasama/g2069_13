---@class WidgetAbilityAwakeCostWidget : CEGUILayout
local WidgetAbilityAwakeCostWidget = M

---@type ItemConfig
local ItemConfig = T(Config, "ItemConfig")
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")


local TEXT_COLOR = {
	ENOUGH = "FF100E0D",
	NOT_ENOUGH = "FFFA3F3F",
}

---@private
function WidgetAbilityAwakeCostWidget:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WidgetAbilityAwakeCostWidget:findAllWindow()
	---@type CEGUIStaticImage
	self.siItemQuality = self.ItemQuality
	---@type CEGUIStaticImage
	self.siItemQualityItemIcon = self.ItemQuality.ItemIcon
	---@type CEGUIStaticImage
	self.siItemQualityDamageIcon = self.ItemQuality.DamageIcon
	---@type CEGUIStaticText
	self.stItemNum = self.ItemNum
end

---@private
function WidgetAbilityAwakeCostWidget:initUI()
	self.stItemNum:setText(Lang:toText(""))
end

---@private
function WidgetAbilityAwakeCostWidget:initEvent()
end

---@private
function WidgetAbilityAwakeCostWidget:onOpen()

end

function WidgetAbilityAwakeCostWidget:updateInfo(data)
    local curNum = data.current_num
    local itemNum = data.item_num
    local itemAlias = data.item_alias

    local config = ItemConfig:getCfgByItemAlias(itemAlias)
	local icon = config.icon
	local qualityBg = Define.ITEM_QUALITY_BG[config.quality_alias]

    self.siItemQualityItemIcon:setImage(icon)
    self.siItemQuality:setImage(qualityBg)

    if config.type_alias == Define.ITEM_TYPE.ABILITY then
        --- 显示伤害类型
        local damageType = AbilityConfig:getCfgByAbilityId(config.item_id).damageType
        local dmgBg = Define.DAMAGE_TYPE_ICON_HOLLOW[damageType]
        self.siItemQualityDamageIcon:setImage(dmgBg)
        self.siItemQualityDamageIcon:setVisible(true)
    else
        self.siItemQualityDamageIcon:setVisible(false)
    end

    local enough = data.enough
    local itemNumText
    if enough then
		itemNumText = tostring(curNum) .. "/" .. tostring(itemNum)
	else
		itemNumText = string.format("[colour='%s']", TEXT_COLOR.NOT_ENOUGH) .. tostring(curNum) 
			.. string.format("[colour='%s']", TEXT_COLOR.ENOUGH) .. "/" .. tostring(itemNum)
	end
    self.stItemNum:setText(itemNumText)
end

---@private
function WidgetAbilityAwakeCostWidget:onDestroy()

end

WidgetAbilityAwakeCostWidget:init()
