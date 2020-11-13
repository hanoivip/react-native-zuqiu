local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local PowerTargetCtrl = class(ActivityContentBaseCtrl)

function PowerTargetCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
end

function PowerTargetCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function PowerTargetCtrl:OnExitScene()
    self.view:OnExitScene()
end

return PowerTargetCtrl
