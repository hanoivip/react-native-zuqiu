local LuaButton = require("ui.control.button.LuaButton")
local HomeSingleOptionView = class(LuaButton)

function HomeSingleOptionView:ctor()
    HomeSingleOptionView.super.ctor(self)
    self.icon = self.___ex.icon
    self.nameText = self.___ex.nameText
end

function HomeSingleOptionView:GetObject()
    return self.gameObject
end

function HomeSingleOptionView:GetNameText()
    return self.nameText
end

return HomeSingleOptionView
