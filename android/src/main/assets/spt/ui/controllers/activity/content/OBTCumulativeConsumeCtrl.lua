local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")

local OBTCumulativeConsumeCtrl = class(ActivityContentBaseCtrl)

function OBTCumulativeConsumeCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view:InitView(self.activityModel)
end

function OBTCumulativeConsumeCtrl:OnRefresh()
end

function OBTCumulativeConsumeCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function OBTCumulativeConsumeCtrl:OnExitScene()
    self.view:OnExitScene()
end

return OBTCumulativeConsumeCtrl

