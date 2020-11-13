local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local RewardDoubleCtrl = class(ActivityContentBaseCtrl)

function RewardDoubleCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
end

function RewardDoubleCtrl:OnRefresh()
end

function RewardDoubleCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function RewardDoubleCtrl:OnExitScene()
    self.view:OnExitScene()
end

return RewardDoubleCtrl

