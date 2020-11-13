local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local CareerDoubleCtrl = class(ActivityContentBaseCtrl)

function CareerDoubleCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
end

return CareerDoubleCtrl
