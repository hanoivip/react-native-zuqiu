local LuaButton = require("ui.control.button.LuaButton")

local PasterUpgradeSortButtonView = class(LuaButton)

function PasterUpgradeSortButtonView:ctor()
    PasterUpgradeSortButtonView.super.ctor(self)
    self.downSign = self.___ex.downSign
    self.upSign = self.___ex.upSign
end

function PasterUpgradeSortButtonView:SetDown(isDown)
    isDown = tobool(isDown)
    self.downSign.interactable = isDown
    self.upSign.interactable = not isDown
end

return PasterUpgradeSortButtonView
