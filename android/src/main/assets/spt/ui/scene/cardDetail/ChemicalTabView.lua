local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local ChemicalTabView = class(LuaButton)

function ChemicalTabView:ctor()
    self.super.ctor(self)
    self.upText = self.___ex.upText
    self.downText = self.___ex.downText
    self.sign = self.___ex.sign
    self.index = 1
    self:regOnButtonClick(function() self:OnBtnChemicalTab() end)
end

function ChemicalTabView:InitView(index, currentChemicalTab, chooseChemicalTab, isShowSign)
	self.index = index
	self.upText.text = tostring(index)
	self.downText.text = tostring(index)
    self.isShowSign = isShowSign
	local isSelect = tobool(index == tonumber(currentChemicalTab))
    local isChoose = tobool(index == tonumber(chooseChemicalTab))
	self:ChangeState(isSelect, isChoose)
end

function ChemicalTabView:ChangeState(isSelect, isChoose)
    self:OnTabSelect(isChoose)
	self:OnSignSelect(isSelect)
end

function ChemicalTabView:OnSignSelect(isSelect)
    GameObjectHelper.FastSetActive(self.sign, isSelect and self.isShowSign)
end

function ChemicalTabView:OnTabSelect(isSelect)
    for k, v in pairs(self.down) do
        GameObjectHelper.FastSetActive(v.gameObject, isSelect)
    end
    for k, v in pairs(self.up) do
        GameObjectHelper.FastSetActive(v.gameObject, not isSelect)
    end
end

function ChemicalTabView:OnBtnChemicalTab()
	if self.clickChemicalTab then 
		self.clickChemicalTab(self.index)
	end
end

return ChemicalTabView