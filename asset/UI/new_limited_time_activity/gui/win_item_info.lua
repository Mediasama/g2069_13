---@class WinItemInfoLayout : CEGUILayout
local WinItemInfoLayout = M
---@type AbilityConfig
local AbilityConfig = T(Config, "AbilityConfig")

---@private
function WinItemInfoLayout:init()
	self:findAllWindow()
	self:initUI()
	self:initEvent()
end

---@private
function WinItemInfoLayout:findAllWindow()
	---@type CEGUIStaticImage
	self.siMaskBg = self.MaskBg
	---@type CEGUIButton
	self.btnClickButton = self.ClickButton
	---@type CEGUIDefaultWindow
	self.wMainWindow = self.MainWindow
	---@type CEGUIStaticImage
	self.siMainWindowBg = self.MainWindow.Bg
	---@type CEGUIStaticText
	self.stMainWindowItemName = self.MainWindow.ItemName
	---@type CEGUIStaticText
	self.stMainWindowItemQualiltyName = self.MainWindow.ItemQualiltyName
	---@type CEGUIStaticImage
	self.siMainWindowDamageIcon = self.MainWindow.DamageIcon
	---@type CEGUIStaticText
	self.stMainWindowDamageIconDamageName = self.MainWindow.DamageIcon.DamageName
	---@type CEGUIStaticImage
	self.siMainWindowItemQualiltyIcon = self.MainWindow.ItemQualiltyIcon
	---@type CEGUIStaticImage
	self.siMainWindowItemQualiltyIconItemIcon = self.MainWindow.ItemQualiltyIcon.ItemIcon
	---@type CEGUIScrollableView
	self.wMainWindowSvDesc = self.MainWindow.SvDesc
	---@type CEGUIVerticalLayoutContainer
	self.wMainWindowSvDescLvDesc = self.MainWindow.SvDesc.LvDesc
	---@type CEGUIStaticText
	self.stMainWindowSvDescLvDescItemDesc = self.MainWindow.SvDesc.LvDesc.ItemDesc
end

---@private
function WinItemInfoLayout:initUI()
end

---@private
function WinItemInfoLayout:initEvent()
    self.btnClickButton.onMouseClick = function()
        Lib.emitEvent(Event.EVENT_PLAY_SOUND, "ui_close")
        UI:closeWindow(self)
	end
end

---@private
function WinItemInfoLayout:onOpen(data)
    self:updateInfo(data)
end

function WinItemInfoLayout:updateInfo(data)
    local itemId = data.itemId
    local itemIcon = data.itemIcon
    local itemName = data.itemName
    local quality = data.quality
    local itemType = data.itemType
    local itemDesc = data.itemDesc

    self.stMainWindowItemName:setText(Lang:toText(itemName))
    self.siMainWindowItemQualiltyIconItemIcon:setImage(itemIcon)
    local qualityBg = Define.ITEM_QUALITY_BG[quality]
    local qualityName = Define.ITEM_QUALITY_LANG[quality]
    local qualityColor = Define.ITEM_QUALITY_FONT_COLOR[quality]
    self.siMainWindowItemQualiltyIcon:setImage(qualityBg)
	self.stMainWindowItemQualiltyName:setText(Lang:toText(qualityName))
	if qualityColor then
		self.stMainWindowItemQualiltyName:setProperty("TextColours", qualityColor)
	end

    self.stMainWindowSvDescLvDescItemDesc:setText(Lang:toText(itemDesc))
    if itemType == Define.ITEM_TYPE.ABILITY then
        self.siMainWindowDamageIcon:setVisible(true)
        local abilityConfig = AbilityConfig:getCfgByAbilityId(itemId)
        local damageType = abilityConfig.damageType
        local dmgBg = Define.DAMAGE_TYPE_ICON[damageType]
        local dmgName = Define.DAMAGE_TYPE_NAME[damageType]
	    local dmgColor = Define.DAMAGE_TYPE_COLOR[damageType]
        self.siMainWindowDamageIcon:setImage(dmgBg)
        self.stMainWindowDamageIconDamageName:setText(Lang:toText(dmgName))
        self.stMainWindowDamageIconDamageName:setProperty("TextColours", dmgColor)
    else
        self.siMainWindowDamageIcon:setVisible(false)
    end
end

---@private
function WinItemInfoLayout:onDestroy()

end

---@private
function WinItemInfoLayout:onClose()

end

WinItemInfoLayout:init()
