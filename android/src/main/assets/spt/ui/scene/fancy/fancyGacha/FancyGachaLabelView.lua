local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local FancyGachaLabelView = class(LuaButton)

function FancyGachaLabelView:ctor()
    FancyGachaLabelView.super.ctor(self)
--------Start_Auto_Generate--------
    self.normalNameTxt = self.___ex.normalNameTxt
    self.selectedNameTxt = self.___ex.selectedNameTxt
    self.upIconGo = self.___ex.upIconGo
--------End_Auto_Generate----------
    self.redPoint = self.___ex.redPoint
end

function FancyGachaLabelView:start()
end

function FancyGachaLabelView:InitView(fanyGachaGroup)
    self.model = fanyGachaGroup
    local isUp = self.model:GetUpIcon()
    GameObjectHelper.FastSetActive(self.upIconGo, isUp)
    local groupName = self.model:GetName()
    self.normalNameTxt.text = groupName
    self.selectedNameTxt.text = groupName
    self:FreshRedPoint()
end

function FancyGachaLabelView:FreshRedPoint()
    local isNew = self.model:IsNew()
    GameObjectHelper.FastSetActive(self.redPoint, isNew)
end

return FancyGachaLabelView
