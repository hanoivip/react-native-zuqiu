local LuaButton = require("ui.control.button.LuaButton")

local FancyFilterTabView = class(LuaButton)

function FancyFilterTabView:ctor()
    self.super.ctor(self)
    self.nameTxt = {self.___ex.nameTxt1, self.___ex.nameTxt2}
    self.tabPath = ""
end

function FancyFilterTabView:InitView(nameStr)
    for i, v in pairs(self.nameTxt) do
        v.text = nameStr
    end
end

return FancyFilterTabView
