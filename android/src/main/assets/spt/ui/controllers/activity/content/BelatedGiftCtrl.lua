local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local BelatedGiftCtrl = class(ActivityContentBaseCtrl)

function BelatedGiftCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.onRewardBtnClick = function (subID, stateCallBack) self:OnRewardBtnClick(subID, stateCallBack) end
    self.view:InitView(self.activityModel)
end

function BelatedGiftCtrl:OnRewardBtnClick(subID, stateCallBack)
    clr.coroutine(function()
        local response = req.activityReceiveLateGift(subID)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            stateCallBack()
            self:ResetCousume()
        end
    end)
end

function BelatedGiftCtrl:OnRefresh()
end

function BelatedGiftCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function BelatedGiftCtrl:OnExitScene()
    self.view:OnExitScene()
end

return BelatedGiftCtrl

