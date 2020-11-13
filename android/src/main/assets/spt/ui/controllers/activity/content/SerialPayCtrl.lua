local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local SerialPayCtrl = class(ActivityContentBaseCtrl)

function SerialPayCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
end

function SerialPayCtrl:OnRefresh()
end

function SerialPayCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function SerialPayCtrl:OnExitScene()
    self.view:OnExitScene()
end

return SerialPayCtrl

