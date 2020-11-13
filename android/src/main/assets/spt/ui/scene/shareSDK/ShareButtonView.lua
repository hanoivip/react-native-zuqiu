local LuaButton = require("ui.control.button.LuaButton")
local ShareButtonView = class(LuaButton)

function ShareButtonView:ctor()
    self.super.ctor(self)
    self.shareInfo = self.___ex.shareInfo
end

return ShareButtonView