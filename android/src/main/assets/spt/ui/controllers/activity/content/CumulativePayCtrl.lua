local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")

local CumulativePayCtrl = class(ActivityContentBaseCtrl)

function CumulativePayCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
end

function CumulativePayCtrl:OnRefresh()
end

function CumulativePayCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CumulativePayCtrl:OnExitScene()
    self.view:OnExitScene()
end

return CumulativePayCtrl

