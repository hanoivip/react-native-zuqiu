local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local AttrIntellectBarView = class(LuaButton)

function AttrIntellectBarView:ctor()
    AttrIntellectBarView.super.ctor(self)
    self.selectBg = self.___ex.selectBg
    self.selectSign = self.___ex.selectSign
    self.attrText = self.___ex.attrText
    self.isSelect = false
end

function AttrIntellectBarView:InitView(abilityIndex, train)
    self.attrText.text = lang.transstr(abilityIndex) .. ": " .. train
end

function AttrIntellectBarView:OnBtnSign(isSelect)
    GameObjectHelper.FastSetActive(self.selectBg, isSelect)
    GameObjectHelper.FastSetActive(self.selectSign, isSelect)
end

return AttrIntellectBarView