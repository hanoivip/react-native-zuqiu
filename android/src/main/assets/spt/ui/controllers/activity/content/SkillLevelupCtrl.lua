local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local SkillLevelupCtrl = class(ActivityContentBaseCtrl)

function SkillLevelupCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)

    self.view.onRewardBtnClick = function(subID) self:OnRewardBtnClick(subID) end
end

function SkillLevelupCtrl:OnRefresh()
    self.view:OnRefresh()
end

function SkillLevelupCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function SkillLevelupCtrl:OnExitScene()
    self.view:OnExitScene()
end

function SkillLevelupCtrl:OnRewardBtnClick(subID)
    clr.coroutine(function()
        local activityType = self.activityModel:GetActivityType()
        local response = req.activityReceive(activityType, subID, nil, nil, true)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.activityModel:UpdateModel(data.activity)
        end
    end)
end

return SkillLevelupCtrl

