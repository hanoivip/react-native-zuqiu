local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local MultiSerialPayCtrl = class(ActivityContentBaseCtrl)

function MultiSerialPayCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.onClickPayBtn = function ()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    end
    self.view.onClickCumulativePayBtn = function ()
        self:OnCickHistoryPayBtn()
    end
end

function MultiSerialPayCtrl:OnRefresh()
end

function MultiSerialPayCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function MultiSerialPayCtrl:OnExitScene()
    self.view:OnExitScene()
end

function MultiSerialPayCtrl:OnCickHistoryPayBtn()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/MultiSerialPay/HistoryDataBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:Init(self.activityModel:GetHistoryTxt())
end

return MultiSerialPayCtrl

