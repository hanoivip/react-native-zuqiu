local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local TimeLimitBrainTraingCtrl = class(ActivityContentBaseCtrl)

function TimeLimitBrainTraingCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
end

return TimeLimitBrainTraingCtrl
