local TriggerEventView = require("ui.scene.greensward.TriggerEventView")
local BuildEventView = class(TriggerEventView)

function BuildEventView:ctor()
    self.super.ctor(self)
	self.btnIcon = self.___ex.btnIcon
end

return BuildEventView