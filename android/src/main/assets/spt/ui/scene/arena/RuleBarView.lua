local LuaButton = require("ui.control.button.LuaButton")
local RuleBarView = class(LuaButton)

function RuleBarView:ctor()
    RuleBarView.super.ctor(self)
    self.title = self.___ex.title
    self.selectTitle = self.___ex.selectTitle
end

function RuleBarView:InitView(title)
    self.title.text = title
    self.selectTitle.text = title
end

return RuleBarView
