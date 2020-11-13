local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")

local CumulativeConsumeCtrl = class(ActivityContentBaseCtrl)

function CumulativeConsumeCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.resetCousume = function (func) self:ResetCousume(func) end

    self.view:InitView(self.activityModel)
end

function CumulativeConsumeCtrl:OnRefresh()
end

function CumulativeConsumeCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CumulativeConsumeCtrl:OnExitScene()
    self.view:OnExitScene()
end

return CumulativeConsumeCtrl

