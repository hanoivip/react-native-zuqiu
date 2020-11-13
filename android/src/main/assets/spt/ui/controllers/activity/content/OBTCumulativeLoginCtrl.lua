local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local OBTSerialConsumeCtrl = class(ActivityContentBaseCtrl)

function OBTSerialConsumeCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
end

function OBTSerialConsumeCtrl:OnRefresh()
end

function OBTSerialConsumeCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function OBTSerialConsumeCtrl:OnExitScene()
    self.view:OnExitScene()
end

return OBTSerialConsumeCtrl

